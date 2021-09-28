----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7001] = {	id = 7001, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 700101, 700102, 700103, 700104, 700105,  } , spawndeny = 0 },
	[7002] = {	id = 7002, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6901,  }, EndClose = {  }, spawnPoints = { 700201, 700202, 700203, 700204, 700205,  } , spawndeny = 0 },
	[7003] = {	id = 7003, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 700301, 700302, 700303, 700304, 700305, 700306,  } , spawndeny = 0 },
	[7004] = {	id = 7004, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6902,  }, EndClose = {  }, spawnPoints = { 700401, 700402, 700403, 700404, 700405, 700406, 700407, 700408,  } , spawndeny = 0 },
	[7005] = {	id = 7005, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 700501, 700502, 700503, 700504, 700505, 700506, 700507, 700508, 700509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
