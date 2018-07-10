today: 20180627_report.md 20180627_deltareport.md

all: 20180627_report.md 20180627_deltareport.md \
	20180621_report.md 20180621_deltareport.md \
	20180618_report.md 20180618_deltareport.md \
	20180615_report.md 20180615_deltareport.md \
	20180614_report.md 20180614_deltareport.md \
	20180613_report.md 20180613_deltareport.md \
	20180612_report.md 20180612_deltareport.md \
	20180611_report.md 20180611_deltareport.md \
	20180610_report.md 20180610_deltareport.md \
	20180609_report.md 20180609_deltareport.md \
	20180608_report.md 20180608_deltareport.md \
	20180607_report.md 20180607_deltareport.md \
	20180606_report.md 20180606_deltareport.md \
	20180605_4_report.md 20180605_4_deltareport.md \
	20180605_1_report.md

# Prevent make from deleting any of the intermediate files
.SECONDARY:

%_ballotimage.txt:
	wget http://www.sfelections.org/results/20180605/data/$(@:_ballotimage.txt=)/$@

%_masterlookup.txt:
	wget http://www.sfelections.org/results/20180605/data/$(@:_masterlookup.txt=)/$@

%_data.json: %_ballotimage.txt %_masterlookup.txt
	node parse.js $(@:_data.json=) > $@

%.sqlite3: %_data.json
	node tosqlite.js $< $@

%_analysis.json: %_data.json
	node analyze.js $< > $@

%_report.md: %.sqlite3
	./generatereport.sh $^ > $@

20180615_deltareport.md: 20180615.sqlite3 20180614.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180614.sqlite3` > $@

20180614_deltareport.md: 20180614.sqlite3 20180613.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180613.sqlite3` > $@

20180613_deltareport.md: 20180613.sqlite3 20180612.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180612.sqlite3` > $@

20180612_deltareport.md: 20180612.sqlite3 20180611.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180611.sqlite3` > $@

20180611_deltareport.md: 20180611.sqlite3 20180610.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180610.sqlite3` > $@

20180610_deltareport.md: 20180610.sqlite3 20180609.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180609.sqlite3` > $@

20180609_deltareport.md: 20180609.sqlite3 20180608.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180608.sqlite3` > $@

20180608_deltareport.md: 20180608.sqlite3 20180607.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180607.sqlite3` > $@

20180607_deltareport.md: 20180607.sqlite3 20180606.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180606.sqlite3` > $@

20180606_deltareport.md: 20180606.sqlite3 20180605_4.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180605_4.sqlite3` > $@

20180605_4_deltareport.md: 20180605_4.sqlite3 20180605_1.sqlite3
	./generatereport.sh $< `echo 'SELECT MAX(id) FROM ballots' | sqlite3 20180605_1.sqlite3` > $@
