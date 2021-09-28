----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4201] = {	id = 4201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 420101, 420102, 420103, 420104, 420105,  } , spawndeny = 0 },
	[4202] = {	id = 4202, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 420202, 420203, 420204, 420205, 420206, 420207, 420208, 420209, 420210, 420211,  } , spawndeny = 0 },
	[4203] = {	id = 4203, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 420301, 420302, 420303, 420304, 420305, 420306, 420307, 420308, 420309, 420310,  } , spawndeny = 0 },
	[4204] = {	id = 4204, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 420401, 420402, 420403, 420404, 420405, 420406, 420407, 420408, 420409, 420410,  } , spawndeny = 0 },
	[4205] = {	id = 4205, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 420503, 420504, 420505, 420506, 420507, 420508, 420509, 420510, 420511,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
