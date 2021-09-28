----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42301] = {	id = 42301, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42301,  } , spawndeny = 0 },
	[42311] = {	id = 42311, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42311, 42312, 42313, 42314,  } , spawndeny = 0 },
	[42321] = {	id = 42321, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42321, 42322, 42323, 42324,  } , spawndeny = 0 },
	[42331] = {	id = 42331, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42331,  } , spawndeny = 0 },
	[42332] = {	id = 42332, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42332,  } , spawndeny = 0 },
	[42333] = {	id = 42333, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42333,  } , spawndeny = 0 },
	[42334] = {	id = 42334, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42334,  } , spawndeny = 0 },
	[42341] = {	id = 42341, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42341, 42342, 42343, 42344,  } , spawndeny = 0 },
	[42351] = {	id = 42351, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42351,  } , spawndeny = 0 },
	[42361] = {	id = 42361, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42361, 42362, 42363, 42364,  } , spawndeny = 0 },
	[42371] = {	id = 42371, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42371, 42372, 42373, 42374,  } , spawndeny = 0 },
	[42381] = {	id = 42381, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42381,  } , spawndeny = 0 },
	[42382] = {	id = 42382, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42382,  } , spawndeny = 0 },
	[42383] = {	id = 42383, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42383,  } , spawndeny = 0 },
	[42384] = {	id = 42384, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42384,  } , spawndeny = 0 },
	[42391] = {	id = 42391, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42391, 42392, 42393, 42394,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
