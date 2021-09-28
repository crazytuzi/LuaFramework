----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[93401] = {	id = 93401, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93401,  } , spawndeny = 3000 },
	[93402] = {	id = 93402, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93402,  } , spawndeny = 3000 },
	[93403] = {	id = 93403, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93403,  } , spawndeny = 3000 },
	[93404] = {	id = 93404, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93404,  } , spawndeny = 3000 },
	[93405] = {	id = 93405, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93405,  } , spawndeny = 3000 },
	[93406] = {	id = 93406, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93406,  } , spawndeny = 3000 },
	[93407] = {	id = 93407, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93407,  } , spawndeny = 3000 },
	[93408] = {	id = 93408, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93408,  } , spawndeny = 3000 },
	[93409] = {	id = 93409, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93409,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
