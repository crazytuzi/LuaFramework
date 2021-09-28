----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[90101] = {	id = 90101, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90101,  } , spawndeny = 3000 },
	[90102] = {	id = 90102, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90102,  } , spawndeny = 3000 },
	[90103] = {	id = 90103, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90103,  } , spawndeny = 3000 },
	[90104] = {	id = 90104, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90104,  } , spawndeny = 3000 },
	[90105] = {	id = 90105, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90105,  } , spawndeny = 3000 },
	[90106] = {	id = 90106, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90106,  } , spawndeny = 3000 },
	[90107] = {	id = 90107, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90107,  } , spawndeny = 3000 },
	[90108] = {	id = 90108, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90108,  } , spawndeny = 3000 },
	[90109] = {	id = 90109, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90109,  } , spawndeny = 3000 },
	[90110] = {	id = 90110, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90110,  } , spawndeny = 3000 },
	[90111] = {	id = 90111, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90111,  } , spawndeny = 3000 },
	[90112] = {	id = 90112, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90112,  } , spawndeny = 3000 },
	[90113] = {	id = 90113, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90113,  } , spawndeny = 3000 },
	[90114] = {	id = 90114, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90114,  } , spawndeny = 3000 },
	[90115] = {	id = 90115, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90115,  } , spawndeny = 3000 },
	[90116] = {	id = 90116, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90116,  } , spawndeny = 3000 },
	[90117] = {	id = 90117, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90117,  } , spawndeny = 3000 },
	[90118] = {	id = 90118, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90118,  } , spawndeny = 3000 },
	[90119] = {	id = 90119, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90119,  } , spawndeny = 3000 },
	[90120] = {	id = 90120, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90120,  } , spawndeny = 3000 },
	[90121] = {	id = 90121, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90121,  } , spawndeny = 3000 },
	[90122] = {	id = 90122, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90122,  } , spawndeny = 3000 },
	[90123] = {	id = 90123, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90123,  } , spawndeny = 3000 },
	[90124] = {	id = 90124, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90124,  } , spawndeny = 3000 },
	[90125] = {	id = 90125, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90125,  } , spawndeny = 3000 },
	[90126] = {	id = 90126, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90126,  } , spawndeny = 3000 },
	[90127] = {	id = 90127, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90127,  } , spawndeny = 3000 },
	[90128] = {	id = 90128, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90128,  } , spawndeny = 3000 },
	[90129] = {	id = 90129, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90129,  } , spawndeny = 3000 },
	[90130] = {	id = 90130, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90130,  } , spawndeny = 3000 },
	[90131] = {	id = 90131, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90131,  } , spawndeny = 3000 },
	[90132] = {	id = 90132, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90132,  } , spawndeny = 3000 },
	[90133] = {	id = 90133, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90133,  } , spawndeny = 3000 },
	[90134] = {	id = 90134, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90134,  } , spawndeny = 3000 },
	[90135] = {	id = 90135, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90135,  } , spawndeny = 3000 },
	[90136] = {	id = 90136, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90136,  } , spawndeny = 3000 },
	[90137] = {	id = 90137, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90137,  } , spawndeny = 3000 },
	[90138] = {	id = 90138, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90138,  } , spawndeny = 3000 },
	[90139] = {	id = 90139, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90139,  } , spawndeny = 3000 },
	[90140] = {	id = 90140, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90140,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
