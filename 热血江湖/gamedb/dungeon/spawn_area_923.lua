----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[92301] = {	id = 92301, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92301,  } , spawndeny = 3000 },
	[92302] = {	id = 92302, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92302,  } , spawndeny = 3000 },
	[92303] = {	id = 92303, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92303,  } , spawndeny = 3000 },
	[92304] = {	id = 92304, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92304,  } , spawndeny = 3000 },
	[92305] = {	id = 92305, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92305,  } , spawndeny = 3000 },
	[92306] = {	id = 92306, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92306,  } , spawndeny = 3000 },
	[92307] = {	id = 92307, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92307,  } , spawndeny = 3000 },
	[92308] = {	id = 92308, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92308,  } , spawndeny = 3000 },
	[92309] = {	id = 92309, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92309,  } , spawndeny = 3000 },
	[92310] = {	id = 92310, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92310,  } , spawndeny = 3000 },
	[92311] = {	id = 92311, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92311,  } , spawndeny = 3000 },
	[92312] = {	id = 92312, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92312,  } , spawndeny = 3000 },
	[92313] = {	id = 92313, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92313,  } , spawndeny = 3000 },
	[92314] = {	id = 92314, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92314,  } , spawndeny = 3000 },
	[92315] = {	id = 92315, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92315,  } , spawndeny = 3000 },
	[92316] = {	id = 92316, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92316,  } , spawndeny = 3000 },
	[92317] = {	id = 92317, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92317,  } , spawndeny = 3000 },
	[92318] = {	id = 92318, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92318,  } , spawndeny = 3000 },
	[92319] = {	id = 92319, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92319,  } , spawndeny = 3000 },
	[92320] = {	id = 92320, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92320,  } , spawndeny = 3000 },
	[92321] = {	id = 92321, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92321,  } , spawndeny = 3000 },
	[92322] = {	id = 92322, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92322,  } , spawndeny = 3000 },
	[92323] = {	id = 92323, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92323,  } , spawndeny = 3000 },
	[92324] = {	id = 92324, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92324,  } , spawndeny = 3000 },
	[92325] = {	id = 92325, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92325,  } , spawndeny = 3000 },
	[92326] = {	id = 92326, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92326,  } , spawndeny = 3000 },
	[92327] = {	id = 92327, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92327,  } , spawndeny = 3000 },
	[92328] = {	id = 92328, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92328,  } , spawndeny = 3000 },
	[92329] = {	id = 92329, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92329,  } , spawndeny = 3000 },
	[92330] = {	id = 92330, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92330,  } , spawndeny = 3000 },
	[92331] = {	id = 92331, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92331,  } , spawndeny = 3000 },
	[92332] = {	id = 92332, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92332,  } , spawndeny = 3000 },
	[92333] = {	id = 92333, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92333,  } , spawndeny = 3000 },
	[92334] = {	id = 92334, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92334,  } , spawndeny = 3000 },
	[92335] = {	id = 92335, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92335,  } , spawndeny = 3000 },
	[92336] = {	id = 92336, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92336,  } , spawndeny = 3000 },
	[92337] = {	id = 92337, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92337,  } , spawndeny = 3000 },
	[92338] = {	id = 92338, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92338,  } , spawndeny = 3000 },
	[92339] = {	id = 92339, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92339,  } , spawndeny = 3000 },
	[92340] = {	id = 92340, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92340,  } , spawndeny = 3000 },
	[92341] = {	id = 92341, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92341,  } , spawndeny = 3000 },
	[92342] = {	id = 92342, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92342,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
