function initialCounts( ballots ) {
    let counts = {}, total = 0;
    for ( let ballot of ballots ) {
        for ( let rank = 0; rank < ballot.votes.length; rank++ ) {
            let candidate = ballot.votes[rank];

            counts[candidate] = counts[candidate] || [];
            counts[candidate][rank] = counts[candidate][rank] || 0;
            counts[candidate][rank]++;
        }
        total++;
    }
    counts.total = total;
    return counts;
}

// TODO Use Set for eliminated candidates

const specialBuckets = [ 'undervote', 'overvote', 'exhausted' ];

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

function bucketCounts( buckets ) {
    let counts = {};
    for ( let candidate in buckets ) {
        counts[candidate] = buckets[candidate].length;
    }
    return counts;
}

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

function contestInfo( ballots ) {
    let counts = initialCounts( ballots ),
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
