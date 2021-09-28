----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76301] = {	id = 76301, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76301, 76302, 76303,  } , spawndeny = 0 },
	[76302] = {	id = 76302, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76304, 76305, 76306,  } , spawndeny = 0 },
	[76303] = {	id = 76303, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76307, 76308, 76309,  } , spawndeny = 0 },
	[76304] = {	id = 76304, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76310, 76311, 76312,  } , spawndeny = 0 },
	[76305] = {	id = 76305, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76313, 76314, 76315,  } , spawndeny = 0 },
	[76306] = {	id = 76306, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76316, 76317, 76318,  } , spawndeny = 0 },
	[76307] = {	id = 76307, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76319, 76320, 76321,  } , spawndeny = 0 },
	[76308] = {	id = 76308, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76322, 76323, 76324,  } , spawndeny = 0 },
	[76309] = {	id = 76309, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76325, 76326, 76327,  } , spawndeny = 0 },
	[76310] = {	id = 76310, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76328, 76329, 76330,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
