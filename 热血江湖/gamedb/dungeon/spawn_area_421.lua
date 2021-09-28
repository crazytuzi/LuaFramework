----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42101] = {	id = 42101, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42101,  } , spawndeny = 0 },
	[42111] = {	id = 42111, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42111, 42112, 42113, 42114,  } , spawndeny = 0 },
	[42121] = {	id = 42121, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42121, 42122, 42123, 42124,  } , spawndeny = 0 },
	[42131] = {	id = 42131, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42131,  } , spawndeny = 0 },
	[42132] = {	id = 42132, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42132,  } , spawndeny = 0 },
	[42133] = {	id = 42133, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42133,  } , spawndeny = 0 },
	[42134] = {	id = 42134, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42134,  } , spawndeny = 0 },
	[42141] = {	id = 42141, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42141, 42142, 42143, 42144,  } , spawndeny = 0 },
	[42151] = {	id = 42151, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42151,  } , spawndeny = 0 },
	[42161] = {	id = 42161, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42161, 42162, 42163, 42164,  } , spawndeny = 0 },
	[42171] = {	id = 42171, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42171, 42172, 42173, 42174,  } , spawndeny = 0 },
	[42181] = {	id = 42181, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42181,  } , spawndeny = 0 },
	[42182] = {	id = 42182, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42182,  } , spawndeny = 0 },
	[42183] = {	id = 42183, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42183,  } , spawndeny = 0 },
	[42184] = {	id = 42184, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42184,  } , spawndeny = 0 },
	[42191] = {	id = 42191, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42191, 42192, 42193, 42194,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
