----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44301] = {	id = 44301, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44301, 44302, 44303, 44304, 44305, 44306,  } , spawndeny = 0 },
	[44311] = {	id = 44311, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44311, 44312, 44313, 44314,  } , spawndeny = 0 },
	[44321] = {	id = 44321, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44321, 44322, 44323, 44324,  } , spawndeny = 0 },
	[44331] = {	id = 44331, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44331,  } , spawndeny = 0 },
	[44332] = {	id = 44332, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44332,  } , spawndeny = 0 },
	[44333] = {	id = 44333, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44333,  } , spawndeny = 0 },
	[44334] = {	id = 44334, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44334,  } , spawndeny = 0 },
	[44341] = {	id = 44341, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44341, 44342, 44343, 44344,  } , spawndeny = 0 },
	[44351] = {	id = 44351, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44351, 44352, 44353, 44354, 44355, 44356,  } , spawndeny = 0 },
	[44361] = {	id = 44361, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44361, 44362, 44363, 44364,  } , spawndeny = 0 },
	[44371] = {	id = 44371, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44371, 44372, 44373, 44374,  } , spawndeny = 0 },
	[44381] = {	id = 44381, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44381,  } , spawndeny = 0 },
	[44382] = {	id = 44382, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44382,  } , spawndeny = 0 },
	[44383] = {	id = 44383, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44383,  } , spawndeny = 0 },
	[44384] = {	id = 44384, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44384,  } , spawndeny = 0 },
	[44391] = {	id = 44391, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44391, 44392, 44393, 44394,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
