----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[93101] = {	id = 93101, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93101,  } , spawndeny = 3000 },
	[93102] = {	id = 93102, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93102,  } , spawndeny = 3000 },
	[93103] = {	id = 93103, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93103,  } , spawndeny = 3000 },
	[93104] = {	id = 93104, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93104,  } , spawndeny = 3000 },
	[93105] = {	id = 93105, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93105,  } , spawndeny = 3000 },
	[93106] = {	id = 93106, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93106,  } , spawndeny = 3000 },
	[93107] = {	id = 93107, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93107,  } , spawndeny = 3000 },
	[93108] = {	id = 93108, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93108,  } , spawndeny = 3000 },
	[93109] = {	id = 93109, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93109,  } , spawndeny = 3000 },
	[93110] = {	id = 93110, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93110,  } , spawndeny = 3000 },
	[93111] = {	id = 93111, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93111,  } , spawndeny = 3000 },
	[93112] = {	id = 93112, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93112,  } , spawndeny = 3000 },
	[93113] = {	id = 93113, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93113,  } , spawndeny = 3000 },
	[93114] = {	id = 93114, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93114,  } , spawndeny = 3000 },
	[93115] = {	id = 93115, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93115,  } , spawndeny = 3000 },
	[93116] = {	id = 93116, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93116,  } , spawndeny = 3000 },
	[93117] = {	id = 93117, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93117,  } , spawndeny = 3000 },
	[93118] = {	id = 93118, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93118,  } , spawndeny = 3000 },
	[93119] = {	id = 93119, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93119,  } , spawndeny = 3000 },
	[93120] = {	id = 93120, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93120,  } , spawndeny = 3000 },
	[93121] = {	id = 93121, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93121,  } , spawndeny = 3000 },
	[93122] = {	id = 93122, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93122,  } , spawndeny = 3000 },
	[93123] = {	id = 93123, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93123,  } , spawndeny = 3000 },
	[93124] = {	id = 93124, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93124,  } , spawndeny = 3000 },
	[93125] = {	id = 93125, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93125,  } , spawndeny = 3000 },
	[93126] = {	id = 93126, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93126,  } , spawndeny = 3000 },
	[93127] = {	id = 93127, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93127,  } , spawndeny = 3000 },
	[93128] = {	id = 93128, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93128,  } , spawndeny = 3000 },
	[93129] = {	id = 93129, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93129,  } , spawndeny = 3000 },
	[93130] = {	id = 93130, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93130,  } , spawndeny = 3000 },
	[93131] = {	id = 93131, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93131,  } , spawndeny = 3000 },
	[93132] = {	id = 93132, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93132,  } , spawndeny = 3000 },
	[93133] = {	id = 93133, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93133,  } , spawndeny = 3000 },
	[93134] = {	id = 93134, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93134,  } , spawndeny = 3000 },
	[93135] = {	id = 93135, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93135,  } , spawndeny = 3000 },
	[93136] = {	id = 93136, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93136,  } , spawndeny = 3000 },
	[93137] = {	id = 93137, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93137,  } , spawndeny = 3000 },
	[93138] = {	id = 93138, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93138,  } , spawndeny = 3000 },
	[93139] = {	id = 93139, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93139,  } , spawndeny = 3000 },
	[93140] = {	id = 93140, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93140,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
