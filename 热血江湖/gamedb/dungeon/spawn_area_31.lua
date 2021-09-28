----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3101] = {	id = 3101, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300701, 300702,  } , spawndeny = 0 },
	[3102] = {	id = 3102, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 300703, 300704, 300705,  } , spawndeny = 0 },
	[3103] = {	id = 3103, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300706, 300707, 300708,  } , spawndeny = 0 },
	[3104] = {	id = 3104, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 300709, 300710, 300711, 300712, 300713,  } , spawndeny = 0 },
	[3105] = {	id = 3105, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300714, 300715, 300716, 300717, 300718, 300719, 300720, 300721, 300722, 300723,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
