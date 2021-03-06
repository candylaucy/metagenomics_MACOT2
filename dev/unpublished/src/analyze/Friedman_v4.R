# This code is part of the MOCAT analysis pipeline
# Code is (c) Copyright Jens ROat Kultima, EMBL 2015
# This code is released under GNU GPL v3.

# THESE FIELDS DETERMINE REQUIRED INPUT AND DESCRIPTION
# DESC Runs Friedman test for Anita's day 7 samples
# REQUIRE metadata


########################
# Packages and libraries
########################
#load.function(ggplot2) # This function is MOCAT specfic
#load.function(gridExtra)
library(ggplot2)
library(gridExtra)
library(DESeq2)
library(vsn)

###########
# Load data
###########
# IMPORTANT NOTE! From MOCAT, data is by default stored in DATA

FIGURES.DIR <- './'
#FILTER_CUTOFF <- 0.000001
#TRANSFORMATION <- 'log10' # arcsin, DESeq2_log
#FILTER_TYPE <- 'keep with value in at least 1 sample' # 'keep with value in all samples'

FILTER_TYPE <- 'keep_features_above_X_in_Y_samples'
FILTER_MIN_SAMPLES <- 5


TEST <- 'anova'


for (type2 in c('mOTU')){

  #for (TRANSFORMATION in c('DESeq2_log')) {  #DESeq2_log
  for (TRANSFORMATION in c('none')) {
    for (FILTER_CUTOFF in c(0.001)) {
      #for (type2 in c('mOTU', 'module', 'pathway')){
      
  
      # file <- '/g/bork5/avoigt/TimeSeries/Data/mm.402.motu.is.annotated.mOTU.clusters.gz'
      # Note that this is a fake link to the insert scaled for the mOTU
      file <- paste('/g/bork5/mocat/MM/functional.profiles/263RefGeneCatalog.padded/screened.screened.adapter.on.hg19.solexaqa.allbest.l45.p95/anita.samples.functional.profile.screened.screened.adapter.on.hg19.on.263RefGeneCatalog.padded.solexaqa.allbest.l45.p95.base.norm.', type2, sep='')
      if(TRANSFORMATION == 'DESeq2_log' & type2 != 'mOTU') {
        file <- paste('/g/bork5/mocat/MM/functional.profiles/263RefGeneCatalog.padded/screened.screened.adapter.on.hg19.solexaqa.allbest.l45.p95/anita.samples.functional.profile.screened.screened.adapter.on.hg19.on.263RefGeneCatalog.padded.solexaqa.allbest.l45.p95.insert.scaled.', type2, sep='')
      }
      
      DATA <- t(read.table(file,quote="", header=T, row.names=1, check.names=FALSE, sep='\t', comment='#', skip = 4))
      if (type2 != 'mOTU') {
        DATA <- DATA[,c(3:dim(DATA)[2])] # Needed if we have funcitonal data
      }
      
      samples <- read.table('/g/bork1/kultima/projects/anita_functional_analysis/files/samples',quote="", header=F, check.names=FALSE, sep='\t', comment='#') # Load Samples to be included, has to be saved as vector, (no row.names=1 otherwise it expects data in column 1) # Header has to be F otherwise it takes a sample as header
      samples <- as.vector(samples[,1]) #  Make as vector
      DATA_SUBSET <- DATA[rownames(DATA) %in% samples,] # Select wanted samples in table based on vector
      
      
      # This is also loaded from MOCAT
      if(type2 == 'mOTU') {
        type <- 'Species'
      }
      if(type2 == 'cog') {
        type <- 'COGs'
      }
      if(type2 == 'ko') {
        type <- 'KOs'
      }
      if(type2 == 'module') {
        type <- 'Modules'
      }
      if(type2 == 'pathway') {
        type <- 'Pathways'
      }
      
      ##########
      # Open PDF
      ##########
      cat (paste('Running : ', type,TRANSFORMATION,FILTER_CUTOFF,TEST,'\n', sep='.'))
      PDF <- paste(type,TRANSFORMATION,FILTER_TYPE,FILTER_MIN_SAMPLES,FILTER_CUTOFF,TEST,'pdf', sep='.')
      if (PDF != '') {
        pdf(file=PDF, width=15, height=20)
      }
      
      
      ######################
      # Low abundance filter
      ######################
      
      if (FILTER_TYPE == 'keep with value in at least 1 sample'){
        max <- apply( DATA_SUBSET / rowSums(DATA_SUBSET) , 2, max)
        ids <- which(max >= FILTER_CUTOFF)
        oldDim <- dim(DATA_SUBSET)[2]
        DATA_SUBSET <- DATA_SUBSET[,ids, drop=F]
        newDim <- dim(DATA_SUBSET)[2]
        cat(paste(" Fraction features kept: ",length(ids)/dim(DATA)[2], "\n", sep=""))
      }
      if (FILTER_TYPE == 'keep with value in all samples'){
        stop() # not implemented currently, probably not meaningful
      }
      if (FILTER_TYPE == 'keep_features_above_X_in_Y_samples'){
        oldDim <- dim(DATA_SUBSET)[2]
        DATA_SUBSET <- DATA_SUBSET[,colSums(DATA_SUBSET >= FILTER_CUTOFF) >= FILTER_MIN_SAMPLES]
        newDim <- dim(DATA_SUBSET)[2]
        cat(paste(" Fraction features kept: ",length(ids)/dim(DATA)[2], "\n", sep=""))
        
      }
      
      
      
      ######################################
      # Rename species with weird annotation
      ######################################
      colnames(DATA_SUBSET) <- gsub(' ','_',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub('/','_',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub('-','_',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub('\\[','',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub(']','',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub('\\(','',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub(')','',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub('\'','',colnames(DATA_SUBSET))
      colnames(DATA_SUBSET) <- gsub('\\.','',colnames(DATA_SUBSET))
      
      
      ###########
      # Fractions
      ###########
      DATA_PROP <- data.frame(prop.table(as.matrix(DATA_SUBSET), 1)) # Calculates fractions
      
      
      ################
      # Transformation
      ################
      
      if ( TRANSFORMATION == 'arcsin' ){
        DATA_PROP <- (asin(sqrt(DATA_PROP)))
      }
      if ( TRANSFORMATION == 'log_wolfgang' ){
        lgf <- function(x){
          (x+sqrt(x*x+1))/2
        }
        DATA_PROP <- lgf(DATA_PROP)
      }
      if ( TRANSFORMATION == 'log10' ){
        DATA_PROP <- log10(DATA_PROP+1e-6)
      }
      if ( TRANSFORMATION == 'DESeq2_log' ){
        
        DATA_PROP2 <- NULL
        DATA_PROP2$Patient <- sapply(rownames(DATA_PROP),function(x) {return(strsplit(x,'-')[[1]][1])})
        DATA_PROP2$Protocol <- sapply(rownames(DATA_PROP),function(x) {return(strsplit(x,'-')[[1]][2])})
        DATA_PROP2$Day <- sapply(rownames(DATA_PROP),function(x) {return(strsplit(x,'-')[[1]][3])})
        DATA_PROP2$Replicate <- sapply(rownames(DATA_PROP),function(x) {return(strsplit(x,'-')[[1]][4])})
        DATA_PROP2 <- as.data.frame(DATA_PROP2)
        
        DESEQ_DATA <- DESeqDataSetFromMatrix(countData = as.matrix(t(floor(DATA_SUBSET))),
                                             colData = DATA_PROP2,
                                             design = ~ Patient)
        #DESEQ_DATA_VSD <- varianceStabilizingTransformation(DESEQ_DATA, blind=TRUE)
        DESEQ_DATA_LOG <- rlogTransformation(DESEQ_DATA)
        DATA_PROP <- t(assay(DESEQ_DATA_LOG))
        
      }
      meanSdPlot(t(DATA_PROP))
      
      
      ################
      # Loop over days
      ################
      FOR_PLOTTING <- list()
      LINE <- list()
      for (DAY in c(7, 392)) {
        subset_names <- names(which(sapply(row.names(DATA_SUBSET), function(x) {return(strsplit(x,'-')[[1]][3])})==DAY)) # extract names for this day
        SUBSET <- data.frame(DATA_PROP[subset_names,]) # get data subset
        
        
        ########################################
        # Take average, of replicates if day 392
        ########################################
        if (DAY == 7) {
          SUBSET_7 <- SUBSET
        }
        if (DAY == 392) {
          patient_protocol <- unique(paste(sapply(rownames(SUBSET),function(x) {return(strsplit(x,'-')[[1]][1])}), sapply(rownames(SUBSET),function(x) {return(strsplit(x,'-')[[1]][2])}), sep='-'))
          SUBSET_MEAN <- NULL
          new_rownames <- NULL
          for (pp in patient_protocol) {
            SUBSET_MEAN <- rbind(SUBSET_MEAN, t(colMeans(SUBSET[grepl(pp, rownames(SUBSET)),,drop=F])))
            new_rownames <- c(new_rownames, grep(pp, rownames(SUBSET), value = T)[1])
          }
          rownames(SUBSET_MEAN) <- new_rownames
          SUBSET <- data.frame(SUBSET_MEAN)
          SUBSET_392 <- SUBSET
        }
        
        
        #####################################
        # Identifiy Protocol, Patient and Day
        #####################################
        SUBSET$Patient <- sapply(rownames(SUBSET),function(x) {return(strsplit(x,'-')[[1]][1])})
        SUBSET$Protocol <- sapply(rownames(SUBSET),function(x) {return(strsplit(x,'-')[[1]][2])})
        SUBSET$Day <- sapply(rownames(SUBSET),function(x) {return(strsplit(x,'-')[[1]][3])})
        SUBSET$Replicate <- sapply(rownames(SUBSET),function(x) {return(strsplit(x,'-')[[1]][4])})
        
        
        ######################
        # Create empty vectors
        ######################
        p_values <- vector(length = ncol(SUBSET)-4) # create empty vectors to store data
        q_ratios <- vector(length = ncol(SUBSET)-4) # create empty vectors to store data
        
        
        ####################
        # Loop over features
        ####################
        for (c in 1:(ncol(SUBSET)-4)) { # does not consider the last 4 columns that include the patient, protocol, day
          
          if (TEST == 'anova') {
            r <- aov(formula( paste(colnames(SUBSET)[c], '~ Patient + Protocol' )), SUBSET)
            r <- unlist(summary(r))
            p_values[c] <- r[14]
            q_ratios[c] <- r[5]/r[4]
          }
          
          if (TEST == 'friedman') {
            r <- friedman.test(formula( paste(colnames(SUBSET)[c], '~ Protocol | Patient' )), SUBSET) # run test
            p_values[c] <- r$p.value # save values
            #if (r$statistic == 0) {
            q_ratios[c] <- r$statistic # save values
            #} else {
            #  q_ratios[c] <- 1/r$statistic # save values
            #}
          } 
        }
        
        #################
        # Adjust p values
        #################
        #p_adjusted <- p.adjust(p_values, method = "BH") # adjust p-values
        p_adjusted <- p_values
        
        
        # Calculate the vertical line, one per day
        ret <- -1
        seq <- 1
        while (ret == -1) {
          seq <- seq * 0.99
          pvalue <- c(seq, p_values)
          pvalueA <- p.adjust(pvalue, method = "BH")
          if (pvalueA[1] <= 0.05) {
            ret <- seq
          }
        }
        LINE[[DAY]] <- ret
        
        ################################
        # Create data frame for plotting
        ################################
        df <- as.data.frame(p_adjusted) 
        df$q_ratios <- q_ratios
        rownames(df) <- paste(colnames(SUBSET), ' (', DAY, ')', sep='')[1:(dim(df)[1])]
        FOR_PLOTTING[[DAY]] <- df
        
      }
      
      
      
      
      
      
      
      
      ##################
      # Merge dataframes
      ##################
      df <- rbind(cbind(FOR_PLOTTING[[7]], 7))
      colnames(df)[3] <- 392            
      df <- rbind(df, cbind(FOR_PLOTTING[[392]], 392))
      colnames(df)[3] <- 'day'
      
      
      ######
      # plot
      ######
      
      # Set colors
      day7_color <- 'red'
      day392_color <- 'blue'
      day_diff_color <- 'black'
      colors <- c(day7_color, day392_color, day_diff_color)
      colors_plot2 <- c(day7_color, day_diff_color)
      
      #########################
      # Plot dots and densities
      #########################
      
      # placeholder plot - prints nothing at all
      empty <- ggplot()+geom_point(aes(1,1), colour="white") +
        theme(                              
          plot.background = element_blank(), 
          panel.border = element_blank(), 
          panel.background = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), 
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank()
        )
      
      # Right hand density
      plot_right <- ggplot() + geom_histogram(aes(df$q_ratios, fill=factor(df$day) ), alpha=0.5) + coord_flip() + theme(legend.position = "none")  +
        theme(                              
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), 
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          plot.background = element_blank(), 
          panel.border = element_blank(), 
          panel.background = element_blank(),
          plot.margin=unit(c(0,0,0,-0.5), "cm")
        ) + scale_fill_manual(values = colors) + scale_x_log10()
      #+ xlim(min(df[,2]),max(df[,2]))
      
      # Top density
      plot_top <- ggplot() + geom_histogram(aes(df$p_adjusted, fill=factor(df$day) ), alpha=0.5) + theme(legend.position = "none")  +
        theme(                              
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), 
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          plot.background = element_blank(), 
          panel.border = element_blank(), 
          panel.background = element_blank(),
          plot.margin=unit(c(0,0,-0.5,0), "cm")
        ) + scale_fill_manual(values = colors) + scale_x_log10()
      #+ xlim(0,1)
      
      # Main
      d7UL <- signif(sum(df$p_adjusted <= 0.05 & df$q_ratios > 1 & df$day == 7, na.rm = T)/dim(FOR_PLOTTING[[7]])[1]*100,2)
      d7BL <- signif(sum(df$p_adjusted < 0.05 & df$q_ratios <= 1 & df$day == 7, na.rm = T)/dim(FOR_PLOTTING[[7]])[1]*100,2)
      d7UR <- signif(sum(df$p_adjusted > 0.05 & df$q_ratios > 1 & df$day == 7, na.rm = T)/dim(FOR_PLOTTING[[7]])[1]*100,2)
      d7BR <- signif(sum(df$p_adjusted > 0.05 & df$q_ratios <= 1 & df$day == 7, na.rm = T)/dim(FOR_PLOTTING[[7]])[1]*100,2)
      
      d392UL <- signif(sum(df$p_adjusted <= 0.05 & df$q_ratios > 1 & df$day == 392, na.rm = T)/dim(FOR_PLOTTING[[392]])[1]*100,2)
      d392BL <- signif(sum(df$p_adjusted < 0.05 & df$q_ratios <= 1 & df$day == 392, na.rm = T)/dim(FOR_PLOTTING[[392]])[1]*100,2)
      d392UR <- signif(sum(df$p_adjusted > 0.05 & df$q_ratios > 1 & df$day == 392, na.rm = T)/dim(FOR_PLOTTING[[392]])[1]*100,2)
      d392BR <- signif(sum(df$p_adjusted > 0.05 & df$q_ratios <= 1 & df$day == 392, na.rm = T)/dim(FOR_PLOTTING[[392]])[1]*100,2)
      
      if(is.na(d7BL)){d7BL<-0}
      if(is.na(d7BR)){d7BR<-0}
      if(is.na(d7UL)){d7UL<-0}
      if(is.na(d7UR)){d7UR<-0}
      
      if(is.na(d392BL)){d392BL<-0}
      if(is.na(d392BR)){d392BR<-0}
      if(is.na(d392UL)){d392UL<-0}
      if(is.na(d392UR)){d392UR<-0}
      
      # Get min and max x and scale
      roundDown <- function(x) 10^floor(log10(x))
      roundUp <- function(x) 10^ceiling(log10(x))
      i <- log10(roundDown(min(df$p_adjusted, na.rm = T)))
      j <- log10(roundUp(max(df$p_adjusted, na.rm = T)))
      x_steps <- 10^(seq(from = i, to = j, by = 1))
      i <- log10(roundDown(min(df$q_ratios, na.rm = T)))
      j <- log10(roundUp(max(df$q_ratios, na.rm = T)))
      y_steps <- 10^(seq(from = i, to = j, by = 1))
      
      # make fancy converter
      fancy_scientific <- function(l) {
        l <- format(l, scientific = TRUE)
        l <- gsub("^(.*)e", "e", l)
        l <- gsub("e", "10^", l)
        parse(text=l)
      }
      
      main <- ggplot(df, aes(p_adjusted,q_ratios),label=df$name,) + geom_point( aes(colour=factor(df$day)), size=3) +
        ylab("Ratio of variance explained:\nMethod effects over subject effects\n") +
        xlab("\nFDR adjusted p-values") +
        geom_hline(yintercept=1, colour='black', size = 1, linetype="dotted") +
        #geom_vline(xintercept=0.05, colour='red', size = 1, linetype="dotted") +
        geom_vline(xintercept=LINE[[7]], colour=day7_color, size = 1, linetype="dotted") +
        geom_vline(xintercept=LINE[[392]], colour=day392_color, size = 1, linetype="dotted") +
        theme_bw() +
        theme(
          # plot.margin=unit(c(0,-0.5,0,0), "cm"), only add this if adding histogram
          legend.position="none",
          axis.text=element_text(size=18),
          axis.title=element_text(size=18),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank()       
        ) +
        scale_fill_manual(values = colors) + scale_colour_manual(values = colors) +
        annotate("text", label=paste('Day 7; N=',dim(FOR_PLOTTING[[7]])[1] ), x = 0.15, y = min(df$q_ratios,na.rm = T), size = 6, colour = day7_color, hjust = 0) +
        annotate("text", label=paste('Day 392; N=',dim(FOR_PLOTTING[[392]])[1] ), x = 0.15, y =2* min(df$q_ratios,na.rm = T), size = 6, colour = day392_color, hjust = 0) +
        annotate("text", label=paste(d7UL, '%', sep=''), x = 0.01, y = 2, size = 6, colour = day7_color, hjust = 0) +
        annotate("text", label=paste(d392UL, '%', sep=''), x = 0.01, y = 4, size = 6, colour = day392_color, hjust = 0) +
        annotate("text", label=paste(d7UR, '%', sep=''), x = 0.06, y = 2, size = 6, colour = day7_color, hjust = 0) +
        annotate("text", label=paste(d392UR, '%', sep=''), x = 0.06, y = 4, size = 6, colour = day392_color, hjust = 0) +
        annotate("text", label=paste(d7BL, '%', sep=''), x = 0.01, y = min(df$q_ratios,na.rm = T), size = 6, colour = day7_color, hjust = 0) +
        annotate("text", label=paste(d392BL, '%', sep=''), x = 0.01, y = 2* min(df$q_ratios,na.rm = T), size = 6, colour = day392_color, hjust = 0) +
        annotate("text", label=paste(d7BR, '%', sep=''), x = 0.06, y = min(df$q_ratios,na.rm = T), size = 6, colour = day7_color, hjust = 0) +
        annotate("text", label=paste(d392BR, '%', sep=''), x = 0.06, y = 2* min(df$q_ratios,na.rm = T), size = 6, colour = day392_color, hjust = 0) +    
        # xlim(0,1) + ylim(min(df[,2]),max(df[,2])) + Reminant of when we didn't use log scale and had histograms
        scale_x_continuous(breaks=c(x_steps), trans="log10", labels=fancy_scientific) +
        scale_y_continuous(breaks=c(x_steps), trans="log10", labels=fancy_scientific)
        
      
      
      # Fix scales
      gB <- ggplotGrob(main)
      gA <- ggplotGrob(plot_top)
      gC <- ggplotGrob(empty)
      gD <- ggplotGrob(plot_right)
      maxWidth = grid::unit.pmax(gA$widths[2:5], gB$widths[2:5])
      maxHeight = grid::unit.pmax(gB$heights[2:5], gD$heights[2:5])
      gA$widths[2:5] <- as.list(maxWidth)
      gB$widths[2:5] <- as.list(maxWidth)
      gB$heights[2:5] <- as.list(maxHeight)
      gD$heights[2:5] <- as.list(maxHeight)
      
      # Plot
      
      
      
      
      
      
      
      #########################
      # Plot correlation graphs
      #########################
      
      # Construct data
      COMBINED <- rbind(SUBSET_7, SUBSET_392)
      patients <- unique(sapply(rownames(COMBINED),function(x) {return(strsplit(x,'-')[[1]][1])}))
      protocols <- sapply(rownames(COMBINED),function(x) {return(strsplit(x,'-')[[1]][2])})
      days <- sapply(rownames(COMBINED),function(x) {return(strsplit(x,'-')[[1]][3])})
      both <- paste(protocols, days, sep='-')
      both_u <- unique(both)
      both_u7 <-grep('-7', both_u, value=T)
      both_u392 <-grep('-392', both_u, value=T)
      
      # Loop over protocols
      COR <- NULL
      for (d in c(7)){ #for (d in c(7, 392)){
        if(d == 7) {
          both_U <- both_u7
        } else {
          both_U <- both_u392
        }
        for (i in c(1:length(both_U))) {
          for (j in c(i+1:length(both_U))){
            for (patient in patients) {
              x <- COMBINED[grepl(paste(patient,both_U[i], sep='-'), rownames(COMBINED)),]
              y <- COMBINED[grepl(paste(patient,both_U[j], sep='-'), rownames(COMBINED)),]
              p1 <- strsplit(both_U[i],'-')[[1]][1]
              p2 <- strsplit(both_U[j],'-')[[1]][1]
              if(dim(x)[1] > 0 & dim(y)[1] > 0) {
                p1 <- gsub('11', 'Frozen', p1)
                p1 <- gsub('12', 'RNALater (RT)', p1)
                p1 <- gsub('13', 'RNALater (4 C)', p1)
                p2 <- gsub('11', 'Frozen', p2)
                p2 <- gsub('12', 'RNALater (RT)', p2)
                p2 <- gsub('13', 'RNALater (4 C)', p2)
                
                COR <- rbind(COR, c(paste(' ',p1,'vs\n', p2), d, patient, cor(as.numeric(x),as.numeric(y),method = "spearman")))
              }
            }
          }
        }
      }
      
      # Loop over days
      for (i in c(11,13)) {
        for (patient in patients) {
          x <- COMBINED[grepl(paste(patient,i,7, sep='-'), rownames(COMBINED)),]
          y <- COMBINED[grepl(paste(patient,i,392, sep='-'), rownames(COMBINED)),]
          if(dim(x)[1] > 0 & dim(y)[1] > 0) {
            COR <- rbind(COR, c(paste('DAY 7 vs 392'), '5', patient, cor(as.numeric(x),as.numeric(y),method = "spearman")))
          }
        }
      }
      COR <- data.frame(COR)
      colnames(COR) <- c('protocol', 'day', 'patient', 'value')
      COR$value <- as.numeric(as.vector(COR$value))
      COR$f <- factor(rep(type,dim(COR),dim(COR)[1]))
      COR$day <- factor(COR$day, levels=c(7, 392, 5))
      
      # Create funciton for median line
      f <- function(x, height) {
        ans <- median(x)
        data.frame(ymin = ans-height/2, ymax = ans+height/2, y = ans)
      }
      
      # save plot
      plot2 <- ggplot(COR, aes(factor(protocol), as.numeric(value))) + geom_jitter(size=6, position = position_jitter(width = 0.1), aes(color=factor(COR$day))) + 
        stat_summary(fun.data = f, geom = "crossbar", height = 0.005,
                     colour = NA, fill = "black", width = 0.5, alpha = 1)+facet_grid(.~f) + theme_bw() +
        theme(legend.position="none") + 
        theme(axis.text=element_text(size=18),
              axis.title=element_text(size=18),
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank()       
        ) +
        theme(strip.text.x = element_text(size = 20, face="bold", angle = 0)) +
        xlab('') + ylab('Rank correlation within subjects\n') +
        scale_fill_manual(values = colors) + scale_colour_manual(values = colors_plot2) +
        ylim(0.5, 1.01)
      
      
      ###################
      # Finally plot both
      ###################
      # with histograms, doesn't work properly yet with log scales
      #grid.arrange(plot2,
      #             arrangeGrob(gA, gC,gB, gD, ncol=2, nrow=2, widths=c(6, 1), heights=c(1, 6)),
      #             nrow=2, heights=c(0.5,1)
      grid.arrange(plot2, main, nrow=2, heights=c(0.5,1))
      if (PDF != '') {
        dev.off()
      }
      
      ##################
      # Print some stats
      ##################
      pr <- df[df$p_adjusted <= 0.05 & df$q_ratios > 1,]
      write.csv(pr, file=paste(type,TRANSFORMATION,FILTER_CUTOFF,FILTER_TYPE,FILTER_MIN_SAMPLES,TEST,'.txt', sep='.'))
      FILTER_CUTOFF <- 0.0001
      
      save.image(file = paste(type,TRANSFORMATION,FILTER_CUTOFF,FILTER_TYPE,FILTER_MIN_SAMPLES,TEST,'.RData', sep='.'))
    }
  }
}

