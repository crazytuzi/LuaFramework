----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74901] = {	id = 74901, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74901, 74902, 74903,  } , spawndeny = 0 },
	[74902] = {	id = 74902, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74904, 74905, 74906,  } , spawndeny = 0 },
	[74903] = {	id = 74903, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74907, 74908, 74909,  } , spawndeny = 0 },
	[74904] = {	id = 74904, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74910, 74911, 74912,  } , spawndeny = 0 },
	[74905] = {	id = 74905, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74913, 74914, 74915,  } , spawndeny = 0 },
	[74906] = {	id = 74906, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74916, 74917, 74918,  } , spawndeny = 0 },
	[74907] = {	id = 74907, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74919, 74920, 74921,  } , spawndeny = 0 },
	[74908] = {	id = 74908, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74922, 74923, 74924,  } , spawndeny = 0 },
	[74909] = {	id = 74909, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74925, 74926, 74927,  } , spawndeny = 0 },
	[74910] = {	id = 74910, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74928, 74929, 74930,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
