----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[91201] = {	id = 91201, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91201,  } , spawndeny = 3000 },
	[91202] = {	id = 91202, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91202,  } , spawndeny = 3000 },
	[91203] = {	id = 91203, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91203,  } , spawndeny = 3000 },
	[91204] = {	id = 91204, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91204,  } , spawndeny = 3000 },
	[91205] = {	id = 91205, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91205,  } , spawndeny = 3000 },
	[91206] = {	id = 91206, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91206,  } , spawndeny = 3000 },
	[91207] = {	id = 91207, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91207,  } , spawndeny = 3000 },
	[91208] = {	id = 91208, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91208,  } , spawndeny = 3000 },
	[91209] = {	id = 91209, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91209,  } , spawndeny = 3000 },
	[91210] = {	id = 91210, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91210,  } , spawndeny = 3000 },
	[91211] = {	id = 91211, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91211,  } , spawndeny = 3000 },
	[91212] = {	id = 91212, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91212,  } , spawndeny = 3000 },
	[91213] = {	id = 91213, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91213,  } , spawndeny = 3000 },
	[91214] = {	id = 91214, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91214,  } , spawndeny = 3000 },
	[91215] = {	id = 91215, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91215,  } , spawndeny = 3000 },
	[91216] = {	id = 91216, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91216,  } , spawndeny = 3000 },
	[91217] = {	id = 91217, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91217,  } , spawndeny = 3000 },
	[91218] = {	id = 91218, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91218,  } , spawndeny = 3000 },
	[91219] = {	id = 91219, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91219,  } , spawndeny = 3000 },
	[91220] = {	id = 91220, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91220,  } , spawndeny = 3000 },
	[91221] = {	id = 91221, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91221,  } , spawndeny = 3000 },
	[91222] = {	id = 91222, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91222,  } , spawndeny = 3000 },
	[91223] = {	id = 91223, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91223,  } , spawndeny = 3000 },
	[91224] = {	id = 91224, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91224,  } , spawndeny = 3000 },
	[91225] = {	id = 91225, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91225,  } , spawndeny = 3000 },
	[91226] = {	id = 91226, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91226,  } , spawndeny = 3000 },
	[91227] = {	id = 91227, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91227,  } , spawndeny = 3000 },
	[91228] = {	id = 91228, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91228,  } , spawndeny = 3000 },
	[91229] = {	id = 91229, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91229,  } , spawndeny = 3000 },
	[91230] = {	id = 91230, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91230,  } , spawndeny = 3000 },
	[91231] = {	id = 91231, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91231,  } , spawndeny = 3000 },
	[91232] = {	id = 91232, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91232,  } , spawndeny = 3000 },
	[91233] = {	id = 91233, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91233,  } , spawndeny = 3000 },
	[91234] = {	id = 91234, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91234,  } , spawndeny = 3000 },
	[91235] = {	id = 91235, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91235,  } , spawndeny = 3000 },
	[91236] = {	id = 91236, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91236,  } , spawndeny = 3000 },
	[91237] = {	id = 91237, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91237,  } , spawndeny = 3000 },
	[91238] = {	id = 91238, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91238,  } , spawndeny = 3000 },
	[91239] = {	id = 91239, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91239,  } , spawndeny = 3000 },
	[91240] = {	id = 91240, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91240,  } , spawndeny = 3000 },
	[91241] = {	id = 91241, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91241,  } , spawndeny = 3000 },
	[91242] = {	id = 91242, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91242,  } , spawndeny = 3000 },
	[91243] = {	id = 91243, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91243,  } , spawndeny = 3000 },
	[91244] = {	id = 91244, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91244,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
