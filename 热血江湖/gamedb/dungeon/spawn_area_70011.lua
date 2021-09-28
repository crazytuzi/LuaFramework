----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7001101] = {	id = 7001101, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001101,  } , spawndeny = 0 },
	[7001102] = {	id = 7001102, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001102,  } , spawndeny = 0 },
	[7001103] = {	id = 7001103, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001103,  } , spawndeny = 0 },
	[7001104] = {	id = 7001104, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001104,  } , spawndeny = 0 },
	[7001105] = {	id = 7001105, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001105,  } , spawndeny = 0 },
	[7001106] = {	id = 7001106, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001106,  } , spawndeny = 0 },
	[7001107] = {	id = 7001107, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001107,  } , spawndeny = 0 },
	[7001108] = {	id = 7001108, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001108,  } , spawndeny = 0 },
	[7001109] = {	id = 7001109, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001109,  } , spawndeny = 0 },
	[7001110] = {	id = 7001110, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001110,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
