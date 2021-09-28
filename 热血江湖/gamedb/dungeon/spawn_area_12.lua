----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[1201] = {	id = 1201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3701, 3702,  } , spawndeny = 0 },
	[1202] = {	id = 1202, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3703, 3704,  } , spawndeny = 0 },
	[1203] = {	id = 1203, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3705, 3706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
