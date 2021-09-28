----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76901] = {	id = 76901, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76901, 76902, 76903,  } , spawndeny = 0 },
	[76902] = {	id = 76902, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76904, 76905, 76906,  } , spawndeny = 0 },
	[76903] = {	id = 76903, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76907, 76908, 76909,  } , spawndeny = 0 },
	[76904] = {	id = 76904, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76910, 76911, 76912,  } , spawndeny = 0 },
	[76905] = {	id = 76905, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76913, 76914, 76915,  } , spawndeny = 0 },
	[76906] = {	id = 76906, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76916, 76917, 76918,  } , spawndeny = 0 },
	[76907] = {	id = 76907, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76919, 76920, 76921,  } , spawndeny = 0 },
	[76908] = {	id = 76908, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76922, 76923, 76924,  } , spawndeny = 0 },
	[76909] = {	id = 76909, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76925, 76926, 76927,  } , spawndeny = 0 },
	[76910] = {	id = 76910, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76928, 76929, 76930,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
