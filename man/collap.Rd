\name{collap}
\alias{A5-advanced-aggregation}
\alias{collap}
\alias{collapv}
\alias{collapg}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Advanced Data Aggregation
}
\description{
\code{collap} is a fast and easy to use multi-purpose data aggregation command.

It performs simple aggregations, multi-type data aggregations applying different functions to numeric and categorical data, weighted aggregations (including weighted multi-type aggregations), multi-function aggregations applying multiple functions to each column, and fully customized aggregations where the user passes a list mapping functions to columns.

\code{collap} works with \emph{collapse}'s \link[=A1-fast-statistical-functions]{Fast Statistical Functions}, providing extremely fast conventional and weighted aggregation. It also works with other functions but this does not deliver high speeds on large data and does not support weighted aggregations.

% \code{collap} supports formula and data (i.e. grouping vectors or lists of vectors) input to \code{by}, whereas \code{collapv} allows names and indices of grouping columns to be passed to \code{by}.
}
\usage{
# Main function: allows formula and data input to `by` and `w` arguments
collap(X, by, FUN = fmean, catFUN = fmode, cols = NULL, w = NULL, wFUN = fsum,
       custom = NULL, keep.by = TRUE, keep.w = TRUE, keep.col.order = TRUE,
       sort = TRUE, decreasing = FALSE, na.last = TRUE, parallel = FALSE, mc.cores = 1L,
       return = c("wide","list","long","long_dupl"), give.names = "auto", sort.row, \dots)

# Programmer function: allows column names and indices input to `by` and `w` arguments
collapv(X, by, FUN = fmean, catFUN = fmode, cols = NULL, w = NULL, wFUN = fsum,
        custom = NULL, keep.by = TRUE, keep.w = TRUE, keep.col.order = TRUE,
        sort = TRUE, decreasing = FALSE, na.last = TRUE, parallel = FALSE, mc.cores = 1L,
        return = c("wide","list","long","long_dupl"), give.names = "auto", sort.row, \dots)

# Auxiliary function: for grouped tibble ('grouped_df') input + non-standard evaluation
collapg(X, FUN = fmean, catFUN = fmode, cols = NULL, w = NULL, wFUN = fsum, custom = NULL,
        keep.group_vars = TRUE, keep.w = TRUE, keep.col.order = TRUE,
        parallel = FALSE, mc.cores = 1L,
        return = c("wide","list","long","long_dupl"), give.names = "auto", sort.row, \dots)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{X}{a data frame, or an object coercible to data frame using \code{\link{qDF}}.}
  \item{by}{for \code{collap}: a one-or two sided formula, i.e. \code{~ group1} or \code{var1 + var2 ~ group1 + group2}, or a atomic vector, list of vectors or \code{\link{GRP}} object used to group \code{X}. For \code{collapv}: names or indices of grouping columns, or a logical vector or selector function such as \code{\link{is.categorical}} selecting grouping columns.}
\item{FUN}{a function, list of functions (i.e. \code{list(fsum, fmean, fsd)} or \code{list(myfun1 = function(x).., sd = sd)}), or a character vector of function names, which are automatically applied only to numeric variables.}
\item{catFUN}{same as \code{FUN}, but applied only to categorical (non-numeric) typed columns (\code{\link{is.categorical}}).}
\item{cols}{select columns to aggregate using a function, column names, indices or logical vector. \emph{Note}: \code{cols} is ignored if a two-sided formula is passed to \code{by}.}
\item{w}{weights. Can be passed as numeric vector or alternatively as formula i.e. \code{~ weightvar} in \code{collap} or column name / index etc. i.e. \code{"weightvar"} in \code{collapv}. \code{collapg} supports non-standard evaluations so \code{weightvar} can be indicated without quotes if found in \code{X}. }
\item{wFUN}{same as \code{FUN}: Function(s) to aggregate weight variable if \code{keep.w = TRUE}. By default the sum of the weights is computed in each group.}

\item{custom}{a named list specifying a fully customized aggregation task. The names of the list are function names and the content columns to aggregate using this function (same input as \code{cols}). For example \code{custom = list(fmean = 1:6, fsd = 7:9, fmode = 10:11)} tells \code{collap} to aggregate columns 1-6 of \code{X} using the mean, columns 7-9 using the standard deviation etc. \emph{Note}: \code{custom} lets \code{collap} ignore any inputs passed to \code{FUN}, \code{catFUN} or \code{cols}.}
\item{keep.by, keep.group_vars}{logical. \code{FALSE} will omit grouping variables from the output. \code{TRUE} keeps the variables, even if passed externally in a list or vector (unlike other \emph{collapse} functions).}
\item{keep.w}{logical. \code{FALSE} will omit weight variable from the output i.e. no aggregation of the weights. \code{TRUE} aggregates and adds weights, even if passed externally as a vector (unlike other \emph{collapse} functions).}
\item{keep.col.order}{logical. Retain original column order post-aggregation.}
\item{sort, decreasing, na.last}{logical. Arguments passed to \code{\link{GRP.default}} and affecting the row-order in the aggregated data frame.}
\item{parallel}{logical. Use \code{parallel::mclapply} instead of \code{lapply} for multi-function or custom aggregation.}
\item{mc.cores}{integer. Argument to \code{parallel::mclapply} setting the number of cores to use.}
\item{return}{character. Control the output format when aggregating with multiple functions or performing custom aggregation. "wide" (default) returns a wider data frame with added columns for each additional function. "list" returns a list of data frames - one for each function. "long" adds a column "Function" and row-binds the results from different functions using \code{data.table::rbindlist}. "long.dupl" is a special option for aggregating multi-type data using multiple \code{FUN} but only one \code{catFUN} or vice-versa. In that case the format is long and data aggregated using only one function is duplicated. See Examples.}
\item{give.names}{logical. Create unique names of aggregated columns by adding a prefix 'FUN.'. 'auto' will automatically create such prefixes whenever multiple functions are applied to a column or \code{custom} is used.}
\item{sort.row}{depreciated, renamed to \code{sort}.}
\item{\dots}{additional arguments passed to all functions supplied to \code{FUN}, \code{catFUN}, \code{wFUN} or \code{custom}. The behavior of \link[=A1-fast-statistical-functions]{Fast Statistical Functions} is regulated by \code{option("collapse_unused_arg_action")} and defaults to \code{"warning"}. }
}

