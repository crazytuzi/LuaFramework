----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[61201] = {	id = 61201, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61201,  } , spawndeny = 0 },
	[61202] = {	id = 61202, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61202,  } , spawndeny = 0 },
	[61203] = {	id = 61203, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61203,  } , spawndeny = 0 },
	[61204] = {	id = 61204, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61204,  } , spawndeny = 0 },
	[61205] = {	id = 61205, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61205,  } , spawndeny = 0 },
	[61206] = {	id = 61206, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61206,  } , spawndeny = 0 },
	[61207] = {	id = 61207, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61207,  } , spawndeny = 0 },
	[61208] = {	id = 61208, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61208,  } , spawndeny = 0 },
	[61209] = {	id = 61209, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61209,  } , spawndeny = 0 },
	[61210] = {	id = 61210, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61210,  } , spawndeny = 0 },
	[61211] = {	id = 61211, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61211,  } , spawndeny = 0 },
	[61212] = {	id = 61212, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61212,  } , spawndeny = 0 },
	[61213] = {	id = 61213, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61213,  } , spawndeny = 0 },
	[61214] = {	id = 61214, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61214,  } , spawndeny = 0 },
	[61215] = {	id = 61215, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61215,  } , spawndeny = 0 },
	[61216] = {	id = 61216, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61216,  } , spawndeny = 0 },
	[61217] = {	id = 61217, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61217,  } , spawndeny = 0 },
	[61218] = {	id = 61218, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61218,  } , spawndeny = 0 },
	[61219] = {	id = 61219, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61219,  } , spawndeny = 0 },
	[61220] = {	id = 61220, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61220,  } , spawndeny = 0 },
	[61221] = {	id = 61221, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61221,  } , spawndeny = 0 },
	[61222] = {	id = 61222, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61222,  } , spawndeny = 0 },
	[61223] = {	id = 61223, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61223,  } , spawndeny = 0 },
	[61224] = {	id = 61224, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61224,  } , spawndeny = 0 },
	[61225] = {	id = 61225, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61225,  } , spawndeny = 0 },
	[61226] = {	id = 61226, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61226,  } , spawndeny = 0 },
	[61227] = {	id = 61227, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61227,  } , spawndeny = 0 },
	[61228] = {	id = 61228, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61228,  } , spawndeny = 0 },
	[61229] = {	id = 61229, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61229,  } , spawndeny = 0 },
	[61230] = {	id = 61230, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61230,  } , spawndeny = 0 },
	[61231] = {	id = 61231, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61231,  } , spawndeny = 0 },
	[61232] = {	id = 61232, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 61232,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
