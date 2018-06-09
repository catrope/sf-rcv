const sqlite3 = require( 'sqlite3' ),
	fs = require( 'fs' );


function formatVote( vote ) {
	return ( {
		undervote: '(blank)',
		overvote: '(overvote)'
	} )[ vote ] || vote;
}

if ( process.argv.length < 4 ) {
	console.error( 'Usage: node tosqlite.js data.json db.sqlite3' );
}

const data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) ),
	db = new sqlite3.Database( process.argv[3] );

db.serialize( function () {
	db.run( 'CREATE TABLE ballots(id INT, contest TEXT, first TEXT, second TEXT, third TEXT, precinct TEXT, machine INT, tallyType TEXT)' );
	db.run( 'BEGIN' );

	let statement = db.prepare( 'INSERT INTO ballots VALUES (?, ?, ?, ?, ?, ?, ?, ?)' );
	for ( let contest in data ) {
		for ( let id in data[contest] ) {
			let vote = data[contest][id];
			statement.run( Number( id ), contest, ...vote.votes.map( formatVote ), vote.precinct, vote.machine, vote.tallyType );
		}
	}
	statement.finalize();
	db.run( 'END' );
} );
