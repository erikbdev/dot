" The built-in Swift syntax treats every double quote as a string boundary,
" which breaks raw multiline strings when their contents contain quotes.
" Raw interpolation switches back to Swift syntax inside the string.
syntax region swiftRawInterpolation contained contains=TOP
      \ matchgroup=swiftInterpolation start=/\\#(/ end=/)/
syntax region swiftRawMultilineString start=/#\%x22\%x22\%x22/ end=/\%x22\%x22\%x22#/ contains=swiftRawInterpolation keepend
highlight default link swiftRawMultilineString String
syntax region swiftRawInterpolation2 contained contains=TOP
      \ matchgroup=swiftInterpolation start=/\\##(/ end=/)/
syntax region swiftRawMultilineString2 start=/##\%x22\%x22\%x22/ end=/\%x22\%x22\%x22##/ contains=swiftRawInterpolation2 keepend
highlight default link swiftRawMultilineString2 String
