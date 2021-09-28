----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[1001] = {	id = 1001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3601, 3602,  } , spawndeny = 500 },
	[1002] = {	id = 1002, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3603, 3604,  } , spawndeny = 500 },
	[1003] = {	id = 1003, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3605, 3606,  } , spawndeny = 500 },
	[1004] = {	id = 1004, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3607, 3608,  } , spawndeny = 500 },
	[1005] = {	id = 1005, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3609, 3610,  } , spawndeny = 500 },
	[1006] = {	id = 1006, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3611, 3612,  } , spawndeny = 500 },
	[1007] = {	id = 1007, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3613, 3614,  } , spawndeny = 500 },
	[1008] = {	id = 1008, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3615, 3616,  } , spawndeny = 500 },
	[1009] = {	id = 1009, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3617, 3618,  } , spawndeny = 500 },
	[1010] = {	id = 1010, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3619, 3620,  } , spawndeny = 500 },
	[1011] = {	id = 1011, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3627, 3628,  } , spawndeny = 500 },
	[1012] = {	id = 1012, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3629, 3630,  } , spawndeny = 500 },
	[1013] = {	id = 1013, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3631, 3632,  } , spawndeny = 500 },
	[1014] = {	id = 1014, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3633, 3634,  } , spawndeny = 500 },
	[1015] = {	id = 1015, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3635, 3636,  } , spawndeny = 500 },
	[1016] = {	id = 1016, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3661, 3662,  } , spawndeny = 500 },
	[1017] = {	id = 1017, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3663, 3664,  } , spawndeny = 500 },
	[1018] = {	id = 1018, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3665, 3666,  } , spawndeny = 500 },
	[1019] = {	id = 1019, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3673, 3674,  } , spawndeny = 500 },
	[1020] = {	id = 1020, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3675, 3676,  } , spawndeny = 500 },
	[1021] = {	id = 1021, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3677, 3678,  } , spawndeny = 500 },

};
function get_db_table()
	return spawn_area;
end
