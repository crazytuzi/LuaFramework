----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2801] = {	id = 2801, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 280101, 280102,  } , spawndeny = 0 },
	[2802] = {	id = 2802, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 280201, 280202, 280203,  } , spawndeny = 0 },
	[2803] = {	id = 2803, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 280301, 280302, 280303,  } , spawndeny = 0 },
	[2804] = {	id = 2804, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 280401, 280402, 280403, 280404, 280405,  } , spawndeny = 0 },
	[2805] = {	id = 2805, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 280501, 280502, 280503, 280504, 280505, 280506, 280507, 280508, 280601, 280602,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
