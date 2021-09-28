----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3538001] = {	id = 3538001, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538001,  } , spawndeny = 0 },
	[3538002] = {	id = 3538002, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538002,  } , spawndeny = 0 },
	[3538003] = {	id = 3538003, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538003,  } , spawndeny = 0 },
	[3538004] = {	id = 3538004, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538004,  } , spawndeny = 0 },
	[3538005] = {	id = 3538005, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3538005, 3538006, 3538007,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
