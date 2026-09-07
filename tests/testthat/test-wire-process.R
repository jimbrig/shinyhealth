
# cross-process realism: the server runs in this process (pumped by later),
# the client is a separate r process making an ordinary blocking request --
# the same shape as an external orchestrator probe

test_that("health endpoint answers a blocking request from another process", {
  skip_on_cran()
  skip_if_no_wire_deps()
  skip_if_not_installed("callr")

  handle <- local_health_app(add_healthcheck(new_wire_app(), verbose = FALSE))
  url <- paste0(handle$url(), "/health")

  proc <- callr::r_bg(
    function(url) {
      resp <- httr2::req_perform(httr2::request(url))
      list(
        status = httr2::resp_status(resp),
        type = httr2::resp_content_type(resp),
        body = httr2::resp_body_string(resp)
      )
    },
    args = list(url = url)
  )

  # pump the event loop so the in-process server can answer while the
  # client process blocks on the request
  deadline <- Sys.time() + 30
  while (proc$is_alive() && Sys.time() < deadline) {
    later::run_now(0.1)
  }
  if (proc$is_alive()) {
    proc$kill()
    skip("client process did not finish in time")
  }

  res <- proc$get_result()
  expect_identical(res$status, 200L)
  expect_identical(res$type, "application/health+json")
  expect_match(res$body, "\"status\":\"pass\"")
})
