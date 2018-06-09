# sf-rcv
Scripts I threw together to analyze SF's ranked-choice voting data files

# Usage

```
$ npm install
$ make
$ sqlite3 20180608.sqlite3    # Name of the .sqlite file may vary
sqlite> select count(*) from ballots;
211344
```
