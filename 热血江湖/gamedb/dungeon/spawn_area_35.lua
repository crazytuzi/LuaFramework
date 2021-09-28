----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3501] = {	id = 3501, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 350101, 350102, 350103, 350104,  } , spawndeny = 0 },
	[3502] = {	id = 3502, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 350201, 350202, 350203, 350204, 350205, 350206,  } , spawndeny = 0 },
	[3503] = {	id = 3503, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 350302, 350303, 350304, 350305, 350306, 350307,  } , spawndeny = 0 },
	[3504] = {	id = 3504, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 350401, 350402, 350403, 350404, 350405, 350406, 350407,  } , spawndeny = 0 },
	[3505] = {	id = 3505, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 350501, 350502, 350503, 350504, 350507, 350508, 350509,  } , spawndeny = 0 },
	[3506] = {	id = 3506, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 350601, 350602, 350603, 350604, 350605, 350606, 350609,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
