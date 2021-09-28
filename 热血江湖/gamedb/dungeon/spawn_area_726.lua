----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72601] = {	id = 72601, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72601, 72602, 72603,  } , spawndeny = 0 },
	[72602] = {	id = 72602, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72604, 72605, 72606,  } , spawndeny = 0 },
	[72603] = {	id = 72603, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72607, 72608, 72609,  } , spawndeny = 0 },
	[72604] = {	id = 72604, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72610, 72611, 72612,  } , spawndeny = 0 },
	[72605] = {	id = 72605, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72613, 72614, 72615,  } , spawndeny = 0 },
	[72606] = {	id = 72606, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72616, 72617, 72618,  } , spawndeny = 0 },
	[72607] = {	id = 72607, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72619, 72620, 72621,  } , spawndeny = 0 },
	[72608] = {	id = 72608, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72622, 72623, 72624,  } , spawndeny = 0 },
	[72609] = {	id = 72609, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72625, 72626, 72627,  } , spawndeny = 0 },
	[72610] = {	id = 72610, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72628, 72629, 72630,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
