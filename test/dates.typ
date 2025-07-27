#import "/src/types.typ": *
#import "/src/utils.typ": *


// Test the `date_in_range` function finds dates in the range (without hours)
#for days in range(7) {
  let start_date = datetime(year: 2025, month: 9, day: 1)
  let date = start_date + duration(days: days)
  let start = start_date
  let end = start_date + duration(days: 6)
  let val = date_in_range(date, start, end)
  assert(
    val == "during",
    message: "Date in range computed incorrectly "
      + date.display(
        "[year]-[month repr:short]-[day]"
          + " as "
          + val
          + " for range "
          + start.display("[year]-[month repr:short]-[day]")
          + " to "
          + end.display("[year]-[month repr:short]-[day]"),
      ),
  )
}

// Test the `date_in_range` function finds dates in the range (without hours)
#for days in range(7) {
  let start_date = datetime(
    year: 2025,
    month: 9,
    day: 1,
    hour: 17,
    minute: 10,
    second: 0,
  )
  let date = start_date + duration(days: days)
  let start = start_date
  let end = start_date + duration(days: 6)
  let val = date_in_range(date, start, end)
  assert(
    val == "during",
    message: "Date in range computed incorrectly "
      + date.display(
        "[year]-[month repr:short]-[day]"
          + " as "
          + val
          + " for range "
          + start.display("[year]-[month repr:short]-[day]")
          + " to "
          + end.display("[year]-[month repr:short]-[day]"),
      ),
  )
}

// Specific test that failed in the past
#let val = date_in_range(
  datetime(
    year: 2025,
    month: 1,
    day: 7,
    hour: 17,
    minute: 10,
    second: 0,
  ),
  datetime(year: 2025, month: 1, day: 1),
  datetime(
    year: 2025,
    month: 1,
    day: 7,
  ),
)
#assert(
  val == "during",
  message: "Date in range computed incorrectly "
    + datetime(
      year: 2025,
      month: 1,
      day: 7,
      hour: 17,
      minute: 10,
      second: 0,
    ).display("[year]-[month repr:short]-[day]")
    + " as "
    + val
    + " for range "
    + datetime(year: 2025, month: 1, day: 1).display("[year]-[month repr:short]-[day]")
    + " to "
    + datetime(year: 2025, month: 1, day: 7).display("[year]-[month repr:short]-[day]"),
)
