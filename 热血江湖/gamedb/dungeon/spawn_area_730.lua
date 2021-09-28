----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[73001] = {	id = 73001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73001, 73002, 73003,  } , spawndeny = 0 },
	[73002] = {	id = 73002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73004, 73005, 73006,  } , spawndeny = 0 },
	[73003] = {	id = 73003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73007, 73008, 73009,  } , spawndeny = 0 },
	[73004] = {	id = 73004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73010, 73011, 73012,  } , spawndeny = 0 },
	[73005] = {	id = 73005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73013, 73014, 73015,  } , spawndeny = 0 },
	[73006] = {	id = 73006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73016, 73017, 73018,  } , spawndeny = 0 },
	[73007] = {	id = 73007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73019, 73020, 73021,  } , spawndeny = 0 },
	[73008] = {	id = 73008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73022, 73023, 73024,  } , spawndeny = 0 },
	[73009] = {	id = 73009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73025, 73026, 73027,  } , spawndeny = 0 },
	[73010] = {	id = 73010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 73028, 73029, 73030,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
