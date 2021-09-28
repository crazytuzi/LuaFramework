----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[91101] = {	id = 91101, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91101,  } , spawndeny = 3000 },
	[91102] = {	id = 91102, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91102,  } , spawndeny = 3000 },
	[91103] = {	id = 91103, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91103,  } , spawndeny = 3000 },
	[91104] = {	id = 91104, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91104,  } , spawndeny = 3000 },
	[91105] = {	id = 91105, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91105,  } , spawndeny = 3000 },
	[91106] = {	id = 91106, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91106,  } , spawndeny = 3000 },
	[91107] = {	id = 91107, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91107,  } , spawndeny = 3000 },
	[91108] = {	id = 91108, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91108,  } , spawndeny = 3000 },
	[91109] = {	id = 91109, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91109,  } , spawndeny = 3000 },
	[91110] = {	id = 91110, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91110,  } , spawndeny = 3000 },
	[91111] = {	id = 91111, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91111,  } , spawndeny = 3000 },
	[91112] = {	id = 91112, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91112,  } , spawndeny = 3000 },
	[91113] = {	id = 91113, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91113,  } , spawndeny = 3000 },
	[91114] = {	id = 91114, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91114,  } , spawndeny = 3000 },
	[91115] = {	id = 91115, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91115,  } , spawndeny = 3000 },
	[91116] = {	id = 91116, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91116,  } , spawndeny = 3000 },
	[91117] = {	id = 91117, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91117,  } , spawndeny = 3000 },
	[91118] = {	id = 91118, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91118,  } , spawndeny = 3000 },
	[91119] = {	id = 91119, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91119,  } , spawndeny = 3000 },
	[91120] = {	id = 91120, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91120,  } , spawndeny = 3000 },
	[91121] = {	id = 91121, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91121,  } , spawndeny = 3000 },
	[91122] = {	id = 91122, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91122,  } , spawndeny = 3000 },
	[91123] = {	id = 91123, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91123,  } , spawndeny = 3000 },
	[91124] = {	id = 91124, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91124,  } , spawndeny = 3000 },
	[91125] = {	id = 91125, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91125,  } , spawndeny = 3000 },
	[91126] = {	id = 91126, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91126,  } , spawndeny = 3000 },
	[91127] = {	id = 91127, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91127,  } , spawndeny = 3000 },
	[91128] = {	id = 91128, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91128,  } , spawndeny = 3000 },
	[91129] = {	id = 91129, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91129,  } , spawndeny = 3000 },
	[91130] = {	id = 91130, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91130,  } , spawndeny = 3000 },
	[91131] = {	id = 91131, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91131,  } , spawndeny = 3000 },
	[91132] = {	id = 91132, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91132,  } , spawndeny = 3000 },
	[91133] = {	id = 91133, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91133,  } , spawndeny = 3000 },
	[91134] = {	id = 91134, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91134,  } , spawndeny = 3000 },
	[91135] = {	id = 91135, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91135,  } , spawndeny = 3000 },
	[91136] = {	id = 91136, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91136,  } , spawndeny = 3000 },
	[91137] = {	id = 91137, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91137,  } , spawndeny = 3000 },
	[91138] = {	id = 91138, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91138,  } , spawndeny = 3000 },
	[91139] = {	id = 91139, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91139,  } , spawndeny = 3000 },
	[91140] = {	id = 91140, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 91140,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
