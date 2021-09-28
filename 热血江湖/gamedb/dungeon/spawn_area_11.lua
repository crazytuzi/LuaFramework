----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[1101] = {	id = 1101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3621, 3622,  } , spawndeny = 500 },
	[1102] = {	id = 1102, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3623, 3624,  } , spawndeny = 500 },
	[1103] = {	id = 1103, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3625, 3626,  } , spawndeny = 500 },
	[1104] = {	id = 1104, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3637, 3638,  } , spawndeny = 500 },
	[1105] = {	id = 1105, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3639, 3640,  } , spawndeny = 500 },
	[1106] = {	id = 1106, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3641, 3642,  } , spawndeny = 500 },
	[1107] = {	id = 1107, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3643, 3644,  } , spawndeny = 500 },
	[1108] = {	id = 1108, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3645, 3646,  } , spawndeny = 500 },
	[1109] = {	id = 1109, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3647, 3648,  } , spawndeny = 500 },
	[1110] = {	id = 1110, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3649, 3650,  } , spawndeny = 500 },
	[1111] = {	id = 1111, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3651, 3652,  } , spawndeny = 500 },
	[1112] = {	id = 1112, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3653, 3654,  } , spawndeny = 500 },
	[1113] = {	id = 1113, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3655, 3656,  } , spawndeny = 500 },
	[1114] = {	id = 1114, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3657, 3658,  } , spawndeny = 500 },
	[1115] = {	id = 1115, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3659, 3660,  } , spawndeny = 500 },
	[1116] = {	id = 1116, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3667, 3668,  } , spawndeny = 500 },
	[1117] = {	id = 1117, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3669, 3670,  } , spawndeny = 500 },
	[1118] = {	id = 1118, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3671, 3672,  } , spawndeny = 500 },
	[1119] = {	id = 1119, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3679, 3680,  } , spawndeny = 500 },
	[1120] = {	id = 1120, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3681, 3682,  } , spawndeny = 500 },
	[1121] = {	id = 1121, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3683, 3684,  } , spawndeny = 500 },

};
function get_db_table()
	return spawn_area;
end
