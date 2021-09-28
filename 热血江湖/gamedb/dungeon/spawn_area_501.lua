----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[50101] = {	id = 50101, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50101,  } , spawndeny = 0 },
	[50102] = {	id = 50102, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50102,  } , spawndeny = 0 },
	[50103] = {	id = 50103, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50103,  } , spawndeny = 0 },
	[50104] = {	id = 50104, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50104,  } , spawndeny = 0 },
	[50105] = {	id = 50105, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50105,  } , spawndeny = 0 },
	[50106] = {	id = 50106, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50106,  } , spawndeny = 0 },
	[50107] = {	id = 50107, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50107,  } , spawndeny = 0 },
	[50108] = {	id = 50108, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50108,  } , spawndeny = 0 },
	[50109] = {	id = 50109, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50109,  } , spawndeny = 0 },
	[50110] = {	id = 50110, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50110,  } , spawndeny = 0 },
	[50111] = {	id = 50111, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50111,  } , spawndeny = 0 },
	[50112] = {	id = 50112, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50112,  } , spawndeny = 0 },
	[50113] = {	id = 50113, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50113,  } , spawndeny = 0 },
	[50114] = {	id = 50114, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50114,  } , spawndeny = 0 },
	[50115] = {	id = 50115, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50115,  } , spawndeny = 0 },
	[50116] = {	id = 50116, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50116,  } , spawndeny = 0 },
	[50117] = {	id = 50117, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50117,  } , spawndeny = 0 },
	[50118] = {	id = 50118, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50118,  } , spawndeny = 0 },
	[50119] = {	id = 50119, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50119,  } , spawndeny = 0 },
	[50120] = {	id = 50120, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50120,  } , spawndeny = 0 },
	[50121] = {	id = 50121, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50121,  } , spawndeny = 0 },
	[50122] = {	id = 50122, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50122,  } , spawndeny = 0 },
	[50123] = {	id = 50123, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50123,  } , spawndeny = 0 },
	[50124] = {	id = 50124, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50124,  } , spawndeny = 0 },
	[50125] = {	id = 50125, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50125,  } , spawndeny = 0 },
	[50126] = {	id = 50126, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50126,  } , spawndeny = 0 },
	[50127] = {	id = 50127, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50127,  } , spawndeny = 0 },
	[50128] = {	id = 50128, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50128,  } , spawndeny = 0 },
	[50129] = {	id = 50129, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50129,  } , spawndeny = 0 },
	[50130] = {	id = 50130, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50130,  } , spawndeny = 0 },
	[50131] = {	id = 50131, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50131,  } , spawndeny = 0 },
	[50132] = {	id = 50132, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50132,  } , spawndeny = 0 },
	[50133] = {	id = 50133, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50133,  } , spawndeny = 0 },
	[50134] = {	id = 50134, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50134,  } , spawndeny = 0 },
	[50135] = {	id = 50135, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50135,  } , spawndeny = 0 },
	[50136] = {	id = 50136, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50136,  } , spawndeny = 0 },
	[50137] = {	id = 50137, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50137,  } , spawndeny = 0 },
	[50138] = {	id = 50138, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50138,  } , spawndeny = 0 },
	[50139] = {	id = 50139, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50139,  } , spawndeny = 0 },
	[50140] = {	id = 50140, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50140,  } , spawndeny = 0 },
	[50141] = {	id = 50141, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50141,  } , spawndeny = 0 },
	[50142] = {	id = 50142, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50142,  } , spawndeny = 0 },
	[50143] = {	id = 50143, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50143,  } , spawndeny = 0 },
	[50144] = {	id = 50144, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50144,  } , spawndeny = 0 },
	[50145] = {	id = 50145, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50145,  } , spawndeny = 0 },
	[50146] = {	id = 50146, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50146,  } , spawndeny = 0 },
	[50147] = {	id = 50147, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50147,  } , spawndeny = 0 },
	[50148] = {	id = 50148, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50148,  } , spawndeny = 0 },
	[50149] = {	id = 50149, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50149,  } , spawndeny = 0 },
	[50150] = {	id = 50150, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50150,  } , spawndeny = 0 },
	[50151] = {	id = 50151, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50151,  } , spawndeny = 0 },
	[50152] = {	id = 50152, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 50152,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
