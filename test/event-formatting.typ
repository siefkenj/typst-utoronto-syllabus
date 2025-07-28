#import "/src/types.typ": *
#import "/src/utils.typ": *

=== Duration and hours
#let ev = (
  name: "",
  date: datetime(year: 2025, month: 9, day: 15, hour: 17, minute: 10, second: 0),
  duration: duration(hours: 2),
)
#let formatted = format_event_date(ev)
#let expected = "Monday, Sep. 15 from 5:10pm to 7:10pm"
#assert(
  formatted == expected,
  message: "Expected '" + expected + "', got '" + formatted + "'",
)
#ev $->$ #raw(formatted)

=== No duration with hours
#let ev = (
  name: "",
  date: datetime(year: 2025, month: 9, day: 15, hour: 17, minute: 10, second: 0),
)
#let formatted = format_event_date(ev)
#let expected = "Monday, Sep. 15 at 5:10pm"
#assert(
  formatted == expected,
  message: "Expected '" + expected + "', got '" + formatted + "'",
)
#ev $->$ #raw(formatted)

=== No hours
#let ev = (
  name: "",
  date: datetime(year: 2025, month: 9, day: 15),
)
#let formatted = format_event_date(ev)
#let expected = "Monday, Sep. 15"
#assert(
  formatted == expected,
  message: "Expected '" + expected + "', got '" + formatted + "'",
)
#ev $->$ #raw(formatted)

=== No hours with duration
#let ev = (
  name: "",
  date: datetime(year: 2025, month: 9, day: 15),
  duration: duration(hours: 2),
)
#let formatted = format_event_date(ev)
#let expected = "Monday, Sep. 15"
#assert(
  formatted == expected,
  message: "Expected '" + expected + "', got '" + formatted + "'",
)
#ev $->$ #raw(formatted)

=== Multi-day event without hours
#let ev = (
  name: "",
  date: datetime(year: 2025, month: 9, day: 15),
  duration: duration(days: 2),
)
#let formatted = format_event_date(ev)
#let expected = "Monday, Sep. 15 to Wednesday, Sep. 17"
#assert(
  formatted == expected,
  message: "Expected '" + expected + "', got '" + formatted + "'",
)
#ev $->$ #raw(formatted)

=== Multi-day event with hours
#let ev = (
  name: "",
  date: datetime(year: 2025, month: 9, day: 15, hour: 17, minute: 10, second: 0),
  duration: duration(days: 2),
)
#let formatted = format_event_date(ev)
#let expected = "Monday, Sep. 15 at 5:10pm to Wednesday, Sep. 17 at 5:10pm"
#assert(
  formatted == expected,
  message: "Expected '" + expected + "', got '" + formatted + "'",
)
#ev $->$ #raw(formatted)
