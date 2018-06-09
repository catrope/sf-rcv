const sqlite3 = require( 'sqlite3' ),
	fs = require( 'fs' );

if ( process.argv.length < 3 ) {
	console.error( 'Usage: node tosqlite.js data.json' );
}

const data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) ),
	db = new sqlite3.Database( process.argv[2].replace( /\.json$/, '' ) + '.sqlite' );

db.serialize( function () {
	db.run( 'CREATE TABLE ballots(id INT, contest TEXT, first TEXT, second TEXT, third TEXT, precinct TEXT, machine INT, tallyType TEXT)' );
	db.run( 'BEGIN' );

	let statement = db.prepare( 'INSERT INTO ballots VALUES (?, ?, ?, ?, ?, ?, ?, ?)' );
	for ( let contest in data ) {
		for ( let id in data[contest] ) {
			let vote = data[contest][id];
			statement.run( Number( id ), contest, ...vote.votes, vote.precinct, vote.machine, vote.tallyType );
		}
	}
	statement.finalize();
	db.run( 'END' );
} );
