// TODO: come up with a better data structure where each candidate has an array of ballots
// that it owns at the time. This speeds up counts (.length) and redistribution

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

function roundCounts( ballots ) {
    let counts = {}, statuses = { active: 0, exhausted: 0, undervote: 0, exhaustedOvervote: 0 };
    for ( let ballot of ballots ) {
        statuses[ballot.status]++;
        if ( ballot.status === 'active' ) {
            counts[ballot.winner] = counts[ballot.winner] || 0;
            counts[ballot.winner]++;
        }
    }
    return { counts, statuses };
}

function roundZero( ballots ) {
    for ( let ballot of ballots ) {
        for ( let rank = 0; rank < ballot.votes.length; rank++ ) {
            let candidate = ballot.votes[rank];
            if ( candidate === 'overvote' ) {
                ballot.status = 'exhaustedOvervote';
                break;
            } else if ( candidate === 'undervote' ) {
                continue;
            } else {
                ballot.status = 'active';
                ballot.winnerRank = rank;
                ballot.winner = candidate;
                break;
            }
        }
        if ( !ballot.status ) {
            // All undervotes
            ballot.status = 'undervote';
        }
    }
}

function losingCandidate( counts ) {
    let lowest = Infinity, losingCandidate;
    for ( let candidate in counts ) {
        if ( counts[candidate] < lowest ) {
            lowest = counts[candidate];
            losingCandidate = candidate;
        }
    }
    return losingCandidate;
}

function winningCandidate( counts ) {
    let highest = -Infinity, winningCandidate;
    for ( let candidate in counts ) {
        if ( counts[candidate] > highest ){
            highest = counts[candidate];
            winningCandidate = candidate;
        }
    }
    return winningCandidate;
}

function eliminateCandidate( ballots, eliminated ) {
    for ( let ballot of ballots ) {
        while ( ballot.status === 'active' && ( eliminated.includes( ballot.winner ) || ballot.winner === 'undervote' ) ) {
            ballot.winnerRank++;
            ballot.winner = ballot.votes[ballot.winnerRank];
            if ( ballot.winner === 'overvote' ) {
                ballot.status = 'exhaustedOvervote';
            }
            if ( ballot.winner === undefined ) {
                ballot.status = 'exhausted';
            }
        }
    }
}

function runContest( ballots ) {
    let result = [],
        initial = initialCounts( ballots ),
        candidates = Object.keys( initial ).filter( (c) => c !== 'total' && c !== 'undervote' && c !== 'overvote' ),
        eliminated = [],
        currentCounts;

    result.push( initial );
    roundZero( ballots );
    while ( candidates.length - eliminated.length > 2 ) {
        currentCounts = roundCounts( ballots );
        let loser = losingCandidate( currentCounts.counts );
        currentCounts.loser = loser;
        result.push( currentCounts );
        eliminated.push( loser );
        eliminateCandidate( ballots, eliminated );
    }
    currentCounts = roundCounts( ballots );
    result.push( currentCounts );
    result.winner = winningCandidate( currentCounts.counts );
    return result;
}

if ( process.argv.length < 3 ) {
    console.error( 'Usage: node analyze.js data.json' );
}

const fs = require('fs'),
    data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) );
let contests = {};
for ( let contest in data ) {
    contests[contest] = Object.values( data[contest] );
}

for ( let contest in contests ) {
    console.log( runContest( contests[contest] ) );

}
