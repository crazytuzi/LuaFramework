----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63400] = {	id = 63400, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63401, 63402, 63403, 63404,  } , spawndeny = 0 },
	[63410] = {	id = 63410, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63411, 63412,  } , spawndeny = 0 },
	[63420] = {	id = 63420, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63421, 63422, 63423, 63424,  } , spawndeny = 0 },
	[63430] = {	id = 63430, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63431, 63432,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
