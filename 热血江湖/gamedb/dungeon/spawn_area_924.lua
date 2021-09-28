----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[92401] = {	id = 92401, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92401,  } , spawndeny = 3000 },
	[92402] = {	id = 92402, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92402,  } , spawndeny = 3000 },
	[92403] = {	id = 92403, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92403,  } , spawndeny = 3000 },
	[92404] = {	id = 92404, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92404,  } , spawndeny = 3000 },
	[92405] = {	id = 92405, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92405,  } , spawndeny = 3000 },
	[92406] = {	id = 92406, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92406,  } , spawndeny = 3000 },
	[92407] = {	id = 92407, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92407,  } , spawndeny = 3000 },
	[92408] = {	id = 92408, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92408,  } , spawndeny = 3000 },
	[92409] = {	id = 92409, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92409,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
