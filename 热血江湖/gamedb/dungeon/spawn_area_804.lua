----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80401] = {	id = 80401, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80401, 80402, 80403, 80404, 80405, 80406,  } , spawndeny = 3000 },
	[80421] = {	id = 80421, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80421, 80422, 80423, 80424, 80425, 80426,  } , spawndeny = 3000 },
	[80441] = {	id = 80441, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80441, 80442, 80443, 80444, 80445, 80446, 80447, 80448,  } , spawndeny = 3000 },
	[80461] = {	id = 80461, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80461, 80462, 80463, 80464,  } , spawndeny = 3000 },
	[80481] = {	id = 80481, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80481, 80482, 80483, 80484, 80485, 80486,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
