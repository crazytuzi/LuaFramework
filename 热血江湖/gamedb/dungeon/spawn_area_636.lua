----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63600] = {	id = 63600, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63601, 63602, 63603, 63604,  } , spawndeny = 0 },
	[63610] = {	id = 63610, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63611, 63612,  } , spawndeny = 0 },
	[63620] = {	id = 63620, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63621, 63622, 63623, 63624,  } , spawndeny = 0 },
	[63630] = {	id = 63630, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63631, 63632,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
