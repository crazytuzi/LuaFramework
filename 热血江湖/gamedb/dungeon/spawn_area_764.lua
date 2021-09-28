----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76401] = {	id = 76401, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76401, 76402, 76403,  } , spawndeny = 0 },
	[76402] = {	id = 76402, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76404, 76405, 76406,  } , spawndeny = 0 },
	[76403] = {	id = 76403, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76407, 76408, 76409,  } , spawndeny = 0 },
	[76404] = {	id = 76404, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76410, 76411, 76412,  } , spawndeny = 0 },
	[76405] = {	id = 76405, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76413, 76414, 76415,  } , spawndeny = 0 },
	[76406] = {	id = 76406, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76416, 76417, 76418,  } , spawndeny = 0 },
	[76407] = {	id = 76407, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76419, 76420, 76421,  } , spawndeny = 0 },
	[76408] = {	id = 76408, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76422, 76423, 76424,  } , spawndeny = 0 },
	[76409] = {	id = 76409, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76425, 76426, 76427,  } , spawndeny = 0 },
	[76410] = {	id = 76410, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76428, 76429, 76430,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
