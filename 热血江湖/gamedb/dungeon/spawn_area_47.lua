----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4701] = {	id = 4701, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4501, 4502, 20000, 20001,  }, EndClose = {  }, spawnPoints = { 470102, 470103, 470104, 470105, 470106, 470107,  } , spawndeny = 0 },
	[4702] = {	id = 4702, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4503, 4504, 20002, 20003,  }, EndClose = {  }, spawnPoints = { 470202, 470203, 470204, 470205, 470206, 470207,  } , spawndeny = 0 },
	[4703] = {	id = 4703, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4505, 4506, 20004, 20005,  }, EndClose = {  }, spawnPoints = { 470302, 470303, 470304, 470305, 470306, 470307,  } , spawndeny = 0 },
	[4704] = {	id = 4704, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4507, 4508, 20006, 20007,  }, EndClose = {  }, spawnPoints = { 470402, 470403, 470404, 470406, 470407, 470408, 470410, 470411, 470412,  } , spawndeny = 0 },
	[4705] = {	id = 4705, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 470501, 470502, 470503, 470505, 470506, 470507, 470509, 470510, 470511, 470513,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
