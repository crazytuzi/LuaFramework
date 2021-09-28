----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3538401] = {	id = 3538401, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538401,  } , spawndeny = 0 },
	[3538402] = {	id = 3538402, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538402,  } , spawndeny = 0 },
	[3538403] = {	id = 3538403, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538403,  } , spawndeny = 0 },
	[3538404] = {	id = 3538404, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538404,  } , spawndeny = 0 },
	[3538405] = {	id = 3538405, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538405, 3538406, 3538407, 3538408,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
