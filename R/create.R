#' @rdname devtools-deprecated
#' @export
create <- function(path, description = getOption("devtools.desc"),
                   check = FALSE, rstudio = TRUE, quiet = FALSE) {
  .Deprecated("usethis::create_package()", package = "devtools")
  check_package_name(path)

  # ensure the parent directory exists
  parent_dir <- normalizePath(dirname(path), winslash = "/", mustWork = FALSE)
  if (!file.exists(parent_dir)) {
    stop("Parent directory '", parent_dir, "' does not exist", call. = FALSE)
  }

  # allow 'create' to create a new directory, or populate
  # an empty directory, as long as the parent directory exists
  if (!file.exists(path)) {
    if (!dir.create(path)) {
      stop("Failed to create package directory '", basename(path), "'",
        call. = FALSE
      )
    }
  }

  # if the directory exists but is not empty, bail
  files <- list.files(path)
  if (length(files)) {
    valid <- length(files) == 1 && tools::file_ext(files) == "Rproj"
    if (!valid) {
      stop("Directory exists and is not empty", call. = FALSE)
    }
  }

  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  setup(
    path = path, description = description, rstudio = rstudio,
    check = check, quiet = quiet
  )

  invisible(TRUE)
}

#' @rdname devtools-deprecated
#' @export
setup <- function(path = ".", description = getOption("devtools.desc"),
                  check = FALSE, rstudio = TRUE, quiet = FALSE) {
  .Deprecated("usethis::create_package()", package = "devtools")
  check_package_name(path)

  parent_dir <- normalizePath(dirname(path), winslash = "/", mustWork = TRUE)
  if (!quiet) {
    message("Creating package '", extract_package_name(path), "' in '", parent_dir, "'")
  }

  dir.create(file.path(path, "R"), showWarnings = FALSE)
  create_description(path, extra = description, quiet = quiet)
  create_namespace(path)

  if (rstudio) use_rstudio(path)

  if (check) check(path)
  invisible(TRUE)
}

#' @rdname devtools-deprecated
#' @export
create_description <- function(path = ".", extra = getOption("devtools.desc"),
                               quiet = FALSE) {
  .Deprecated("usethis::use_description()", package = "devtools")
  # Don't call check_dir(path) here (#803)
  desc_path <- file.path(path, "DESCRIPTION")

  if (file.exists(desc_path)) return(FALSE)

  subdir <- file.path(path, c("R", "src", "data"))
  if (!any(file.exists(subdir))) {
    stop("'", path, "' does not look like a package: no R/, src/ or data directories",
      call. = FALSE
    )
  }

  desc <- build_description(extract_package_name(path), extra)

  if (!quiet) {
    message("No DESCRIPTION found. Creating with values:\n\n")
    write_dcf("", desc)
  }

  write_dcf(desc_path, desc)

  TRUE
}

build_description <- function(name, extra = list()) {
  check_package_name(name)

  defaults <- compact(list(
    Package = name,
    Title = "What the Package Does (one line, title case)",
    Version = "0.0.0.9000",
    "Authors@R" = getOption("devtools.desc.author"),
    Description = "What the package does (one paragraph).",
    Depends = paste0("R (>= ", as.character(getRversion()), ")"),
    License = getOption("devtools.desc.license"),
    Suggests = getOption("devtools.desc.suggests"),
    Encoding = "UTF-8",
    LazyData = "true"
  ))

  # Override defaults with user supplied options
  desc <- modifyList(defaults, extra)
  # Collapse all vector arguments to single strings
  desc <- lapply(desc, function(x) paste(x, collapse = ", "))

  desc
}


extract_package_name <- function(path) {
  basename(normalizePath(path, mustWork = FALSE))
}

check_package_name <- function(path) {
  name <- extract_package_name(path)
  if (!valid_name(name)) {
    stop(
      name, " is not a valid package name: it should contain only\n",
      "ASCII letters, numbers and dot, have at least two characters\n",
      "and start with a letter and not end in a dot.",
      call. = FALSE
    )
  }
}


valid_name <- function(x) {
  grepl("^[[:alpha:]][[:alnum:].]+$", x) && !grepl("\\.$", x)
}

create_namespace <- function(path) {
  ns_path <- file.path(path, "NAMESPACE")
  if (file.exists(ns_path)) return()

  cat(
    "# Generated by roxygen2: fake comment so roxygen2 overwrites silently.\n",
    'exportPattern("^[^\\\\.]")\n',
    sep = "",
    file = ns_path
  )
}