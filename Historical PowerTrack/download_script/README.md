*Overview*

Easily download or re-download files from a Historical Snapshot Job.

*Features*

* Interactive command prompt.
* Ability to download or re-download files.
* Ability to delete downloaded files.

*Requirements*

* A previously finished Historical Snapshot Job.

*Setup*

This project uses the following folder structure:

* downloads - Where all files are downloaded to.
* input - Where the results.csv is located (as downloaded from Historical Snapshot Job).
* scripts - Bash scripts and support files used by this program.

*Usage*

Type the following from the command line to install:

  ./run.sh

Follow the command prompt for additional details. The options prompt can be bypassed by passing the desired option
as an argument to the run.sh script if necessary.

*Troubleshooting*

If a file failed to download or is corrupt, simply delete the corrupt file from the downloads folder
and re-run the run.sh script again. The run.sh script will only download files that don't exist.
