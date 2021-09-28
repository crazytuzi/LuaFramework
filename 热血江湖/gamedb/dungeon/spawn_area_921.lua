----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[92101] = {	id = 92101, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92101,  } , spawndeny = 3000 },
	[92102] = {	id = 92102, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92102,  } , spawndeny = 3000 },
	[92103] = {	id = 92103, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92103,  } , spawndeny = 3000 },
	[92104] = {	id = 92104, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92104,  } , spawndeny = 3000 },
	[92105] = {	id = 92105, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92105,  } , spawndeny = 3000 },
	[92106] = {	id = 92106, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92106,  } , spawndeny = 3000 },
	[92107] = {	id = 92107, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92107,  } , spawndeny = 3000 },
	[92108] = {	id = 92108, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92108,  } , spawndeny = 3000 },
	[92109] = {	id = 92109, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92109,  } , spawndeny = 3000 },
	[92110] = {	id = 92110, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92110,  } , spawndeny = 3000 },
	[92111] = {	id = 92111, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92111,  } , spawndeny = 3000 },
	[92112] = {	id = 92112, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92112,  } , spawndeny = 3000 },
	[92113] = {	id = 92113, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92113,  } , spawndeny = 3000 },
	[92114] = {	id = 92114, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92114,  } , spawndeny = 3000 },
	[92115] = {	id = 92115, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92115,  } , spawndeny = 3000 },
	[92116] = {	id = 92116, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92116,  } , spawndeny = 3000 },
	[92117] = {	id = 92117, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92117,  } , spawndeny = 3000 },
	[92118] = {	id = 92118, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92118,  } , spawndeny = 3000 },
	[92119] = {	id = 92119, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92119,  } , spawndeny = 3000 },
	[92120] = {	id = 92120, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92120,  } , spawndeny = 3000 },
	[92121] = {	id = 92121, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92121,  } , spawndeny = 3000 },
	[92122] = {	id = 92122, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92122,  } , spawndeny = 3000 },
	[92123] = {	id = 92123, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92123,  } , spawndeny = 3000 },
	[92124] = {	id = 92124, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92124,  } , spawndeny = 3000 },
	[92125] = {	id = 92125, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92125,  } , spawndeny = 3000 },
	[92126] = {	id = 92126, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92126,  } , spawndeny = 3000 },
	[92127] = {	id = 92127, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92127,  } , spawndeny = 3000 },
	[92128] = {	id = 92128, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92128,  } , spawndeny = 3000 },
	[92129] = {	id = 92129, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92129,  } , spawndeny = 3000 },
	[92130] = {	id = 92130, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92130,  } , spawndeny = 3000 },
	[92131] = {	id = 92131, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92131,  } , spawndeny = 3000 },
	[92132] = {	id = 92132, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92132,  } , spawndeny = 3000 },
	[92133] = {	id = 92133, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92133,  } , spawndeny = 3000 },
	[92134] = {	id = 92134, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92134,  } , spawndeny = 3000 },
	[92135] = {	id = 92135, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92135,  } , spawndeny = 3000 },
	[92136] = {	id = 92136, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92136,  } , spawndeny = 3000 },
	[92137] = {	id = 92137, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92137,  } , spawndeny = 3000 },
	[92138] = {	id = 92138, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92138,  } , spawndeny = 3000 },
	[92139] = {	id = 92139, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92139,  } , spawndeny = 3000 },
	[92140] = {	id = 92140, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92140,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
