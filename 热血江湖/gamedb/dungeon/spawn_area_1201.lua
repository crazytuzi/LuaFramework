----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[120101] = {	id = 120101, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120101,  } , spawndeny = 0 },
	[120102] = {	id = 120102, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120102,  } , spawndeny = 0 },
	[120103] = {	id = 120103, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120103,  } , spawndeny = 0 },
	[120104] = {	id = 120104, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120104,  } , spawndeny = 0 },
	[120105] = {	id = 120105, range = 300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 120105,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
