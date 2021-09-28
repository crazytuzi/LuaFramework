----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4001] = {	id = 4001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 400101, 400102, 400103,  } , spawndeny = 0 },
	[4002] = {	id = 4002, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 400202, 400203, 400204, 400205, 400206, 400207,  } , spawndeny = 0 },
	[4003] = {	id = 4003, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 400302, 400303, 400304, 400305, 400306,  } , spawndeny = 0 },
	[4004] = {	id = 4004, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 400402, 400403, 400404, 400405, 400406,  } , spawndeny = 0 },
	[4005] = {	id = 4005, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 400502, 400503, 400504, 400505, 400506, 400507,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
