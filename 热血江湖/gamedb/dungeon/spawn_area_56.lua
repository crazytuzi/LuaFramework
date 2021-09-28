----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5601] = {	id = 5601, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5608,  }, EndClose = {  }, spawnPoints = { 560101, 560102,  } , spawndeny = 0 },
	[5602] = {	id = 5602, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5609,  }, EndClose = {  }, spawnPoints = { 560201, 560202, 560203, 560204,  } , spawndeny = 0 },
	[5603] = {	id = 5603, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5610, 5601,  }, EndClose = {  }, spawnPoints = { 560301, 560302, 560303, 560304,  } , spawndeny = 0 },
	[5604] = {	id = 5604, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5602, 5607,  }, EndClose = {  }, spawnPoints = { 560401, 560402, 560403, 560404, 560405,  } , spawndeny = 0 },
	[5605] = {	id = 5605, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 560501, 560502, 560503, 560504, 560505,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
