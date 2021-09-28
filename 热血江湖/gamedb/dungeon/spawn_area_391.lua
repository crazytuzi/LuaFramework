----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[39121] = {	id = 39121, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39121,  } , spawndeny = 10000 },
	[39122] = {	id = 39122, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39122,  } , spawndeny = 10000 },
	[39123] = {	id = 39123, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39123,  } , spawndeny = 10000 },
	[39124] = {	id = 39124, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39124,  } , spawndeny = 10000 },
	[39125] = {	id = 39125, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39125,  } , spawndeny = 10000 },
	[39126] = {	id = 39126, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39126,  } , spawndeny = 10000 },
	[39127] = {	id = 39127, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39127,  } , spawndeny = 10000 },

};
function get_db_table()
	return spawn_area;
end
