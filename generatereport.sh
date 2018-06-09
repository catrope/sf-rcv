#! /bin/bash

cat <<MD
# First/second/third choices per candidate
The number of first-choice, second-choice and third-choice received by each candidate overall.

Candidate | First-choice votes | Second-choice votes | Third-choice votes
--------- | ------------------ | ------------------- | ------------------
MD
sqlite3 $@ <<SQL
SELECT
    candidate,
    (SELECT COUNT(*) FROM ballots WHERE first=candidate),
    (SELECT COUNT(*) FROM ballots WHERE second=candidate),
    (SELECT COUNT(*) FROM ballots WHERE third=candidate)
FROM (
    SELECT DISTINCT first AS candidate FROM ballots WHERE contest='Mayor'
);
SQL

cat <<MD


# First choice Breed: second choices
The distribution of second choices of the voters whose first choice was London Breed.

Candidate | Second-choice votes
--------- | -------------------
MD

sqlite3 $@ <<SQL
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

sqlite3 $@ <<SQL
SELECT second, COUNT(*) AS votes
FROM ballots
WHERE contest='Mayor'
AND first='Mark Leno'
GROUP BY second
ORDER BY votes DESC;
SQL
