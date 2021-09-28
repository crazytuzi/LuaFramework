----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76001] = {	id = 76001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76001, 76002, 76003,  } , spawndeny = 0 },
	[76002] = {	id = 76002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76004, 76005, 76006,  } , spawndeny = 0 },
	[76003] = {	id = 76003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76007, 76008, 76009,  } , spawndeny = 0 },
	[76004] = {	id = 76004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76010, 76011, 76012,  } , spawndeny = 0 },
	[76005] = {	id = 76005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76013, 76014, 76015,  } , spawndeny = 0 },
	[76006] = {	id = 76006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76016, 76017, 76018,  } , spawndeny = 0 },
	[76007] = {	id = 76007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76019, 76020, 76021,  } , spawndeny = 0 },
	[76008] = {	id = 76008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76022, 76023, 76024,  } , spawndeny = 0 },
	[76009] = {	id = 76009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76025, 76026, 76027,  } , spawndeny = 0 },
	[76010] = {	id = 76010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76028, 76029, 76030,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
