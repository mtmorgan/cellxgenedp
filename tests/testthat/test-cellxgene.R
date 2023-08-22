test_that("endpoints exist", {
    expect_true(nzchar(.CELLXGENE_PRODUCTION_HOST))
    expect_true(nzchar(.CELLXGENE_PRODUCTION_ENDPOINT))
    expect_true(nzchar(.DATASETS))
    expect_true(nzchar(.COLLECTIONS))
    expect_true(nzchar(.CELLXGENE_EXPLORER))

    skip_if_offline(.CELLXGENE_PRODUCTION_HOST)
    expect_identical(status_code(.cellxgene_HEAD(.COLLECTIONS)), 200L)
    expect_identical(status_code(.cellxgene_HEAD(.DATASETS)), 200L)
})

test_that(".cellxgene_cache_path() works", {
    expect_true(dir.exists(.cellxgene_cache_path(tempfile())))

    ## don't create cache if it does not exist
    cache_path <- file.path(
        R_user_dir("cellxgenedp", "cache"), "curation", "v1"
    )
    skip_if(!dir.exists(cache_path))
    expect_identical(.cellxgene_cache_path(), cache_path)
})

test_that(".cellxgene_cache_get() works from existing cache", {
    cache_path <- file.path(
        R_user_dir("cellxgenedp", "cache"), "curation", "v1"
    )
    collections <- file.path(cache_path, "collections")

    skip_if(!file.exists(collections))
    expect_identical(.cellxgene_cache_get(file = "collections"), collections)
})

test_that(".cellxgene_cache_get() works online", {
    skip_if_offline(.CELLXGENE_PRODUCTION_HOST)
    cache_path <- tempfile(); dir.create(cache_path)
    expect_identical(
        .cellxgene_cache_get(.COLLECTIONS, cache_path = cache_path),
        file.path(cache_path, "collections")
    )
})
