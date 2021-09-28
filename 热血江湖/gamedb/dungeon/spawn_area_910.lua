----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[91001] = {	id = 91001, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91001,  } , spawndeny = 3000 },
	[91002] = {	id = 91002, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91002,  } , spawndeny = 3000 },
	[91003] = {	id = 91003, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91003,  } , spawndeny = 3000 },
	[91004] = {	id = 91004, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91004,  } , spawndeny = 3000 },
	[91005] = {	id = 91005, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91005,  } , spawndeny = 3000 },
	[91006] = {	id = 91006, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91006,  } , spawndeny = 3000 },
	[91007] = {	id = 91007, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91007,  } , spawndeny = 3000 },
	[91008] = {	id = 91008, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91008,  } , spawndeny = 3000 },
	[91009] = {	id = 91009, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91009,  } , spawndeny = 3000 },
	[91010] = {	id = 91010, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91010,  } , spawndeny = 3000 },
	[91011] = {	id = 91011, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91011,  } , spawndeny = 3000 },
	[91012] = {	id = 91012, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91012,  } , spawndeny = 3000 },
	[91013] = {	id = 91013, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91013,  } , spawndeny = 3000 },
	[91014] = {	id = 91014, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91014,  } , spawndeny = 3000 },
	[91015] = {	id = 91015, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91015,  } , spawndeny = 3000 },
	[91016] = {	id = 91016, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91016,  } , spawndeny = 3000 },
	[91017] = {	id = 91017, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91017,  } , spawndeny = 3000 },
	[91018] = {	id = 91018, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91018,  } , spawndeny = 3000 },
	[91019] = {	id = 91019, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91019,  } , spawndeny = 3000 },
	[91020] = {	id = 91020, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91020,  } , spawndeny = 3000 },
	[91021] = {	id = 91021, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91021,  } , spawndeny = 3000 },
	[91022] = {	id = 91022, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91022,  } , spawndeny = 3000 },
	[91023] = {	id = 91023, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91023,  } , spawndeny = 3000 },
	[91024] = {	id = 91024, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91024,  } , spawndeny = 3000 },
	[91025] = {	id = 91025, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91025,  } , spawndeny = 3000 },
	[91026] = {	id = 91026, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91026,  } , spawndeny = 3000 },
	[91027] = {	id = 91027, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91027,  } , spawndeny = 3000 },
	[91028] = {	id = 91028, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91028,  } , spawndeny = 3000 },
	[91029] = {	id = 91029, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91029,  } , spawndeny = 3000 },
	[91030] = {	id = 91030, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91030,  } , spawndeny = 3000 },
	[91031] = {	id = 91031, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91031,  } , spawndeny = 3000 },
	[91032] = {	id = 91032, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91032,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
