----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41701] = {	id = 41701, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41701,  } , spawndeny = 0 },
	[41711] = {	id = 41711, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41711, 41712, 41713, 41714,  } , spawndeny = 0 },
	[41721] = {	id = 41721, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41721, 41722, 41723, 41724,  } , spawndeny = 0 },
	[41731] = {	id = 41731, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41731,  } , spawndeny = 0 },
	[41732] = {	id = 41732, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41732,  } , spawndeny = 0 },
	[41733] = {	id = 41733, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41733,  } , spawndeny = 0 },
	[41734] = {	id = 41734, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41734,  } , spawndeny = 0 },
	[41741] = {	id = 41741, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41741, 41742, 41743, 41744,  } , spawndeny = 0 },
	[41751] = {	id = 41751, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41751,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
