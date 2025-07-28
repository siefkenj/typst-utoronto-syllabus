#import "/src/lib.typ" as s
#import "/src/types.typ": *
#import "@preview/cmarker:0.1.6"

// Functions to render information about an element.

#let show_docs = e.element.declare(
  "show_docs",
  prefix: PREFIX,
  doc: "Show the documentation for an element.",
  display: it => {
    let data = it.element_data
    raw(
      "/// " + data.doc + "\n",
      lang: "typst",
    )
    text(fill: blue, raw(data.name))
    raw("(")
    // Get the positional arguments first.
    let positional = data.all-fields.pairs().filter(((key, f)) => not f.named)
    // Get the required named fields.
    let required_named = data.all-fields.pairs().filter(((key, f)) => f.required and f.named)
    // Get the optional named fields.
    let optional_named = data.all-fields.pairs().filter(((key, f)) => not f.required and f.named)
    block(inset: (left: 1em, top: -.7em, bottom: -.7em), {
      // Positional arguments
      let pos_args = positional.map(((name, info)) => {
        raw(
          "/// " + if info.required { "(required) " } else { "[optional] " } + info.doc + "\n",
          lang: "typst",
        )
        text(fill: purple, raw(name))
      })

      // Named arguments
      let named_args = (required_named + optional_named).map(((name, info)) => {
        raw(
          "/// " + if info.required { "(required) " } else { "[optional] " } + info.doc + "\n",
          lang: "typst",
        )
        text(fill: purple, raw(name))
        raw(": " + info.typeinfo.name)
      })

      (pos_args + named_args).join(",\n")
      //[#positional]
    })

    raw(")")
  },
  fields: (
    e.field(
      "element_data",
      e.types.any,
      doc: "The `data` dictionary for the element. This is obtained by calling `e.data(element)`.",
      required: true,
    ),
  ),
)


#{
  [Example documentation:

  ]

  parbreak()
  let data = e.data(s.template)
  show_docs(data)

  parbreak()
  let data = e.data(s.annotated_item)
  show_docs(data)

  parbreak()
  let data = e.data(s.settings)
  show_docs(data)

  parbreak()
  set text(size: .6em)
  //[#data]
}
