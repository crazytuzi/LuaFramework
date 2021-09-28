----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3601] = {	id = 3601, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 360101, 360102, 360103, 360104, 360105,  } , spawndeny = 0 },
	[3602] = {	id = 3602, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 360202, 360203, 360204, 360205, 360206, 360207,  } , spawndeny = 0 },
	[3603] = {	id = 3603, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 360302, 360303, 360304, 360305, 360306, 360307, 360308,  } , spawndeny = 0 },
	[3604] = {	id = 3604, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 360402, 360403, 360404, 360405, 360406, 360407, 360408, 360409,  } , spawndeny = 0 },
	[3605] = {	id = 3605, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 360501, 360503, 360504, 360505, 360506, 360507, 360508, 360510, 360511,  } , spawndeny = 0 },
	[3606] = {	id = 3606, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 360602, 360603, 360604, 360605, 360606, 360607, 360608, 360609, 360611,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
