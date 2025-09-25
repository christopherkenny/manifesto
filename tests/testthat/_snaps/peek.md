# manifest_peek handles no dependencies

    Code
      manifest_peek(file)
    Message
      * Manifesto version: "0.0.1"
      * Project name: "myproject"
      * Project version: "1.2.3"
      * Required R version: "4.3.2"

# manifest_peek handles many dependencies

    Code
      manifest_peek(file)
    Message
      * Manifesto version: "0.0.1"
      * Project name: "many-deps-project"
      * Project version: "1.0.0"
      * Required R version: "4.0.0"
      Dependencies:
        * default: dplyr (">= 1.0.0"), ggplot2 (">= 3.3.0"), tidyr (">= 1.1.0"),
        readr (">= 1.4.0"), purrr (">= 0.3.0"), stringr (">= 1.4.0"), and 1 more
        package

# manifest_peek handles various dependency specifications

    Code
      manifest_peek(file)
    Condition
      Warning:
      Missing expected section(s): "environment"
    Message
      * Manifesto version: "0.1.0"
      * Project name: "dedup-test"
      * Project version: "0.1.0"
      Dependencies:
        * default: fs (">= 1.6.0")
        * dev: glue (">= 1.6.2")
        * ci: fs (">= 1.4.0")

