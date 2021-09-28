----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2301] = {	id = 2301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 230101, 230102, 230103, 230104,  } , spawndeny = 0 },
	[2302] = {	id = 2302, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 230201, 230202, 230203, 230204, 230205, 230206,  } , spawndeny = 0 },
	[2303] = {	id = 2303, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 230301, 230302, 230303, 230304, 230305, 230306,  } , spawndeny = 0 },
	[2304] = {	id = 2304, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 230401, 230402, 230403, 230404, 230405, 230406, 230407, 230408, 230409,  } , spawndeny = 0 },
	[2305] = {	id = 2305, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 230501, 230502, 230503, 230504, 230505, 230506, 230507, 230508, 230509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
