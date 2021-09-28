----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[90001] = {	id = 90001, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90001,  } , spawndeny = 3000 },
	[90002] = {	id = 90002, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90002,  } , spawndeny = 3000 },
	[90003] = {	id = 90003, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90003,  } , spawndeny = 3000 },
	[90004] = {	id = 90004, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90004,  } , spawndeny = 3000 },
	[90005] = {	id = 90005, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90005,  } , spawndeny = 3000 },
	[90006] = {	id = 90006, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90006,  } , spawndeny = 3000 },
	[90007] = {	id = 90007, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90007,  } , spawndeny = 3000 },
	[90008] = {	id = 90008, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90008,  } , spawndeny = 3000 },
	[90009] = {	id = 90009, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90009,  } , spawndeny = 3000 },
	[90010] = {	id = 90010, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90010,  } , spawndeny = 3000 },
	[90011] = {	id = 90011, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90011,  } , spawndeny = 3000 },
	[90012] = {	id = 90012, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90012,  } , spawndeny = 3000 },
	[90013] = {	id = 90013, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90013,  } , spawndeny = 3000 },
	[90014] = {	id = 90014, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90014,  } , spawndeny = 3000 },
	[90015] = {	id = 90015, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90015,  } , spawndeny = 3000 },
	[90016] = {	id = 90016, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90016,  } , spawndeny = 3000 },
	[90017] = {	id = 90017, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90017,  } , spawndeny = 3000 },
	[90018] = {	id = 90018, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90018,  } , spawndeny = 3000 },
	[90019] = {	id = 90019, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90019,  } , spawndeny = 3000 },
	[90020] = {	id = 90020, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90020,  } , spawndeny = 3000 },
	[90021] = {	id = 90021, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90021,  } , spawndeny = 3000 },
	[90022] = {	id = 90022, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90022,  } , spawndeny = 3000 },
	[90023] = {	id = 90023, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90023,  } , spawndeny = 3000 },
	[90024] = {	id = 90024, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90024,  } , spawndeny = 3000 },
	[90025] = {	id = 90025, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90025,  } , spawndeny = 3000 },
	[90026] = {	id = 90026, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90026,  } , spawndeny = 3000 },
	[90027] = {	id = 90027, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90027,  } , spawndeny = 3000 },
	[90028] = {	id = 90028, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90028,  } , spawndeny = 3000 },
	[90029] = {	id = 90029, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90029,  } , spawndeny = 3000 },
	[90030] = {	id = 90030, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90030,  } , spawndeny = 3000 },
	[90031] = {	id = 90031, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90031,  } , spawndeny = 3000 },
	[90032] = {	id = 90032, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90032,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
