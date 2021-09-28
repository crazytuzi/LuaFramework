----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3538101] = {	id = 3538101, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538101,  } , spawndeny = 0 },
	[3538102] = {	id = 3538102, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538102,  } , spawndeny = 0 },
	[3538103] = {	id = 3538103, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538103,  } , spawndeny = 0 },
	[3538104] = {	id = 3538104, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538104,  } , spawndeny = 0 },
	[3538105] = {	id = 3538105, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538105, 3538106, 3538107,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
