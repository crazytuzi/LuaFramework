----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74201] = {	id = 74201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74201, 74202, 74203,  } , spawndeny = 0 },
	[74202] = {	id = 74202, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74204, 74205, 74206,  } , spawndeny = 0 },
	[74203] = {	id = 74203, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74207, 74208, 74209,  } , spawndeny = 0 },
	[74204] = {	id = 74204, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74210, 74211, 74212,  } , spawndeny = 0 },
	[74205] = {	id = 74205, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74213, 74214, 74215,  } , spawndeny = 0 },
	[74206] = {	id = 74206, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74216, 74217, 74218,  } , spawndeny = 0 },
	[74207] = {	id = 74207, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74219, 74220, 74221,  } , spawndeny = 0 },
	[74208] = {	id = 74208, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74222, 74223, 74224,  } , spawndeny = 0 },
	[74209] = {	id = 74209, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74225, 74226, 74227,  } , spawndeny = 0 },
	[74210] = {	id = 74210, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74228, 74229, 74230,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
