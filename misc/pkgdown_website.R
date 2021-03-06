# Make package website:
# usethis::use_pkgdown() # overwrites _pkgdown.yml
library(pkgdown)
# update .pkgdown.yml
init_site()
build_home(preview = FALSE)
# in index.html, remove misc/figures/.
topics <- sort(setdiff(unlist(lapply(tools::Rd_db("collapse"),
                                    tools:::.Rd_get_metadata, "name"), use.names = FALSE),
                      c("collapse-documentation","A0-collapse-documentation","collapse-depreciated"))) # "collapse-package"
build_reference(examples = TRUE, topics = topics) # "collapse-package"
Sys.setenv(NCRAN = "TRUE")
build_articles(lazy = TRUE) # lazy = FALSE # Still do with NCRAN = TRUE
# Replace all A0-collapse-documentation.html with index.html !!
# Replce all <h1>Reference</h1> with <h1>Documentation & Overview</h1>
# Replce all <h1>Articles</h1> with <h1>Vignettes / Articles</h1>
# Replace &amp;lt;- with &lt;- and %&amp;gt;% with %&gt;% and
# <span class='kw'>&amp;</span><span class='no'>lt</span>;- with <span class='kw'>&lt;-</span>
build_news()
# Add favicon:
# replace <head> by <head><link rel="shortcut icon" href="https://sebkrantz.github.io/collapse/favicon.ico" type="image/x-icon">

# replace "https://twitter.com/collapse_R" target="_blank",
# href="https://github.com/SebKrantz/collapse" target="_blank" and
# href="https://sebkrantz.github.io/Rblog/" target="_blank"  (target = "_blank")

# in index.html, replace with
# <li id="bloglink">
#  <a href="https://sebkrantz.github.io/Rblog/" target="_blank">Blog</a>
# </li>

# in pkgdown.js, add line
# $("#bloglink").removeClass("active");   below     menu_anchor.closest("li.dropdown").addClass("active");
preview_site()

# ?build_home
