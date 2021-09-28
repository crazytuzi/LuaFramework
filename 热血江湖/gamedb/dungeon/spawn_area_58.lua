----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5801] = {	id = 5801, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5608,  }, EndClose = {  }, spawnPoints = { 580101, 580102, 580103, 580104, 580105, 580106,  } , spawndeny = 0 },
	[5802] = {	id = 5802, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5609,  }, EndClose = {  }, spawnPoints = { 580201, 580202, 580203, 580204, 580205, 580206, 580207, 580208,  } , spawndeny = 0 },
	[5803] = {	id = 5803, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5610, 5601,  }, EndClose = {  }, spawnPoints = { 580301, 580302, 580303, 580304, 580305, 580306, 580307, 580308,  } , spawndeny = 0 },
	[5804] = {	id = 5804, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5602, 5607,  }, EndClose = {  }, spawnPoints = { 580401, 580402, 580403, 580404, 580405, 580406, 580407, 580408, 580409,  } , spawndeny = 0 },
	[5805] = {	id = 5805, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 580501, 580502, 580503, 580504, 580505, 580506, 580507, 580508, 580509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
