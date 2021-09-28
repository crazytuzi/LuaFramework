----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44011] = {	id = 44011, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44011, 44012, 44013, 44014,  } , spawndeny = 0 },
	[44021] = {	id = 44021, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44021, 44022, 44023, 44024,  } , spawndeny = 0 },
	[44031] = {	id = 44031, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44031,  } , spawndeny = 0 },
	[44032] = {	id = 44032, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44032,  } , spawndeny = 0 },
	[44033] = {	id = 44033, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44033,  } , spawndeny = 0 },
	[44034] = {	id = 44034, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44034,  } , spawndeny = 0 },
	[44041] = {	id = 44041, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44041, 44042, 44043, 44044,  } , spawndeny = 0 },
	[44051] = {	id = 44051, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44051, 44052, 44053,  } , spawndeny = 0 },
	[44061] = {	id = 44061, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44061, 44062, 44063, 44064,  } , spawndeny = 0 },
	[44071] = {	id = 44071, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44071, 44072, 44073, 44074,  } , spawndeny = 0 },
	[44081] = {	id = 44081, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44081,  } , spawndeny = 0 },
	[44082] = {	id = 44082, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44082,  } , spawndeny = 0 },
	[44083] = {	id = 44083, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44083,  } , spawndeny = 0 },
	[44084] = {	id = 44084, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44084,  } , spawndeny = 0 },
	[44091] = {	id = 44091, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44091, 44092, 44093, 44094,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
