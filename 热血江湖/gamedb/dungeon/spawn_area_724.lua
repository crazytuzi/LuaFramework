----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72401] = {	id = 72401, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72401, 72402, 72403,  } , spawndeny = 0 },
	[72402] = {	id = 72402, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72404, 72405, 72406,  } , spawndeny = 0 },
	[72403] = {	id = 72403, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72407, 72408, 72409,  } , spawndeny = 0 },
	[72404] = {	id = 72404, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72410, 72411, 72412,  } , spawndeny = 0 },
	[72405] = {	id = 72405, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72413, 72414, 72415,  } , spawndeny = 0 },
	[72406] = {	id = 72406, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72416, 72417, 72418,  } , spawndeny = 0 },
	[72407] = {	id = 72407, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72419, 72420, 72421,  } , spawndeny = 0 },
	[72408] = {	id = 72408, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72422, 72423, 72424,  } , spawndeny = 0 },
	[72409] = {	id = 72409, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72425, 72426, 72427,  } , spawndeny = 0 },
	[72410] = {	id = 72410, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72428, 72429, 72430,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
