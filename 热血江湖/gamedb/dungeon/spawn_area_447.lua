----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44701] = {	id = 44701, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44701, 44702, 44703, 44704, 44705, 44706,  } , spawndeny = 0 },
	[44711] = {	id = 44711, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44711, 44712, 44713, 44714,  } , spawndeny = 0 },
	[44721] = {	id = 44721, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44721, 44722, 44723, 44724,  } , spawndeny = 0 },
	[44731] = {	id = 44731, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44731,  } , spawndeny = 0 },
	[44732] = {	id = 44732, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44732,  } , spawndeny = 0 },
	[44733] = {	id = 44733, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44733,  } , spawndeny = 0 },
	[44734] = {	id = 44734, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44734,  } , spawndeny = 0 },
	[44741] = {	id = 44741, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44741, 44742, 44743, 44744,  } , spawndeny = 0 },
	[44751] = {	id = 44751, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44751, 44752, 44753, 44754, 44755, 44756,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
