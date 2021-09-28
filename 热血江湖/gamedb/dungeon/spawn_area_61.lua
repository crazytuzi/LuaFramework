----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6101] = {	id = 6101, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 610101, 610102, 610103, 610104, 610105, 610106,  } , spawndeny = 0 },
	[6102] = {	id = 6102, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 610201, 610202, 610203, 610204, 610205, 610206,  } , spawndeny = 0 },
	[6103] = {	id = 6103, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 610301, 610302, 610303, 610304, 610305, 610306,  } , spawndeny = 0 },
	[6104] = {	id = 6104, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6001,  }, EndClose = {  }, spawnPoints = { 610401, 610402, 610403, 610404, 610405, 610406,  } , spawndeny = 0 },
	[6105] = {	id = 6105, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 610501, 610502, 610503, 610504, 610505, 610506, 610507,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
