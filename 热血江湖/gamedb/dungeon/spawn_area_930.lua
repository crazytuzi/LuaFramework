----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[93001] = {	id = 93001, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93001,  } , spawndeny = 3000 },
	[93002] = {	id = 93002, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93002,  } , spawndeny = 3000 },
	[93003] = {	id = 93003, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93003,  } , spawndeny = 3000 },
	[93004] = {	id = 93004, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93004,  } , spawndeny = 3000 },
	[93005] = {	id = 93005, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93005,  } , spawndeny = 3000 },
	[93006] = {	id = 93006, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93006,  } , spawndeny = 3000 },
	[93007] = {	id = 93007, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93007,  } , spawndeny = 3000 },
	[93008] = {	id = 93008, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93008,  } , spawndeny = 3000 },
	[93009] = {	id = 93009, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93009,  } , spawndeny = 3000 },
	[93010] = {	id = 93010, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93010,  } , spawndeny = 3000 },
	[93011] = {	id = 93011, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93011,  } , spawndeny = 3000 },
	[93012] = {	id = 93012, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93012,  } , spawndeny = 3000 },
	[93013] = {	id = 93013, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93013,  } , spawndeny = 3000 },
	[93014] = {	id = 93014, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93014,  } , spawndeny = 3000 },
	[93015] = {	id = 93015, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93015,  } , spawndeny = 3000 },
	[93016] = {	id = 93016, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93016,  } , spawndeny = 3000 },
	[93017] = {	id = 93017, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93017,  } , spawndeny = 3000 },
	[93018] = {	id = 93018, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93018,  } , spawndeny = 3000 },
	[93019] = {	id = 93019, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93019,  } , spawndeny = 3000 },
	[93020] = {	id = 93020, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93020,  } , spawndeny = 3000 },
	[93021] = {	id = 93021, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93021,  } , spawndeny = 3000 },
	[93022] = {	id = 93022, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93022,  } , spawndeny = 3000 },
	[93023] = {	id = 93023, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93023,  } , spawndeny = 3000 },
	[93024] = {	id = 93024, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93024,  } , spawndeny = 3000 },
	[93025] = {	id = 93025, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93025,  } , spawndeny = 3000 },
	[93026] = {	id = 93026, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93026,  } , spawndeny = 3000 },
	[93027] = {	id = 93027, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93027,  } , spawndeny = 3000 },
	[93028] = {	id = 93028, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93028,  } , spawndeny = 3000 },
	[93029] = {	id = 93029, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93029,  } , spawndeny = 3000 },
	[93030] = {	id = 93030, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93030,  } , spawndeny = 3000 },
	[93031] = {	id = 93031, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93031,  } , spawndeny = 3000 },
	[93032] = {	id = 93032, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93032,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
