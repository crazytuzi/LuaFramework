----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[93201] = {	id = 93201, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93201,  } , spawndeny = 3000 },
	[93202] = {	id = 93202, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93202,  } , spawndeny = 3000 },
	[93203] = {	id = 93203, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93203,  } , spawndeny = 3000 },
	[93204] = {	id = 93204, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93204,  } , spawndeny = 3000 },
	[93205] = {	id = 93205, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93205,  } , spawndeny = 3000 },
	[93206] = {	id = 93206, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93206,  } , spawndeny = 3000 },
	[93207] = {	id = 93207, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93207,  } , spawndeny = 3000 },
	[93208] = {	id = 93208, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93208,  } , spawndeny = 3000 },
	[93209] = {	id = 93209, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93209,  } , spawndeny = 3000 },
	[93210] = {	id = 93210, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93210,  } , spawndeny = 3000 },
	[93211] = {	id = 93211, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93211,  } , spawndeny = 3000 },
	[93212] = {	id = 93212, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93212,  } , spawndeny = 3000 },
	[93213] = {	id = 93213, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93213,  } , spawndeny = 3000 },
	[93214] = {	id = 93214, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93214,  } , spawndeny = 3000 },
	[93215] = {	id = 93215, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93215,  } , spawndeny = 3000 },
	[93216] = {	id = 93216, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93216,  } , spawndeny = 3000 },
	[93217] = {	id = 93217, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93217,  } , spawndeny = 3000 },
	[93218] = {	id = 93218, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93218,  } , spawndeny = 3000 },
	[93219] = {	id = 93219, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93219,  } , spawndeny = 3000 },
	[93220] = {	id = 93220, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93220,  } , spawndeny = 3000 },
	[93221] = {	id = 93221, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93221,  } , spawndeny = 3000 },
	[93222] = {	id = 93222, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93222,  } , spawndeny = 3000 },
	[93223] = {	id = 93223, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93223,  } , spawndeny = 3000 },
	[93224] = {	id = 93224, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93224,  } , spawndeny = 3000 },
	[93225] = {	id = 93225, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93225,  } , spawndeny = 3000 },
	[93226] = {	id = 93226, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93226,  } , spawndeny = 3000 },
	[93227] = {	id = 93227, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93227,  } , spawndeny = 3000 },
	[93228] = {	id = 93228, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93228,  } , spawndeny = 3000 },
	[93229] = {	id = 93229, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93229,  } , spawndeny = 3000 },
	[93230] = {	id = 93230, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93230,  } , spawndeny = 3000 },
	[93231] = {	id = 93231, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93231,  } , spawndeny = 3000 },
	[93232] = {	id = 93232, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93232,  } , spawndeny = 3000 },
	[93233] = {	id = 93233, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93233,  } , spawndeny = 3000 },
	[93234] = {	id = 93234, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93234,  } , spawndeny = 3000 },
	[93235] = {	id = 93235, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93235,  } , spawndeny = 3000 },
	[93236] = {	id = 93236, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93236,  } , spawndeny = 3000 },
	[93237] = {	id = 93237, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93237,  } , spawndeny = 3000 },
	[93238] = {	id = 93238, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93238,  } , spawndeny = 3000 },
	[93239] = {	id = 93239, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93239,  } , spawndeny = 3000 },
	[93240] = {	id = 93240, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93240,  } , spawndeny = 3000 },
	[93241] = {	id = 93241, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93241,  } , spawndeny = 3000 },
	[93242] = {	id = 93242, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93242,  } , spawndeny = 3000 },
	[93243] = {	id = 93243, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93243,  } , spawndeny = 3000 },
	[93244] = {	id = 93244, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93244,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
