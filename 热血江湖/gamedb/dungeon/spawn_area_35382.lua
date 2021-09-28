----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3538201] = {	id = 3538201, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538201,  } , spawndeny = 0 },
	[3538202] = {	id = 3538202, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538202,  } , spawndeny = 0 },
	[3538203] = {	id = 3538203, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538203,  } , spawndeny = 0 },
	[3538204] = {	id = 3538204, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538204,  } , spawndeny = 0 },
	[3538205] = {	id = 3538205, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538205, 3538206, 3538207,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