\details{
\code{collap} automatically checks each function passed to it whether it is a \link[=A1-fast-statistical-functions]{Fast Statistical Function} (i.e. whether the function name is contained in \code{.FAST_STAT_FUN}). If the function is a fast statistical function, \code{collap} only does the grouping and then calls the function to carry out the grouped computations. If the function is not one of \code{.FAST_STAT_FUN}, \code{\link{BY}} is called internally to perform the computation. The resulting computations from each function are put into a list and recombined to produce the desired output format as controlled by the \code{return} argument. When multiple functions are used with \code{collap}, setting \code{parallel = TRUE} and the number of cores with \code{mc.cores} will instruct \code{collap} to execute these function calls in parallel using \code{parallel::mclapply}. If only a single function is used which is not a \code{.FAST_STAT_FUN}, the \code{parallel} and \code{mc.cores} arguments are handed down to \code{\link{BY}}. See Examples.
}
\value{
\code{X} aggregated. If \code{X} is not a data frame it is coerced to one using \code{\link{qDF}} and then aggregated.
}
% \references{
%% ~put references to the literature/web site here ~
% }
% \author{
%%  ~~who you are~~
 %}
\note{
Since \code{\link{BY}} does not check and split additional arguments passed to it, it is presently not possible to create a weighted function in R and apply it to data by groups with \code{collap}. Weighted aggregations only work with \link[=A1-fast-statistical-functions]{Fast Statistical Functions} supporting weights. User written weighted functions can be applied using the \emph{data.table} package.

\code{collap} by default (\code{keep.by = TRUE, keep.w = TRUE}) preserves all arguments passed to the \code{by} or \code{w} arguments, whether passed in a formula or externally. The names of externally passed vectors and lists are intelligently extracted. So it is possible to write \code{collap(iris, iris$Species)}, and obtain an aggregated data frame with two \code{Species} columns, whereas \code{collap(iris, ~ Species)} only has one \code{Species} column. Similarly for weight vectors passed to \code{w}. In this regard \code{collap} is more sophisticated than other \emph{collapse} functions where preservation of grouping and weight variables is restricted to formula use. For example \code{STD(iris, iris$Species)} does not preserve \code{Species} in the output, whereas \code{STD(iris, ~ Species)} does. This \code{collap} feature is there simply for convenience, for example sometimes a survey is disaggregated into several datasets, and this now allows easy pulling of identifiers or weights from other datasets for aggregations. If all information is available in one dataset, just using formulas is highly recommended.
}

