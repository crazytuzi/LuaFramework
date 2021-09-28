----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72901] = {	id = 72901, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72901, 72902, 72903,  } , spawndeny = 0 },
	[72902] = {	id = 72902, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72904, 72905, 72906,  } , spawndeny = 0 },
	[72903] = {	id = 72903, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72907, 72908, 72909,  } , spawndeny = 0 },
	[72904] = {	id = 72904, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72910, 72911, 72912,  } , spawndeny = 0 },
	[72905] = {	id = 72905, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72913, 72914, 72915,  } , spawndeny = 0 },
	[72906] = {	id = 72906, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72916, 72917, 72918,  } , spawndeny = 0 },
	[72907] = {	id = 72907, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72919, 72920, 72921,  } , spawndeny = 0 },
	[72908] = {	id = 72908, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72922, 72923, 72924,  } , spawndeny = 0 },
	[72909] = {	id = 72909, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72925, 72926, 72927,  } , spawndeny = 0 },
	[72910] = {	id = 72910, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72928, 72929, 72930,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
