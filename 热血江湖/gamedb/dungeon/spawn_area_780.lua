----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[78000] = {	id = 78000, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100010, 100011,  } , spawndeny = 0 },
	[78001] = {	id = 78001, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 100020, 100021, 100022, 100023,  } , spawndeny = 0 },
	[78002] = {	id = 78002, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100030, 100031, 100032, 100033,  } , spawndeny = 0 },
	[78003] = {	id = 78003, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 100040, 100041, 100042, 100043, 100044, 100045, 100046,  } , spawndeny = 0 },
	[78004] = {	id = 78004, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100050, 100051, 100052, 100053, 100054, 100055, 100056,  } , spawndeny = 0 },
	[78010] = {	id = 78010, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100110, 100111,  } , spawndeny = 0 },
	[78011] = {	id = 78011, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 100120, 100121, 100122, 100123,  } , spawndeny = 0 },
	[78012] = {	id = 78012, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100130, 100131, 100132, 100133,  } , spawndeny = 0 },
	[78013] = {	id = 78013, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 100140, 100141, 100142, 100143, 100144, 100145, 100146,  } , spawndeny = 0 },
	[78014] = {	id = 78014, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100150, 100151, 100152, 100153, 100154, 100155, 100156,  } , spawndeny = 0 },
	[78020] = {	id = 78020, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100210, 100211,  } , spawndeny = 0 },
	[78021] = {	id = 78021, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 100220, 100221, 100222, 100223,  } , spawndeny = 0 },
	[78022] = {	id = 78022, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100230, 100231, 100232, 100233,  } , spawndeny = 0 },
	[78023] = {	id = 78023, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 100240, 100241, 100242, 100243, 100244, 100245, 100246,  } , spawndeny = 0 },
	[78024] = {	id = 78024, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100250, 100251, 100252, 100253, 100254, 100255, 100256,  } , spawndeny = 0 },
	[78030] = {	id = 78030, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100310, 100311,  } , spawndeny = 0 },
	[78031] = {	id = 78031, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 100320, 100321, 100322, 100323,  } , spawndeny = 0 },
	[78032] = {	id = 78032, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100330, 100331, 100332, 100333,  } , spawndeny = 0 },
	[78033] = {	id = 78033, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 100340, 100341, 100342, 100343, 100344, 100345, 100346,  } , spawndeny = 0 },
	[78034] = {	id = 78034, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 100350, 100351, 100352, 100353, 100354, 100355, 100356,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
