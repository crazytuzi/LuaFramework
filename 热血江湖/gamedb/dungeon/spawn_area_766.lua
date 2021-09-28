----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76601] = {	id = 76601, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76601, 76602, 76603,  } , spawndeny = 0 },
	[76602] = {	id = 76602, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76604, 76605, 76606,  } , spawndeny = 0 },
	[76603] = {	id = 76603, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76607, 76608, 76609,  } , spawndeny = 0 },
	[76604] = {	id = 76604, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76610, 76611, 76612,  } , spawndeny = 0 },
	[76605] = {	id = 76605, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76613, 76614, 76615,  } , spawndeny = 0 },
	[76606] = {	id = 76606, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76616, 76617, 76618,  } , spawndeny = 0 },
	[76607] = {	id = 76607, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76619, 76620, 76621,  } , spawndeny = 0 },
	[76608] = {	id = 76608, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76622, 76623, 76624,  } , spawndeny = 0 },
	[76609] = {	id = 76609, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76625, 76626, 76627,  } , spawndeny = 0 },
	[76610] = {	id = 76610, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76628, 76629, 76630,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
