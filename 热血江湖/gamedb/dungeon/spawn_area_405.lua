----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40501] = {	id = 40501, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40501,  } , spawndeny = 0 },
	[40511] = {	id = 40511, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40511, 40512, 40513, 40514,  } , spawndeny = 0 },
	[40521] = {	id = 40521, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40521, 40522, 40523, 40524,  } , spawndeny = 0 },
	[40531] = {	id = 40531, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40531,  } , spawndeny = 0 },
	[40532] = {	id = 40532, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40532,  } , spawndeny = 0 },
	[40533] = {	id = 40533, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40533,  } , spawndeny = 0 },
	[40534] = {	id = 40534, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40534,  } , spawndeny = 0 },
	[40541] = {	id = 40541, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40541, 40542, 40543, 40544,  } , spawndeny = 0 },
	[40551] = {	id = 40551, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40551,  } , spawndeny = 0 },
	[40561] = {	id = 40561, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40561, 40562, 40563, 40564,  } , spawndeny = 0 },
	[40571] = {	id = 40571, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40571, 40572, 40573, 40574,  } , spawndeny = 0 },
	[40581] = {	id = 40581, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40581,  } , spawndeny = 0 },
	[40582] = {	id = 40582, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40582,  } , spawndeny = 0 },
	[40583] = {	id = 40583, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40583,  } , spawndeny = 0 },
	[40584] = {	id = 40584, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40584,  } , spawndeny = 0 },
	[40591] = {	id = 40591, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40591, 40592, 40593, 40594,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
