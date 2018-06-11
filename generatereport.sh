#! /bin/bash

cat <<MD
# First/second/third choices per candidate
The number of first-choice, second-choice and third-choice received by each candidate overall.

Candidate | First-choice votes | Second-choice votes | Third-choice votes
--------- | ------------------ | ------------------- | ------------------
MD
sqlite3 $1 <<SQL
SELECT candidate,
    firstChoices||' ('||ROUND(100.0*firstChoices/total, 2)||'%)',
    secondChoices||' ('||ROUND(100.0*secondChoices/total, 2)||'%)',
    thirdChoices||' ('||ROUND(100.0*thirdChoices/total, 2)||'%)'
FROM (
    SELECT
        candidate,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate) AS firstChoices,
        (SELECT COUNT(*) FROM ballots WHERE second=candidate) AS secondChoices,
        (SELECT COUNT(*) FROM ballots WHERE third=candidate) AS thirdChoices,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor') AS total
    FROM (
        SELECT DISTINCT first AS candidate FROM ballots WHERE contest='Mayor'
    )
)
ORDER BY firstChoices DESC
SQL

cat <<MD

# Number of votes by district

Supervisorial district | Votes in mayor's race
---------------------- | ---------------------
MD
sqlite3 $1 <<SQL
SELECT district, votes||' ('||percentage||'%)'
FROM (
    SELECT district, COUNT(*) AS votes,
        ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM ballots WHERE contest='Mayor'), 2) AS percentage
    FROM ballots
    WHERE contest='Mayor'
    GROUP BY district
    ORDER BY district
);
SQL

cat <<MD

# First choice votes by district

Candidate | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | D11
--------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | --- | ---
MD
sqlite3 $1 <<SQL
SELECT candidate,
    d1||' ('||ROUND(100.0*d1/d1total, 2)||'%)',
    d2||' ('||ROUND(100.0*d2/d2total, 2)||'%)',
    d3||' ('||ROUND(100.0*d3/d3total, 2)||'%)',
    d4||' ('||ROUND(100.0*d4/d4total, 2)||'%)',
    d5||' ('||ROUND(100.0*d5/d5total, 2)||'%)',
    d6||' ('||ROUND(100.0*d6/d6total, 2)||'%)',
    d7||' ('||ROUND(100.0*d7/d7total, 2)||'%)',
    d8||' ('||ROUND(100.0*d8/d8total, 2)||'%)',
    d9||' ('||ROUND(100.0*d9/d9total, 2)||'%)',
    d10||' ('||ROUND(100.0*d10/d10total, 2)||'%)',
    d11||' ('||ROUND(100.0*d11/d11total, 2)||'%)'
FROM (
    SELECT candidate,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=1) as d1,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=2) as d2,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=3) as d3,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=4) as d4,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=5) as d5,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=6) as d6,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=7) as d7,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=8) as d8,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=9) as d9,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=10) as d10,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=11) as d11
        FROM (
            SELECT DISTINCT first AS candidate FROM ballots WHERE contest='Mayor'
        )
    )
JOIN (
    SELECT
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=1) as d1total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=2) as d2total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=3) as d3total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=4) as d4total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=5) as d5total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=6) as d6total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=7) as d7total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=8) as d8total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=9) as d9total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=10) as d10total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=11) as d11total
)
ORDER BY d1 DESC;
SQL

cat <<MD


# First choice Breed: second choices
The distribution of second choices of the voters whose first choice was London Breed.

Candidate | Second-choice votes
--------- | -------------------
MD

sqlite3 $1 <<SQL
SELECT second, votes||' ('||percentage||'%)'
FROM (
    SELECT second, COUNT(*) AS votes,
        ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND first='London Breed'), 2) AS percentage
    FROM ballots
    WHERE contest='Mayor'
    AND first='London Breed'
    GROUP BY second
    ORDER BY votes DESC
)
SQL

cat <<MD


# First choice Leno: second choices
The distribution of second choices of the voters whose first choice was Mark Leno.

Candidate | Second-choice votes
--------- | -------------------
MD

sqlite3 $1 <<SQL
SELECT second, votes||' ('||percentage||'%)'
FROM (
    SELECT second, COUNT(*) AS votes,
        ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND first='Mark Leno'), 2) AS percentage
    FROM ballots
    WHERE contest='Mayor'
    AND first='Mark Leno'
    GROUP BY second
    ORDER BY votes DESC
)
SQL

KIMDATA=$(cat $2 | jq '.Mayor.rounds[6].sources | map_values(.["Jane Kim"]) | to_entries | map(select(.value != null)) | sort_by(.value) | reverse | from_entries')
KIMTOTAL=$(echo $KIMDATA | jq add)
cat <<MD


# First non-blank choice Kim: last round distribution
Where ballots whose first non-blank choice was Jane Kim end up in the final round.

Candidate | Kim-originating votes
--------- | ---------------------
MD
IFS=$'\n'
for candidate in $(echo $KIMDATA | jq -r 'keys_unsorted | .[]');
do
    CANDIDATEVOTES=$(echo $KIMDATA | jq -r .[\"$candidate\"])
    CANDIDATEPERCENT=$(awk -v candidate=$CANDIDATEVOTES -v total=$KIMTOTAL 'BEGIN{printf "%.2f\n", 100*candidate/total}')
    echo "$candidate|$CANDIDATEVOTES ($CANDIDATEPERCENT%)"
done


cat <<MD


# Mayoral first choice by D8 first choice
First choice breakdown of voters who voted in both the Mayor's race and the District 8 Supervisor race.

(first choice) | Rafael Mandelman | Jeff Sheehy | Lawrence "Stark" Dagesse | (blank) | (overvote)
-- | ---------------- | ----------- | ------------------------ | ------- | ----------
MD

sqlite3 $1 <<SQL
SELECT mandelman.first,
    COALESCE(mandelman.count, 0),
    COALESCE(sheehy.count, 0),
    COALESCE(dagesse.count, 0),
    COALESCE(blank.count, 0),
    COALESCE(overvote.count, 0)
FROM (SELECT m.first AS first, COUNT(*) AS count
    FROM ballots AS m JOIN ballots AS s ON m.id=s.id
    WHERE m.contest='Mayor' AND s.first='Rafael Mandelman'
    GROUP BY m.first) AS mandelman
LEFT JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='Jeff Sheehy'
    GROUP BY m2.first) AS sheehy ON sheehy.first=mandelman.first
LEFT JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='Lawrence ''''Stark'''' Dagesse'
    GROUP BY m2.first) AS dagesse ON dagesse.first=mandelman.first
LEFT JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='(blank)'
    GROUP BY m2.first) AS blank ON blank.first=mandelman.first
LEFT JOIN (SELECT m2.first AS first, COUNT(*) AS count
    FROM ballots AS m2 JOIN ballots AS s2 ON m2.id=s2.id
    WHERE m2.contest='Mayor' AND s2.first='(overvote)'
    GROUP BY m2.first) AS overvote ON overvote.first=mandelman.first
ORDER BY mandelman.count DESC;
SQL
