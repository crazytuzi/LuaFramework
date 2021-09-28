----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[11301] = {	id = 11301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110301,  } , spawndeny = 0 },
	[11302] = {	id = 11302, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110302,  } , spawndeny = 0 },
	[11303] = {	id = 11303, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110303, 110304,  } , spawndeny = 0 },
	[11304] = {	id = 11304, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110305,  } , spawndeny = 0 },
	[11311] = {	id = 11311, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110311,  } , spawndeny = 0 },
	[11312] = {	id = 11312, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110312,  } , spawndeny = 0 },
	[11313] = {	id = 11313, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110313, 110314,  } , spawndeny = 0 },
	[11314] = {	id = 11314, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110315,  } , spawndeny = 0 },
	[11321] = {	id = 11321, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110321,  } , spawndeny = 0 },
	[11322] = {	id = 11322, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110322,  } , spawndeny = 0 },
	[11323] = {	id = 11323, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110323, 110324,  } , spawndeny = 0 },
	[11324] = {	id = 11324, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110325,  } , spawndeny = 0 },
	[11331] = {	id = 11331, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110331,  } , spawndeny = 0 },
	[11332] = {	id = 11332, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110332,  } , spawndeny = 0 },
	[11333] = {	id = 11333, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110333, 110334,  } , spawndeny = 0 },
	[11334] = {	id = 11334, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110335,  } , spawndeny = 0 },
	[11341] = {	id = 11341, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110341,  } , spawndeny = 0 },
	[11342] = {	id = 11342, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110342,  } , spawndeny = 0 },
	[11343] = {	id = 11343, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110343, 110344,  } , spawndeny = 0 },
	[11344] = {	id = 11344, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110345,  } , spawndeny = 0 },
	[11351] = {	id = 11351, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110351,  } , spawndeny = 0 },
	[11352] = {	id = 11352, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110352,  } , spawndeny = 0 },
	[11353] = {	id = 11353, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110353, 110354,  } , spawndeny = 0 },
	[11354] = {	id = 11354, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110355,  } , spawndeny = 0 },
	[11361] = {	id = 11361, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110361,  } , spawndeny = 0 },
	[11362] = {	id = 11362, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110362,  } , spawndeny = 0 },
	[11363] = {	id = 11363, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110363, 110364,  } , spawndeny = 0 },
	[11364] = {	id = 11364, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110365,  } , spawndeny = 0 },
	[11371] = {	id = 11371, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110371,  } , spawndeny = 0 },
	[11372] = {	id = 11372, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110372,  } , spawndeny = 0 },
	[11373] = {	id = 11373, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110373, 110374,  } , spawndeny = 0 },
	[11374] = {	id = 11374, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110375,  } , spawndeny = 0 },
	[11381] = {	id = 11381, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110381,  } , spawndeny = 0 },
	[11382] = {	id = 11382, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110382,  } , spawndeny = 0 },
	[11383] = {	id = 11383, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110383, 110384,  } , spawndeny = 0 },
	[11384] = {	id = 11384, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110385,  } , spawndeny = 0 },
	[11391] = {	id = 11391, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110391,  } , spawndeny = 0 },
	[11392] = {	id = 11392, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110392,  } , spawndeny = 0 },
	[11393] = {	id = 11393, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110393, 110394,  } , spawndeny = 0 },
	[11394] = {	id = 11394, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 110395,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
