# Contributing

(This contributing guide is an adaptation of the [Carpentries](https://github.com/carpentries-incubator/git-Rstudio-course/blob/gh-pages/CONTRIBUTING.md),
[tidyverse](https://github.com/tidyverse/tidyverse.org/blob/main/content/contribute/index.md), and
[unifr](https://github.com/ropensci/unifir/blob/HEAD/.github/CONTRIBUTING.md) contributing guides.)

`gfwr` is an open source project,
and we welcome contributions of multiple kinds:
bug reports, 
fixes to bugs,
typos,
improvements to documentation, 
new functions.

## Contributor Agreement

By contributing,
you agree that we may redistribute your work under [our license](LICENSE.md).
In exchange,
we will address your issues and/or assess your change proposal as promptly as we can,
and help you become a member of our community.
Everyone involved in `gfwr` 
agrees to abide by our [code of conduct](CodeOfConduct.md).

## How to Contribute

The easiest way to get started is to file an issue
to tell us about a spelling mistake,
some awkward wording,
or a bug.

1.  If you do not have a [GitHub](https://github.com) account,
    you can send us comments by email (see our emails in the [DESCRIPTION file](DESCRIPTION)).
    However,
    we will be able to respond more quickly if you use one of the other methods described below.

2.  If you have a [GitHub](https://github.com) account,
    or are willing to [create one](https://github.com/join),
    but do not know how to use Git,
    you can report problems or suggest improvements by [creating an issue](https://github.com/GlobalFishingWatch/gfwr/issues).
    This allows us to assign the item to someone
    and to respond to it in a threaded discussion.

3.  If you are comfortable with Git,
    and would like to add or change material,
    you can submit a pull request (PR).

Our preferred options are 3, 2, and 1, in that order.

## What to Contribute

### Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly with a PR. 
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

If the PR is too complicated, you can use options 1 or 2 in the [previous section](#how-to-contribute)

### Improvements to documentation

You may think that some functions are not clear enough and have suggestions to 
improve the documentation of the package. Here you'll also need to edit 
[roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R` 
file, in case you go for a PR.

### Bug reports

If you've found a bug, first create a minimal [reprex](/help#reprex). Spend some time trying to make it as minimal as possible: the more time you spend doing this, the easier it will be for the `gfwr` team to fix it. Then file an issue. If you can't reproduce the bug, it will be very difficult for us to fix it.

### Fixes to bugs

If you see a bug report in an issue and know how to fix it, please share your solution in the issue.
If you can do a PR that would fix the issue, please do so and let us know in the issue. 

### New functions

The `gfwr` package has been developed to help the R community access GFW data for
research and other applications. If you have ideas of new functions that are consistent 
with this aim, please let us know through email, an issue, or a proposal with a PR. 
If you would like to write the function but prefer to chat about it first with us,
you can open an issue and start the conversation before doing a PR. 


## What *Not* to Contribute

Remember that this package is a wrapper for an API, so we do not intend to add
functions to plot or analyze data. That would be out of the scope of the package.

If you are interested in collaborating with us to generate such a package, please get in touch.
Otherwise, you are welcome to create a package with functions out of the scope of
this one by yourself. 
We are happy to see other people making contributions for the community based on our work. 


