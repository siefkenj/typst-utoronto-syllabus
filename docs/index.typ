#import "@preview/elembic:1.1.1" as e
#import "/src/lib.typ" as s
#import "@preview/cmarker:0.1.6"
#import "_render_info.typ": show_docs
#let package_info = toml("/typst.toml")
#let example_render(body) = context {
  if sys.inputs.at("html", default: false) == "true" and target() == "html" {
    html.frame(body)
  } else {
    body
  }
}


= #package_info.package.name

A Typst package for creating syllabi originally designed for courses at the University of Toronto.

== Usage

#raw(package_info.package.name) uses #link("https://github.com/PgBiel/elembic")[Elembic] to allow you to set and override
settings for your course. A basic syllabus is shown below.

#let full_package_name = (
  "@preview/" + package_info.package.name + ":" + package_info.package.version
)
#let usage_string = (
  "#import \""
    + full_package_name
    + "\" as s"
    + ```typst

    #import "@preview/elembic:1.1.1" as e

    // Initialize all settings for the course
    #show: e.set_(
      s.settings,
      code: "Mat 244",
      name: "Differential Equations",
      term: "Fall 2025",
      term_start_date: datetime(year: 2025, month: 9, day: 2),
      term_end_date: datetime(year: 2025, month: 10, day: 15),
      // `basic_info` is populated in a table at the start of the syllabus
      basic_info: (
        (
          title: "Textbook",
          value: [Introduction to Differential Equations by John Doe],
        ),
        (
          title: "Course webpage",
          value: [https://example.com/course],
        ),
      ),
      // Holidays are automatically added to the timetable
      holidays: (
        (
          name: [Thanksgiving],
          date: datetime(year: 2025, month: 10, day: 13),
        ),
      ),
      // Events are automatically added to the timetable
      events: (
        (
          name: [Midterm],
          // hours/minutes/seconds are optional
          date: datetime(year: 2025, month: 9, day: 15, hour: 17, minute: 10, second: 0),
          // An optional duration will affect how the event is displayed
          duration: duration(hours: 2),
          type: "test",
          // Setting a `key` allows this date to be referenced later in the syllabus
          key: "midterm",
        ),
        (
          name: [Optional Homework],
          date: datetime(year: 2025, month: 9, day: 22),
          type: "homework",
        ),
      ),
    )

    // After we `show: s.template` we put the actual content of our syllabus.
    #show: s.template

    Differential Equations is a really great course! You'll love lit.

    == Assessments

    #s.annotated_item(
      title: "Midterm",
      subtitle: "50%"
    )[
      A multiple-choice midterm on
      // We can access and print dates that we have previously set in the settings
      // by referencing them with their `key` field.
      #s.get_event_time("midterm")
    ]
    #s.annotated_item(
      title: "Final Exam",
      subtitle: "50%"
    )[
      A comprehensive final exam on the last day of the term
      // We can also access the term start and end dates as well as the tutorial start date.
      #s.get_event_time("term_end_date")
    ]

    == Schedule

    #s.timetable(
      week_start_day: "monday",
      weekly_data: (
        [Week 1: Introduction to Differential Equations],
        [Week 2: First-Order Differential Equations],
        [Week 3: Second-Order Differential Equations],
        [Week 4: Laplace Transforms],
        [Week 5: Systems of Differential Equations],
      ),
    )

    ```.text
)

#align(center, {
  set align(left)
  block(inset: .5cm, stroke: 1pt + black, fill: gray.lighten(95%), {
    set text(size: .8em)
    raw(usage_string, lang: "typst", block: true)
  })
})

// Make sure we are able to execute the example, but use a local version of the package when we do.
#let example_for_eval = (
  ("[\n" + usage_string + "\n]")
    .replace(full_package_name, "/src/lib.typ")
    .replace("show: s.template", "show: s.template.with(minipage: true)")
)
//#example_for_eval

Compiling this thesis results in:

#align(center, example_render(block(stroke: 1pt + black, width: 20em, inset: .5cm, {
  set text(size: .5em)
  set align(left)
  eval(example_for_eval)
})))

== Elements

#let data = e.data(s.settings)
=== #raw(data.name + "(...)")
#show_docs(data)

#let data = e.data(s.template)
=== #raw(data.name + "(...)")
#show_docs(data)

#let data = e.data(s.annotated_item)
=== #raw(data.name + "(...)")
#show_docs(data)

//#cmarker.render(data.doc)

//#e.data(s.template)

