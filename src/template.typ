#import "@preview/elembic:1.1.1" as e
#import "types.typ": *
#import "constants.typ": NOT_FOUND_SENTINEL
#import "utils.typ": *
#import "settings.typ": *
#import "elements/section-divider.typ": *
#import "elements/header.typ": *
#import "elements/annotated-item.typ": *



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
