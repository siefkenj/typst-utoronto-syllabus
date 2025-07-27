#import "@preview/elembic:1.1.1" as e
#import "types.typ": *
#import "constants.typ": NOT_FOUND_SENTINEL



/// Settings for the syllabus template.
#let settings = e.element.declare(
  "syllabus-settings",
  prefix: PREFIX,
  doc: "Settings for the syllabus template.",

  // The settings should not be displayed.
  display: it => panic("Settings should not be displayed directly."),

  fields: (
    e.field("code", str, doc: "Course code (e.g., \"MAT244\")"),
    e.field("name", str, doc: "Course name (e.g., \"Mathematics for Computer Science\")"),
    e.field("term", e.types.option(str), doc: "Term (e.g., \"Fall 2025\")"),
    e.field("term_start_date", datetime, doc: "The date the term starts", default: datetime(
      year: 2000,
      month: 9,
      day: 3,
    )),
    e.field("term_end_date", datetime, doc: "The date the term ends", default: datetime(
      year: 2000,
      month: 12,
      day: 31,
    )),
    e.field("tutorial_start_date", e.types.option(datetime), doc: "The date tutorials start"),
    e.field(
      "basic_info",
      e.types.array(basic_info_type),
      doc: "Basic information to be displayed at the start of the syllabus. For example, the textbook, or course webpage.",
      default: (),
    ),
    e.field(
      "events",
      e.types.array(event),
      doc: "Events in the syllabus timetable, such as homeworks or midterms",
    ),
    e.field(
      "holidays",
      e.types.array(event),
      doc: "Holidays that occur during the term; it is assumed that no classes occurs during a holiday",
    ),
    // Formatting options
    e.field("colors", colors_type, doc: "Colors used in the syllabus", default: colors_type()),
    e.field(
      "font_mono",
      e.types.union(str, e.types.array(str)),
      doc: "Monospace font for links",
      default: "DejaVu Sans Mono",
    ),
    e.field(
      "font_sans",
      e.types.union(str, e.types.array(str)),
      doc: "Sans-serif font for headings",
      default: "GeosansLight",
    ),
    e.field("font", e.types.union(str, e.types.array(str)), doc: "Serif font for body text", default: "DejaVu Serif"),
    e.field(
      "gutter_width",
      length,
      doc: "Width of the gutter for the syllabus; this is where the section headings will be displayed",
      default: 1.1in,
    ),
  ),
)

/// Smallcaps text that is meant to appear as a heading used in the gutter of the syllabus.
#let gutter_label = e.element.declare(
  "gutter-label",
  prefix: PREFIX,
  doc: "A label for the gutter of the syllabus.",
  display: it => box(baseline: 50%, block(breakable: false, {
    set align(right)
    set par(justify: false, leading: 0.1em)
    show: smallcaps
    it.body
  })),

  fields: (
    e.field("body", content, doc: "The text of the gutter label", required: true),
  ),
)

/// A divider for sections in the syllabus.
#let section_divider = e.element.declare(
  "section-divider",
  prefix: PREFIX,
  doc: "A divider for sections in the syllabus.",
  display: it => e.get(get => {
    let opts = get(settings)
    let gutter_width = opts.gutter_width
    //    set text(fill: opts.colors.primary)

    // Lay out the label and vertically center it
    let label = block(
      width: gutter_width,
      breakable: false,
      inset: (right: 4pt),

      {
        set align(right)
        gutter_label(it.title)
      },
    )
    block(sticky: true, {
      context {
        // Measure the height, but since we want to center based on the height of the lower case letters
        // we multiply by 0.7
        let single_letter_height = measure(gutter_label([m])).height * 0.7
        let label_height = measure(label).height
        let is_multiline = label_height > 2 * single_letter_height
        let hoffset = if is_multiline {
          label_height / 2.1 + single_letter_height / 3.5
        } else {
          single_letter_height / 1.3
        }

        place(dx: -gutter_width, dy: -hoffset, label)
      }
      box(baseline: 0%, block(
        width: 100%,
        fill: opts.colors.primary,
        height: 2pt,
      ))
    })
  }),

  fields: (
    e.field("title", e.types.option(content), doc: "The text of the section divider", named: false),
  ),
)

#let header_banner = e.element.declare(
  "header-banner",
  prefix: PREFIX,
  doc: "A header banner for the syllabus.",
  display: it => e.get(get => {
    let opts = get(settings)
    set text(fill: opts.colors.primary, size: 1.2em)
    show: smallcaps

    block(breakable: false, width: 100%, {
      place(left + bottom, {
        set text(size: 1.5em)
        opts.code
      })
      place(center + bottom, {
        opts.name
      })
      place(right + bottom, { opts.term })
      place(bottom, dy: 6pt, box(width: 100%, height: 2pt, fill: opts.colors.primary, none))
    })
  }),
  fields: (),
)

