----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[61600] = {	id = 61600, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155150,  } , spawndeny = 0 },
	[61601] = {	id = 61601, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155151,  } , spawndeny = 0 },
	[61602] = {	id = 61602, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155152,  } , spawndeny = 0 },
	[61603] = {	id = 61603, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155153,  } , spawndeny = 0 },
	[61604] = {	id = 61604, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155154,  } , spawndeny = 0 },
	[61605] = {	id = 61605, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155155,  } , spawndeny = 0 },
	[61606] = {	id = 61606, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155156,  } , spawndeny = 0 },
	[61607] = {	id = 61607, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6155157,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
