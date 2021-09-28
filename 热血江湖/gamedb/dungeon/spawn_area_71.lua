----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7101] = {	id = 7101, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 710101, 710102, 710103, 710104, 710105, 710106,  } , spawndeny = 0 },
	[7102] = {	id = 7102, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6901,  }, EndClose = {  }, spawnPoints = { 710201, 710202, 710203, 710204, 710205, 710206,  } , spawndeny = 0 },
	[7103] = {	id = 7103, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 710301, 710302, 710303, 710304, 710305, 710306, 710307,  } , spawndeny = 0 },
	[7104] = {	id = 7104, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6902,  }, EndClose = {  }, spawnPoints = { 710401, 710402, 710403, 710404, 710405, 710406, 710407,  } , spawndeny = 0 },
	[7105] = {	id = 7105, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 710501, 710502, 710503, 710504, 710505, 710506, 710507, 710508, 710509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
