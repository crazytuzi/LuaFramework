----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[92001] = {	id = 92001, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92001,  } , spawndeny = 3000 },
	[92002] = {	id = 92002, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92002,  } , spawndeny = 3000 },
	[92003] = {	id = 92003, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92003,  } , spawndeny = 3000 },
	[92004] = {	id = 92004, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92004,  } , spawndeny = 3000 },
	[92005] = {	id = 92005, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92005,  } , spawndeny = 3000 },
	[92006] = {	id = 92006, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92006,  } , spawndeny = 3000 },
	[92007] = {	id = 92007, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92007,  } , spawndeny = 3000 },
	[92008] = {	id = 92008, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92008,  } , spawndeny = 3000 },
	[92009] = {	id = 92009, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92009,  } , spawndeny = 3000 },
	[92010] = {	id = 92010, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92010,  } , spawndeny = 3000 },
	[92011] = {	id = 92011, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92011,  } , spawndeny = 3000 },
	[92012] = {	id = 92012, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92012,  } , spawndeny = 3000 },
	[92013] = {	id = 92013, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92013,  } , spawndeny = 3000 },
	[92014] = {	id = 92014, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92014,  } , spawndeny = 3000 },
	[92015] = {	id = 92015, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92015,  } , spawndeny = 3000 },
	[92016] = {	id = 92016, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92016,  } , spawndeny = 3000 },
	[92017] = {	id = 92017, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92017,  } , spawndeny = 3000 },
	[92018] = {	id = 92018, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92018,  } , spawndeny = 3000 },
	[92019] = {	id = 92019, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92019,  } , spawndeny = 3000 },
	[92020] = {	id = 92020, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92020,  } , spawndeny = 3000 },
	[92021] = {	id = 92021, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92021,  } , spawndeny = 3000 },
	[92022] = {	id = 92022, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92022,  } , spawndeny = 3000 },
	[92023] = {	id = 92023, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92023,  } , spawndeny = 3000 },
	[92024] = {	id = 92024, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92024,  } , spawndeny = 3000 },
	[92025] = {	id = 92025, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92025,  } , spawndeny = 3000 },
	[92026] = {	id = 92026, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92026,  } , spawndeny = 3000 },
	[92027] = {	id = 92027, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92027,  } , spawndeny = 3000 },
	[92028] = {	id = 92028, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92028,  } , spawndeny = 3000 },
	[92029] = {	id = 92029, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92029,  } , spawndeny = 3000 },
	[92030] = {	id = 92030, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92030,  } , spawndeny = 3000 },
	[92031] = {	id = 92031, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92031,  } , spawndeny = 3000 },
	[92032] = {	id = 92032, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92032,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
