----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40701] = {	id = 40701, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40701,  } , spawndeny = 0 },
	[40711] = {	id = 40711, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40711, 40712, 40713, 40714,  } , spawndeny = 0 },
	[40721] = {	id = 40721, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40721, 40722, 40723, 40724,  } , spawndeny = 0 },
	[40731] = {	id = 40731, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40731,  } , spawndeny = 0 },
	[40732] = {	id = 40732, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40732,  } , spawndeny = 0 },
	[40733] = {	id = 40733, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40733,  } , spawndeny = 0 },
	[40734] = {	id = 40734, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40734,  } , spawndeny = 0 },
	[40741] = {	id = 40741, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40741, 40742, 40743, 40744,  } , spawndeny = 0 },
	[40751] = {	id = 40751, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40751,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
