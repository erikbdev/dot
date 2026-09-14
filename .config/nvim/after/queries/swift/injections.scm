;; extends

; Inject JavaScript/CSS into Swift string literals that are immediately
; preceded by a `/* js */` or `/* css */` marker comment. Used by
; swift-wav's MainPage.swift, which inlines its client-side JS/CSS as
; plain multi-line Swift string properties (`Self.appScript`,
; `Self.styles`) instead of separate files.
;
; The comment and the string are NOT direct siblings — tree-sitter-swift
; wraps a computed property's body in a `statements` node, so the pattern
; has to match through that wrapper (verified against the actual parse
; tree, not assumed).
;
; This captures the WHOLE `multi_line_string_literal` node (delimiters
; included), then `#offset!` trims the 3-char `"""` on each side by hand —
; assumes both `"""` lines are indented with exactly 4 spaces (this
; project's convention); change the offsets if that indentation changes.
;
; `(#set! injection.include-children)` is required and easy to miss: by
; default Neovim's injection system MASKS OUT a captured node's named
; children and only injects the gaps between them (this exists so e.g.
; `"text \(expr)"` doesn't treat the interpolated `expr` as part of the
; injected language). Since real JS/CSS is full of `"quoted strings"`,
; tree-sitter-swift's lexer breaks `multi_line_string_literal` into many
; `multi_line_str_text` children around each one — without
; `include-children` the default masking drops everything between them,
; producing a corrupted, effectively-random subset of the source (found
; by dumping actual injected text: real content came out truncated/
; scrambled, and even a whole-file text dump the wrong length was traced
; to this, not a query-matching bug). With `include-children` set, the
; single offset-trimmed range is used as-is — verified clean end-to-end
; against both a small probe and the real ~300-line `script`/`styles`.

((multiline_comment) @_marker
 .
 (statements
   (multi_line_string_literal) @injection.content)
 (#match? @_marker "js")
 (#offset! @injection.content 1 -4 0 -3)
 (#set! injection.language "javascript")
 (#set! injection.include-children))

((multiline_comment) @_marker
 .
 (statements
   (multi_line_string_literal) @injection.content)
 (#match? @_marker "css")
 (#offset! @injection.content 1 -4 0 -3)
 (#set! injection.language "css")
 (#set! injection.include-children))
