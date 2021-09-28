----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[101] = {	id = 101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101, 102, 103, 104, 105, 106, 107,  } , spawndeny = 0 },
	[102] = {	id = 102, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 108, 109, 110,  } , spawndeny = 0 },
	[103] = {	id = 103, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 111, 112, 113, 114, 115,  } , spawndeny = 0 },
	[104] = {	id = 104, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 116, 117, 118, 119, 120, 121, 122,  } , spawndeny = 0 },
	[105] = {	id = 105, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 123, 124, 125, 126, 127, 128, 129,  } , spawndeny = 0 },
	[106] = {	id = 106, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 130, 131, 132, 133, 134, 135, 136,  } , spawndeny = 0 },
	[107] = {	id = 107, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 137, 138, 139, 140, 141, 142, 143,  } , spawndeny = 0 },
	[108] = {	id = 108, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 144, 145, 146, 147, 148, 149, 150,  } , spawndeny = 0 },
	[109] = {	id = 109, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 151, 152, 153, 154, 155, 156, 157,  } , spawndeny = 0 },
	[110] = {	id = 110, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 158, 159, 160, 161, 162, 163, 164,  } , spawndeny = 0 },
	[111] = {	id = 111, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 171, 172, 173, 174, 175, 176, 177,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
