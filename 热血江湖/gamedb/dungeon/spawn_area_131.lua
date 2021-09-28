----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[13101] = {	id = 13101, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 113101,  } , spawndeny = 0 },
	[13102] = {	id = 13102, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 113102,  } , spawndeny = 0 },
	[13103] = {	id = 13103, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 113103, 113104,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
