----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[60501] = {	id = 60501, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60501,  } , spawndeny = 0 },
	[60502] = {	id = 60502, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60502,  } , spawndeny = 0 },
	[60503] = {	id = 60503, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60503,  } , spawndeny = 0 },
	[60504] = {	id = 60504, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60504,  } , spawndeny = 0 },
	[60505] = {	id = 60505, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60505,  } , spawndeny = 0 },
	[60506] = {	id = 60506, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60506,  } , spawndeny = 0 },
	[60507] = {	id = 60507, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60507,  } , spawndeny = 0 },
	[60508] = {	id = 60508, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60508,  } , spawndeny = 0 },
	[60509] = {	id = 60509, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60509,  } , spawndeny = 0 },
	[60510] = {	id = 60510, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60510,  } , spawndeny = 0 },
	[60511] = {	id = 60511, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60511,  } , spawndeny = 0 },
	[60512] = {	id = 60512, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60512,  } , spawndeny = 0 },
	[60513] = {	id = 60513, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60513,  } , spawndeny = 0 },
	[60514] = {	id = 60514, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60514,  } , spawndeny = 0 },
	[60515] = {	id = 60515, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60515,  } , spawndeny = 0 },
	[60516] = {	id = 60516, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60516,  } , spawndeny = 0 },
	[60517] = {	id = 60517, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60517,  } , spawndeny = 0 },
	[60518] = {	id = 60518, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60518,  } , spawndeny = 0 },
	[60519] = {	id = 60519, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60519,  } , spawndeny = 0 },
	[60520] = {	id = 60520, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60520,  } , spawndeny = 0 },
	[60521] = {	id = 60521, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60521,  } , spawndeny = 0 },
	[60522] = {	id = 60522, range = 0.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60522,  } , spawndeny = 0 },
	[60523] = {	id = 60523, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60523,  } , spawndeny = 0 },
	[60524] = {	id = 60524, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60524,  } , spawndeny = 0 },
	[60525] = {	id = 60525, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60525,  } , spawndeny = 0 },
	[60526] = {	id = 60526, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60526,  } , spawndeny = 0 },
	[60527] = {	id = 60527, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60527,  } , spawndeny = 0 },
	[60528] = {	id = 60528, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60528,  } , spawndeny = 0 },
	[60529] = {	id = 60529, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 60529,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