/// A table for displaying basic information in the syllabus.
#let basic_info_table = e.element.declare(
  "basic-info-table",
  prefix: PREFIX,
  doc: "A table for displaying basic information in the syllabus.",
  display: it => e.get(get => {
    let opts = get(settings)

    let basic_info = opts.basic_info
    if opts.tutorial_start_date != none {
      basic_info.push((
        title: "Tutorials:",
        value: [Starting #opts.tutorial_start_date.display("[weekday], [month repr:long] [day]")],
      ))
    }

    block(breakable: false, width: 100%, {
      show table.cell: it => {
        // Make the headings sans-serif
        if calc.rem(it.x, 3) == 0 {
          text(fill: gray.darken(10%), font: opts.font_sans, baseline: -.3em, (it))
        } else {
          it
        }
      }
      table(
        stroke: none,
        columns: (auto, auto, 1fr, auto, auto, 0pt),
        align: (right, left, right, left),
        ..basic_info
          .map(info_item => {
            (info_item.title, info_item.value, [])
          })
          .join(),
      )
    })
  }),
  fields: (),
)

/// An item with an annotation that hangs in the left margin.
#let annotated_item = e.element.declare(
  "annotated-item",
  prefix: PREFIX,
  doc: "An item with an annotation that hangs in the left margin",
  display: it => e.get(get => {
    let opts = get(settings)

    // The part that goes in the margin
    let annotation = block(
      width: opts.gutter_width,
      inset: (right: 4pt),

      {
        set align(right)
        set par(leading: 0.3em, justify: false)
        let items = (
          text(font: opts.font_sans, size: 1.2em, baseline: -.3em, {
            it.title
          }),
        )
        if it.subtitle != none {
          items.push(text(font: opts.font, size: .85em, fill: gray.darken(10%), {
            it.subtitle
          }))
        }
        stack(spacing: .8em, ..items)
      },
    )

    let body = layout(size => {
      block(
        width: size.width,
        breakable: true,

        it.body,
      )
    })

    // We need to measure the height of the annotation and body. If the
    // body is shorter than the annotation, it needs to be placed in a block with a forced height so
    // that subsequent items don't overlap with the annotation.
    context {
      let annotation_height = measure(annotation).height
      let body_height = measure(body).height
      // This helps the heading and the attached paragraph stay on the same page.
      // TODO: find a better solution.
      block(breakable: false)
      if body_height < annotation_height {
        // If the body is shorter than the annotation, we need to pad it to the height of the annotation
        place(annotation, dx: -opts.gutter_width)
        block(height: annotation_height, breakable: true, {
          body
        })
      } else {
        place(annotation, dx: -opts.gutter_width)
        body
      }
    }
  }),

  fields: (
    e.field("title", e.types.option(content), doc: "The title of the item"),
    e.field("subtitle", e.types.option(content), doc: "Additional description appearing below the title"),
    e.field("body", content, doc: "The descriptive test that will be shown inline in the document", required: true),
  ),
)

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

