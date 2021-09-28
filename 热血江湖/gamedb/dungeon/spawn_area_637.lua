----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63700] = {	id = 63700, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63701, 63702, 63703, 63704,  } , spawndeny = 0 },
	[63710] = {	id = 63710, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63711, 63712,  } , spawndeny = 0 },
	[63720] = {	id = 63720, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63721, 63722, 63723, 63724,  } , spawndeny = 0 },
	[63730] = {	id = 63730, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63731, 63732,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
