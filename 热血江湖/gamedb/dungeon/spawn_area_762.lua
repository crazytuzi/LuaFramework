----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76201] = {	id = 76201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76201, 76202, 76203,  } , spawndeny = 0 },
	[76202] = {	id = 76202, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76204, 76205, 76206,  } , spawndeny = 0 },
	[76203] = {	id = 76203, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76207, 76208, 76209,  } , spawndeny = 0 },
	[76204] = {	id = 76204, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76210, 76211, 76212,  } , spawndeny = 0 },
	[76205] = {	id = 76205, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76213, 76214, 76215,  } , spawndeny = 0 },
	[76206] = {	id = 76206, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76216, 76217, 76218,  } , spawndeny = 0 },
	[76207] = {	id = 76207, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76219, 76220, 76221,  } , spawndeny = 0 },
	[76208] = {	id = 76208, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76222, 76223, 76224,  } , spawndeny = 0 },
	[76209] = {	id = 76209, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76225, 76226, 76227,  } , spawndeny = 0 },
	[76210] = {	id = 76210, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76228, 76229, 76230,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
