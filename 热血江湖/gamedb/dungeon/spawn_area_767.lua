----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76701] = {	id = 76701, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76701, 76702, 76703,  } , spawndeny = 0 },
	[76702] = {	id = 76702, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76704, 76705, 76706,  } , spawndeny = 0 },
	[76703] = {	id = 76703, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76707, 76708, 76709,  } , spawndeny = 0 },
	[76704] = {	id = 76704, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76710, 76711, 76712,  } , spawndeny = 0 },
	[76705] = {	id = 76705, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76713, 76714, 76715,  } , spawndeny = 0 },
	[76706] = {	id = 76706, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76716, 76717, 76718,  } , spawndeny = 0 },
	[76707] = {	id = 76707, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76719, 76720, 76721,  } , spawndeny = 0 },
	[76708] = {	id = 76708, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76722, 76723, 76724,  } , spawndeny = 0 },
	[76709] = {	id = 76709, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76725, 76726, 76727,  } , spawndeny = 0 },
	[76710] = {	id = 76710, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76728, 76729, 76730,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
