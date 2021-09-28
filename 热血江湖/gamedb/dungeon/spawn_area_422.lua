----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42201] = {	id = 42201, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42201,  } , spawndeny = 0 },
	[42211] = {	id = 42211, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42211, 42212, 42213, 42214,  } , spawndeny = 0 },
	[42221] = {	id = 42221, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42221, 42222, 42223, 42224,  } , spawndeny = 0 },
	[42231] = {	id = 42231, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42231,  } , spawndeny = 0 },
	[42232] = {	id = 42232, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42232,  } , spawndeny = 0 },
	[42233] = {	id = 42233, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42233,  } , spawndeny = 0 },
	[42234] = {	id = 42234, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42234,  } , spawndeny = 0 },
	[42241] = {	id = 42241, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42241, 42242, 42243, 42244,  } , spawndeny = 0 },
	[42251] = {	id = 42251, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42251,  } , spawndeny = 0 },
	[42261] = {	id = 42261, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42261, 42262, 42263, 42264,  } , spawndeny = 0 },
	[42271] = {	id = 42271, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42271, 42272, 42273, 42274,  } , spawndeny = 0 },
	[42281] = {	id = 42281, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42281,  } , spawndeny = 0 },
	[42282] = {	id = 42282, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42282,  } , spawndeny = 0 },
	[42283] = {	id = 42283, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42283,  } , spawndeny = 0 },
	[42284] = {	id = 42284, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42284,  } , spawndeny = 0 },
	[42291] = {	id = 42291, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42291, 42292, 42293, 42294,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
