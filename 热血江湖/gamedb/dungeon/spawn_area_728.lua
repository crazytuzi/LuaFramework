----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72801] = {	id = 72801, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72801, 72802, 72803,  } , spawndeny = 0 },
	[72802] = {	id = 72802, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72804, 72805, 72806,  } , spawndeny = 0 },
	[72803] = {	id = 72803, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72807, 72808, 72809,  } , spawndeny = 0 },
	[72804] = {	id = 72804, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72810, 72811, 72812,  } , spawndeny = 0 },
	[72805] = {	id = 72805, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72813, 72814, 72815,  } , spawndeny = 0 },
	[72806] = {	id = 72806, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72816, 72817, 72818,  } , spawndeny = 0 },
	[72807] = {	id = 72807, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72819, 72820, 72821,  } , spawndeny = 0 },
	[72808] = {	id = 72808, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72822, 72823, 72824,  } , spawndeny = 0 },
	[72809] = {	id = 72809, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72825, 72826, 72827,  } , spawndeny = 0 },
	[72810] = {	id = 72810, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72828, 72829, 72830,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
