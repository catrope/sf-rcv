# sf-rcv
Scripts I threw together to analyze SF's ranked-choice voting data files

# Most recent report
[2018-06-08 report](20180608_report.md)

# Usage

```
$ sudo apt install make sqlite3 jq
$ npm install
$ make
```

This will generate a `.md` file with a report, as well as a `.sqlite3` file
with a database containing all ballots.
