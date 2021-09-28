----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[941101] = {	id = 941101, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 941101,  } , spawndeny = 0 },
	[941102] = {	id = 941102, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 941102,  } , spawndeny = 0 },
	[941103] = {	id = 941103, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 941103,  } , spawndeny = 0 },
	[941104] = {	id = 941104, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 941104,  } , spawndeny = 0 },
	[941105] = {	id = 941105, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 941105,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
