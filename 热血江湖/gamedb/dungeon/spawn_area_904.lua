----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[90401] = {	id = 90401, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90401,  } , spawndeny = 3000 },
	[90402] = {	id = 90402, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90402,  } , spawndeny = 3000 },
	[90403] = {	id = 90403, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90403,  } , spawndeny = 3000 },
	[90404] = {	id = 90404, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90404,  } , spawndeny = 3000 },
	[90405] = {	id = 90405, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90405,  } , spawndeny = 3000 },
	[90406] = {	id = 90406, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90406,  } , spawndeny = 3000 },
	[90407] = {	id = 90407, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90407,  } , spawndeny = 3000 },
	[90408] = {	id = 90408, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90408,  } , spawndeny = 3000 },
	[90409] = {	id = 90409, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90409,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
