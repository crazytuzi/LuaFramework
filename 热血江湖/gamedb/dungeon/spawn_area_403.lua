----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40301] = {	id = 40301, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40301,  } , spawndeny = 0 },
	[40311] = {	id = 40311, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40311, 40312, 40313, 40314,  } , spawndeny = 0 },
	[40321] = {	id = 40321, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40321, 40322, 40323, 40324,  } , spawndeny = 0 },
	[40331] = {	id = 40331, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40331,  } , spawndeny = 0 },
	[40332] = {	id = 40332, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40332,  } , spawndeny = 0 },
	[40333] = {	id = 40333, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40333,  } , spawndeny = 0 },
	[40334] = {	id = 40334, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40334,  } , spawndeny = 0 },
	[40341] = {	id = 40341, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40341, 40342, 40343, 40344,  } , spawndeny = 0 },
	[40351] = {	id = 40351, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40351,  } , spawndeny = 0 },
	[40361] = {	id = 40361, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40361, 40362, 40363, 40364,  } , spawndeny = 0 },
	[40371] = {	id = 40371, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40371, 40372, 40373, 40374,  } , spawndeny = 0 },
	[40381] = {	id = 40381, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40381,  } , spawndeny = 0 },
	[40382] = {	id = 40382, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40382,  } , spawndeny = 0 },
	[40383] = {	id = 40383, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40383,  } , spawndeny = 0 },
	[40384] = {	id = 40384, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40384,  } , spawndeny = 0 },
	[40391] = {	id = 40391, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40391, 40392, 40393, 40394,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
