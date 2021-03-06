#' @title Trim whitespace
#' @description Uses regex to remove whitespace from a string.
#' @param x String
#' @return String without whitespace
#' @rdname trim
#' @export 
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#' @title Removes trailing whitespace
#' @description Uses regex to remove trailing whitespace from a string.
#' @param x String
#' @return String without trailing whitespace.
#' @rdname trim.trailing
#' @export 
trim.trailing <- function (x) sub("\\s+$", "", x)

#' @title Convert a vector to factor
#' @description Takes a numeric or character factor and converts it to factor. Sets levels to numeric levels 0-3 etc.
#' @param vector Vector
#' @return Factor vector
#' @rdname factorize
#' @export 
factorize <- function(vector){
  items <- as.factor(vector)
  new.levels <- c(0:(length(levels(items)) - 1 ))
  levels(items) <- as.numeric(new.levels)
  # --- return ---
  items
}

#' @title Is variable not in a table?
#' @description Checks if variable x is oresent in table 'table'.
#' @param x Variable
#' @param table Table or vector
#' @return TRUE/FALSE
#' @rdname not_in
#' @export 
`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

#' @title Get PPM error range 
#' @description Given a m/z value, generates a window of user ppm to perform matching in.
#' @param mz Mass over charge value
#' @param ppm Parts per million error allowed
#' @return Character vector c(mz - mz times ppm, mz + mz times ppm)
#' @rdname ppm_range
#' @export 
ppm_range <- function(mz, ppm) c((mz - (ppm/1000000 * mz)), (mz + (ppm/1000000 * mz)))

# 
#' @title Visualise SMILES molecule.
#' @description Plot molecules in R plot window instead of separate Java window
#' @param smi SMILES string
#' @param width Image width in pixels, Default: 500
#' @param height Image height in pixels, Default: 500
#' @param marg Margins around molecule, Default: 0
#' @param main Text above image, Default: ''
#' @param style Style (see rcdk 'get.depictor'), Default: 'bow'
#' @return File path to refer to in shiny.
#' @seealso 
#'  \code{\link[rcdk]{parse.smiles}}
#' @rdname plot.mol
#' @export 
#' @importFrom rcdk parse.smiles get.depictor view.image.2d
plot_mol = function(smi,
                    width=500,
                    height=500,
                    marg=0,
                    main='',
                    style="bow") {

  if(is.null(smi)){
    return(NULL)
  }
  molecule = rcdk::parse.smiles(smi)[[1]]
  par(mar=c(marg,marg,marg,marg)) # set margins to zero since this isn't a real plot
  dept = rcdk::get.depictor(width = width, height = height, zoom = 3, style = style,
                      annotate = "off", abbr = "on", suppressh = TRUE,
                      showTitle = FALSE, smaLimit = 100, sma = NULL)
  temp1 = rcdk::view.image.2d(molecule, dept) # get Java representation into an image matrix. set number of pixels you want horiz and vertical

  # - - return - -
  # A temp file to save the output. It will be deleted after renderImage
  # sends it, because deleteFile=TRUE.
  a <- tempfile(fileext='.png')
 
  plot(NA,NA,xlim=c(1,10),ylim=c(1,10),xaxt='n',yaxt='n',xlab='',ylab='',main=main,bg=NA) # create an empty plot
  rasterImage(temp1,1,1,10,10) # boundaries of raster: xmin, ymin, xmax, ymax. here i set them equal to plot boundaries

  # Return a list
  list(src = a)
}

#lcl = mSet = input = enrich = shown_matches = my_selection = browse_content = pieinfo = result_filters = list()

#' @title Joanna's debugger
#' @description Function to use after using the 'debug' button when running in R. Writes various objects (mSet, current input etc.) to global.
#' @seealso 
#'  \code{\link[shiny]{isolate}},\code{\link[shiny]{reactiveValuesToList}}
#' @rdname joanna_debugger
#' @export 
#' @importFrom shiny isolate reactiveValuesToList
joanna_debugger <- function(){
  
  shown_matches <- shiny::isolate({shiny::reactiveValuesToList(debug_matches)})
  my_selection <- shiny::isolate({shiny::reactiveValuesToList(debug_selection)})
  browse_content <- shiny::isolate({shiny::reactiveValuesToList(debug_browse_content)})
  pieinfo <- shiny::isolate({shiny::reactiveValuesToList(debug_pieinfo)})
  result_filters <- shiny::isolate({shiny::reactiveValuesToList(debug_result_filters)})
  
  assign("lcl", debug_lcl, envir = .GlobalEnv)
  assign("mSet", debug_mSet, envir = .GlobalEnv)
  assign("input", debug_input, envir = .GlobalEnv)
  assign("enrich", debug_enrich, envir = .GlobalEnv)
  assign("shown_matches", shown_matches, envir = .GlobalEnv)
  assign("my_selection", my_selection, envir = .GlobalEnv)
  assign("browse_content", browse_content, envir = .GlobalEnv)
  assign("pieinfo", pieinfo, envir = .GlobalEnv)
  assign("result_filters", result_filters, envir = .GlobalEnv)
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param file.loc PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @rdname getOptions
#' @export 
getOptions <- function(file.loc){
  opt_conn <- file(file.loc)
  # ----------------
  options_raw <- readLines(opt_conn)
  close(opt_conn)
  # --- list-ify ---
  options <- list()
  for(line in options_raw){
    split  <- (strsplit(line, ' = '))[[1]]
    options[[split[[1]]]] = split[[2]]
  }
  # --- return ---
  options
}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param file.loc PARAM_DESCRIPTION
#' @param key PARAM_DESCRIPTION
#' @param value PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @rdname setOption
#' @export 
setOption <- function(file.loc, key, value){
  opt_conn <- file(file.loc)
  # -------------------------
  options <- getOptions(file.loc)
  # --- add new or change ---
  options[[key]] = value
  # --- list-ify ---
  new_options <- lapply(seq_along(options), FUN=function(i){
    line <- paste(names(options)[i], options[i], sep=" = ")
    line
  })
  writeLines(opt_conn, text = unlist(new_options))
  
  close(opt_conn)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @rdname get_os
#' @export 
get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}

# Customised TRUE-FALSE switch button for Rshiny
# Only sing CSS3 code (No javascript)
#
# Sébastien Rochette
# http://statnmap.com/en/
# April 2016
#
# CSS3 code was found on https://proto.io/freebies/onoff/
# For CSS3 customisation, refer to this website.
#' @title Generate custom switch button
#' @description Generates css for custom switch button.
#' @param inputId Shiny ID to use (behaves as checkbox)
#' @param label HTML label
#' @param value Default on/off? TRUE/FALSE, Default: FALSE
#' @param col Color binary used (RG red green, GB grey blue BW black white), Default: 'GB'
#' @param type Pick display option TF true-false, OO on-off, YN yes-no, ASMB asca-meba, TTFC t-test/fold-change Default: 'TF'
#' @return HTML tag to display in shiny app
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  switchButton("doThing", "Do thing?", TRUE, "GB", "YN")
#'  }
#' }
#' @seealso 
#'  \code{\link[shiny]{tag}},\code{\link[shiny]{builder}}
#' @rdname switchButton
#' @export 
#' @importFrom shiny tagList tags
switchButton <- function(inputId, label, value=FALSE, col = "GB", type="TF") {
  
  # # color class
  # if (col != "RG" & col != "GB" & col != "BW") {
  #   stop("Please choose a color between \"RG\" (Red-Green) 
  #        and \"GB\" (Grey-Blue) and Black-white(added).")
  # }
  # if (!type %in% c("OO", "TF", "YN", "TTFC", "2d3d")){
  #   warning("No known text type (\"OO\", \"TF\" or \"YN\") have been specified, 
  #           button will be empty of text") 
  # }
  if(col == "RG"){colclass <- "RedGreen"}
  if(col == "GB"){colclass <- "GreyBlue"}
  if(col == "BW"){colclass <- "BlackWhite"}
  if(type == "OO"){colclass <- paste(colclass,"OnOff")}
  if(type == "TF"){colclass <- paste(colclass,"TrueFalse")}
  if(type == "YN"){colclass <- paste(colclass,"YesNo")}
  if(type == "TTFC"){colclass <- paste(colclass,"TtFc")}
  if(type == "ASMB"){colclass <- paste(colclass,"AsMb")}
  if(type == "CLBR"){colclass <- paste(colclass,"ClBr")}
  
  if(type == "2d3d"){
    colclass <- paste(colclass,"twodthreed")
  }
  
  # No javascript button - total CSS3
  # As there is no javascript, the "checked" value implies to
  # duplicate code for giving the possibility to choose default value
  
  if(value){
    tagList(
      tags$div(class = "form-group shiny-input-container",
               tags$div(class = colclass,
                        tags$label(label, class = "control-label"),
                        tags$div(
                          class = "onoffswitch",
                          tags$input(type = "checkbox", name = "onoffswitch", class = "onoffswitch-checkbox",
                                     id = inputId, checked = ""
                          ),
                          tags$label(class = "onoffswitch-label", `for` = inputId,
                                     tags$span(class = "onoffswitch-inner"),
                                     tags$span(class = "onoffswitch-switch")
                          )
                        )
               )
      )
    )
  } else {
    tagList(
      tags$div(class = "form-group shiny-input-container",
               tags$div(class = colclass,
                        tags$label(label, class = "control-label"),
                        tags$div(class = "onoffswitch",
                                 tags$input(type = "checkbox", name = "onoffswitch", class = "onoffswitch-checkbox",
                                            id = inputId
                                 ),
                                 tags$label(class = "onoffswitch-label", `for` = inputId,
                                            tags$span(class = "onoffswitch-inner"),
                                            tags$span(class = "onoffswitch-switch")
                                 )
                        )
               )
      )
    ) 
  }
}

#' @title Small image checkbox that fades upon deselection
#' @description Used in MetaboShiny database selection when searching or pre-matching
#' @param inputId Shiny input ID to connect to
#' @param img.path Path to image to use, Default: NULL
#' @param value Default value (T/F), Default: FALSE
#' @return Shiny HTML tag
#' @seealso 
#'  \code{\link[shiny]{tag}},\code{\link[shiny]{builder}}
#' @rdname fadeImageButton
#' @export 
#' @importFrom shiny tagList tags
fadeImageButton <- function(inputId, img.path=NULL,value=FALSE) {
  # ---------------
  #if(is.null(img)) stop("Please enter an image name (place in www folder please)")
  # ---------------
  shiny::tagList(
    shiny::tags$div(class = "form-group shiny-input-container",
                    if(value){
                      shiny::tags$input(type="checkbox", class="fadebox", id=inputId)
                    } else{
                      shiny::tags$input(type="checkbox", class="fadebox", id=inputId, checked="")
                    },
                    shiny::tags$label(class="btn", "for"=inputId,
                                      shiny::tags$img(src=img.path, id="btnLeft"))
    )
  )
}

#' @title Make content sit next to each other
#' @description Hacky thing to make html elements sit next to each other.
#' @param content List of shiny html tags 
#' @return Shiny inline-block div
#' @seealso 
#'  \code{\link[shiny]{builder}}
#' @rdname sardine
#' @export 
#' @importFrom shiny div
sardine <- function(content) shiny::div(style="display: inline-block;vertical-align:top;", content)

# loading screen
#' @title MetaboShiny loading screen
#' @description Generates the loading screen modal!
#' @return OUTPUT_DESCRIPTION
#' @seealso 
#'  \code{\link[shiny]{modalDialog}},\code{\link[shiny]{fluidPage}},\code{\link[shiny]{builder}}
#' @rdname loadModal
#' @export 
#' @importFrom shiny modalDialog fluidRow br h3 img
loadModal <- function() {
  shiny::modalDialog(
    shiny::fluidRow(align="center",
             shiny::br(),shiny::br(),
             shiny::h3("Starting MetaboShiny..."),
             shiny::br(),shiny::br(),
             #shiny::helpText("ଘ(੭ˊᵕˋ)੭* ੈ✩‧₊˚"), 
             #shiny::br(),shiny::br(),
             shiny::img(class="rotategem", src="gemmy_rainbow.png", width="70px", height="70px"),
             shiny::br(),shiny::br(),shiny::br()
    )
  )
}

#' @title Create table with all possible comparisons
#' @description Takes a vector and makes all possible pairs of two elements. Useful in power analysis.
#' @param x One vector
#' @param y Another vector
#' @param include.equals Include same vs. same pairings?, Default: FALSE
#' @return Table of all possible unique pairs.
#' @rdname expand.grid.unique
#' @export 
expand.grid.unique <- function(x, y, include.equals=FALSE)
{
  x <- unique(x)
  y <- unique(y)
  
  g <- function(i)
  {
    z <- setdiff(y, x[seq_len(i-include.equals)])
    if(length(z)) cbind(x[i], z, deparse.level=0)
  }
  do.call(rbind, lapply(seq_along(x), g))
}

#' @title Perform a search to get PubMed abstracts
#' @description Taking a search term, date range and amount of abstracts to count, finds all abstracts of interest.
#' @param searchTerms Search term(s). If multiple, make them one string with spaces in between the words.
#' @param retmax Max abstracts to consider, Default: 500
#' @param mindate Minimum year to consider, Default: 2000
#' @param maxdate Maximum year to consider, Default: 2019
#' @return Data frame of abstracts
#' @seealso 
#'  \code{\link[RISmed]{EUtilsSummary}},\code{\link[RISmed]{QueryId}},\code{\link[RISmed]{EUtilsGet}}
#' @rdname getAbstracts
#' @export 
#' @importFrom RISmed EUtilsSummary QueryId EUtilsGet
getAbstracts <- function(searchTerms, retmax=500, mindate=2000, maxdate=2019){
  searchTerms = strsplit(searchTerms, " ")[[1]]
  # ==== SEARCH A METABOLITE TERM =====
  SUMMARYx <- RISmed::EUtilsSummary(paste0(searchTerms, collapse="+"),type = "esearch", db = "pubmed",
                            datetype = "edat",retmax = 500, 
                            mindate = 2000, maxdate = 2019)
  Idsx <- RISmed::QueryId(SUMMARYx)
  # Get Download(Fetch)
  MyDownloadsx <- RISmed::EUtilsGet(SUMMARYx, type = "efetch", db = "pubmed")
  #Make Data.frame of MyDownloads
  abstractsx <- data.frame(title = MyDownloadsx@ArticleTitle,
                           abstract = MyDownloadsx@AbstractText,
                           journal = MyDownloadsx@Title,
                           DOI = MyDownloadsx@PMID,
                           year = MyDownloadsx@YearPubmed)
  #Constract a charaterized variable for abstract of abstracts data.frame
  abstractsx <- abstractsx %>% mutate(abstract = as.character(abstract))
  #abstractsx$abstract <- as.character(abstractsx$abstract) # alternative for above line
  return(abstractsx)
}

#' @title Get frequency of a word in an abstract
#' @description Takes an abstract, returns word vs frequency table.
#' @param abstractsx Data table with abstract
#' @seealso 
#'  \code{\link[tidytext]{unnest_tokens}}
#' @return Frequency table
#' @rdname getWordFrequency
#' @export 
#' @importFrom tidytext unnest_tokens
getWordFrequency <- function(abstractsx){
  abstractsx <- data.table::data.table(abstract = abstractsx)
  #Split a column into tokens using the tokenizers package
  CorpusofMyCloudx <- abstractsx %>% tidytext::unnest_tokens(word, abstract) %>% dplyr::count(word, sort = TRUE)
  CorpusofMyCloudx$word <- gsub("^\\d+$", "", CorpusofMyCloudx$word)
  return(CorpusofMyCloudx)
}

#' @title Filter lists out of a frequency table
#' @description Taking a blacklist, removes words that match that blacklist.
#' @param frequencies Frequency table
#' @param filterList Vector of words to filter out
#' @return Filtered frequency table
#' @rdname getFilteredWordFreqency
#' @export 
getFilteredWordFreqency <- function(frequencies, filterList){
  filterWords <- unique(filterList)#$word)
  filteredWords <- frequencies[!(frequencies$word %in% filterWords),]
  filteredWords <- filteredWords[]
  return(filteredWords)
}

#' @title Escape a string for use in terminal
#' @description If you're suffering from file names with spaces and brackets on a linux machine, this escapes everything so you can copy paste without manually doing the escapes.
#' @param str String
#' @return Escaped string
#' @rdname escape
#' @export 
escape = function(str){
  str_adj = gsub(str, pattern = "( )", replacement = "\\\\\\1")
  str_adj = gsub(str_adj, pattern = "(\\))", replacement = "\\\\\\1")
  str_adj = gsub(str_adj, pattern = "(\\()", replacement = "\\\\\\1")
  str_adj = gsub(str_adj, pattern = "(&)", replacement = "\\\\\\1")
  # - - - - - 
  cat(str_adj)
}


