----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[31101] = {	id = 31101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31101, 31102,  } , spawndeny = 0 },
	[31103] = {	id = 31103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31103, 31104,  } , spawndeny = 0 },
	[31105] = {	id = 31105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31105, 31106,  } , spawndeny = 0 },
	[31107] = {	id = 31107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31107, 31108,  } , spawndeny = 0 },
	[31109] = {	id = 31109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 31109, 31110,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
