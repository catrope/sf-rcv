let fs = require('fs');

function parseManifest( file ) {
	let data = JSON.parse( fs.readFileSync( file, { encoding: 'utf-8' } ) ),
		map = {};
	for ( let entry of data.List ) {
		map[ entry.Id ] = entry.Description;
	}
	return map;
}

let candidates = parseManifest( './CandidateManifest.json' ),
	contests = parseManifest( './ContestManifest.json' ),
	precincts = parseManifest( './PrecinctPortionManifest.json' ),
	countingGroups = parseManifest( './CountingGroupManifest.json' ),
	ballotTypes = parseManifest( './BallotTypeManifest.json' ),
	cvrData = JSON.parse( fs.readFileSync( './CvrExport.json', { encoding: 'utf-8' } ) );

function ranksToArray( marks ) {
	let arr = [];
	for ( let mark of marks ) {
		if ( arr[ mark.Rank - 1 ] === undefined ) {
			arr[ mark.Rank - 1 ] = mark;
		} else if ( Array.isArray( arr[ mark.Rank - 1 ] ) ) {
			arr[ mark.Rank - 1 ] = [ ...arr[ mark.Rank - 1 ], mark ];
		} else {
			arr[ mark.Rank - 1 ] = [ arr[ mark.Rank - 1 ], mark ];
		}
	}
	return arr;
}

let reformatted = cvrData.Sessions.map( function ( session ) {
	let ballot = session.Modified || session.Original;
	let data = {
		countingGroup: countingGroups[ session.CountingGroupId ],
		precinct: precincts[ ballot.PrecinctPortionId ],
		ballotType: ballotTypes[ ballot.BallotTypeId ]
	};
	for ( let contest of ballot.Contests ) {
		data[ contests[ contest.Id ] ] = ranksToArray( contest.Marks.filter( (m) => !m.IsAmbiguous ) )
			.map( (m) => Array.isArray( m ) ? m.map( (n) => n ? candidates[ n.CandidateId ] : null ) : m ? candidates[ m.CandidateId ] : null );
	}
	return data;
} );

process.stdout.write( JSON.stringify( reformatted ) );
