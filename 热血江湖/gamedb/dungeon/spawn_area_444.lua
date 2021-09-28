----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44401] = {	id = 44401, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44401, 44402, 44403, 44404, 44405, 44406,  } , spawndeny = 0 },
	[44411] = {	id = 44411, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44411, 44412, 44413, 44414,  } , spawndeny = 0 },
	[44421] = {	id = 44421, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44421, 44422, 44423, 44424,  } , spawndeny = 0 },
	[44431] = {	id = 44431, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44431,  } , spawndeny = 0 },
	[44432] = {	id = 44432, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44432,  } , spawndeny = 0 },
	[44433] = {	id = 44433, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44433,  } , spawndeny = 0 },
	[44434] = {	id = 44434, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44434,  } , spawndeny = 0 },
	[44441] = {	id = 44441, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44441, 44442, 44443, 44444,  } , spawndeny = 0 },
	[44451] = {	id = 44451, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44451, 44452, 44453, 44454, 44455, 44456,  } , spawndeny = 0 },
	[44461] = {	id = 44461, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44461, 44462, 44463, 44464,  } , spawndeny = 0 },
	[44471] = {	id = 44471, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44471, 44472, 44473, 44474,  } , spawndeny = 0 },
	[44481] = {	id = 44481, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44481,  } , spawndeny = 0 },
	[44482] = {	id = 44482, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44482,  } , spawndeny = 0 },
	[44483] = {	id = 44483, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44483,  } , spawndeny = 0 },
	[44484] = {	id = 44484, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44484,  } , spawndeny = 0 },
	[44491] = {	id = 44491, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44491, 44492, 44493, 44494,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
