# reload plots (pca/plsda) if the 2d/3d button is triggered
shiny::observeEvent(input$pca_2d3d, {
  datamanager$reload <- "pca"
}, ignoreNULL = T)

shiny::observeEvent(input$plsda_2d3d, {
  datamanager$reload <- "plsda"
}, ignoreNULL = T)

shiny::observeEvent(input$tt_nonpar, {
  statsmanager$calculate <- "tt"
  datamanager$reload <- "tt"
},ignoreInit = TRUE)

shiny::observeEvent(input$tt_eqvar, {
  statsmanager$calculate <- "tt"
  datamanager$reload <- "tt"
},ignoreInit = TRUE)

# set default mode for heatmap top hits pick button (tt/fc or asca/meba)
heatbutton <- shiny::reactiveValues(status = "ttfc")

# render heatmap button
output$heatbutton <- shiny::renderUI({
  if(is.null(heatbutton$status)){
    NULL
  }else{
    switch(heatbutton$status,
           asmb = switchButton(inputId = "heatmode",
                               label = "Use data from:", 
                               value = TRUE, col = "BW", type = "ASMB"),
           ttfc = switchButton(inputId = "heatmode",
                               label = "Use data from:", 
                               value = TRUE, col = "BW", type = "TTFC")
    )
  }
})

shiny::observeEvent(input$heatmode, {
  statsmanager$calculate <- "heatmap"
  datamanager$reload <- "heatmap"
})#,ignoreInit = F, ignoreNULL = T)

shiny::observeEvent(input$heatsign, {
  statsmanager$calculate <- "heatmap"
  datamanager$reload <- "heatmap"
})#,ignoreInit = F, ignoreNULL = T)

shiny::observeEvent(input$heatmap_topn, {
  if(!is.null(mSet$analSet$heatmap)){
    datamanager$reload <- "heatmap" # just reload
  }
})#,ignoreInit = F, ignoreNULL = T)

shiny::observeEvent(input$wc_topn, {
  datamanager$reload <- "matchplots"
})#,ignoreInit = TRUE, ignoreNULL = T)

shiny::observeEvent(input$db_only, {
  if(input$db_only){
    MetaboShiny::setOption(lcl$paths$opt.loc, "mode", "dbonly")
    logged$status <- "dbonly"
  }else{
    MetaboShiny::setOption(lcl$paths$opt.loc, "mode", "complete")
    logged$status <- "logged"
  }
},ignoreInit = F, ignoreNULL = T)