%% ~Make other sections like Warning with \section{Warning }{\dots.} ~

\seealso{
\code{\link{BY}}, \link[=A1-fast-statistical-functions]{Fast Statistical Functions}, \link[=collapse-documentation]{Collapse Overview}
}
\examples{
## A Simple Introduction --------------------------------------
head(iris)
collap(iris, ~ Species)                                        # Default: FUN = fmean for numeric
collapv(iris, 5)                                               # Same using collapv
collap(iris, ~ Species, fmedian)                               # Using the median
collap(iris, ~ Species, fmedian, keep.col.order = FALSE)       # Groups in-front
collap(iris, Sepal.Width + Petal.Width ~ Species, fmedian)     # Only '.Width' columns
collapv(iris, 5, cols = c(2, 4))                               # Same using collapv
collap(iris, ~ Species, list(fmean, fmedian))                  # Two functions
collap(iris, ~ Species, list(fmean, fmedian), return = "long") # Long format
collapv(iris, 5, custom = list(fmean = 1:2, fmedian = 3:4))    # Custom aggregation
collapv(iris, 5, custom = list(fmean = 1:2, fmedian = 3:4),    # Raw output, no column reordering
        return = "list")
collapv(iris, 5, custom = list(fmean = 1:2, fmedian = 3:4),    # A strange choice..
        return = "long")
collap(iris, ~ Species, w = ~ Sepal.Length)                    # Using Sepal.Length as weights, ..
weights <- abs(rnorm(fnrow(iris)))
collap(iris, ~ Species, w = weights)                           # Some random weights..
collap(iris, iris$Species, w = weights)                        # Note this behavior..
collap(iris, iris$Species, w = weights,
       keep.by = FALSE, keep.w = FALSE)
library(dplyr) # Needed for "\%>\%"
iris \%>\% fgroup_by(Species) \%>\% collapg                        # dplyr style, but faster

## Multi-Type Aggregation --------------------------------------
head(wlddev)                                                    # World Development Panel Data
head(collap(wlddev, ~ country + decade))                        # Aggregate by country and decade
head(collap(wlddev, ~ country + decade, fmedian, ffirst))       # Different functions
head(collap(wlddev, ~ country + decade, cols = is.numeric))     # Aggregate only numeric columns
head(collap(wlddev, ~ country + decade, cols = 9:12))           # Only the 4 series
head(collap(wlddev, PCGDP + LIFEEX ~ country + decade))         # Only GDP and life-expactancy
head(collap(wlddev, PCGDP + LIFEEX ~ country + decade, fsum))   # Using the sum instead
head(collap(wlddev, PCGDP + LIFEEX ~ country + decade, sum,     # Same using base::sum -> slower!
            na.rm = TRUE))
head(collap(wlddev, wlddev[c("country","decade")], fsum,        # Same, exploring different inputs
            cols = 9:10))
head(collap(wlddev[9:10], wlddev[c("country","decade")], fsum))
head(collapv(wlddev, c("country","decade"), fsum))              # ..names/indices with collapv
head(collapv(wlddev, c(1,5), fsum))

g <- GRP(wlddev, ~ country + decade)                            # Precomputing the grouping
head(collap(wlddev, g, keep.by = FALSE))                        # This is slightly faster now
# Aggregate categorical data using not the mode but the last element
head(collap(wlddev, ~ country + decade, fmean, flast))
head(collap(wlddev, ~ country + decade, catFUN = flast,         # Aggregate only categorical data
            cols = is.categorical))


## Weighted Aggregation ----------------------------------------
weights <- abs(rnorm(fnrow(wlddev)))                            # Random weight vector
head(collap(wlddev, ~ country + decade, w = weights))           # Takes weighted mean for numeric..
# ..and weighted mode for categorical data. The weight vector is aggregated using fsum
wlddev$weights <- weights                                       # Adding to data
head(collap(wlddev, ~ country + decade, w = ~ weights))         # Keeps column order
head(collap(wlddev, ~ country + decade, w = ~ weights,          # Aggregating weights using sum
            wFUN = list(fsum, fmax)))                           # and max (corresponding to mode)
wlddev$weights <- NULL


## Multi-Function Aggregation ----------------------------------
head(collap(wlddev, ~ country + decade, list(fmean, fNobs),     # Saving mean and Nobs
            cols = 9:12))

head(collap(wlddev, ~ country + decade,                         # Same using base R -> slower
            list(mean = mean,
                 Nobs = function(x, \dots) sum(!is.na(x))),
            cols = 9:12, na.rm = TRUE))

lapply(collap(wlddev, ~ country + decade,                       # List output format
            list(fmean, fNobs), cols = 9:12, return = "list"), head)

head(collap(wlddev, ~ country + decade,                         # Long output format
            list(fmean, fNobs), cols = 9:12, return = "long"))

head(collap(wlddev, ~ country + decade,                         # Also aggregating categorical data,
            list(fmean, fNobs), return = "long_dupl"))          # and duplicating it 2 times

head(collap(wlddev, ~ country + decade,                         # Now also using 2 functions on
            list(fmean, fNobs), list(fmode, flast),             # categorical data
            keep.col.order = FALSE))

head(collap(wlddev, ~ country + decade,                         # More functions, string input,
            c("fmean","fsum","fNobs","fsd","fvar"),             # parallelized execution
            c("fmode","ffirst","flast","fNdistinct"),           # (choose more than 1 cores,
            parallel = TRUE, mc.cores = 1L,                     # depending on your machine)
            keep.col.order = FALSE))


## Custom Aggregation ------------------------------------------
head(collap(wlddev, ~ country + decade,                         # Custom aggregation
            custom = list(fmean = 9:12, fsd = 9:10, fmode = 7:8)))

head(collap(wlddev, ~ country + decade,                         # Using column names
            custom = list(fmean = "PCGDP", fsd = c("LIFEEX","GINI"),
                          flast = "date")))

head(collap(wlddev, ~ country + decade,                         # Weighted parallelized custom
            custom = list(fmean = 9:12, fsd = 9:10,             # aggregation
                          fmode = 7:8), w = weights,
            wFUN = list(fsum, fmax),
            parallel = TRUE, mc.cores = 1L))

head(collap(wlddev, ~ country + decade,                         # No column reordering
            custom = list(fmean = 9:12, fsd = 9:10,
                          fmode = 7:8), w = weights,
            wFUN = list(fsum, fmax),
            parallel = TRUE, mc.cores = 1L, keep.col.order = FALSE))


## Piped Use --------------------------------------------------
wlddev \%>\% fgroup_by(country, decade) \%>\% collapg
wlddev \%>\% fgroup_by(country, decade) \%>\% collapg(w = ODA)
wlddev \%>\% fgroup_by(country, decade) \%>\% collapg(fmedian, flast)
wlddev \%>\% fgroup_by(country, decade) \%>\%
  collapg(custom = list(fmean = 9:12, fmode = 5:7, flast = 3))

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{manip} % __ONLY ONE__ keyword per line
