----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[71100] = {	id = 71100, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71100,  } , spawndeny = 0 },
	[71101] = {	id = 71101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71101,  } , spawndeny = 0 },
	[71102] = {	id = 71102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71102,  } , spawndeny = 0 },
	[71103] = {	id = 71103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71103,  } , spawndeny = 0 },
	[71104] = {	id = 71104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71104,  } , spawndeny = 0 },
	[71105] = {	id = 71105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71105,  } , spawndeny = 0 },
	[71106] = {	id = 71106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71106,  } , spawndeny = 0 },
	[71107] = {	id = 71107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71107,  } , spawndeny = 0 },
	[71108] = {	id = 71108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71108,  } , spawndeny = 0 },
	[71109] = {	id = 71109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71109,  } , spawndeny = 0 },
	[71110] = {	id = 71110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71110,  } , spawndeny = 0 },
	[71111] = {	id = 71111, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71111,  } , spawndeny = 0 },
	[71112] = {	id = 71112, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71112,  } , spawndeny = 0 },
	[71113] = {	id = 71113, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71113,  } , spawndeny = 0 },
	[71114] = {	id = 71114, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71114,  } , spawndeny = 0 },
	[71115] = {	id = 71115, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71115,  } , spawndeny = 0 },
	[71116] = {	id = 71116, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71116,  } , spawndeny = 0 },
	[71117] = {	id = 71117, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71117,  } , spawndeny = 0 },
	[71118] = {	id = 71118, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71118,  } , spawndeny = 0 },
	[71119] = {	id = 71119, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71119,  } , spawndeny = 0 },
	[71120] = {	id = 71120, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71120,  } , spawndeny = 0 },
	[71121] = {	id = 71121, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71121,  } , spawndeny = 0 },
	[71122] = {	id = 71122, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71122,  } , spawndeny = 0 },
	[71123] = {	id = 71123, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71123,  } , spawndeny = 0 },
	[71151] = {	id = 71151, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71151,  } , spawndeny = 0 },
	[71152] = {	id = 71152, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71152,  } , spawndeny = 0 },
	[71153] = {	id = 71153, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71153,  } , spawndeny = 0 },
	[71154] = {	id = 71154, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71154,  } , spawndeny = 0 },
	[71155] = {	id = 71155, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71155,  } , spawndeny = 0 },
	[71156] = {	id = 71156, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71156,  } , spawndeny = 0 },
	[71157] = {	id = 71157, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71157,  } , spawndeny = 0 },
	[71158] = {	id = 71158, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71158,  } , spawndeny = 0 },
	[71159] = {	id = 71159, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71159,  } , spawndeny = 0 },
	[71160] = {	id = 71160, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71160,  } , spawndeny = 0 },
	[71161] = {	id = 71161, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71161,  } , spawndeny = 0 },
	[71162] = {	id = 71162, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71162,  } , spawndeny = 0 },
	[71163] = {	id = 71163, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71163,  } , spawndeny = 0 },
	[71164] = {	id = 71164, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71164,  } , spawndeny = 0 },
	[71165] = {	id = 71165, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71165,  } , spawndeny = 0 },
	[71166] = {	id = 71166, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71166,  } , spawndeny = 0 },
	[71167] = {	id = 71167, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71167,  } , spawndeny = 0 },
	[71168] = {	id = 71168, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71168,  } , spawndeny = 0 },
	[71169] = {	id = 71169, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71169,  } , spawndeny = 0 },
	[71170] = {	id = 71170, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 71170,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
