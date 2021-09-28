----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43301] = {	id = 43301, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43301, 43302,  } , spawndeny = 0 },
	[43311] = {	id = 43311, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43311, 43312, 43313, 43314,  } , spawndeny = 0 },
	[43321] = {	id = 43321, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43321, 43322, 43323, 43324,  } , spawndeny = 0 },
	[43331] = {	id = 43331, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43331,  } , spawndeny = 0 },
	[43332] = {	id = 43332, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43332,  } , spawndeny = 0 },
	[43333] = {	id = 43333, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43333,  } , spawndeny = 0 },
	[43334] = {	id = 43334, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43334,  } , spawndeny = 0 },
	[43341] = {	id = 43341, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43341, 43342, 43343, 43344,  } , spawndeny = 0 },
	[43351] = {	id = 43351, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43351, 43352,  } , spawndeny = 0 },
	[43361] = {	id = 43361, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43361, 43362, 43363, 43364,  } , spawndeny = 0 },
	[43371] = {	id = 43371, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43371, 43372, 43373, 43374,  } , spawndeny = 0 },
	[43381] = {	id = 43381, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43381,  } , spawndeny = 0 },
	[43382] = {	id = 43382, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43382,  } , spawndeny = 0 },
	[43383] = {	id = 43383, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43383,  } , spawndeny = 0 },
	[43384] = {	id = 43384, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43384,  } , spawndeny = 0 },
	[43391] = {	id = 43391, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43391, 43392, 43393, 43394,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
