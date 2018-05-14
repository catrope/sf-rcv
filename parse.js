const fs = require('fs');

/**
 * Parse rows in the master lookup file.
 *
 * The returned data structure looks like { TYPE: { ID: data } }, where TYPE is one of
 * 'Candidate', 'Contest', 'Precinct', 'Tally Type', ID is the ID of each item and the data
 * object has keys type, id, name, listOrder, contestId, isWriteIn and isProvisional.
 *
 * @param {string[]} rows Array of rows in the master lookup file
 * @return {Object} Parsed data
 */
function parseMasterLookup( rows ) {
    let byType = {};
    rows.forEach( function ( row ) {
        if ( row.trim() === '' ) {
            return;
        }
        let parsedRow = {
            type: row.substr(0, 10).trim(),
            id: Number( row.substr(10, 7) ),
            name: row.substr(17, 50).trim(),
            listOrder: Number( row.substr(67, 7) ),
            contestId: Number( row.substr(74, 7) ),
            isWriteIn: row.substr(81, 1) === '1',
            isProvisional: row.substr(82, 1) === '1'
        };
        byType[parsedRow.type] = byType[parsedRow.type] || {};
        byType[parsedRow.type][parsedRow.id] = parsedRow;
    } );
    return byType;
}

function parseBallotImages( rows, lookupMap ) {
    let byContest = {};
    rows.forEach( function ( row ) {
        if ( row.trim() === '' ) {
            return;
        }
        let contest = Number( row.substr(0, 7) );
        let parsedRow = {
            voterId: Number( row.substr(7, 9) ),
            machine: Number( row.substr(16, 7) ),
            tallyType: Number( row.substr(23, 3) ),
            precinct: Number( row.substr(26, 7) ),
            voteRank: Number( row.substr(33, 3) ),
            candidate: Number( row.substr(36, 7) ),
            isOvervote: row.substr(43, 1) === '1',
            isUndervote: row.substr(44, 1) === '1'
        };
        contest = lookupMap.Contest[contest].name;
        parsedRow.tallyType = lookupMap['Tally Type'][parsedRow.tallyType].name;
        parsedRow.precinct = lookupMap.Precinct[parsedRow.precinct].name;
        parsedRow.candidate = parsedRow.candidate === 0 ?
            null :
            lookupMap.Candidate[parsedRow.candidate].name;
        byContest[contest] = byContest[contest] || [];
        byContest[contest].push( parsedRow );
    } );
    return byContest;
}

function groupByVoterId( rows ) {
    let byVoterId = {};
    rows.forEach( function ( row ) {
        byVoterId[row.voterId] = byVoterId[row.voterId] || {
            machine: row.machine,
            tallyType: row.tallyType,
            precinct: row.precinct,
            votes: []
        };
        byVoterId[row.voterId].votes[row.voteRank - 1] =
            row.candidate || ( row.isUndervote ? 'undervote' : 'overvote' );
    } );
    return byVoterId;
}

if ( process.argv.length < 3 ) {
    console.error('Usage: node parse.js date');
    return;
}

const rawMasterLookup = fs.readFileSync( process.argv[2] + '_masterlookup.txt', { encoding: 'utf8' } ),
    rawBallotImage = fs.readFileSync( process.argv[2] + '_ballotimage.txt', { encoding: 'utf8' } ),
    typeIdMap = parseMasterLookup( rawMasterLookup.split( '\r\n' ) ),
    ballotImages = parseBallotImages( rawBallotImage.split( '\r\n' ), typeIdMap );

let grouped = {};
for ( let contest in ballotImages ) {
    grouped[contest] = groupByVoterId( ballotImages[contest] );
}
process.stdout.write(JSON.stringify(grouped));
