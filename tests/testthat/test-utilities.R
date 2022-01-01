test_that(".timestamp_to_date() works", {
    origin <- as.Date("1970-01-01")
    expect_identical(.timestamp_to_date(integer()), as.Date(character()))
    expect_identical(.timestamp_to_date(0L), origin)
    expect_identical(.timestamp_to_date(rep(0L, 2L)), rep(origin, 2L))
})

test_that(".is_scalar() works", {
    expect_true(.is_scalar_character("a"))
    expect_false(.is_scalar_character(character()))
    expect_false(.is_scalar_character(integer(1)))
    expect_false(.is_scalar_character(""))
    expect_false(.is_scalar_character(letters))
    expect_false(.is_scalar_character(NA_character_))
})
