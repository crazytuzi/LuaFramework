----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41011] = {	id = 41011, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41011, 41012, 41013, 41014,  } , spawndeny = 0 },
	[41021] = {	id = 41021, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41021, 41022, 41023, 41024,  } , spawndeny = 0 },
	[41031] = {	id = 41031, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41031,  } , spawndeny = 0 },
	[41032] = {	id = 41032, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41032,  } , spawndeny = 0 },
	[41033] = {	id = 41033, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41033,  } , spawndeny = 0 },
	[41034] = {	id = 41034, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41034,  } , spawndeny = 0 },
	[41041] = {	id = 41041, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41041, 41042, 41043, 41044,  } , spawndeny = 0 },
	[41051] = {	id = 41051, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41051,  } , spawndeny = 0 },
	[41061] = {	id = 41061, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41061, 41062, 41063, 41064,  } , spawndeny = 0 },
	[41071] = {	id = 41071, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41071, 41072, 41073, 41074,  } , spawndeny = 0 },
	[41081] = {	id = 41081, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41081,  } , spawndeny = 0 },
	[41082] = {	id = 41082, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41082,  } , spawndeny = 0 },
	[41083] = {	id = 41083, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41083,  } , spawndeny = 0 },
	[41084] = {	id = 41084, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41084,  } , spawndeny = 0 },
	[41091] = {	id = 41091, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41091, 41092, 41093, 41094,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
