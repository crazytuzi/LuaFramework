----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43011] = {	id = 43011, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43011, 43012, 43013, 43014,  } , spawndeny = 0 },
	[43021] = {	id = 43021, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43021, 43022, 43023, 43024,  } , spawndeny = 0 },
	[43031] = {	id = 43031, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43031,  } , spawndeny = 0 },
	[43032] = {	id = 43032, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43032,  } , spawndeny = 0 },
	[43033] = {	id = 43033, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43033,  } , spawndeny = 0 },
	[43034] = {	id = 43034, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43034,  } , spawndeny = 0 },
	[43041] = {	id = 43041, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43041, 43042, 43043, 43044,  } , spawndeny = 0 },
	[43051] = {	id = 43051, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43051, 43052,  } , spawndeny = 0 },
	[43061] = {	id = 43061, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43061, 43062, 43063, 43064,  } , spawndeny = 0 },
	[43071] = {	id = 43071, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43071, 43072, 43073, 43074,  } , spawndeny = 0 },
	[43081] = {	id = 43081, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43081,  } , spawndeny = 0 },
	[43082] = {	id = 43082, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43082,  } , spawndeny = 0 },
	[43083] = {	id = 43083, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43083,  } , spawndeny = 0 },
	[43084] = {	id = 43084, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43084,  } , spawndeny = 0 },
	[43091] = {	id = 43091, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43091, 43092, 43093, 43094,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
