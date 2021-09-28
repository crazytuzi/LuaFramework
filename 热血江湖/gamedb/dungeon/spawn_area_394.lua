----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[39421] = {	id = 39421, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39421,  } , spawndeny = 10000 },
	[39422] = {	id = 39422, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39422,  } , spawndeny = 10000 },
	[39423] = {	id = 39423, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39423,  } , spawndeny = 10000 },
	[39424] = {	id = 39424, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39424,  } , spawndeny = 10000 },
	[39425] = {	id = 39425, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39425,  } , spawndeny = 10000 },
	[39426] = {	id = 39426, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39426,  } , spawndeny = 10000 },
	[39427] = {	id = 39427, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39427,  } , spawndeny = 10000 },

};
function get_db_table()
	return spawn_area;
end
