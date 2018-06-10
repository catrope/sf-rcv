# sf-rcv
Scripts I threw together to analyze SF's ranked-choice voting data files

# Most recent report
[2018-06-09 report](20180609_report.md)

# Previous reports
[2018-06-08 report](20180608_report.md)


# Usage

```
$ npm install
$ make
```

This will generate a `.md` file with a report, as well as a `.sqlite3` file
with a database containing all ballots.

# Dependencies

The following command line programs are assumed to be present:
- sqlite3
- jq
- make
- awk
