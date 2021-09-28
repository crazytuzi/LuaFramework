----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[90201] = {	id = 90201, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90201,  } , spawndeny = 3000 },
	[90202] = {	id = 90202, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90202,  } , spawndeny = 3000 },
	[90203] = {	id = 90203, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90203,  } , spawndeny = 3000 },
	[90204] = {	id = 90204, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90204,  } , spawndeny = 3000 },
	[90205] = {	id = 90205, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90205,  } , spawndeny = 3000 },
	[90206] = {	id = 90206, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90206,  } , spawndeny = 3000 },
	[90207] = {	id = 90207, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90207,  } , spawndeny = 3000 },
	[90208] = {	id = 90208, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90208,  } , spawndeny = 3000 },
	[90209] = {	id = 90209, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90209,  } , spawndeny = 3000 },
	[90210] = {	id = 90210, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90210,  } , spawndeny = 3000 },
	[90211] = {	id = 90211, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90211,  } , spawndeny = 3000 },
	[90212] = {	id = 90212, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90212,  } , spawndeny = 3000 },
	[90213] = {	id = 90213, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90213,  } , spawndeny = 3000 },
	[90214] = {	id = 90214, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90214,  } , spawndeny = 3000 },
	[90215] = {	id = 90215, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90215,  } , spawndeny = 3000 },
	[90216] = {	id = 90216, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90216,  } , spawndeny = 3000 },
	[90217] = {	id = 90217, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90217,  } , spawndeny = 3000 },
	[90218] = {	id = 90218, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90218,  } , spawndeny = 3000 },
	[90219] = {	id = 90219, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90219,  } , spawndeny = 3000 },
	[90220] = {	id = 90220, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90220,  } , spawndeny = 3000 },
	[90221] = {	id = 90221, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90221,  } , spawndeny = 3000 },
	[90222] = {	id = 90222, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90222,  } , spawndeny = 3000 },
	[90223] = {	id = 90223, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90223,  } , spawndeny = 3000 },
	[90224] = {	id = 90224, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90224,  } , spawndeny = 3000 },
	[90225] = {	id = 90225, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90225,  } , spawndeny = 3000 },
	[90226] = {	id = 90226, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90226,  } , spawndeny = 3000 },
	[90227] = {	id = 90227, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90227,  } , spawndeny = 3000 },
	[90228] = {	id = 90228, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90228,  } , spawndeny = 3000 },
	[90229] = {	id = 90229, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90229,  } , spawndeny = 3000 },
	[90230] = {	id = 90230, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90230,  } , spawndeny = 3000 },
	[90231] = {	id = 90231, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90231,  } , spawndeny = 3000 },
	[90232] = {	id = 90232, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90232,  } , spawndeny = 3000 },
	[90233] = {	id = 90233, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90233,  } , spawndeny = 3000 },
	[90234] = {	id = 90234, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90234,  } , spawndeny = 3000 },
	[90235] = {	id = 90235, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90235,  } , spawndeny = 3000 },
	[90236] = {	id = 90236, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90236,  } , spawndeny = 3000 },
	[90237] = {	id = 90237, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90237,  } , spawndeny = 3000 },
	[90238] = {	id = 90238, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90238,  } , spawndeny = 3000 },
	[90239] = {	id = 90239, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90239,  } , spawndeny = 3000 },
	[90240] = {	id = 90240, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90240,  } , spawndeny = 3000 },
	[90241] = {	id = 90241, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90241,  } , spawndeny = 3000 },
	[90242] = {	id = 90242, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90242,  } , spawndeny = 3000 },
	[90243] = {	id = 90243, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90243,  } , spawndeny = 3000 },
	[90244] = {	id = 90244, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90244,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
