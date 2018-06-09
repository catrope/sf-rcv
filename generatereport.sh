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
