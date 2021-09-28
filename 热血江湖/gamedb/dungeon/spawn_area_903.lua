----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[90301] = {	id = 90301, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90301,  } , spawndeny = 3000 },
	[90302] = {	id = 90302, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90302,  } , spawndeny = 3000 },
	[90303] = {	id = 90303, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90303,  } , spawndeny = 3000 },
	[90304] = {	id = 90304, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90304,  } , spawndeny = 3000 },
	[90305] = {	id = 90305, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90305,  } , spawndeny = 3000 },
	[90306] = {	id = 90306, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90306,  } , spawndeny = 3000 },
	[90307] = {	id = 90307, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90307,  } , spawndeny = 3000 },
	[90308] = {	id = 90308, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90308,  } , spawndeny = 3000 },
	[90309] = {	id = 90309, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90309,  } , spawndeny = 3000 },
	[90310] = {	id = 90310, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90310,  } , spawndeny = 3000 },
	[90311] = {	id = 90311, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90311,  } , spawndeny = 3000 },
	[90312] = {	id = 90312, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90312,  } , spawndeny = 3000 },
	[90313] = {	id = 90313, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90313,  } , spawndeny = 3000 },
	[90314] = {	id = 90314, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90314,  } , spawndeny = 3000 },
	[90315] = {	id = 90315, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90315,  } , spawndeny = 3000 },
	[90316] = {	id = 90316, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90316,  } , spawndeny = 3000 },
	[90317] = {	id = 90317, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90317,  } , spawndeny = 3000 },
	[90318] = {	id = 90318, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90318,  } , spawndeny = 3000 },
	[90319] = {	id = 90319, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90319,  } , spawndeny = 3000 },
	[90320] = {	id = 90320, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90320,  } , spawndeny = 3000 },
	[90321] = {	id = 90321, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90321,  } , spawndeny = 3000 },
	[90322] = {	id = 90322, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90322,  } , spawndeny = 3000 },
	[90323] = {	id = 90323, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90323,  } , spawndeny = 3000 },
	[90324] = {	id = 90324, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90324,  } , spawndeny = 3000 },
	[90325] = {	id = 90325, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90325,  } , spawndeny = 3000 },
	[90326] = {	id = 90326, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90326,  } , spawndeny = 3000 },
	[90327] = {	id = 90327, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90327,  } , spawndeny = 3000 },
	[90328] = {	id = 90328, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90328,  } , spawndeny = 3000 },
	[90329] = {	id = 90329, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90329,  } , spawndeny = 3000 },
	[90330] = {	id = 90330, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90330,  } , spawndeny = 3000 },
	[90331] = {	id = 90331, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90331,  } , spawndeny = 3000 },
	[90332] = {	id = 90332, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90332,  } , spawndeny = 3000 },
	[90333] = {	id = 90333, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90333,  } , spawndeny = 3000 },
	[90334] = {	id = 90334, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90334,  } , spawndeny = 3000 },
	[90335] = {	id = 90335, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90335,  } , spawndeny = 3000 },
	[90336] = {	id = 90336, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90336,  } , spawndeny = 3000 },
	[90337] = {	id = 90337, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90337,  } , spawndeny = 3000 },
	[90338] = {	id = 90338, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90338,  } , spawndeny = 3000 },
	[90339] = {	id = 90339, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90339,  } , spawndeny = 3000 },
	[90340] = {	id = 90340, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90340,  } , spawndeny = 3000 },
	[90341] = {	id = 90341, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90341,  } , spawndeny = 3000 },
	[90342] = {	id = 90342, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 90342,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
