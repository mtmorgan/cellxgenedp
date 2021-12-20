.timestamp_to_date <-
    function(x)
{
    as.Date(as.POSIXct(x, origin = "1970-01-01"))
}

.is_scalar <-
    function(x)
{
    length(x) == 1L && !is.na(x)
}

.is_scalar_character <-
    function(x)
{
    .is_scalar(x) && is.character(x) && nzchar(x)
}

.is_scalar_logical <-
    function(x)
{
    .is_scalar(x) && is.logical(x)
}
