----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[951001] = {	id = 951001, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951001,  } , spawndeny = 0 },
	[951002] = {	id = 951002, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951002,  } , spawndeny = 0 },
	[951003] = {	id = 951003, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951003,  } , spawndeny = 0 },
	[951004] = {	id = 951004, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951004,  } , spawndeny = 0 },
	[951005] = {	id = 951005, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951005,  } , spawndeny = 0 },
	[951006] = {	id = 951006, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951006,  } , spawndeny = 0 },
	[951007] = {	id = 951007, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951007,  } , spawndeny = 0 },
	[951008] = {	id = 951008, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951008,  } , spawndeny = 0 },
	[951009] = {	id = 951009, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951009,  } , spawndeny = 0 },
	[951010] = {	id = 951010, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951010,  } , spawndeny = 0 },
	[951011] = {	id = 951011, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951011,  } , spawndeny = 0 },
	[951012] = {	id = 951012, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951012,  } , spawndeny = 0 },
	[951013] = {	id = 951013, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951013,  } , spawndeny = 0 },
	[951014] = {	id = 951014, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951014,  } , spawndeny = 0 },
	[951015] = {	id = 951015, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951015,  } , spawndeny = 0 },
	[951016] = {	id = 951016, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951016,  } , spawndeny = 0 },
	[951017] = {	id = 951017, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951017,  } , spawndeny = 0 },
	[951018] = {	id = 951018, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951018,  } , spawndeny = 0 },
	[951019] = {	id = 951019, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951019,  } , spawndeny = 0 },
	[951020] = {	id = 951020, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951020,  } , spawndeny = 0 },
	[951021] = {	id = 951021, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951021,  } , spawndeny = 0 },
	[951022] = {	id = 951022, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951022,  } , spawndeny = 0 },
	[951023] = {	id = 951023, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951023,  } , spawndeny = 0 },
	[951024] = {	id = 951024, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951024,  } , spawndeny = 0 },
	[951025] = {	id = 951025, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951025,  } , spawndeny = 0 },
	[951026] = {	id = 951026, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951026,  } , spawndeny = 0 },
	[951027] = {	id = 951027, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951027,  } , spawndeny = 0 },
	[951028] = {	id = 951028, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951028,  } , spawndeny = 0 },
	[951029] = {	id = 951029, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951029,  } , spawndeny = 0 },
	[951030] = {	id = 951030, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951030,  } , spawndeny = 0 },
	[951031] = {	id = 951031, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951031,  } , spawndeny = 0 },
	[951032] = {	id = 951032, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951032,  } , spawndeny = 0 },
	[951033] = {	id = 951033, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951033,  } , spawndeny = 0 },
	[951034] = {	id = 951034, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951034,  } , spawndeny = 0 },
	[951035] = {	id = 951035, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951035,  } , spawndeny = 0 },
	[951036] = {	id = 951036, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951036,  } , spawndeny = 0 },
	[951037] = {	id = 951037, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951037,  } , spawndeny = 0 },
	[951038] = {	id = 951038, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951038,  } , spawndeny = 0 },
	[951039] = {	id = 951039, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951039,  } , spawndeny = 0 },
	[951040] = {	id = 951040, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 951040,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
