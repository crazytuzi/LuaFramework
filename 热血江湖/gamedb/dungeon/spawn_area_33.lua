----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3301] = {	id = 3301, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 330101, 330102,  } , spawndeny = 0 },
	[3302] = {	id = 3302, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 330201, 330202, 330203, 330204,  } , spawndeny = 0 },
	[3303] = {	id = 3303, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 330301, 330302, 330303, 330304,  } , spawndeny = 0 },
	[3304] = {	id = 3304, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 330401, 330402, 330403, 330404,  } , spawndeny = 0 },
	[3305] = {	id = 3305, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 330501, 330502, 330503, 330504, 330505,  } , spawndeny = 0 },
	[3306] = {	id = 3306, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 330601, 330602, 330603,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