/// Display a user's content and any events that they have specified for a week.
#let content_and_events = e.element.declare(
  "content-and-events",
  prefix: PREFIX,
  doc: "A block that includes content and events for a particular week",
  display: it => e.get(get => {
    let opts = get(settings)

    // Split events up by their type
    let events = (holiday: (), homework: (), test: (), other: ())
    for event in it.events {
      let key = event.at("type", default: "other")
      if ("holiday", "homework", "test", "other").contains(key) == false {
        // If the type is not one of the known types, we just put it in "other"
        key = "other"
      }
      if events.at(key, default: none) == none {
        events.insert(key, ())
      }
      events.at(key).push(event)
    }

    // Display holidays first
    events
      .at("holiday")
      .map(h => {
        text(weight: "bold", [#h.name #_format_event_date(h) (no classes)\ ])
      })
      .join([])

    // Regular content comes next
    it.content

    parbreak()
    // Then midterms and homeworks
    events
      .at("test")
      .map(e => text(weight: "bold", fill: opts.colors.primary, [
        #e.name #_format_event_date(e)\
      ]))
      .join([])
    events
      .at("homework")
      .map(e => text(fill: opts.colors.secondary, [
        #e.name #_format_event_date(e)\
      ]))
      .join([])
    events
      .at("other")
      .map(e => text(fill: opts.colors.tertiary, [
        #e.name #_format_event_date(e)\
      ]))
      .join([])
  }),
  fields: (
    e.field(
      "content",
      content,
      doc: "Content for the week, such as textbook sections to read or other items that aren't already in `settings.events`",
    ),
    e.field(
      "events",
      e.types.array(event),
      doc: "Events for the week, such as homeworks or midterms. These will be displayed in the timetable.",
    ),
  ),
)

/// Display a weekly timetable for the course.
#let timetable = e.element.declare(
  "timetable",
  prefix: PREFIX,
  doc: "A weekly timetable for the course, including homeworks, midterms, and holidays.",
  display: it => e.get(get => {
    let opts = get(settings)
    // Typst uses `1` to represent Monday
    let week_start_day = (
      "monday": 1,
      "tuesday": 2,
      "wednesday": 3,
      "thursday": 4,
      "friday": 5,
      "saturday": 6,
      "sunday": 7,
    ).at(it.week_start_day, default: 1)
    // Create an array with one day for every day of the semester.
    let all_semester_days = range(int((opts.term_end_date - opts.term_start_date).days()) + 1).map(i => {
      opts.term_start_date + duration(days: i)
    })

    // Find the start of the first full week. Since the week may start on a Monday, but the semester may
    // start on a Tuesday or Wednesday, the first full week may not be at the start of the semester.

    let first_full_week_start_idx = all_semester_days.position(d => {
      // Find the first day that is a week_start_day
      d.weekday() == week_start_day
    })

    let first_partial_week = if first_full_week_start_idx == 0 {
      ()
    } else {
      (all_semester_days.slice(0, first_full_week_start_idx),)
    }
    let all_weeks = (
      first_partial_week
        + all_semester_days
          .slice(
            first_full_week_start_idx,
          )
          .chunks(7)
    )
    let week_boundaries = all_weeks.map(week => (
      start: week.at(0),
      end: week.at(-1),
    ))

    let all_events = (
      opts.events
        + opts.holidays.map(h => {
          // Make sure that every holiday has a type "holiday"
          if h.at("type", default: none) == none {
            h.set("type", "holiday")
          } else {
            h
          }
        })
    )

    let weekly_content = week_boundaries
      .enumerate()
      .map(((i, week)) => {
        let events_in_range = all_events.filter(e => {
          // Check if the event is in the range of the week
          _date_in_range(e.date, week.start, week.end) == "during"
        })
        (
          // Display number for the week
          week_num: i + 1,
          bounds: week,
          content: it.weekly_data.at(i, default: none),
          events: events_in_range,
        )
      })

    // If there are any events that take place before classes, we add a cell
    // and display them.
    let before_classes_events = all_events.filter(e => {
      _date_in_range(e.date, opts.term_start_date, opts.term_start_date) == "before"
    })
    let before_classes = if before_classes_events.len() > 0 {
      (
        text(font: opts.font_sans, size: 1.2em, baseline: -.3em, [Before Classes]),
        content_and_events(events: before_classes_events),
      )
    } else { () }

    let after_classes_events = all_events.filter(e => {
      _date_in_range(e.date, opts.term_end_date, opts.term_end_date) == "after"
    })
    let after_classes = if after_classes_events.len() > 0 {
      (
        text(font: opts.font_sans, size: 1.2em, baseline: -.3em, [After Classes]),
        content_and_events(events: after_classes_events),
      )
    } else { () }


    set list(marker: none, indent: 0pt)
    set par(justify: false)

    show: pad.with(left: -opts.gutter_width)
    table(
      stroke: 0.25pt + gray,
      align: (right, left),
      columns: (opts.gutter_width, 1fr),
      row-gutter: 0.3em,
      ..before_classes,
      ..weekly_content
        .map(data => {
          (
            [
              #text(font: opts.font_sans, size: 1.2em, baseline: -.3em, [Week #data.week_num])
              #text(fill: gray.darken(20%), _format_week_range(start: data.bounds.start, end: data.bounds.end))],
            {
              content_and_events(
                content: data.content,
                events: data.events,
              )
            },
          )
        })
        .join(),
      ..after_classes
    )
  }),
  fields: (
    e.field(
      "weekly_data",
      e.types.array(content),
      doc: "Additional data to be displayed each week. For example, what textbook sections to read or other items that aren't already in `settings.events`.",
    ),
    e.field(
      "week_start_day",
      e.types.union("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"),
      doc: "The day of the week that the week starts on. Weeks will be counted out as the start day + 7",
      default: "monday",
    ),
  ),
)



/// Get a value that is stored in the syllabus settings.
#let get_setting(name, map: none) = e.get(get => {
  let opts = get(settings)
  let val = opts.at(name, default: NOT_FOUND_SENTINEL)
  if val == NOT_FOUND_SENTINEL {
    return text(fill: red, [
      (WARNING: Setting  "#text(fill: gray, [#name])" not found. Existing settings are:
      #(opts.keys().map(k => ["#text(fill: gray, raw(k))"])).join(", "))
    ])
  }
  if type(map) == function {
    map(val)
  } else {
    val
  }
})

/// Get a formatted version of the date of an event.
#let get_event_time(event_name) = {
  // We search for events as keys in the settings,
  // then in `settings.events`, then in `settings.holidays`.
  e.get(get => {
    let opts = get(settings)
    let event = opts.at(event_name, default: NOT_FOUND_SENTINEL)
    if event != NOT_FOUND_SENTINEL {
      return _format_date(event)
    }
    // Not found in the settings, so we look in the events and holidays
    let all_events = opts.events + opts.holidays
    // get a list of all searchable events. This includes the events as keys of `opts`
    let all_event_names = (
      opts.pairs().filter(((k, v)) => type(v) == datetime).map(((k, v)) => k)
        + all_events.filter(e => e.key != none).map(e => e.key)
    )

    let event = all_events.find(e => e.key == event_name)
    if event == none {
      return text(fill: red, [
        WARNING: Event "#text(fill: gray, event_name)" not found. Valid event names are given as `key`s
        in the `settings` object. Currently specified events are: #(
          all_event_names.map(e => ["#text(fill: gray, raw(e))"]).join(", ")
        )
      ])
    }


    _format_event_date(event)
  })
}
