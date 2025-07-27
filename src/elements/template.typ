#import "../types.typ": *
#import "../settings.typ": *
#import "section-divider.typ": section_divider
#import "header.typ": basic_info_table, header_banner


/// The syllabus template. Use with `#show: template`
#let template(doc) = e.get(get => {
  let opts = get(settings)

  set page(
    paper: "us-letter",
    margin: (left: opts.gutter_width + 0.6in, right: 0.6in, top: 1.1in),

    footer: pad(left: -opts.gutter_width, align(center, context { counter(page).display("1") })),
    header: pad(left: -opts.gutter_width, context {
      if here().page() == 1 {
        header_banner()
      } else {}
    }),
  )
  set par(justify: true)

  set list(indent: 1em, marker: place(dx: -3pt, dy: 2pt, rect(
    width: 4pt,
    height: 4pt,
    fill: opts.colors.primary,
  )))
  show link: it => text(
    fill: opts.colors.primary,
    font: opts.font_mono,
    size: 0.83em,
    it,
  )
  show heading: set text(fill: opts.colors.primary)
  show heading.where(level: 2): it => {
    set text(weight: "regular")
    section_divider(it.body)
  }

  if opts.basic_info.len() > 0 {
    pad(left: -opts.gutter_width, {
      v(-1.3em)
      stack(basic_info_table(), line(length: 100%, stroke: .5pt + opts.colors.primary))
    })
  }

  doc
})
