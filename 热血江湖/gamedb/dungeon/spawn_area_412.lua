----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41201] = {	id = 41201, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41201,  } , spawndeny = 0 },
	[41211] = {	id = 41211, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41211, 41212, 41213, 41214,  } , spawndeny = 0 },
	[41221] = {	id = 41221, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41221, 41222, 41223, 41224,  } , spawndeny = 0 },
	[41231] = {	id = 41231, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41231,  } , spawndeny = 0 },
	[41232] = {	id = 41232, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41232,  } , spawndeny = 0 },
	[41233] = {	id = 41233, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41233,  } , spawndeny = 0 },
	[41234] = {	id = 41234, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41234,  } , spawndeny = 0 },
	[41241] = {	id = 41241, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41241, 41242, 41243, 41244,  } , spawndeny = 0 },
	[41251] = {	id = 41251, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41251,  } , spawndeny = 0 },
	[41261] = {	id = 41261, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41261, 41262, 41263, 41264,  } , spawndeny = 0 },
	[41271] = {	id = 41271, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41271, 41272, 41273, 41274,  } , spawndeny = 0 },
	[41281] = {	id = 41281, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41281,  } , spawndeny = 0 },
	[41282] = {	id = 41282, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41282,  } , spawndeny = 0 },
	[41283] = {	id = 41283, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41283,  } , spawndeny = 0 },
	[41284] = {	id = 41284, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41284,  } , spawndeny = 0 },
	[41291] = {	id = 41291, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41291, 41292, 41293, 41294,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
