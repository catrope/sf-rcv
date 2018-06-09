today: 20180608_report.md

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

%_report.md: %.sqlite3 %_analysis.json
	./generatereport.sh $^ > $@
