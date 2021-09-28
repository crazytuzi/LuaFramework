----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72301] = {	id = 72301, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72301, 72302, 72303,  } , spawndeny = 0 },
	[72302] = {	id = 72302, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72304, 72305, 72306,  } , spawndeny = 0 },
	[72303] = {	id = 72303, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72307, 72308, 72309,  } , spawndeny = 0 },
	[72304] = {	id = 72304, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72310, 72311, 72312,  } , spawndeny = 0 },
	[72305] = {	id = 72305, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72313, 72314, 72315,  } , spawndeny = 0 },
	[72306] = {	id = 72306, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72316, 72317, 72318,  } , spawndeny = 0 },
	[72307] = {	id = 72307, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72319, 72320, 72321,  } , spawndeny = 0 },
	[72308] = {	id = 72308, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72322, 72323, 72324,  } , spawndeny = 0 },
	[72309] = {	id = 72309, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72325, 72326, 72327,  } , spawndeny = 0 },
	[72310] = {	id = 72310, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72328, 72329, 72330,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
