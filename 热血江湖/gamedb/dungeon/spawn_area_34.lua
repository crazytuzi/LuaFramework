----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[3401] = {	id = 3401, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 340101, 340102, 340103,  } , spawndeny = 0 },
	[3402] = {	id = 3402, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 340201, 340202, 340203, 340204, 340205,  } , spawndeny = 0 },
	[3403] = {	id = 3403, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 340302, 340303, 340304, 340305, 340306,  } , spawndeny = 0 },
	[3404] = {	id = 3404, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 340402, 340403, 340404, 340405, 340406,  } , spawndeny = 0 },
	[3405] = {	id = 3405, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 340502, 340503, 340504, 340505, 340506, 340507,  } , spawndeny = 0 },
	[3406] = {	id = 3406, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 340602, 340603, 340604, 340605, 340607,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
