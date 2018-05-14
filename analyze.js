const specialBuckets = [ 'undervote', 'overvote', 'exhausted' ];

/**
 * Create buckets for each candidate, and the special buckets.
 * @param {Object[]} ballots Ballots in the format generated by parse.js
 * @return {Object} Object mapping a bucket name (candidate name or special value) to an array of ballots
 */
function prepBuckets( ballots ) {
    let buckets = {};
    // Ensure all special buckets are defined
    for ( let specialBucket of specialBuckets ) {
        buckets[specialBucket] = [];
    }
    for ( let ballot of ballots ) {
        let i = 0, bucket;
        // Skip over undervotes
        while ( ballot.votes[i] === 'undervote' ) {
            i++;
        }
        // If we skipped everything, this is an undervote
        bucket = ballot.votes[i] || 'undervote';
        buckets[bucket] = buckets[bucket] || [];
        buckets[bucket].push( ballot );
    }
    return buckets;
}

/**
 * Redistribute ballots when a candidate is eliminated. Each ballot in the loser's bucket is moved
 * to the bucket of the highest-ranked non-eliminated candidate on that ballot, or to the exhausted
 * bucket if all chosen candidates are eliminated.
 *
 * @param {Object} buckets Buckets object as generated by prepBuckets(). WIll be modified.
 * @param {string} loser Name of the candidate whose ballots should be redistributed
 * @param {string[]} eliminated Names of the candidates who have already been eliminated
 */
function redistribute( buckets, loser, eliminated ) {
    for ( let ballot of buckets[loser] ) {
        let i = 0, newBucket;
        // Find the first vote that's not for an eliminated candidate (or an undervote)
        while ( eliminated.includes( ballot.votes[i] ) || ballot.votes[i] === loser || ballot.votes[i] === 'undervote' ) {
            i++;
        }
        // If we skipped everything, this ballot is exhausted
        newBucket = ballot.votes[i] || 'exhausted';
        // Move the ballot to the new bucket. We copy it here, and empty the loser's bucket at the end
        buckets[newBucket].push( ballot );
    }
    buckets[loser] = [];
}

/**
 * Find the non-eliminated candidate with the fewest votes.
 *
 * @param {Object} buckets Buckets object as generated by prepBuckets()
 * @param {string[]} eliminated Names of the candidates who have been eliminated
 * @return {string} Name of the losing candidate
 */
function losingCandidate( buckets, eliminated ) {
    let lowest = Infinity, loser;
    for ( let candidate in buckets ) {
        if ( specialBuckets.includes( candidate ) || eliminated.includes( candidate ) ) {
            continue;
        }
        if ( buckets[candidate].length < lowest ) {
            lowest = buckets[candidate].length;
            loser = candidate;
        }
    }
    return loser;
}

/**
 * Find the candidate with the most votes.
 *
 * @param {Object} buckets Buckets object as generated by prepBuckets()
 * @return {string} Name of the winning candidate
 */
function winningCandidate( buckets ) {
    let highest = -Infinity, winner;
    for ( let candidate in buckets ) {
        if ( specialBuckets.includes( candidate ) ) {
            continue;
        }
        if ( buckets[candidate].length > highest ) {
            highest = buckets[candidate].length;
            winner = candidate;
        }
    }
    return winner;
}

/**
 * Count the number of ballots in each bucket
 * @param {Object} buckets Buckets object as generated by prepBuckets()
 * @return {Object} Object mapping bucket names to numbers
 */
function bucketCounts( buckets ) {
    let counts = {};
    for ( let candidate in buckets ) {
        counts[candidate] = buckets[candidate].length;
    }
    return counts;
}

/**
 * Run the RCV elimination rounds for a contest
 * @param {Object[]} ballots Ballots in the format generated by parse.js
 * @return {Object[]} Object describing each round
 */
