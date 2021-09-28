----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[91301] = {	id = 91301, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91301,  } , spawndeny = 3000 },
	[91302] = {	id = 91302, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91302,  } , spawndeny = 3000 },
	[91303] = {	id = 91303, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91303,  } , spawndeny = 3000 },
	[91304] = {	id = 91304, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91304,  } , spawndeny = 3000 },
	[91305] = {	id = 91305, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91305,  } , spawndeny = 3000 },
	[91306] = {	id = 91306, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91306,  } , spawndeny = 3000 },
	[91307] = {	id = 91307, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91307,  } , spawndeny = 3000 },
	[91308] = {	id = 91308, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91308,  } , spawndeny = 3000 },
	[91309] = {	id = 91309, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91309,  } , spawndeny = 3000 },
	[91310] = {	id = 91310, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91310,  } , spawndeny = 3000 },
	[91311] = {	id = 91311, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91311,  } , spawndeny = 3000 },
	[91312] = {	id = 91312, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91312,  } , spawndeny = 3000 },
	[91313] = {	id = 91313, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91313,  } , spawndeny = 3000 },
	[91314] = {	id = 91314, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91314,  } , spawndeny = 3000 },
	[91315] = {	id = 91315, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91315,  } , spawndeny = 3000 },
	[91316] = {	id = 91316, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91316,  } , spawndeny = 3000 },
	[91317] = {	id = 91317, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91317,  } , spawndeny = 3000 },
	[91318] = {	id = 91318, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91318,  } , spawndeny = 3000 },
	[91319] = {	id = 91319, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91319,  } , spawndeny = 3000 },
	[91320] = {	id = 91320, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91320,  } , spawndeny = 3000 },
	[91321] = {	id = 91321, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91321,  } , spawndeny = 3000 },
	[91322] = {	id = 91322, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91322,  } , spawndeny = 3000 },
	[91323] = {	id = 91323, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91323,  } , spawndeny = 3000 },
	[91324] = {	id = 91324, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91324,  } , spawndeny = 3000 },
	[91325] = {	id = 91325, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91325,  } , spawndeny = 3000 },
	[91326] = {	id = 91326, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91326,  } , spawndeny = 3000 },
	[91327] = {	id = 91327, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91327,  } , spawndeny = 3000 },
	[91328] = {	id = 91328, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91328,  } , spawndeny = 3000 },
	[91329] = {	id = 91329, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91329,  } , spawndeny = 3000 },
	[91330] = {	id = 91330, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91330,  } , spawndeny = 3000 },
	[91331] = {	id = 91331, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91331,  } , spawndeny = 3000 },
	[91332] = {	id = 91332, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91332,  } , spawndeny = 3000 },
	[91333] = {	id = 91333, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91333,  } , spawndeny = 3000 },
	[91334] = {	id = 91334, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91334,  } , spawndeny = 3000 },
	[91335] = {	id = 91335, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91335,  } , spawndeny = 3000 },
	[91336] = {	id = 91336, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91336,  } , spawndeny = 3000 },
	[91337] = {	id = 91337, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91337,  } , spawndeny = 3000 },
	[91338] = {	id = 91338, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91338,  } , spawndeny = 3000 },
	[91339] = {	id = 91339, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91339,  } , spawndeny = 3000 },
	[91340] = {	id = 91340, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91340,  } , spawndeny = 3000 },
	[91341] = {	id = 91341, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91341,  } , spawndeny = 3000 },
	[91342] = {	id = 91342, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91342,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
