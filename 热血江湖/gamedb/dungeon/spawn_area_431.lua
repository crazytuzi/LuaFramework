----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43101] = {	id = 43101, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43101, 43102,  } , spawndeny = 0 },
	[43111] = {	id = 43111, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43111, 43112, 43113, 43114,  } , spawndeny = 0 },
	[43121] = {	id = 43121, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43121, 43122, 43123, 43124,  } , spawndeny = 0 },
	[43131] = {	id = 43131, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43131,  } , spawndeny = 0 },
	[43132] = {	id = 43132, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43132,  } , spawndeny = 0 },
	[43133] = {	id = 43133, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43133,  } , spawndeny = 0 },
	[43134] = {	id = 43134, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43134,  } , spawndeny = 0 },
	[43141] = {	id = 43141, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43141, 43142, 43143, 43144,  } , spawndeny = 0 },
	[43151] = {	id = 43151, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43151, 43152,  } , spawndeny = 0 },
	[43161] = {	id = 43161, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43161, 43162, 43163, 43164,  } , spawndeny = 0 },
	[43171] = {	id = 43171, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43171, 43172, 43173, 43174,  } , spawndeny = 0 },
	[43181] = {	id = 43181, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43181,  } , spawndeny = 0 },
	[43182] = {	id = 43182, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43182,  } , spawndeny = 0 },
	[43183] = {	id = 43183, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43183,  } , spawndeny = 0 },
	[43184] = {	id = 43184, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43184,  } , spawndeny = 0 },
	[43191] = {	id = 43191, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43191, 43192, 43193, 43194,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
