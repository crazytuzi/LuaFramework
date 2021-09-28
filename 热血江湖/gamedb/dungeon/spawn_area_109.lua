----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[10900] = {	id = 10900, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2101, 2102, 2103, 2104,  } , spawndeny = 0 },
	[10901] = {	id = 10901, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2105, 2106, 2107, 2108,  } , spawndeny = 500 },
	[10902] = {	id = 10902, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2109, 2110, 2111,  } , spawndeny = 500 },
	[10903] = {	id = 10903, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2112, 2113, 2114, 2115, 2116, 2117,  } , spawndeny = 500 },
	[10904] = {	id = 10904, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2118, 2119, 2120, 2121, 2122, 2123,  } , spawndeny = 500 },
	[10905] = {	id = 10905, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2124, 2125, 2126, 2127,  } , spawndeny = 500 },
	[10906] = {	id = 10906, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 2128, 2129, 2130,  } , spawndeny = 500 },

};
function get_db_table()
	return spawn_area;
end
