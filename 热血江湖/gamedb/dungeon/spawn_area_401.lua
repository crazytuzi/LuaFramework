----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40101] = {	id = 40101, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40101,  } , spawndeny = 0 },
	[40111] = {	id = 40111, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40111, 40112, 40113, 40114,  } , spawndeny = 0 },
	[40121] = {	id = 40121, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40121, 40122, 40123, 40124,  } , spawndeny = 0 },
	[40131] = {	id = 40131, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40131,  } , spawndeny = 0 },
	[40132] = {	id = 40132, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40132,  } , spawndeny = 0 },
	[40133] = {	id = 40133, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40133,  } , spawndeny = 0 },
	[40134] = {	id = 40134, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40134,  } , spawndeny = 0 },
	[40141] = {	id = 40141, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40141, 40142, 40143, 40144,  } , spawndeny = 0 },
	[40151] = {	id = 40151, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40151,  } , spawndeny = 0 },
	[40161] = {	id = 40161, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40161, 40162, 40163, 40164,  } , spawndeny = 0 },
	[40171] = {	id = 40171, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40171, 40172, 40173, 40174,  } , spawndeny = 0 },
	[40181] = {	id = 40181, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40181,  } , spawndeny = 0 },
	[40182] = {	id = 40182, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40182,  } , spawndeny = 0 },
	[40183] = {	id = 40183, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40183,  } , spawndeny = 0 },
	[40184] = {	id = 40184, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40184,  } , spawndeny = 0 },
	[40191] = {	id = 40191, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40191, 40192, 40193, 40194,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
