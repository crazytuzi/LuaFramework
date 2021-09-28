----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[10001] = {	id = 10001, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10001,  } , spawndeny = 0 },
	[10002] = {	id = 10002, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10002,  } , spawndeny = 0 },
	[10003] = {	id = 10003, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10003,  } , spawndeny = 0 },
	[10004] = {	id = 10004, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10004,  } , spawndeny = 0 },
	[10005] = {	id = 10005, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10005,  } , spawndeny = 0 },
	[10006] = {	id = 10006, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10006,  } , spawndeny = 0 },
	[10007] = {	id = 10007, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10007,  } , spawndeny = 0 },
	[10008] = {	id = 10008, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10008,  } , spawndeny = 0 },
	[10009] = {	id = 10009, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10009,  } , spawndeny = 0 },
	[10010] = {	id = 10010, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10010,  } , spawndeny = 0 },
	[10011] = {	id = 10011, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10011,  } , spawndeny = 0 },
	[10012] = {	id = 10012, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10012,  } , spawndeny = 0 },
	[10013] = {	id = 10013, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10013,  } , spawndeny = 0 },
	[10014] = {	id = 10014, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10014,  } , spawndeny = 0 },
	[10015] = {	id = 10015, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10015,  } , spawndeny = 0 },
	[10016] = {	id = 10016, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10016,  } , spawndeny = 0 },
	[10017] = {	id = 10017, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10017,  } , spawndeny = 0 },
	[10018] = {	id = 10018, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10018,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
