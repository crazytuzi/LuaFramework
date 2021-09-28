----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[32001] = {	id = 32001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5001, 5002, 5003, 5004,  } , spawndeny = 500 },
	[32002] = {	id = 32002, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5005,  } , spawndeny = 2500 },
	[32003] = {	id = 32003, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5006, 5007,  } , spawndeny = 2500 },
	[32004] = {	id = 32004, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5008,  } , spawndeny = 2500 },
	[32005] = {	id = 32005, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5101, 5102, 5103, 5104,  } , spawndeny = 500 },
	[32006] = {	id = 32006, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5105,  } , spawndeny = 2500 },
	[32007] = {	id = 32007, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5106, 5107,  } , spawndeny = 2500 },
	[32008] = {	id = 32008, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5108,  } , spawndeny = 2500 },
	[32009] = {	id = 32009, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5201, 5202, 5203, 5204,  } , spawndeny = 500 },
	[32010] = {	id = 32010, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5205,  } , spawndeny = 2500 },
	[32011] = {	id = 32011, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5206, 5207,  } , spawndeny = 2500 },
	[32012] = {	id = 32012, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5208,  } , spawndeny = 2500 },
	[32013] = {	id = 32013, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5301, 5302, 5303, 5304,  } , spawndeny = 500 },
	[32014] = {	id = 32014, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5305,  } , spawndeny = 2500 },
	[32015] = {	id = 32015, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5306, 5307,  } , spawndeny = 2500 },
	[32016] = {	id = 32016, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 5308,  } , spawndeny = 2500 },

};
function get_db_table()
	return spawn_area;
end
