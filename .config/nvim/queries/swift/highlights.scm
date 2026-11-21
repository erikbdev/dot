;; extends

; Some keywords are parsed as identifiers by the installed Swift grammar.
((simple_identifier) @keyword
  (#any-of? @keyword "defer" "init")
  (#set! priority 130))

; Named keyword nodes not covered by the base Swift highlight query.
[
  "associatedtype"
  "is"
  "operator"
  "precedencegroup"
] @keyword
  (#set! priority 130)

; Capitalized language keywords and built-in keyword-like values.
((type_identifier) @keyword
  (#any-of? @keyword "Any" "Self")
  (#set! priority 130))

(init_declaration
  "init" @keyword
  (#set! priority 130))

((self_expression) @keyword
  (#set! priority 130))

((super_expression) @keyword
  (#set! priority 130))

((boolean_literal) @keyword
  (#set! priority 130))

((nil_literal) @keyword
  (#set! priority 130))

((wildcard_pattern) @keyword
  (#set! priority 130))

; Contextual type keywords.
(navigation_suffix
  (simple_identifier) @keyword
  (#any-of? @keyword "Protocol" "Type")
  (#set! priority 130))

(precedence_group_attribute
  (simple_identifier) @keyword
  (#any-of? @keyword "associativity" "left" "none" "right")
  (#set! priority 130))

; Built-in pound keywords are child tokens of macro-like syntax nodes.
(availability_condition
  "available" @keyword
  (#set! priority 130))

(availability_condition
  "unavailable" @keyword
  (#set! priority 130))

(playground_literal
  "colorLiteral" @keyword
  (#set! priority 130))

(playground_literal
  "fileLiteral" @keyword
  (#set! priority 130))

(playground_literal
  "imageLiteral" @keyword
  (#set! priority 130))

(key_path_string_expression
  "keyPath" @keyword
  (#set! priority 130))

(selector_expression
  "selector" @keyword
  (#set! priority 130))
