----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[12501] = {	id = 12501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111501,  } , spawndeny = 0 },
	[12502] = {	id = 12502, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111502,  } , spawndeny = 0 },
	[12503] = {	id = 12503, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111503, 111504,  } , spawndeny = 0 },
	[12504] = {	id = 12504, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111505,  } , spawndeny = 0 },
	[12511] = {	id = 12511, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111511,  } , spawndeny = 0 },
	[12512] = {	id = 12512, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111512,  } , spawndeny = 0 },
	[12513] = {	id = 12513, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111513, 111514,  } , spawndeny = 0 },
	[12514] = {	id = 12514, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111515,  } , spawndeny = 0 },
	[12521] = {	id = 12521, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111521,  } , spawndeny = 0 },
	[12522] = {	id = 12522, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111522,  } , spawndeny = 0 },
	[12523] = {	id = 12523, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111523, 111524,  } , spawndeny = 0 },
	[12524] = {	id = 12524, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111525,  } , spawndeny = 0 },
	[12531] = {	id = 12531, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111531,  } , spawndeny = 0 },
	[12532] = {	id = 12532, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111532,  } , spawndeny = 0 },
	[12533] = {	id = 12533, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111533, 111534,  } , spawndeny = 0 },
	[12534] = {	id = 12534, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111535,  } , spawndeny = 0 },
	[12541] = {	id = 12541, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111541,  } , spawndeny = 0 },
	[12542] = {	id = 12542, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111542,  } , spawndeny = 0 },
	[12543] = {	id = 12543, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111543, 111544,  } , spawndeny = 0 },
	[12544] = {	id = 12544, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111545,  } , spawndeny = 0 },
	[12551] = {	id = 12551, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111551,  } , spawndeny = 0 },
	[12552] = {	id = 12552, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111552,  } , spawndeny = 0 },
	[12553] = {	id = 12553, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111553, 111554,  } , spawndeny = 0 },
	[12554] = {	id = 12554, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111555,  } , spawndeny = 0 },
	[12561] = {	id = 12561, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111561,  } , spawndeny = 0 },
	[12562] = {	id = 12562, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111562,  } , spawndeny = 0 },
	[12563] = {	id = 12563, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111563, 111564,  } , spawndeny = 0 },
	[12564] = {	id = 12564, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111565,  } , spawndeny = 0 },
	[12571] = {	id = 12571, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111571,  } , spawndeny = 0 },
	[12572] = {	id = 12572, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111572,  } , spawndeny = 0 },
	[12573] = {	id = 12573, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111573, 111574,  } , spawndeny = 0 },
	[12574] = {	id = 12574, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111575,  } , spawndeny = 0 },
	[12581] = {	id = 12581, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111581,  } , spawndeny = 0 },
	[12582] = {	id = 12582, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111582,  } , spawndeny = 0 },
	[12583] = {	id = 12583, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111583, 111584,  } , spawndeny = 0 },
	[12584] = {	id = 12584, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111585,  } , spawndeny = 0 },
	[12591] = {	id = 12591, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111591,  } , spawndeny = 0 },
	[12592] = {	id = 12592, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111592,  } , spawndeny = 0 },
	[12593] = {	id = 12593, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111593, 111594,  } , spawndeny = 0 },
	[12594] = {	id = 12594, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111595,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
