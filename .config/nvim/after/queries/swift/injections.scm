;; extends

; A `/* language */` comment immediately before a string selects its embedded
; parser. The repeated pattern crosses interpolation delimiters while leaving
; those tokens and Swift expressions out of the embedded content.
((multiline_comment) @injection.language
 .
 [
   (line_string_literal
     [
       (line_str_text) @injection.content
       (str_escaped_char) @injection.content
       "\\("
       (interpolated_expression)
       ","
       ")"
     ]+)
   (_
     (line_string_literal
       [
         (line_str_text) @injection.content
         (str_escaped_char) @injection.content
         "\\("
         (interpolated_expression)
         ","
         ")"
       ]+))
 ]
 (#lua-match? @injection.language "^/%* [%w_.+%-]+ %*/$")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "^js$" "javascript"))

((multiline_comment) @injection.language
 .
 [
   (multi_line_string_literal
     [
       (multi_line_str_text) @injection.content
       (str_escaped_char) @injection.content
       "\"" @injection.content
       "\\("
       (interpolated_expression)
       ","
       ")"
     ]+)
   (_
     (multi_line_string_literal
       [
         (multi_line_str_text) @injection.content
         (str_escaped_char) @injection.content
         "\"" @injection.content
         "\\("
         (interpolated_expression)
         ","
         ")"
       ]+))
 ]
 (#lua-match? @injection.language "^/%* [%w_.+%-]+ %*/$")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "^js$" "javascript"))

; Raw strings use one continuous body range because their delimiter length is
; dynamic. The helper trims any number of hash markers; raw interpolation is
; also parsed as Swift, while ordinary `\(` text stays literal.
((multiline_comment) @injection.language
 .
 [
   (raw_string_literal) @injection.content
   (_ (raw_string_literal) @injection.content)
 ]
 (#lua-match? @injection.language "^/%* [%w_.+%-]+ %*/$")
 (#offset! @injection.language 0 3 0 -3)
 (#gsub! @injection.language "^js$" "javascript")
 (#swift-string-body! @injection.content)
 (#set! injection.include-children))

((multiline_comment) @_marker
 .
 [
   (raw_string_literal
     (raw_str_interpolation
       (interpolated_expression) @injection.content))
   (_
     (raw_string_literal
       (raw_str_interpolation
         (interpolated_expression) @injection.content)))
 ]
 (#lua-match? @_marker "^/%* [%w_.+%-]+ %*/$")
 (#set! injection.language "swift")
 (#set! injection.include-children))
