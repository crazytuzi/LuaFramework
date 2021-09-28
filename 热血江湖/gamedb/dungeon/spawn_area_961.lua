----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[96101] = {	id = 96101, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96101,  } , spawndeny = 0 },
	[96102] = {	id = 96102, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96102,  } , spawndeny = 0 },
	[96103] = {	id = 96103, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96103,  } , spawndeny = 0 },
	[96104] = {	id = 96104, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96104,  } , spawndeny = 0 },
	[96105] = {	id = 96105, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96105,  } , spawndeny = 0 },
	[96106] = {	id = 96106, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96106,  } , spawndeny = 0 },
	[96107] = {	id = 96107, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96107,  } , spawndeny = 0 },
	[96108] = {	id = 96108, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96108,  } , spawndeny = 0 },
	[96109] = {	id = 96109, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96109,  } , spawndeny = 0 },
	[96110] = {	id = 96110, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 96110,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
