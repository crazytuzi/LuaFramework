----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[71201] = {	id = 71201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71201,  } , spawndeny = 0 },
	[71202] = {	id = 71202, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71202,  } , spawndeny = 0 },
	[71203] = {	id = 71203, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71203,  } , spawndeny = 0 },
	[71204] = {	id = 71204, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71204, 71205,  } , spawndeny = 0 },
	[71211] = {	id = 71211, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71211,  } , spawndeny = 0 },
	[71212] = {	id = 71212, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71212,  } , spawndeny = 0 },
	[71213] = {	id = 71213, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71213,  } , spawndeny = 0 },
	[71214] = {	id = 71214, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71214, 71215,  } , spawndeny = 0 },
	[71221] = {	id = 71221, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71221,  } , spawndeny = 0 },
	[71222] = {	id = 71222, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71222,  } , spawndeny = 0 },
	[71223] = {	id = 71223, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71223,  } , spawndeny = 0 },
	[71224] = {	id = 71224, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71224, 71225,  } , spawndeny = 0 },
	[71231] = {	id = 71231, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71231,  } , spawndeny = 0 },
	[71232] = {	id = 71232, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71232,  } , spawndeny = 0 },
	[71233] = {	id = 71233, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71233,  } , spawndeny = 0 },
	[71234] = {	id = 71234, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71234, 71235,  } , spawndeny = 0 },
	[71241] = {	id = 71241, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71241,  } , spawndeny = 0 },
	[71242] = {	id = 71242, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71242,  } , spawndeny = 0 },
	[71243] = {	id = 71243, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71243,  } , spawndeny = 0 },
	[71244] = {	id = 71244, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71244, 71245,  } , spawndeny = 0 },
	[71251] = {	id = 71251, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71251,  } , spawndeny = 0 },
	[71252] = {	id = 71252, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71252,  } , spawndeny = 0 },
	[71253] = {	id = 71253, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71253,  } , spawndeny = 0 },
	[71254] = {	id = 71254, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71254, 71255,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
