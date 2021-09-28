----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2701] = {	id = 2701, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 270101, 270102,  } , spawndeny = 0 },
	[2702] = {	id = 2702, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 270201, 270202, 270203,  } , spawndeny = 0 },
	[2703] = {	id = 2703, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 270301, 270302, 270303,  } , spawndeny = 0 },
	[2704] = {	id = 2704, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 270401, 270402, 270403, 270404, 270405,  } , spawndeny = 0 },
	[2705] = {	id = 2705, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 270501, 270502, 270503, 270504, 270505, 270506, 270507, 270508, 270601, 270602,  } , spawndeny = 0 },
	[2711] = {	id = 2711, range = 950.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2701,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300901, 300902,  } , spawndeny = 0 },
	[2712] = {	id = 2712, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2701,  }, EndClose = {  }, spawnPoints = { 300903, 300904, 300905,  } , spawndeny = 0 },
	[2713] = {	id = 2713, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2702,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300906, 300907, 300908,  } , spawndeny = 0 },
	[2714] = {	id = 2714, range = 900.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2702,  }, EndClose = {  }, spawnPoints = { 300909, 300910, 300911, 300912, 300913,  } , spawndeny = 0 },
	[2715] = {	id = 2715, range = 350.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 300914, 300915, 300916, 300917, 300918, 300919, 300920, 300921, 300922, 300923,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
