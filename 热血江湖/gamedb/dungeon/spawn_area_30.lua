----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3001] = {	id = 3001, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300101, 300102,  } , spawndeny = 0 },
	[3002] = {	id = 3002, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 300201, 300202, 300203,  } , spawndeny = 0 },
	[3003] = {	id = 3003, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300301, 300302, 300303,  } , spawndeny = 0 },
	[3004] = {	id = 3004, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 300401, 300402, 300403, 300404, 300405,  } , spawndeny = 0 },
	[3005] = {	id = 3005, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300501, 300502, 300503, 300504, 300505, 300506, 300507, 300508, 300601, 300602,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
