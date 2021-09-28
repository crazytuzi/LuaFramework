----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40201] = {	id = 40201, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40201,  } , spawndeny = 0 },
	[40211] = {	id = 40211, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40211, 40212, 40213, 40214,  } , spawndeny = 0 },
	[40221] = {	id = 40221, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40221, 40222, 40223, 40224,  } , spawndeny = 0 },
	[40231] = {	id = 40231, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40231,  } , spawndeny = 0 },
	[40232] = {	id = 40232, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40232,  } , spawndeny = 0 },
	[40233] = {	id = 40233, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40233,  } , spawndeny = 0 },
	[40234] = {	id = 40234, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40234,  } , spawndeny = 0 },
	[40241] = {	id = 40241, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40241, 40242, 40243, 40244,  } , spawndeny = 0 },
	[40251] = {	id = 40251, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40251,  } , spawndeny = 0 },
	[40261] = {	id = 40261, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40261, 40262, 40263, 40264,  } , spawndeny = 0 },
	[40271] = {	id = 40271, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40271, 40272, 40273, 40274,  } , spawndeny = 0 },
	[40281] = {	id = 40281, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40281,  } , spawndeny = 0 },
	[40282] = {	id = 40282, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40282,  } , spawndeny = 0 },
	[40283] = {	id = 40283, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40283,  } , spawndeny = 0 },
	[40284] = {	id = 40284, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40284,  } , spawndeny = 0 },
	[40291] = {	id = 40291, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40291, 40292, 40293, 40294,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
