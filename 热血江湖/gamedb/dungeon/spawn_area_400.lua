----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40011] = {	id = 40011, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40011, 40012, 40013, 40014,  } , spawndeny = 0 },
	[40021] = {	id = 40021, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40021, 40022, 40023, 40024,  } , spawndeny = 0 },
	[40031] = {	id = 40031, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40031,  } , spawndeny = 0 },
	[40032] = {	id = 40032, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40032,  } , spawndeny = 0 },
	[40033] = {	id = 40033, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40033,  } , spawndeny = 0 },
	[40034] = {	id = 40034, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40034,  } , spawndeny = 0 },
	[40041] = {	id = 40041, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40041, 40042, 40043, 40044,  } , spawndeny = 0 },
	[40051] = {	id = 40051, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40051,  } , spawndeny = 0 },
	[40061] = {	id = 40061, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40061, 40062, 40063, 40064,  } , spawndeny = 0 },
	[40071] = {	id = 40071, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40071, 40072, 40073, 40074,  } , spawndeny = 0 },
	[40081] = {	id = 40081, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40081,  } , spawndeny = 0 },
	[40082] = {	id = 40082, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40082,  } , spawndeny = 0 },
	[40083] = {	id = 40083, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40083,  } , spawndeny = 0 },
	[40084] = {	id = 40084, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40084,  } , spawndeny = 0 },
	[40091] = {	id = 40091, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40091, 40092, 40093, 40094,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
