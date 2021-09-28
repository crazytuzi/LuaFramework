----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74701] = {	id = 74701, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74701, 74702, 74703,  } , spawndeny = 0 },
	[74702] = {	id = 74702, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74704, 74705, 74706,  } , spawndeny = 0 },
	[74703] = {	id = 74703, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74707, 74708, 74709,  } , spawndeny = 0 },
	[74704] = {	id = 74704, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74710, 74711, 74712,  } , spawndeny = 0 },
	[74705] = {	id = 74705, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74713, 74714, 74715,  } , spawndeny = 0 },
	[74706] = {	id = 74706, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74716, 74717, 74718,  } , spawndeny = 0 },
	[74707] = {	id = 74707, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74719, 74720, 74721,  } , spawndeny = 0 },
	[74708] = {	id = 74708, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74722, 74723, 74724,  } , spawndeny = 0 },
	[74709] = {	id = 74709, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74725, 74726, 74727,  } , spawndeny = 0 },
	[74710] = {	id = 74710, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74728, 74729, 74730,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
