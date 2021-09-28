----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[75001] = {	id = 75001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75001, 75002, 75003,  } , spawndeny = 0 },
	[75002] = {	id = 75002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75004, 75005, 75006,  } , spawndeny = 0 },
	[75003] = {	id = 75003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75007, 75008, 75009,  } , spawndeny = 0 },
	[75004] = {	id = 75004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75010, 75011, 75012,  } , spawndeny = 0 },
	[75005] = {	id = 75005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75013, 75014, 75015,  } , spawndeny = 0 },
	[75006] = {	id = 75006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75016, 75017, 75018,  } , spawndeny = 0 },
	[75007] = {	id = 75007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75019, 75020, 75021,  } , spawndeny = 0 },
	[75008] = {	id = 75008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75022, 75023, 75024,  } , spawndeny = 0 },
	[75009] = {	id = 75009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75025, 75026, 75027,  } , spawndeny = 0 },
	[75010] = {	id = 75010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 75028, 75029, 75030,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
