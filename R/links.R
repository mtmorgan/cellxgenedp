links <-
    function(cellxgene_db = db())
{
    link_lengths <-
        .jmes_to_r(cellxgene_db, "[*].length(links)[]")
    collection_ids <- .jmes_to_r(cellxgene_db, "[*].id")
    collection_id <- tibble(collection_id = rep(collection_ids, link_lengths))
    links <-
        cellxgene_db |>
        .jmes_to_r("[*].links[*]") |>
        ## create a single tibble
        bind_rows() |>
        as_tibble() |>
        ## clean up unnamed links from '""' to NA
        mutate(
            link_name = ifelse(
                nzchar(.data$link_name), .data$link_name, NA_character_
            )
        )

    bind_cols(collection_id, links)
}
