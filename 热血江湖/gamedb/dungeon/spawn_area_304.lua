----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[30401] = {	id = 30401, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30401,  } , spawndeny = 0 },
	[30402] = {	id = 30402, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30402,  } , spawndeny = 0 },
	[30403] = {	id = 30403, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30403,  } , spawndeny = 0 },
	[30404] = {	id = 30404, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30404,  } , spawndeny = 0 },
	[30405] = {	id = 30405, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30405,  } , spawndeny = 0 },
	[30406] = {	id = 30406, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30406,  } , spawndeny = 0 },
	[30407] = {	id = 30407, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30407,  } , spawndeny = 0 },
	[30408] = {	id = 30408, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 30408,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
