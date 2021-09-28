----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4501] = {	id = 4501, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4501, 4502, 20000, 20001,  }, EndClose = {  }, spawnPoints = { 450101, 450102, 450103, 450104,  } , spawndeny = 0 },
	[4502] = {	id = 4502, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4503, 4504, 20002, 20003,  }, EndClose = {  }, spawnPoints = { 450201, 450202, 450203, 450204,  } , spawndeny = 0 },
	[4503] = {	id = 4503, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4505, 4506, 20004, 20005,  }, EndClose = {  }, spawnPoints = { 450301, 450302, 450303, 450304,  } , spawndeny = 0 },
	[4504] = {	id = 4504, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 4507, 4508, 20006, 20007,  }, EndClose = {  }, spawnPoints = { 450401, 450402, 450403, 450404, 450405, 450406,  } , spawndeny = 0 },
	[4505] = {	id = 4505, range = 4000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 450501, 450502, 450503, 450504, 450505, 450506, 450507,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
