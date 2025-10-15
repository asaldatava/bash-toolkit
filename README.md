# bash-toolkit
This repo is a set of basic bash script using in the daily work of devops:
backup, log analysis, system reports. 

The command from cli looks like:

```
./toolkit.sh [function] [arguments] 
```

[function] is get from functions.sh

## backup
This command is used to create backup with logs:

```
./toolkit.sh backup [path-to-source-file] [path-to-destination-dir] [number-of-backups]
```
e.g. 
```
./toolkit.sh backup ./sources/fileTobackup.txt ./backups 5
```
Code ```exit 0``` means that command has succeeded.
Code ```exit 1``` means that command has failed
Logs are stored in /logs directory. 
Info and errors logs are stored separately in backup_*INFO.log
and backup_*_ERROR.log