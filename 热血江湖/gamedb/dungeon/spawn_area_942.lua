----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[94200] = {	id = 94200, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94200,  } , spawndeny = 0 },
	[94201] = {	id = 94201, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94201,  } , spawndeny = 0 },
	[94202] = {	id = 94202, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94202,  } , spawndeny = 0 },
	[94203] = {	id = 94203, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94203,  } , spawndeny = 0 },
	[94204] = {	id = 94204, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94204,  } , spawndeny = 0 },
	[94205] = {	id = 94205, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94205,  } , spawndeny = 0 },
	[94206] = {	id = 94206, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94206,  } , spawndeny = 0 },
	[94207] = {	id = 94207, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94207,  } , spawndeny = 0 },
	[94208] = {	id = 94208, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94208,  } , spawndeny = 0 },
	[94209] = {	id = 94209, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94209,  } , spawndeny = 0 },
	[94210] = {	id = 94210, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94210,  } , spawndeny = 0 },
	[94211] = {	id = 94211, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94211,  } , spawndeny = 0 },
	[94212] = {	id = 94212, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94212,  } , spawndeny = 0 },
	[94213] = {	id = 94213, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94213,  } , spawndeny = 0 },
	[94214] = {	id = 94214, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94214,  } , spawndeny = 0 },
	[94215] = {	id = 94215, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94215,  } , spawndeny = 0 },
	[94216] = {	id = 94216, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94216,  } , spawndeny = 0 },
	[94217] = {	id = 94217, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94217,  } , spawndeny = 0 },
	[94218] = {	id = 94218, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94218,  } , spawndeny = 0 },
	[94219] = {	id = 94219, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94219,  } , spawndeny = 0 },
	[94220] = {	id = 94220, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94220,  } , spawndeny = 0 },
	[94221] = {	id = 94221, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94221,  } , spawndeny = 0 },
	[94222] = {	id = 94222, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94222,  } , spawndeny = 0 },
	[94223] = {	id = 94223, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94223,  } , spawndeny = 0 },
	[94224] = {	id = 94224, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 94224,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
