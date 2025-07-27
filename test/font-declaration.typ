#import "/src/types.typ": *

// Everything but the first line of text should show up in Arial.

#[Hi There]

#let f = fond_declaration(it => text(font: "Arial", it))
#(f.font)[Hi there]

#let (success, f) = e.types.cast("Arial", fond_declaration)
#assert(success, message: if not success { f } else { "" })
#(f.font)[Hi there]

#let (success, f) = e.types.cast("Arial", fond_declaration)
#assert(success, message: if not success { f } else { "" })
#(f.font)[Hi there]

#let (success, f) = e.types.cast(it => text(font: "Arial", it), fond_declaration)
#assert(success, message: if not success { f } else { "" })
#(f.font)[Hi there]
