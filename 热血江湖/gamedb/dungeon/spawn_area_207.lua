----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[20701] = {	id = 20701, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 20701,  } , spawndeny = 0 },
	[20702] = {	id = 20702, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 20702,  } , spawndeny = 0 },
	[20703] = {	id = 20703, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 20703,  } , spawndeny = 0 },
	[20704] = {	id = 20704, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 20704,  } , spawndeny = 0 },
	[20705] = {	id = 20705, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 20705,  } , spawndeny = 0 },
	[20706] = {	id = 20706, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 20706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
