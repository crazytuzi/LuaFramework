----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[31201] = {	id = 31201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31201, 31202,  } , spawndeny = 0 },
	[31203] = {	id = 31203, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31203, 31204,  } , spawndeny = 0 },
	[31205] = {	id = 31205, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31205, 31206,  } , spawndeny = 0 },
	[31207] = {	id = 31207, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31207, 31208,  } , spawndeny = 0 },
	[31209] = {	id = 31209, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31209, 31210,  } , spawndeny = 0 },
	[31211] = {	id = 31211, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31211, 31212,  } , spawndeny = 0 },
	[31213] = {	id = 31213, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31213, 31214,  } , spawndeny = 0 },
	[31215] = {	id = 31215, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31215, 31216,  } , spawndeny = 0 },
	[31217] = {	id = 31217, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31217, 31218,  } , spawndeny = 0 },
	[31219] = {	id = 31219, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31219, 31220,  } , spawndeny = 0 },
	[31221] = {	id = 31221, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31221, 31222,  } , spawndeny = 0 },
	[31223] = {	id = 31223, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31223, 31224,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
