----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41101] = {	id = 41101, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41101,  } , spawndeny = 0 },
	[41111] = {	id = 41111, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41111, 41112, 41113, 41114,  } , spawndeny = 0 },
	[41121] = {	id = 41121, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41121, 41122, 41123, 41124,  } , spawndeny = 0 },
	[41131] = {	id = 41131, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41131,  } , spawndeny = 0 },
	[41132] = {	id = 41132, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41132,  } , spawndeny = 0 },
	[41133] = {	id = 41133, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41133,  } , spawndeny = 0 },
	[41134] = {	id = 41134, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41134,  } , spawndeny = 0 },
	[41141] = {	id = 41141, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41141, 41142, 41143, 41144,  } , spawndeny = 0 },
	[41151] = {	id = 41151, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41151,  } , spawndeny = 0 },
	[41161] = {	id = 41161, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41161, 41162, 41163, 41164,  } , spawndeny = 0 },
	[41171] = {	id = 41171, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41171, 41172, 41173, 41174,  } , spawndeny = 0 },
	[41181] = {	id = 41181, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41181,  } , spawndeny = 0 },
	[41182] = {	id = 41182, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41182,  } , spawndeny = 0 },
	[41183] = {	id = 41183, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41183,  } , spawndeny = 0 },
	[41184] = {	id = 41184, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41184,  } , spawndeny = 0 },
	[41191] = {	id = 41191, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41191, 41192, 41193, 41194,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
