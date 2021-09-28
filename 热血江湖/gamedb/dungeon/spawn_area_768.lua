----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76801] = {	id = 76801, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76801, 76802, 76803,  } , spawndeny = 0 },
	[76802] = {	id = 76802, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76804, 76805, 76806,  } , spawndeny = 0 },
	[76803] = {	id = 76803, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76807, 76808, 76809,  } , spawndeny = 0 },
	[76804] = {	id = 76804, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76810, 76811, 76812,  } , spawndeny = 0 },
	[76805] = {	id = 76805, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76813, 76814, 76815,  } , spawndeny = 0 },
	[76806] = {	id = 76806, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76816, 76817, 76818,  } , spawndeny = 0 },
	[76807] = {	id = 76807, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76819, 76820, 76821,  } , spawndeny = 0 },
	[76808] = {	id = 76808, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76822, 76823, 76824,  } , spawndeny = 0 },
	[76809] = {	id = 76809, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76825, 76826, 76827,  } , spawndeny = 0 },
	[76810] = {	id = 76810, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76828, 76829, 76830,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
