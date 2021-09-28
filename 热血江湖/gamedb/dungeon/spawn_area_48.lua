----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4801] = {	id = 4801, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4501, 4502, 20000, 20001,  }, EndClose = {  }, spawnPoints = { 480102, 480103, 480104, 480105, 480106, 480107, 480108, 480109,  } , spawndeny = 0 },
	[4802] = {	id = 4802, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4503, 4504, 20002, 20003,  }, EndClose = {  }, spawnPoints = { 480202, 480203, 480204, 480205, 480206, 480207, 480208, 480209,  } , spawndeny = 0 },
	[4803] = {	id = 4803, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4505, 4506, 20004, 20005,  }, EndClose = {  }, spawnPoints = { 480302, 480303, 480304, 480305, 480306, 480307, 480308, 480309,  } , spawndeny = 0 },
	[4804] = {	id = 4804, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4507, 4508, 20006, 20007,  }, EndClose = {  }, spawnPoints = { 480403, 480404, 480405, 480407, 480408, 480409, 480410, 480412, 480413, 480414,  } , spawndeny = 0 },
	[4805] = {	id = 4805, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 480504, 480505, 480507, 480508, 480509, 480510, 480512, 480513, 480514, 480515, 480516,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
