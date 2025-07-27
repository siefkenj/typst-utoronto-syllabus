#import "/src/types.typ": *

#[Hi There]

#let f = fond_declaration(it => text(font: "Arial", it))
#(f.font)[Hi there]

#let (success, f) = e.types.cast("Arial", fond_declaration)
#assert(success, message: if not success { f } else { "" })
#(f.font)[Hi there]

#let (success, f) = e.types.cast("Arial", fond_declaration)
#assert(success, message: if not success { f } else { "" })
#(f.font)[Hi there]
