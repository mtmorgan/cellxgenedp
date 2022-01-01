test_that("jmespath_version() works", {
    version <- jmespath_version()
    expect_s3_class(version, "package_version")
    expect_true(version >= "0.168.1")
})

test_that("jmespath() works", {
    data <-r'([{ "datasets" : [] }])';
    path = r'([].{ dataset: datasets[]})';
    expect_identical(jmespath(data, path), r'([{"dataset":[]}])')
})
