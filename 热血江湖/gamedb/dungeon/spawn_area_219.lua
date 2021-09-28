----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[21901] = {	id = 21901, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 21901,  } , spawndeny = 0 },
	[21902] = {	id = 21902, range = 100.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 21902,  } , spawndeny = 0 },
	[21903] = {	id = 21903, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 21903,  } , spawndeny = 0 },
	[21904] = {	id = 21904, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 21904,  } , spawndeny = 0 },
	[21905] = {	id = 21905, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 21905,  } , spawndeny = 0 },
	[21906] = {	id = 21906, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 21906,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
