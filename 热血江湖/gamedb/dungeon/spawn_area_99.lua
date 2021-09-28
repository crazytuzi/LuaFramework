----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[9901] = {	id = 9901, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 990101,  } , spawndeny = 0 },
	[9910] = {	id = 9910, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7000,  } , spawndeny = 0 },
	[9911] = {	id = 9911, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7001,  } , spawndeny = 0 },
	[9912] = {	id = 9912, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7002,  } , spawndeny = 0 },
	[9913] = {	id = 9913, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7003,  } , spawndeny = 0 },
	[9914] = {	id = 9914, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7004,  } , spawndeny = 0 },
	[9915] = {	id = 9915, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7005,  } , spawndeny = 0 },
	[9916] = {	id = 9916, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7006,  } , spawndeny = 0 },
	[9917] = {	id = 9917, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7007,  } , spawndeny = 0 },
	[9918] = {	id = 9918, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7008,  } , spawndeny = 0 },
	[9919] = {	id = 9919, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7009,  } , spawndeny = 0 },
	[9920] = {	id = 9920, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7010,  } , spawndeny = 0 },
	[9921] = {	id = 9921, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7011,  } , spawndeny = 0 },
	[9922] = {	id = 9922, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7012,  } , spawndeny = 0 },
	[9923] = {	id = 9923, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7013,  } , spawndeny = 0 },
	[9924] = {	id = 9924, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7014,  } , spawndeny = 0 },
	[9925] = {	id = 9925, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7015,  } , spawndeny = 0 },
	[9926] = {	id = 9926, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7016,  } , spawndeny = 0 },
	[9927] = {	id = 9927, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7017,  } , spawndeny = 0 },
	[9928] = {	id = 9928, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7018,  } , spawndeny = 0 },
	[9929] = {	id = 9929, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7019,  } , spawndeny = 0 },
	[9930] = {	id = 9930, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 7020,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
