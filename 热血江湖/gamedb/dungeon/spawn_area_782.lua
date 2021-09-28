----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[78200] = {	id = 78200, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102000, 102001, 102002, 102003,  } , spawndeny = 0 },
	[78201] = {	id = 78201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 102010, 102011, 102012, 102013, 102014, 102015, 102016, 102017, 102018,  } , spawndeny = 0 },
	[78202] = {	id = 78202, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102020, 102021, 102022, 102023, 102024, 102025, 102026, 102027,  } , spawndeny = 0 },
	[78203] = {	id = 78203, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 102030, 102031, 102032, 102033, 102034, 102035, 102036, 102037,  } , spawndeny = 0 },
	[78204] = {	id = 78204, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102040, 102041, 102042, 102043, 102044, 102045, 102046, 102047, 102048,  } , spawndeny = 0 },
	[78210] = {	id = 78210, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102100, 102101, 102102, 102103,  } , spawndeny = 0 },
	[78211] = {	id = 78211, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 102110, 102111, 102112, 102113, 102114, 102115, 102116, 102117, 102118,  } , spawndeny = 0 },
	[78212] = {	id = 78212, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102120, 102121, 102122, 102123, 102124, 102125, 102126, 102127,  } , spawndeny = 0 },
	[78213] = {	id = 78213, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 102130, 102131, 102132, 102133, 102134, 102135, 102136, 102137,  } , spawndeny = 0 },
	[78214] = {	id = 78214, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102140, 102141, 102142, 102143, 102144, 102145, 102146, 102147, 102148,  } , spawndeny = 0 },
	[78220] = {	id = 78220, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102200, 102201, 102202, 102203,  } , spawndeny = 0 },
	[78221] = {	id = 78221, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 102210, 102211, 102212, 102213, 102214, 102215, 102216, 102217, 102218,  } , spawndeny = 0 },
	[78222] = {	id = 78222, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102220, 102221, 102222, 102223, 102224, 102225, 102226, 102227,  } , spawndeny = 0 },
	[78223] = {	id = 78223, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 102230, 102231, 102232, 102233, 102234, 102235, 102236, 102237,  } , spawndeny = 0 },
	[78224] = {	id = 78224, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102240, 102241, 102242, 102243, 102244, 102245, 102246, 102247, 102248,  } , spawndeny = 0 },
	[78230] = {	id = 78230, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102300, 102301, 102302, 102303,  } , spawndeny = 0 },
	[78231] = {	id = 78231, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 102310, 102311, 102312, 102313, 102314, 102315, 102316, 102317, 102318,  } , spawndeny = 0 },
	[78232] = {	id = 78232, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102320, 102321, 102322, 102323, 102324, 102325, 102326, 102327,  } , spawndeny = 0 },
	[78233] = {	id = 78233, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 102330, 102331, 102332, 102333, 102334, 102335, 102336, 102337,  } , spawndeny = 0 },
	[78234] = {	id = 78234, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 102340, 102341, 102342, 102343, 102344, 102345, 102346, 102347, 102348,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
