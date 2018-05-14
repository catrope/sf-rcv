const rcv = require( './rcv.js' ),
    fs = require( 'fs' ),
    util = require( 'util' );

function contestInfo( ballots ) {
    let counts = rcv.getCounts( ballots ),
        rounds = rcv.runContest( ballots ),
        winner = rounds[ rounds.length - 1 ].winner;
    return { counts, winner, rounds };
}

if ( process.argv.length < 3 ) {
    console.error( 'Usage: node analyze.js data.json' );
}

const data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) );
let contests = {};
for ( let contest in data ) {
    contests[contest] = Object.values( data[contest] );
}

let result = {};
for ( let contest in contests ) {
    result[contest] = contestInfo( contests[contest] );
}

process.stdout.write( JSON.stringify( result ) );
