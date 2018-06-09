const sqlite = require( 'sqlite3' ),
	fs = require( 'fs' );

if ( process.argv.length < 3 ) {
	console.error( 'Usage: node tosqlite.js data.json' );
}

function encodeValue( x ) {
	if ( typeof x === 'number' ) {
		return x;
	}
	return "'" + String(x).replace(/'/, "''") + "'";
}

const data = JSON.parse( fs.readFileSync( process.argv[2], { encoding: 'utf8' } ) );

console.log('CREATE TABLE ballots(id INT, contest TEXT, first TEXT, second TEXT, third TEXT, precinct TEXT, machine INT, tallyType TEXT);');
for ( let contest in data ) {
	for ( let id in data[contest] ) {
		let vote = data[contest][id];
		console.log( 'INSERT INTO ballots VALUES(' +
			[ Number( id ), contest ].concat( vote.votes ).concat( [ vote.precinct, vote.machine, vote.tallyType ] )
				.map( encodeValue ).join( ', ' ) +
			');'
		);
	}
}
