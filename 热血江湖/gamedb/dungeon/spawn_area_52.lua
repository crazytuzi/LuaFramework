----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5201] = {	id = 5201, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 520101, 520102, 520103, 520104, 520105, 520106,  } , spawndeny = 0 },
	[5202] = {	id = 5202, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5001,  }, EndClose = {  }, spawnPoints = { 520107, 520108, 520109, 520110, 520111, 520112,  } , spawndeny = 0 },
	[5203] = {	id = 5203, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 520201, 520202, 520203, 520204, 520205, 520206, 520207, 520208,  } , spawndeny = 0 },
	[5204] = {	id = 5204, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5006,  }, EndClose = {  }, spawnPoints = { 520301, 520302, 520303, 520304, 520305, 520306, 520307, 520308, 520309, 520310,  } , spawndeny = 0 },
	[5205] = {	id = 5205, range = 2000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 520401, 520402, 520403, 520404, 520405, 520406, 520407, 520408, 520409,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
