----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[11001] = {	id = 11001, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110001,  } , spawndeny = 0 },
	[11002] = {	id = 11002, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110002,  } , spawndeny = 0 },
	[11003] = {	id = 11003, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110003, 110004,  } , spawndeny = 0 },
	[11011] = {	id = 11011, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110011,  } , spawndeny = 0 },
	[11012] = {	id = 11012, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110012,  } , spawndeny = 0 },
	[11013] = {	id = 11013, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110013, 110014,  } , spawndeny = 0 },
	[11021] = {	id = 11021, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110021,  } , spawndeny = 0 },
	[11022] = {	id = 11022, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110022,  } , spawndeny = 0 },
	[11023] = {	id = 11023, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110023, 110024,  } , spawndeny = 0 },
	[11031] = {	id = 11031, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110031,  } , spawndeny = 0 },
	[11032] = {	id = 11032, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110032,  } , spawndeny = 0 },
	[11033] = {	id = 11033, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110033, 110034,  } , spawndeny = 0 },
	[11041] = {	id = 11041, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110041,  } , spawndeny = 0 },
	[11042] = {	id = 11042, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110042,  } , spawndeny = 0 },
	[11043] = {	id = 11043, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110043, 110044,  } , spawndeny = 0 },
	[11051] = {	id = 11051, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110051,  } , spawndeny = 0 },
	[11052] = {	id = 11052, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110052,  } , spawndeny = 0 },
	[11053] = {	id = 11053, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110053, 110054,  } , spawndeny = 0 },
	[11061] = {	id = 11061, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110061,  } , spawndeny = 0 },
	[11062] = {	id = 11062, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110062,  } , spawndeny = 0 },
	[11063] = {	id = 11063, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110063, 110064,  } , spawndeny = 0 },
	[11071] = {	id = 11071, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110071,  } , spawndeny = 0 },
	[11072] = {	id = 11072, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110072,  } , spawndeny = 0 },
	[11073] = {	id = 11073, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110073, 110074,  } , spawndeny = 0 },
	[11081] = {	id = 11081, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110081,  } , spawndeny = 0 },
	[11082] = {	id = 11082, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110082,  } , spawndeny = 0 },
	[11083] = {	id = 11083, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110083, 110084,  } , spawndeny = 0 },
	[11091] = {	id = 11091, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110091,  } , spawndeny = 0 },
	[11092] = {	id = 11092, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110092,  } , spawndeny = 0 },
	[11093] = {	id = 11093, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110093, 110094,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
