----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[85001] = {	id = 85001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85001, 85002, 85003, 85004, 85005, 85006,  } , spawndeny = 5000 },
	[85002] = {	id = 85002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85007, 85008, 85009, 85010, 85011, 85012,  } , spawndeny = 3000 },
	[85003] = {	id = 85003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85013, 85014,  } , spawndeny = 3000 },
	[85004] = {	id = 85004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85015, 85016, 85017, 85018, 85019, 85020,  } , spawndeny = 3000 },
	[85005] = {	id = 85005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85021, 85022, 85023, 85024, 85025, 85026,  } , spawndeny = 3000 },
	[85006] = {	id = 85006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85027, 85028, 85029, 85030, 85031, 85032,  } , spawndeny = 3000 },
	[85007] = {	id = 85007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85033, 85034,  } , spawndeny = 3000 },
	[85008] = {	id = 85008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85035, 85036, 85037, 85038, 85039, 85040,  } , spawndeny = 3000 },
	[85009] = {	id = 85009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85041, 85042, 85043, 85044, 85045, 85046,  } , spawndeny = 3000 },
	[85010] = {	id = 85010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 85047, 85048,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
