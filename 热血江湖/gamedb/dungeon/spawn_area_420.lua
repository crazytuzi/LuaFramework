----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42011] = {	id = 42011, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42011, 42012, 42013, 42014,  } , spawndeny = 0 },
	[42021] = {	id = 42021, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42021, 42022, 42023, 42024,  } , spawndeny = 0 },
	[42031] = {	id = 42031, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42031,  } , spawndeny = 0 },
	[42032] = {	id = 42032, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42032,  } , spawndeny = 0 },
	[42033] = {	id = 42033, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42033,  } , spawndeny = 0 },
	[42034] = {	id = 42034, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42034,  } , spawndeny = 0 },
	[42041] = {	id = 42041, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42041, 42042, 42043, 42044,  } , spawndeny = 0 },
	[42051] = {	id = 42051, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42051,  } , spawndeny = 0 },
	[42061] = {	id = 42061, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42061, 42062, 42063, 42064,  } , spawndeny = 0 },
	[42071] = {	id = 42071, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42071, 42072, 42073, 42074,  } , spawndeny = 0 },
	[42081] = {	id = 42081, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42081,  } , spawndeny = 0 },
	[42082] = {	id = 42082, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42082,  } , spawndeny = 0 },
	[42083] = {	id = 42083, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42083,  } , spawndeny = 0 },
	[42084] = {	id = 42084, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42084,  } , spawndeny = 0 },
	[42091] = {	id = 42091, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42091, 42092, 42093, 42094,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
