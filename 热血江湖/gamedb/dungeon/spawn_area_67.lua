----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6701] = {	id = 6701, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6501,  }, EndClose = {  }, spawnPoints = { 670101, 670102, 670103, 670104, 670105, 670106, 670107,  } , spawndeny = 0 },
	[6702] = {	id = 6702, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6502,  }, EndClose = {  }, spawnPoints = { 670201, 670202, 670203, 670204, 670205, 670206, 670207, 670208, 670209, 670210,  } , spawndeny = 0 },
	[6703] = {	id = 6703, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 670301, 670302, 670303, 670304, 670305, 670306, 670307,  } , spawndeny = 0 },
	[6704] = {	id = 6704, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 670308,  } , spawndeny = 0 },
	[6705] = {	id = 6705, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 670309,  } , spawndeny = 0 },
	[6706] = {	id = 6706, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 670310,  } , spawndeny = 0 },
	[6707] = {	id = 6707, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6503,  }, EndClose = {  }, spawnPoints = { 670311,  } , spawndeny = 0 },
	[6708] = {	id = 6708, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 670401, 670402, 670403, 670404, 670405, 670406, 670407, 670408, 670409, 670410, 670411, 670412, 670413,  } , spawndeny = 0 },
	[6770] = {	id = 6770, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 30010, 30011, 30012, 0,  }, EndClose = {  }, spawnPoints = { 677701,  } , spawndeny = 0 },
	[6771] = {	id = 6771, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 30010, 30011, 30012, 0,  }, EndClose = {  }, spawnPoints = { 677702,  } , spawndeny = 0 },
	[6772] = {	id = 6772, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 30010, 30011, 30012, 0,  }, EndClose = {  }, spawnPoints = { 677703,  } , spawndeny = 0 },
	[6773] = {	id = 6773, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 30010, 30011, 30012, 0,  }, EndClose = {  }, spawnPoints = { 677704,  } , spawndeny = 0 },
	[6774] = {	id = 6774, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 30010, 30011, 30012, 0,  }, EndClose = {  }, spawnPoints = { 677705,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
