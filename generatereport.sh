#! /bin/bash
DELTACOND="1=1"
MSDELTACOND="1=1"
if [ "x$2" != "x" ]
then
    DELTACOND="id > $2"
    MSDELTACOND="m.id > $2 AND s.id > $2"
fi

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
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND $DELTACOND) AS firstChoices,
        (SELECT COUNT(*) FROM ballots WHERE second=candidate AND $DELTACOND) AS secondChoices,
        (SELECT COUNT(*) FROM ballots WHERE third=candidate AND $DELTACOND) AS thirdChoices,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND $DELTACOND) AS total
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
        ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND $DELTACOND), 2) AS percentage
    FROM ballots
    WHERE contest='Mayor' AND $DELTACOND
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
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=1 AND $DELTACOND) as d1,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=2 AND $DELTACOND) as d2,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=3 AND $DELTACOND) as d3,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=4 AND $DELTACOND) as d4,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=5 AND $DELTACOND) as d5,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=6 AND $DELTACOND) as d6,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=7 AND $DELTACOND) as d7,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=8 AND $DELTACOND) as d8,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=9 AND $DELTACOND) as d9,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=10 AND $DELTACOND) as d10,
        (SELECT COUNT(*) FROM ballots WHERE first=candidate AND district=11 AND $DELTACOND) as d11
        FROM (
            SELECT DISTINCT first AS candidate FROM ballots WHERE contest='Mayor'
        )
    )
JOIN (
    SELECT
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=1 AND $DELTACOND) as d1total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=2 AND $DELTACOND) as d2total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=3 AND $DELTACOND) as d3total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=4 AND $DELTACOND) as d4total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=5 AND $DELTACOND) as d5total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=6 AND $DELTACOND) as d6total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=7 AND $DELTACOND) as d7total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=8 AND $DELTACOND) as d8total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=9 AND $DELTACOND) as d9total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=10 AND $DELTACOND) as d10total,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND district=11 AND $DELTACOND) as d11total
)
ORDER BY d1 DESC;
SQL

cat <<MD

# Round of three votes by district
District | Breed | Leno | Kim
-------- | ----- | ---- | ---
MD
sqlite3 $1 <<SQL
SELECT district,
    breed||' ('||ROUND(100.0*breed/total, 2)||'%)',
    leno||' ('||ROUND(100.0*leno/total, 2)||'%)',
    kim||' ('||ROUND(100.0*kim/total, 2)||'%)'
FROM (
    SELECT b.district AS district, b.votes AS breed, l.votes AS leno, k.votes AS kim,
        (SELECT COUNT(*) FROM ballots WHERE district=b.district AND roundOf3 IN ('London Breed', 'Mark Leno', 'Jane Kim') AND $DELTACOND) AS total
    FROM
    (SELECT district, COUNT(*) AS votes FROM ballots WHERE roundOf3='London Breed' AND $DELTACOND GROUP BY district) AS b
    JOIN (SELECT district, COUNT(*) AS votes FROM ballots WHERE roundOf3='Mark Leno' AND $DELTACOND GROUP BY district) AS l ON l.district=b.district
    JOIN (SELECT district, COUNT(*) AS votes FROM ballots WHERE roundOf3='Jane Kim' AND $DELTACOND GROUP BY district) AS k ON k.district=b.district
)
ORDER BY district;
SQL

cat <<MD

# Last round votes by district
District | Breed | Leno
-------- | ----- | ----
MD
sqlite3 $1 <<SQL
SELECT district,
    breed||' ('||ROUND(100.0*breed/total, 2)||'%)',
    leno||' ('||ROUND(100.0*leno/total, 2)||'%)'
FROM (
    SELECT b.district AS district, b.votes AS breed, l.votes AS leno,
        (SELECT COUNT(*) FROM ballots WHERE district=b.district AND roundOf2 IN ('London Breed', 'Mark Leno') AND $DELTACOND) AS total
    FROM
    (SELECT district, COUNT(*) AS votes FROM ballots WHERE roundOf2='London Breed' AND $DELTACOND GROUP BY district) AS b
    JOIN (SELECT district, COUNT(*) AS votes FROM ballots WHERE roundOf2='Mark Leno' AND $DELTACOND GROUP BY district) AS l ON l.district=b.district
)
ORDER BY district;
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
        ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND first='London Breed' AND $DELTACOND), 2) AS percentage
    FROM ballots
    WHERE contest='Mayor'
    AND first='London Breed'
    AND $DELTACOND
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
        ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND first='Mark Leno' AND $DELTACOND), 2) AS percentage
    FROM ballots
    WHERE contest='Mayor'
    AND first='Mark Leno'
    AND $DELTACOND
    GROUP BY second
    ORDER BY votes DESC
)
SQL

cat <<MD

# Redistribution of Kim votes
Where Jane Kim's votes went after she was eliminated

Candidate | Votes gained
--------- | ------------
MD
sqlite3 $1 <<SQL
SELECT candidate,
    votes||'( '||ROUND(100.0*votes/total, 2)||'%)'
FROM (
    SELECT roundOf2 AS candidate, COUNT(*) AS votes,
        (SELECT COUNT(*) FROM ballots WHERE contest='Mayor' AND roundOf3='Jane Kim' AND $DELTACOND) AS total
    FROM ballots
    WHERE contest='Mayor'
    AND roundOf3='Jane Kim'
    AND $DELTACOND
    GROUP BY roundOf2
    ORDER BY votes DESC
);
SQL

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
    AND $MSDELTACOND
    GROUP BY m.first) AS mandelman
LEFT JOIN (SELECT m.first AS first, COUNT(*) AS count
    FROM ballots AS m JOIN ballots AS s ON m.id=s.id
    WHERE m.contest='Mayor' AND s.first='Jeff Sheehy'
    AND $MSDELTACOND
    GROUP BY m.first) AS sheehy ON sheehy.first=mandelman.first
LEFT JOIN (SELECT m.first AS first, COUNT(*) AS count
    FROM ballots AS m JOIN ballots AS s ON m.id=s.id
    WHERE m.contest='Mayor' AND s.first='Lawrence ''''Stark'''' Dagesse'
    AND $MSDELTACOND
    GROUP BY m.first) AS dagesse ON dagesse.first=mandelman.first
LEFT JOIN (SELECT m.first AS first, COUNT(*) AS count
    FROM ballots AS m JOIN ballots AS s ON m.id=s.id
    WHERE m.contest='Mayor' AND s.first='(blank)'
    AND $MSDELTACOND
    GROUP BY m.first) AS blank ON blank.first=mandelman.first
LEFT JOIN (SELECT m.first AS first, COUNT(*) AS count
    FROM ballots AS m JOIN ballots AS s ON m.id=s.id
    WHERE m.contest='Mayor' AND s.first='(overvote)'
    AND $MSDELTACOND
    GROUP BY m.first) AS overvote ON overvote.first=mandelman.first
ORDER BY mandelman.count DESC;
SQL
