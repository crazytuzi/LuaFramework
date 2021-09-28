----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63100] = {	id = 63100, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63101, 63102, 63103, 63104,  } , spawndeny = 0 },
	[63110] = {	id = 63110, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63111, 63112,  } , spawndeny = 0 },
	[63120] = {	id = 63120, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63121, 63122, 63123, 63124,  } , spawndeny = 0 },
	[63130] = {	id = 63130, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63131, 63132,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
