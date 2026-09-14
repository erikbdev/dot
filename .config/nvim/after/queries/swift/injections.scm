;; extends

; Inject embedded languages into Swift string literals that are immediately
; preceded by a `/* <language> */` marker comment. Strings may be direct
; siblings of the marker or nested in a `statements`/`value_argument` node
; (as they are when passed to a function such as `HTMLRaw`).
;
; Add supported marker languages to the `any-of?` list below. The marker
; supplies the injection language, with `js` normalized to `javascript`.

; Single-line strings have one text node for the usual case, so keep their
; content capture unchanged.
((multiline_comment) @injection.language
 .
 [
   (line_string_literal
     (line_str_text) @injection.content)
   (_
     (line_string_literal
       (line_str_text) @injection.content))
 ]
 (#any-of? @injection.language "/* js */" "/* javascript */" "/* css */" "/* html */")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "js" "javascript"))

; Swift splits a multiline string into multiple text nodes around embedded
; quotes. Capture the complete literal instead, include its children, and
; remove only the outer triple-quote delimiters.
((multiline_comment) @injection.language
 .
 [
   (multi_line_string_literal) @injection.content
   (_
     (multi_line_string_literal) @injection.content)
 ]
 (#any-of? @injection.language "/* js */" "/* javascript */" "/* css */" "/* html */")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "js" "javascript")
 (#offset! @injection.content 0 3 0 -3)
 (#set! injection.include-children))

; Swift raw strings use a single # around the quote in the forms handled here:
; #"..."# and #"""..."""#. The raw_string_literal node includes both
; delimiters, so remove them from the injected range.

; Single-line raw strings.
((multiline_comment) @injection.language
 .
 [
   (raw_string_literal) @injection.content
   (_
     (raw_string_literal) @injection.content)
 ]
 (#any-of? @injection.language "/* js */" "/* javascript */" "/* css */" "/* html */")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "js" "javascript")
 (#lua-match? @injection.content "^#\"")
 (#not-lua-match? @injection.content "^#\"\"\"")
 (#offset! @injection.content 0 2 0 -2)
 (#set! injection.include-children))

; Multiline raw strings. Include children so interpolations do not mask the
; surrounding injected region.
((multiline_comment) @injection.language
 .
 [
   (raw_string_literal) @injection.content
   (_
     (raw_string_literal) @injection.content)
 ]
 (#any-of? @injection.language "/* js */" "/* javascript */" "/* css */" "/* html */")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "js" "javascript")
 (#lua-match? @injection.content "^#\"\"\"")
 (#offset! @injection.content 0 4 0 -4)
 (#set! injection.include-children))
