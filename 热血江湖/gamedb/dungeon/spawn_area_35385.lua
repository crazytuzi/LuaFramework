----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3538501] = {	id = 3538501, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538501,  } , spawndeny = 0 },
	[3538502] = {	id = 3538502, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538502,  } , spawndeny = 0 },
	[3538503] = {	id = 3538503, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538503,  } , spawndeny = 0 },
	[3538504] = {	id = 3538504, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538504,  } , spawndeny = 0 },
	[3538505] = {	id = 3538505, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538505, 3538506, 3538507, 3538508,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
