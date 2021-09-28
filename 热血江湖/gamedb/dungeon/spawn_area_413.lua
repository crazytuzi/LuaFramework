----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41301] = {	id = 41301, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41301,  } , spawndeny = 0 },
	[41311] = {	id = 41311, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41311, 41312, 41313, 41314,  } , spawndeny = 0 },
	[41321] = {	id = 41321, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41321, 41322, 41323, 41324,  } , spawndeny = 0 },
	[41331] = {	id = 41331, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41331,  } , spawndeny = 0 },
	[41332] = {	id = 41332, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41332,  } , spawndeny = 0 },
	[41333] = {	id = 41333, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41333,  } , spawndeny = 0 },
	[41334] = {	id = 41334, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41334,  } , spawndeny = 0 },
	[41341] = {	id = 41341, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41341, 41342, 41343, 41344,  } , spawndeny = 0 },
	[41351] = {	id = 41351, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41351,  } , spawndeny = 0 },
	[41361] = {	id = 41361, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41361, 41362, 41363, 41364,  } , spawndeny = 0 },
	[41371] = {	id = 41371, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41371, 41372, 41373, 41374,  } , spawndeny = 0 },
	[41381] = {	id = 41381, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41381,  } , spawndeny = 0 },
	[41382] = {	id = 41382, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41382,  } , spawndeny = 0 },
	[41383] = {	id = 41383, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41383,  } , spawndeny = 0 },
	[41384] = {	id = 41384, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41384,  } , spawndeny = 0 },
	[41391] = {	id = 41391, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41391, 41392, 41393, 41394,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
