----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7601] = {	id = 7601, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 750601, 750602, 750603, 750604, 750605, 750606,  } , spawndeny = 0 },
	[7602] = {	id = 7602, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7206,  }, EndClose = {  }, spawnPoints = { 750701, 750702, 750703, 750704,  } , spawndeny = 0 },
	[7603] = {	id = 7603, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7207,  }, EndClose = {  }, spawnPoints = { 750801, 750802, 750803, 750804, 750805,  } , spawndeny = 0 },
	[7604] = {	id = 7604, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 750901, 750902, 750903,  } , spawndeny = 0 },
	[7605] = {	id = 7605, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 751001,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
