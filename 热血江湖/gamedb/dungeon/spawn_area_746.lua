----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74601] = {	id = 74601, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74601, 74602, 74603,  } , spawndeny = 0 },
	[74602] = {	id = 74602, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74604, 74605, 74606,  } , spawndeny = 0 },
	[74603] = {	id = 74603, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74607, 74608, 74609,  } , spawndeny = 0 },
	[74604] = {	id = 74604, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74610, 74611, 74612,  } , spawndeny = 0 },
	[74605] = {	id = 74605, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74613, 74614, 74615,  } , spawndeny = 0 },
	[74606] = {	id = 74606, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74616, 74617, 74618,  } , spawndeny = 0 },
	[74607] = {	id = 74607, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74619, 74620, 74621,  } , spawndeny = 0 },
	[74608] = {	id = 74608, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74622, 74623, 74624,  } , spawndeny = 0 },
	[74609] = {	id = 74609, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74625, 74626, 74627,  } , spawndeny = 0 },
	[74610] = {	id = 74610, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74628, 74629, 74630,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
