----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72001] = {	id = 72001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72001, 72002, 72003,  } , spawndeny = 0 },
	[72002] = {	id = 72002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72004, 72005, 72006,  } , spawndeny = 0 },
	[72003] = {	id = 72003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72007, 72008, 72009,  } , spawndeny = 0 },
	[72004] = {	id = 72004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72010, 72011, 72012,  } , spawndeny = 0 },
	[72005] = {	id = 72005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72013, 72014, 72015,  } , spawndeny = 0 },
	[72006] = {	id = 72006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72016, 72017, 72018,  } , spawndeny = 0 },
	[72007] = {	id = 72007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72019, 72020, 72021,  } , spawndeny = 0 },
	[72008] = {	id = 72008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72022, 72023, 72024,  } , spawndeny = 0 },
	[72009] = {	id = 72009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72025, 72026, 72027,  } , spawndeny = 0 },
	[72010] = {	id = 72010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72028, 72029, 72030,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
