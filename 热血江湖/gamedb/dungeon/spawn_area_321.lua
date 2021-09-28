----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[32101] = {	id = 32101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6001, 6002,  } , spawndeny = 800 },
	[32102] = {	id = 32102, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6003, 6004,  } , spawndeny = 1500 },
	[32103] = {	id = 32103, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6005,  } , spawndeny = 1500 },
	[32104] = {	id = 32104, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6006, 6007,  } , spawndeny = 1500 },
	[32105] = {	id = 32105, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6008,  } , spawndeny = 1500 },
	[32111] = {	id = 32111, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6011, 6012,  } , spawndeny = 800 },
	[32112] = {	id = 32112, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6013, 6014,  } , spawndeny = 1500 },
	[32113] = {	id = 32113, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6015,  } , spawndeny = 1500 },
	[32114] = {	id = 32114, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6016, 6017,  } , spawndeny = 1500 },
	[32115] = {	id = 32115, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6018,  } , spawndeny = 1500 },
	[32121] = {	id = 32121, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6021, 6022,  } , spawndeny = 800 },
	[32122] = {	id = 32122, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6023, 6024,  } , spawndeny = 1500 },
	[32123] = {	id = 32123, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6025,  } , spawndeny = 1500 },
	[32124] = {	id = 32124, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6026, 6027,  } , spawndeny = 1500 },
	[32125] = {	id = 32125, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6028,  } , spawndeny = 1500 },
	[32131] = {	id = 32131, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6031, 6032,  } , spawndeny = 800 },
	[32132] = {	id = 32132, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6033, 6034,  } , spawndeny = 1500 },
	[32133] = {	id = 32133, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6035,  } , spawndeny = 1500 },
	[32134] = {	id = 32134, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6036, 6037,  } , spawndeny = 1500 },
	[32135] = {	id = 32135, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6038,  } , spawndeny = 1500 },
	[32141] = {	id = 32141, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6041, 6042,  } , spawndeny = 800 },
	[32142] = {	id = 32142, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6043, 6044,  } , spawndeny = 1500 },
	[32143] = {	id = 32143, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6045,  } , spawndeny = 1500 },
	[32144] = {	id = 32144, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6046, 6047,  } , spawndeny = 1500 },
	[32145] = {	id = 32145, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6048,  } , spawndeny = 1500 },
	[32151] = {	id = 32151, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6051, 6052,  } , spawndeny = 800 },
	[32152] = {	id = 32152, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6053, 6054,  } , spawndeny = 1500 },
	[32153] = {	id = 32153, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6055,  } , spawndeny = 1500 },
	[32154] = {	id = 32154, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6056, 6057,  } , spawndeny = 1500 },
	[32155] = {	id = 32155, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 6058,  } , spawndeny = 1500 },

};
function get_db_table()
	return spawn_area;
end
