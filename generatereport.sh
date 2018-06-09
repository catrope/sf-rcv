#! /bin/bash

cat <<MD
# Number of votes by district

Supervisorial district | Votes in mayor's race
---------------------- | ---------------------
MD
sqlite3 $1 <<SQL
SELECT district, COUNT(*)
FROM ballots
WHERE contest='Mayor'
GROUP BY district;
SQL

cat <<MD



# First/second/third choices per candidate
The number of first-choice, second-choice and third-choice received by each candidate overall.

Candidate | First-choice votes | Second-choice votes | Third-choice votes
--------- | ------------------ | ------------------- | ------------------
MD
sqlite3 $1 <<SQL
SELECT
    candidate,
    (SELECT COUNT(*) FROM ballots WHERE first=candidate) AS firstChoice,
    (SELECT COUNT(*) FROM ballots WHERE second=candidate),
    (SELECT COUNT(*) FROM ballots WHERE third=candidate)
FROM (
    SELECT DISTINCT first AS candidate FROM ballots WHERE contest='Mayor'
)
ORDER BY firstChoice DESC;
SQL

cat <<MD


# First choice Breed: second choices
The distribution of second choices of the voters whose first choice was London Breed.

Candidate | Second-choice votes
--------- | -------------------
MD

sqlite3 $1 <<SQL
SELECT second, COUNT(*) AS votes
FROM ballots
WHERE contest='Mayor'
AND first='London Breed'
GROUP BY second
ORDER BY votes DESC;
SQL

cat <<MD


# First choice Leno: second choices
The distribution of second choices of the voters whose first choice was Mark Leno.

Candidate | Second-choice votes
--------- | -------------------
MD

sqlite3 $1 <<SQL
SELECT second, COUNT(*) AS votes
FROM ballots
WHERE contest='Mayor'
AND first='Mark Leno'
GROUP BY second
ORDER BY votes DESC;
SQL

KIMDATA=$(cat $2 | jq '.Mayor.rounds[6].sources | map_values(.["Jane Kim"]) | to_entries | map(select(.value != null)) | sort_by(.value) | reverse | from_entries')
cat <<MD


# First non-blank choice Kim: last round distribution
Where ballots whose first non-blank choice was Jane Kim end up in the final round.

Candidate | Kim-originating votes
--------- | ---------------------
MD
IFS=$'\n'
for candidate in $(echo $KIMDATA | jq -r 'keys_unsorted | .[]');
do
    echo "$candidate|$(echo $KIMDATA | jq -r .[\"$candidate\"])"
done


cat <<MD


# Mayoral first choice by D8 first choice
First choice breakdown of voters who voted in both the Mayor's race and the District 8 Supervisor race.

 | Rafael Mandelman | Jeff Sheehy | Lawrence "Stark" Dagesse | (blank) | (overvote)
-|------------------|-------------|--------------------------|---------|-----------
MD

sqlite3 $1 <<SQL
SELECT mandelman.first, mandelman.count, sheehy.count, dagesse.count, blank.count, overvote.count
FROM (SELECT m.first AS first, COUNT(*) AS count
    FROM ballots AS m JOIN ballots AS s ON m.id=s.id
    WHERE m.contest='Mayor' AND s.first='Rafael Mandelman'
    GROUP BY m.first) AS mandelman
JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='Jeff Sheehy'
    GROUP BY m2.first) AS sheehy ON sheehy.first=mandelman.first
JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='Lawrence ''''Stark'''' Dagesse'
    GROUP BY m2.first) AS dagesse ON dagesse.first=mandelman.first
JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='(blank)'
    GROUP BY m2.first) AS blank ON blank.first=mandelman.first
JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='(overvote)'
    GROUP BY m2.first) AS overvote ON overvote.first=mandelman.first
ORDER BY mandelman.count DESC;
SQL
