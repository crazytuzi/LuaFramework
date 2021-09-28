----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[1301] = {	id = 1301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3721, 3722,  } , spawndeny = 0 },
	[1302] = {	id = 1302, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3723, 3724,  } , spawndeny = 0 },
	[1303] = {	id = 1303, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 3725, 3726,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
