----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[91401] = {	id = 91401, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91401,  } , spawndeny = 3000 },
	[91402] = {	id = 91402, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91402,  } , spawndeny = 3000 },
	[91403] = {	id = 91403, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91403,  } , spawndeny = 3000 },
	[91404] = {	id = 91404, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91404,  } , spawndeny = 3000 },
	[91405] = {	id = 91405, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91405,  } , spawndeny = 3000 },
	[91406] = {	id = 91406, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91406,  } , spawndeny = 3000 },
	[91407] = {	id = 91407, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91407,  } , spawndeny = 3000 },
	[91408] = {	id = 91408, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91408,  } , spawndeny = 3000 },
	[91409] = {	id = 91409, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91409,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
