# bash-toolkit
This repo is a set of basic bash script using in the daily work of devops:
backup, log analysis, system reports.

Code ```exit 0``` means that command has succeeded.
Code ```exit 1``` means that command has failed.

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

Logs are stored in /logs directory. 
Info and errors logs are stored separately in backup_*INFO.log
and backup_*_ERROR.log

## log

This command is used to search by pattern, showing the n matches. 

```
./toolkit.sh log [number-matches] [pattern] [path-to-log]
```
e.g.
```
./toolkit.sh log 4 "Freezing" /var/log/syslog
```

## sysinfo

This command is used to show basic system information represented in a table

```
./toolkit.sh sysinfo
```

## menu 

This command is used to see which the option are available. 

To run this command use:

```
./toolkit.sh menu

```

After running this command you can see in menu_*_INFO.log the following prompt:

```
Usage: ./toolkit.sh {backup|log|sysinfo}
```


