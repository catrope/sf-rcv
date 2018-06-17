const sqlite3 = require( 'sqlite3' ),
	fs = require( 'fs' ),
	rcv = require( './rcv.js' );


function formatVote( vote ) {
	return ( {
		undervote: '(blank)',
		overvote: '(overvote)'
	} )[ vote ] || vote;
}

function getDistrict( precinct ) {
	if ( precinct.startsWith( 'Pct 11' ) ) {
		return 11;
	}
	let secondDigit = Number( precinct.charAt( 'Pct N'.length ) );
	return secondDigit === 0 ? 10 : secondDigit;
}

function keyById( buckets ) {
	let result = {};
	for ( let candidate in buckets ) {
		result[candidate] = {};
		for ( let ballot of buckets[candidate] ) {
			result[candidate][ballot.id] = ballot;
		}
	}
	return result;
}

if ( process.argv.length < 4 ) {
	console.error( 'Usage: node tosqlite.js data.json db.sqlite3' );
	return;
}

const data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) ),
	db = new sqlite3.Database( process.argv[3] );

let contestData = {};
for ( let contest in data ) {
	let ballots = data[contest];
	for ( let id in ballots ) {
		ballots[id].id = id;
	}
	contestData[contest] = rcv.runContest( Object.values( ballots ), true );
}



db.serialize( function () {
	db.run( 'CREATE TABLE ballots(id INT, contest TEXT, first TEXT, second TEXT, third TEXT, precinct TEXT, district INT, machine INT, tallyType TEXT,' +
		'round1 TEXT, round2 TEXT, round3 TEXT, round4 TEXT, round5 TEXT, round6 TEXT, round7 TEXT, round8 TEXT)' );
	db.run( 'BEGIN' );

	let statement = db.prepare( 'INSERT INTO ballots VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
	for ( let contest in data ) {
		let roundData = contestData[contest].map( (c) => keyById( c.buckets ) );
		for ( let id in data[contest] ) {
			let vote = data[contest][id], roundCandidates = [];
			for ( let r = 0; r < 8; r++ ) {
				for ( let candidate in roundData[r] ) {
					if ( id in roundData[r][candidate] ) {
						roundCandidates[r] = candidate;
						break;
					}
				}
			}
			statement.run(
				Number( id ),
				contest,
				...vote.votes.map( formatVote ),
				vote.precinct,
				getDistrict( vote.precinct ),
				vote.machine,
				vote.tallyType,
				...roundCandidates
			);
		}
	}
	statement.finalize();
	db.run( 'END' );
} );
