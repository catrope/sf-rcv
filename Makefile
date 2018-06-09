today: 20180608_report.md

# Prevent make from deleting any of the intermediate files
.SECONDARY:

%_ballotimage.txt:
	wget http://www.sfelections.org/results/20180605/data/$(@:_ballotimage.txt=)/$@

%_masterlookup.txt:
	wget http://www.sfelections.org/results/20180605/data/$(@:_masterlookup.txt=)/$@

%.json: %_ballotimage.txt %_masterlookup.txt
	node parse.js $(@:.json=) > $@

%.sqlite3: %.json
	node tosqlite.js $<

%_report.md: %.sqlite3
	./generatereport.sh $< > $@