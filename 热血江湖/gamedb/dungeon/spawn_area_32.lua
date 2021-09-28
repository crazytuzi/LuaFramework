----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3201] = {	id = 3201, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300801, 300802,  } , spawndeny = 0 },
	[3202] = {	id = 3202, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 300803, 300804, 300805,  } , spawndeny = 0 },
	[3203] = {	id = 3203, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300806, 300807, 300808,  } , spawndeny = 0 },
	[3204] = {	id = 3204, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 300809, 300810, 300811, 300812, 300813,  } , spawndeny = 0 },
	[3205] = {	id = 3205, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300814, 300815, 300816, 300817, 300818, 300819, 300820, 300821, 300822, 300823,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
