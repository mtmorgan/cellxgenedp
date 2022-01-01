test_that("endpoints exist", {
    expect_true(nzchar(.CELLXGENE_PRODUCTION_HOST))
    expect_true(nzchar(.CELLXGENE_PRODUCTION_ENDPOINT))
    expect_true(nzchar(.DATASETS))
    expect_true(nzchar(.COLLECTIONS))
    expect_true(nzchar(.CELLXGENE_EXPLORER))

    skip_if_offline(.CELLXGENE_PRODUCTION_HOST)
    expect_success(.cellxgene_GET(.COLLECTIONS))
    expect_success(.cellxgene_GET(.DATASETS))
})

test_that(".cellxgene_cache_path() works", {
    expect_true(dir.exists(.cellxgene_cache_path(tempfile())))

    ## don't create cache if it does not exist
    cache_path <- R_user_dir("cellxgenedp", "cache")
    skip_if(!dir.exists(cache_path))
    expect_identical(.cellxgene_cache_path(), cache_path)
})

test_that(".cellxgene_cache_get() works from existing cache", {
    cache_path <- R_user_dir("cellxgenedp", "cache")
    collections <- file.path(cache_path, "collections")

    skip_if(!file.exists(collections))
    expect_identical(.cellxgene_cache_get(file = "collections"), collections)
})

test_that(".cellxgene_cache_get() works online", {
    skip_if_offline(.CELLXGENE_PRODUCTION_HOST)
    cache_path <- tempfile()
    expect_success(.cellxgene_cache_get(.COLLECTIONS, cache_path = cache_path))
})

    
