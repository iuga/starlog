#
# This package contains simple methods to create a starlog (from StarTrek).
# The Starlog is a recording entered into a starship computer record for posterity.
# The log was used to inform the captain's superiors of what was happening on a
# mission and to record historical facts for future generations.
#
# In other words, this library is going to help you to
# keep track the experiments you run, the context and its results.
#

#'
#' Create an experiment entry log
#'
#' Create a new text file in the selected {folder} with all the experiment
#' information passed refered to an experiment, the context and the result.
#'
#' All the information should be passed a ... parameters.
#' Empty characters are considered new lines.
#'
#' Folder Structure:
#'  ./{folder}
#'      ./capitans.log
#'      ./{version}
#'           ./exp.{tag}.{version}.{number}.txt
#'
#' Supports: characters, numbers, data.frames, lists, vectors, ggplots.
#'
#' @param ... all the objects and information you want to log. We recommend a ("title", value, "") format.
#' @param description containing the main information of you experiment. E.g: Testing the max_date new feature
#' @param tag an optional tag to separate and organize your logs.
#' @param version a character with the main version of your project. E.g: "1.3" == v1.3 or just "1"
#' @param number of the experiment. E.g: 4 == "v1.3.4"
#' @param folder as character to store the logs
#'
#' @seealso \code{\link{capitan_log}}
#'
#' @examples
#' log_experiment(
#'     # Entry log information:
#'     description = "First experiment using XGBoost witout categorical features",
#'     tag = 'ml', version='1.0', number = 1,
#'     # Log all the needed information:
#'     "Final AUC:", 0.789, ""
#' )
#'
log_experiment <- function(..., description='', tag='', version='1.0', number=1, folder='./logs'){
    # Star date
    stardate <- as.character(Sys.time())

    # Folder must end with / and exist
    vfolder <- file.path(folder, version)
    create_folders(vfolder)

    # Open the file
    if(tag == ''){
        logfile <- file.path(vfolder, paste0("exp.", version, ".", number, ".txt"))
    } else {
        logfile <- file.path(vfolder, paste0("exp.", tag, ".", version, ".", number, ".txt"))
    }

    # If the file exist fail with an error.
    # We don't want to override a previous experiment information
    if(file.exists(logfile)){
        stop(paste("File", logfile, "already exists. Manually delete the file and try again or you can loose information."))
    }

    # Write Summary
    if(tag == ''){
        cat(paste0("\nExperiment #", number, " (v:",version, ")", collapse=''), sep='\n', append=TRUE, file=logfile)
    } else {
        cat(paste0("\nExperiment #", number, " (v:",version, "-", tag,")", collapse=''), sep='\n', append=TRUE, file=logfile)
    }
    # Experiment execution date and time
    cat("StarDate: ", append=TRUE, file=logfile)
    cat(stardate, sep='\n', append=TRUE, file=logfile)
    cat("", append=TRUE, file=logfile, sep='\n')

    # Write Description
    cat("Capitan's log:", append=TRUE, file=logfile, sep='\n')
    cat(description, append=TRUE, file=logfile, sep='\n')
    cat("", append=TRUE, file=logfile, sep='\n')

    # Number of objects to export
    number_exports <- 1

    # Write all information
    input_list <- list(...)
    for(x in input_list){
        if(is.data.frame(x) | data.table::is.data.table(x)){
            # Data Frames and Data Tables
            s = stargazer::stargazer(x, type = 'text', summary = FALSE, digits=5)
            cat(paste(s, "\n"), file=logfile, append=TRUE)
        } else if(x=='' || (typeof(x)=='character' && length(x)==0)){
            # Text
            cat("", append=TRUE, file=logfile, sep='\n')
        } else if(ggplot2::is.ggplot(x)){
            # GGplot / Patchwork
            if(tag == ''){
                plot_filename <- file.path(vfolder, paste0("exp.", version, ".", number, "-", letters[number_exports], ".png"))
            } else {
                plot_filename <- file.path(vfolder, paste0("exp.", tag, ".", version, ".", number, "-", letters[number_exports], ".png"))
            }
            if(file.exists(plot_filename)){
                stop(paste("Plot file", plot_filename, "already exists. Manually delete the file and try again or you can loose information."))
            }
            ggsave(filename = plot_filename, plot=x)
            cat(plot_filename, append=TRUE, file=logfile, sep='\n')
            number_exports <- number_exports + 1
        } else {
            # New lines
            cat(x, file = logfile, append = TRUE, sep='\n')
        }
    }

    # If everything was successfull, write an entry in the capitans log:
    capitan_log(stardate=stardate, description=description, version=version, number=number, folder=folder)
}

#'
#' Append the entry in the main capitan's log.
#'
#' "Private method" used to create and append the main capitans log containing the:
#' Complete version, Stardate and Description
#'
#' @param stardate is the experiment execution date. Default: as.character(Sys.time())
#' @param description containing the main information of you experiment. E.g: Testing the max_date new feature
#' @param version a character with the main version of your project. E.g: "1.3" == v1.3 or just "1"
#' @param number of the experiment. E.g: 4 == "v1.3.4"
#' @param folder as character to store the logs
#'
#' @examples
#' capitan_log(
#'     stardate = as.character(Sys.time()),
#'     description = "First experiment using XGBoost witout categorical features",
#'     tag = 'ml', version='1.0', number = 1
#' )
#'
capitan_log <- function(stardate=as.character(Sys.time()), description='', version='1.0', number=1, folder='./logs/'){
    # Folder must end with / and exist
    create_folders(folder)
    # Capitan's log filename
    logfile <- file.path(folder, "capitan.log")
    # Append the summary
    cat(paste0("\n• Experiment v:", version, ".", number, " - Stardate: ", stardate, collapse=''), sep='\n', append=TRUE, file=logfile)
    cat(paste0("\t", description), append=TRUE, file=logfile, sep='\n')
}

#'
#' Create the folder recursivelly, if exists
#'
#' @param folder name as character
#'
create_folders <- function(folder){
    # Folder must end with the /
    if(!endsWith(folder, '/')){
        folder <- paste0(folder, '/')
    }
    # If the folder does not exist, create it:
    dir.create(folder, showWarnings = F, recursive = T)
}