function runContest( ballots ) {
    let buckets = prepBuckets( ballots ),
        candidates = Object.keys( buckets ).filter( ( b ) => !specialBuckets.includes( b ) );
        rounds = [],
        eliminated = [];
    while ( candidates.length - eliminated.length > 2 ) {
        let roundCounts = bucketCounts( buckets ),
            loser = losingCandidate( buckets, eliminated );
        redistribute( buckets, loser, eliminated );
        eliminated.push( loser );
        rounds.push( { roundCounts, loser } );
    }
    rounds.push( { roundCounts: bucketCounts( buckets ), winner: winningCandidate( buckets ) } );
    return rounds;
}

/**
 * Count the number of votes for each candidate, and other statistics.
 *
 * @param {Object[]} ballots Ballots in the format generated by parse.js
 * @return {Object} Contest statistics
 * @return {number} return.total Total number of ballots
 * @return {number[]} return.choices Number of ballots with a 1st/2nd/3rd choice filled out
 * @return {Object} return.validChoices Object mapping a number (0-3) to the number of ballots
 *   with that number of valid choices. Choices below an overvote are invalid.
 * @return {number} return.duplicates Number of ballots with the same candidate chosen more than once
 * @return {Object} return.counts Object mapping a candidate name (or 'undervote'/'overvote') to an
 *   array with the number of 1st/2nd/3rd choice votes for that candidate.
 * @return {Object} return.breakdown Object mapping a candidate name to a breakdown of the second
 *   and third choices of the voters who chose that candidate as their first choice. Format:
 *   {
 *     CANDIDATE: {
 *       total: number, // number of first choice votes for CANDIDATE
 *       second: {
 *         CANDIDATE2: {
 *           total: number, // number of votes with 1) CANDIDATE, 2) CANDIDATE2
 *           third: {
 *             CANDIDATE3: number, // number of votes with 1) CANDIDATE, 2) CANDIDATE2, 3) CANDIDATE3
 *             ...
 *           }
 *         },
 *         ...
 *       }
 *     },
 *     ...
 *   }
 */
function getCounts( ballots ) {
    let total = 0, choices = [], validChoices = {}, duplicates = 0, counts = {}, breakdown = {};
    for ( let ballot of ballots ) {
        let numValid = 0, invalid = false, duplicate = false;
        for ( let rank = 0; rank < ballot.votes.length; rank++ ) {
            let candidate = ballot.votes[rank];

            counts[candidate] = counts[candidate] || [];
            counts[candidate][rank] = counts[candidate][rank] || 0;
            counts[candidate][rank]++;

            if ( candidate !== 'overvote' && candidate !== 'undervote' ) {
                choices[rank] = choices[rank] || 0;
                choices[rank]++;
                if ( !invalid ) {
                    numValid++;
                }
                if ( ballot.votes.indexOf( candidate ) !== rank ) {
                    duplicate = true;
                }
            } else if ( candidate === 'overvote' ) {
                invalid = true;
            }
        }
        validChoices[numValid] = validChoices[numValid] || 0;
        validChoices[numValid]++;
        if ( duplicate ) {
            duplicates++;
        }

        let [ first, second, third ] = ballot.votes;
        breakdown[first] = breakdown[first] || { total: 0, second: {} };
        breakdown[first].total++;
        breakdown[first].second[second] = breakdown[first].second[second] || { total: 0, third: {} };
        breakdown[first].second[second].total++;
        breakdown[first].second[second].third[third] = breakdown[first].second[second].third[third] || 0;
        breakdown[first].second[second].third[third]++;

        total++;
    }
    return { total, choices, validChoices, duplicates, counts, breakdown };
}

function contestInfo( ballots ) {
    let counts = getCounts( ballots ),
        rounds = runContest( ballots ),
        winner = rounds[ rounds.length - 1 ].winner;
    return { counts, winner, rounds };
}

if ( process.argv.length < 3 ) {
    console.error( 'Usage: node analyze.js data.json' );
}

const fs = require( 'fs' ),
    util = require( 'util' ),
    data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) );
let contests = {};
for ( let contest in data ) {
    contests[contest] = Object.values( data[contest] );
}

for ( let contest in contests ) {
    console.log( util.inspect( contestInfo( contests[contest] ), { depth: Infinity } ) );
}
