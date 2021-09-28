----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43201] = {	id = 43201, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43201, 43202,  } , spawndeny = 0 },
	[43211] = {	id = 43211, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43211, 43212, 43213, 43214,  } , spawndeny = 0 },
	[43221] = {	id = 43221, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43221, 43222, 43223, 43224,  } , spawndeny = 0 },
	[43231] = {	id = 43231, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43231,  } , spawndeny = 0 },
	[43232] = {	id = 43232, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43232,  } , spawndeny = 0 },
	[43233] = {	id = 43233, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43233,  } , spawndeny = 0 },
	[43234] = {	id = 43234, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43234,  } , spawndeny = 0 },
	[43241] = {	id = 43241, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43241, 43242, 43243, 43244,  } , spawndeny = 0 },
	[43251] = {	id = 43251, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43251, 43252,  } , spawndeny = 0 },
	[43261] = {	id = 43261, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43261, 43262, 43263, 43264,  } , spawndeny = 0 },
	[43271] = {	id = 43271, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43271, 43272, 43273, 43274,  } , spawndeny = 0 },
	[43281] = {	id = 43281, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43281,  } , spawndeny = 0 },
	[43282] = {	id = 43282, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43282,  } , spawndeny = 0 },
	[43283] = {	id = 43283, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43283,  } , spawndeny = 0 },
	[43284] = {	id = 43284, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43284,  } , spawndeny = 0 },
	[43291] = {	id = 43291, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43291, 43292, 43293, 43294,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
