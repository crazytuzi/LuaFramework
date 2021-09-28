----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[11501] = {	id = 11501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110501,  } , spawndeny = 0 },
	[11502] = {	id = 11502, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110502,  } , spawndeny = 0 },
	[11503] = {	id = 11503, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110503, 110504,  } , spawndeny = 0 },
	[11511] = {	id = 11511, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110511,  } , spawndeny = 0 },
	[11512] = {	id = 11512, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110512,  } , spawndeny = 0 },
	[11513] = {	id = 11513, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110513, 110514,  } , spawndeny = 0 },
	[11521] = {	id = 11521, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110521,  } , spawndeny = 0 },
	[11522] = {	id = 11522, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110522,  } , spawndeny = 0 },
	[11523] = {	id = 11523, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110523, 110524,  } , spawndeny = 0 },
	[11531] = {	id = 11531, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110531,  } , spawndeny = 0 },
	[11532] = {	id = 11532, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110532,  } , spawndeny = 0 },
	[11533] = {	id = 11533, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110533, 110534,  } , spawndeny = 0 },
	[11541] = {	id = 11541, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110541,  } , spawndeny = 0 },
	[11542] = {	id = 11542, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110542,  } , spawndeny = 0 },
	[11543] = {	id = 11543, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110543, 110544,  } , spawndeny = 0 },
	[11551] = {	id = 11551, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110551,  } , spawndeny = 0 },
	[11552] = {	id = 11552, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110552,  } , spawndeny = 0 },
	[11553] = {	id = 11553, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110553, 110554,  } , spawndeny = 0 },
	[11561] = {	id = 11561, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110561,  } , spawndeny = 0 },
	[11562] = {	id = 11562, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110562,  } , spawndeny = 0 },
	[11563] = {	id = 11563, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110563, 110564,  } , spawndeny = 0 },
	[11571] = {	id = 11571, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110571,  } , spawndeny = 0 },
	[11572] = {	id = 11572, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110572,  } , spawndeny = 0 },
	[11573] = {	id = 11573, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110573, 110574,  } , spawndeny = 0 },
	[11581] = {	id = 11581, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110581,  } , spawndeny = 0 },
	[11582] = {	id = 11582, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110582,  } , spawndeny = 0 },
	[11583] = {	id = 11583, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110583, 110584,  } , spawndeny = 0 },
	[11591] = {	id = 11591, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110591,  } , spawndeny = 0 },
	[11592] = {	id = 11592, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110592,  } , spawndeny = 0 },
	[11593] = {	id = 11593, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110593, 110594,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
