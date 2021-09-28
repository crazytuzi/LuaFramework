----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6501] = {	id = 6501, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6501,  }, EndClose = {  }, spawnPoints = { 650101, 650102, 650103, 650104, 650105,  } , spawndeny = 0 },
	[6502] = {	id = 6502, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6502,  }, EndClose = {  }, spawnPoints = { 650201, 650202, 650203, 650204, 650205, 650206, 650207,  } , spawndeny = 0 },
	[6503] = {	id = 6503, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6503,  }, EndClose = {  }, spawnPoints = { 650301, 650302, 650303, 650304, 650305,  } , spawndeny = 0 },
	[6504] = {	id = 6504, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 650306,  } , spawndeny = 0 },
	[6505] = {	id = 6505, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 650307,  } , spawndeny = 0 },
	[6506] = {	id = 6506, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 650401, 650402, 650403, 650404, 650405, 650406, 650407, 650408,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
