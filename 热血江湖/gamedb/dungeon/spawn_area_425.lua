----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42501] = {	id = 42501, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42501,  } , spawndeny = 0 },
	[42511] = {	id = 42511, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42511, 42512, 42513, 42514,  } , spawndeny = 0 },
	[42521] = {	id = 42521, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42521, 42522, 42523, 42524,  } , spawndeny = 0 },
	[42531] = {	id = 42531, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42531,  } , spawndeny = 0 },
	[42532] = {	id = 42532, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42532,  } , spawndeny = 0 },
	[42533] = {	id = 42533, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42533,  } , spawndeny = 0 },
	[42534] = {	id = 42534, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42534,  } , spawndeny = 0 },
	[42541] = {	id = 42541, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42541, 42542, 42543, 42544,  } , spawndeny = 0 },
	[42551] = {	id = 42551, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42551,  } , spawndeny = 0 },
	[42561] = {	id = 42561, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42561, 42562, 42563, 42564,  } , spawndeny = 0 },
	[42571] = {	id = 42571, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42571, 42572, 42573, 42574,  } , spawndeny = 0 },
	[42581] = {	id = 42581, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42581,  } , spawndeny = 0 },
	[42582] = {	id = 42582, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42582,  } , spawndeny = 0 },
	[42583] = {	id = 42583, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42583,  } , spawndeny = 0 },
	[42584] = {	id = 42584, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42584,  } , spawndeny = 0 },
	[42591] = {	id = 42591, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42591, 42592, 42593, 42594,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
