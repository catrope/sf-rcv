# sf-rcv
Scripts I threw together to analyze SF's ranked-choice voting data files

# Today's reports
- [2018-06-13 full report](20180613_report.md)
- [2018-06-13 newly added votes report](20180613_deltareport.md)

# Previous reports
- 2018-06-12 ([full report](20180612_report.md), [newly added votes](20180612_deltareport.md))
- 2018-06-11 ([full report](20180611_report.md), [newly added votes](20180611_deltareport.md))
- 2018-06-10 ([full report](20180610_report.md), [newly added votes](20180610_deltareport.md))
- 2018-06-09 ([full report](20180609_report.md), [newly added votes](20180609_deltareport.md))
- 2018-06-08 ([full report](20180608_report.md), [newly added votes](20180608_deltareport.md))
- 2018-06-07 ([full report](20180607_report.md), [newly added votes](20180607_deltareport.md))
- 2018-06-06 ([full report](20180606_report.md), [newly added votes](20180606_deltareport.md))
- 2018-06-05 second report (early mail and e-day precinct votes) ([full report](20180605_4_report.md), [newly added votes](20180605_4_deltareport.md))
- 2018-06-05 first report (early mail votes only) ([full report](20180605_1_report.md))

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
