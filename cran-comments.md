## Resubmission

This is a resubmission. In this version, I have:

* Removed the use of `installed.packages()` in favor of using `find.packages()`.
* Verified that no packages are installed during examples, testing, or vignettes: all functions that could install are set to use the dry run which instead prints information on what *would have been* installed.

## Test environments

* local R installation (Windows 11), R 4.6.0
* local R installation (macOS 11.4), R 4.6.0
* ubuntu-latest (on GitHub Actions), (oldrel-1, devel, and release)
* windows-latest (on GitHub Actions), (release)
* macOS-latest (on GitHub Actions), (release)
* Windows (on Winbuilder), (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Additional notes

* There is no corresponding paper to cite in the description.
