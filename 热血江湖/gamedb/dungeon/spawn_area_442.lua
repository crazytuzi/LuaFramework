----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44201] = {	id = 44201, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44201, 44202, 44203, 44204, 44205,  } , spawndeny = 0 },
	[44211] = {	id = 44211, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44211, 44212, 44213, 44214,  } , spawndeny = 0 },
	[44221] = {	id = 44221, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44221, 44222, 44223, 44224,  } , spawndeny = 0 },
	[44231] = {	id = 44231, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44231,  } , spawndeny = 0 },
	[44232] = {	id = 44232, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44232,  } , spawndeny = 0 },
	[44233] = {	id = 44233, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44233,  } , spawndeny = 0 },
	[44234] = {	id = 44234, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44234,  } , spawndeny = 0 },
	[44241] = {	id = 44241, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44241, 44242, 44243, 44244,  } , spawndeny = 0 },
	[44251] = {	id = 44251, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44251, 44252, 44253, 44254, 44255,  } , spawndeny = 0 },
	[44261] = {	id = 44261, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44261, 44262, 44263, 44264,  } , spawndeny = 0 },
	[44271] = {	id = 44271, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44271, 44272, 44273, 44274,  } , spawndeny = 0 },
	[44281] = {	id = 44281, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44281,  } , spawndeny = 0 },
	[44282] = {	id = 44282, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44282,  } , spawndeny = 0 },
	[44283] = {	id = 44283, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44283,  } , spawndeny = 0 },
	[44284] = {	id = 44284, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44284,  } , spawndeny = 0 },
	[44291] = {	id = 44291, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44291, 44292, 44293, 44294,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
