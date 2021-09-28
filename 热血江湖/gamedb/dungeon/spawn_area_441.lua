----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[44101] = {	id = 44101, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44101, 44102, 44103, 44104,  } , spawndeny = 0 },
	[44111] = {	id = 44111, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44111, 44112, 44113, 44114,  } , spawndeny = 0 },
	[44121] = {	id = 44121, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44121, 44122, 44123, 44124,  } , spawndeny = 0 },
	[44131] = {	id = 44131, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44131,  } , spawndeny = 0 },
	[44132] = {	id = 44132, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44132,  } , spawndeny = 0 },
	[44133] = {	id = 44133, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44133,  } , spawndeny = 0 },
	[44134] = {	id = 44134, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44134,  } , spawndeny = 0 },
	[44141] = {	id = 44141, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44141, 44142, 44143, 44144,  } , spawndeny = 0 },
	[44151] = {	id = 44151, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44151, 44152, 44153, 44154, 44155,  } , spawndeny = 0 },
	[44161] = {	id = 44161, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44161, 44162, 44163, 44164,  } , spawndeny = 0 },
	[44171] = {	id = 44171, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44171, 44172, 44173, 44174,  } , spawndeny = 0 },
	[44181] = {	id = 44181, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44181,  } , spawndeny = 0 },
	[44182] = {	id = 44182, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44182,  } , spawndeny = 0 },
	[44183] = {	id = 44183, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44183,  } , spawndeny = 0 },
	[44184] = {	id = 44184, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44184,  } , spawndeny = 0 },
	[44191] = {	id = 44191, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 44191, 44192, 44193, 44194,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
