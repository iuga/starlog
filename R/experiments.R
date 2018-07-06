#
# This package contains simple methods to create a starlog (from StarTrek).
# The Starlog is a recording entered into a starship computer record for posterity.
# The log was used to inform the captain's superiors of what was happening on a
# mission and to record historical facts for future generations.
#
# In other words, this library is going to help you to
# keep track the experiments you run, the context and its results.
#
library(stargazer)
library(data.table)

#'
#' Create an experiment entry log
#'
#' Create a new text file in the selected {folder} with all the experiment
#' information passed refered to an experiment, the context and the result.
#'
#' All the information should be passed a ... parameters.
#' Empty characters are considered new lines.
#'
#' Supports: characters, numbers, data.frames, lists, vectors, etc.
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
log_experiment <- function(..., description='', tag='', version='1.0', number=1, folder='./logs/'){
    # Star date
    stardate <- as.character(Sys.time())

    # Folder must end with / and exist
    create_folders(folder)

    # Open the file
    if(tag == ''){
        logfile <- paste0(folder, "exp.", version, ".", number, ".txt")
    } else {
        logfile <- paste0(folder, "exp.", tag, ".", version, ".", number, ".txt")
    }

    # If the file exist fail with an error.
    # We don't want to override a previous experiment information
    if(file.exists(logfile)){
        stop(paste("File", logfile, "already exists. Manually delete the file and try again or you can loose information."))
    }

    # Write Summary
    cat(paste0("\nExperiment #", number, " (v:",version, ")", collapse=''), sep='\n', append=TRUE, file=logfile)
    cat("", append=TRUE, file=logfile, sep='\n')

    # Write Description
    cat("Description:", append=TRUE, file=logfile, sep='\n')
    cat(description, append=TRUE, file=logfile, sep='\n')
    cat("", append=TRUE, file=logfile, sep='\n')

    # Experiment execution date and time
    cat("Execution Date and Time: ", sep='\n', append=TRUE, file=logfile)
    cat(stardate, sep='\n', append=TRUE, file=logfile)
    cat("", append=TRUE, file=logfile, sep='\n')

    # Write all information
    input_list <- list(...)
    lapply(X=input_list, function(x){
        if(is.data.frame(x) | is.data.table(x)){
            s = stargazer(x, type = 'text', summary = FALSE, digits=5)
            cat(paste(s, "\n"), file=logfile, append=TRUE)
        } else if(x=='' || (typeof(x)=='character' && length(x)==0)){
            cat("", append=TRUE, file=logfile, sep='\n')
        } else {
            cat(x, file = logfile, append = TRUE, sep='\n')
        }
    })

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
    logfile <- paste0(folder, "capitan.log")
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
