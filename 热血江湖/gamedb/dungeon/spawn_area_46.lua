----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4601] = {	id = 4601, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4501, 4502, 20000, 20001,  }, EndClose = {  }, spawnPoints = { 460102, 460103, 460104, 460105, 460106,  } , spawndeny = 0 },
	[4602] = {	id = 4602, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4503, 4504, 20002, 20003,  }, EndClose = {  }, spawnPoints = { 460202, 460203, 460204, 460205, 460206,  } , spawndeny = 0 },
	[4603] = {	id = 4603, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4505, 4506, 20004, 20005,  }, EndClose = {  }, spawnPoints = { 460302, 460303, 460304, 460305, 460306,  } , spawndeny = 0 },
	[4604] = {	id = 4604, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4507, 4508, 20006, 20007,  }, EndClose = {  }, spawnPoints = { 460401, 460402, 460404, 460405, 460407, 460408,  } , spawndeny = 0 },
	[4605] = {	id = 4605, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 460501, 460502, 460503, 460504, 460505, 460507, 460508, 460510,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
