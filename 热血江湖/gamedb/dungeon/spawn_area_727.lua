----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72701] = {	id = 72701, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72701, 72702, 72703,  } , spawndeny = 0 },
	[72702] = {	id = 72702, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72704, 72705, 72706,  } , spawndeny = 0 },
	[72703] = {	id = 72703, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72707, 72708, 72709,  } , spawndeny = 0 },
	[72704] = {	id = 72704, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72710, 72711, 72712,  } , spawndeny = 0 },
	[72705] = {	id = 72705, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72713, 72714, 72715,  } , spawndeny = 0 },
	[72706] = {	id = 72706, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72716, 72717, 72718,  } , spawndeny = 0 },
	[72707] = {	id = 72707, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72719, 72720, 72721,  } , spawndeny = 0 },
	[72708] = {	id = 72708, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72722, 72723, 72724,  } , spawndeny = 0 },
	[72709] = {	id = 72709, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72725, 72726, 72727,  } , spawndeny = 0 },
	[72710] = {	id = 72710, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72728, 72729, 72730,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
