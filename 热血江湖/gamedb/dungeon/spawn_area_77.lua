----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7701] = {	id = 7701, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 751101, 751102, 751103, 751104, 751105, 751106,  } , spawndeny = 0 },
	[7702] = {	id = 7702, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7206,  }, EndClose = {  }, spawnPoints = { 751201, 751202, 751203, 751204,  } , spawndeny = 0 },
	[7703] = {	id = 7703, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7207,  }, EndClose = {  }, spawnPoints = { 751301, 751302, 751303, 751304, 751305,  } , spawndeny = 0 },
	[7704] = {	id = 7704, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 751401, 751402, 751403,  } , spawndeny = 0 },
	[7705] = {	id = 7705, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 751501,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
