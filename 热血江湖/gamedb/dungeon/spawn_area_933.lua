----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[93301] = {	id = 93301, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93301,  } , spawndeny = 3000 },
	[93302] = {	id = 93302, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93302,  } , spawndeny = 3000 },
	[93303] = {	id = 93303, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93303,  } , spawndeny = 3000 },
	[93304] = {	id = 93304, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93304,  } , spawndeny = 3000 },
	[93305] = {	id = 93305, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93305,  } , spawndeny = 3000 },
	[93306] = {	id = 93306, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93306,  } , spawndeny = 3000 },
	[93307] = {	id = 93307, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93307,  } , spawndeny = 3000 },
	[93308] = {	id = 93308, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93308,  } , spawndeny = 3000 },
	[93309] = {	id = 93309, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93309,  } , spawndeny = 3000 },
	[93310] = {	id = 93310, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93310,  } , spawndeny = 3000 },
	[93311] = {	id = 93311, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93311,  } , spawndeny = 3000 },
	[93312] = {	id = 93312, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93312,  } , spawndeny = 3000 },
	[93313] = {	id = 93313, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93313,  } , spawndeny = 3000 },
	[93314] = {	id = 93314, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93314,  } , spawndeny = 3000 },
	[93315] = {	id = 93315, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93315,  } , spawndeny = 3000 },
	[93316] = {	id = 93316, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93316,  } , spawndeny = 3000 },
	[93317] = {	id = 93317, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93317,  } , spawndeny = 3000 },
	[93318] = {	id = 93318, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93318,  } , spawndeny = 3000 },
	[93319] = {	id = 93319, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93319,  } , spawndeny = 3000 },
	[93320] = {	id = 93320, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93320,  } , spawndeny = 3000 },
	[93321] = {	id = 93321, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93321,  } , spawndeny = 3000 },
	[93322] = {	id = 93322, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93322,  } , spawndeny = 3000 },
	[93323] = {	id = 93323, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93323,  } , spawndeny = 3000 },
	[93324] = {	id = 93324, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93324,  } , spawndeny = 3000 },
	[93325] = {	id = 93325, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93325,  } , spawndeny = 3000 },
	[93326] = {	id = 93326, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93326,  } , spawndeny = 3000 },
	[93327] = {	id = 93327, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93327,  } , spawndeny = 3000 },
	[93328] = {	id = 93328, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93328,  } , spawndeny = 3000 },
	[93329] = {	id = 93329, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93329,  } , spawndeny = 3000 },
	[93330] = {	id = 93330, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93330,  } , spawndeny = 3000 },
	[93331] = {	id = 93331, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93331,  } , spawndeny = 3000 },
	[93332] = {	id = 93332, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93332,  } , spawndeny = 3000 },
	[93333] = {	id = 93333, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93333,  } , spawndeny = 3000 },
	[93334] = {	id = 93334, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93334,  } , spawndeny = 3000 },
	[93335] = {	id = 93335, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93335,  } , spawndeny = 3000 },
	[93336] = {	id = 93336, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93336,  } , spawndeny = 3000 },
	[93337] = {	id = 93337, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93337,  } , spawndeny = 3000 },
	[93338] = {	id = 93338, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93338,  } , spawndeny = 3000 },
	[93339] = {	id = 93339, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93339,  } , spawndeny = 3000 },
	[93340] = {	id = 93340, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93340,  } , spawndeny = 3000 },
	[93341] = {	id = 93341, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93341,  } , spawndeny = 3000 },
	[93342] = {	id = 93342, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 93342,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
