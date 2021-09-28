----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[92201] = {	id = 92201, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92201,  } , spawndeny = 3000 },
	[92202] = {	id = 92202, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92202,  } , spawndeny = 3000 },
	[92203] = {	id = 92203, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92203,  } , spawndeny = 3000 },
	[92204] = {	id = 92204, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92204,  } , spawndeny = 3000 },
	[92205] = {	id = 92205, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92205,  } , spawndeny = 3000 },
	[92206] = {	id = 92206, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92206,  } , spawndeny = 3000 },
	[92207] = {	id = 92207, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92207,  } , spawndeny = 3000 },
	[92208] = {	id = 92208, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92208,  } , spawndeny = 3000 },
	[92209] = {	id = 92209, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92209,  } , spawndeny = 3000 },
	[92210] = {	id = 92210, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92210,  } , spawndeny = 3000 },
	[92211] = {	id = 92211, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92211,  } , spawndeny = 3000 },
	[92212] = {	id = 92212, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92212,  } , spawndeny = 3000 },
	[92213] = {	id = 92213, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92213,  } , spawndeny = 3000 },
	[92214] = {	id = 92214, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92214,  } , spawndeny = 3000 },
	[92215] = {	id = 92215, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92215,  } , spawndeny = 3000 },
	[92216] = {	id = 92216, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92216,  } , spawndeny = 3000 },
	[92217] = {	id = 92217, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92217,  } , spawndeny = 3000 },
	[92218] = {	id = 92218, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92218,  } , spawndeny = 3000 },
	[92219] = {	id = 92219, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92219,  } , spawndeny = 3000 },
	[92220] = {	id = 92220, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92220,  } , spawndeny = 3000 },
	[92221] = {	id = 92221, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92221,  } , spawndeny = 3000 },
	[92222] = {	id = 92222, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92222,  } , spawndeny = 3000 },
	[92223] = {	id = 92223, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92223,  } , spawndeny = 3000 },
	[92224] = {	id = 92224, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92224,  } , spawndeny = 3000 },
	[92225] = {	id = 92225, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92225,  } , spawndeny = 3000 },
	[92226] = {	id = 92226, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92226,  } , spawndeny = 3000 },
	[92227] = {	id = 92227, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92227,  } , spawndeny = 3000 },
	[92228] = {	id = 92228, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92228,  } , spawndeny = 3000 },
	[92229] = {	id = 92229, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92229,  } , spawndeny = 3000 },
	[92230] = {	id = 92230, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92230,  } , spawndeny = 3000 },
	[92231] = {	id = 92231, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92231,  } , spawndeny = 3000 },
	[92232] = {	id = 92232, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92232,  } , spawndeny = 3000 },
	[92233] = {	id = 92233, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92233,  } , spawndeny = 3000 },
	[92234] = {	id = 92234, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92234,  } , spawndeny = 3000 },
	[92235] = {	id = 92235, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92235,  } , spawndeny = 3000 },
	[92236] = {	id = 92236, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92236,  } , spawndeny = 3000 },
	[92237] = {	id = 92237, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92237,  } , spawndeny = 3000 },
	[92238] = {	id = 92238, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92238,  } , spawndeny = 3000 },
	[92239] = {	id = 92239, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92239,  } , spawndeny = 3000 },
	[92240] = {	id = 92240, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92240,  } , spawndeny = 3000 },
	[92241] = {	id = 92241, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92241,  } , spawndeny = 3000 },
	[92242] = {	id = 92242, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92242,  } , spawndeny = 3000 },
	[92243] = {	id = 92243, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92243,  } , spawndeny = 3000 },
	[92244] = {	id = 92244, range = 320.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 92244,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
