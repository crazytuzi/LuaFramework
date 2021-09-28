----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74801] = {	id = 74801, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74801, 74802, 74803,  } , spawndeny = 0 },
	[74802] = {	id = 74802, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74804, 74805, 74806,  } , spawndeny = 0 },
	[74803] = {	id = 74803, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74807, 74808, 74809,  } , spawndeny = 0 },
	[74804] = {	id = 74804, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74810, 74811, 74812,  } , spawndeny = 0 },
	[74805] = {	id = 74805, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74813, 74814, 74815,  } , spawndeny = 0 },
	[74806] = {	id = 74806, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74816, 74817, 74818,  } , spawndeny = 0 },
	[74807] = {	id = 74807, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74819, 74820, 74821,  } , spawndeny = 0 },
	[74808] = {	id = 74808, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74822, 74823, 74824,  } , spawndeny = 0 },
	[74809] = {	id = 74809, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74825, 74826, 74827,  } , spawndeny = 0 },
	[74810] = {	id = 74810, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74828, 74829, 74830,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
