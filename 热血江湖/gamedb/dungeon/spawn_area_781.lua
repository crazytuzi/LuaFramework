----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[78100] = {	id = 78100, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 101000, 101001, 101002, 101003,  } , spawndeny = 0 },
	[78101] = {	id = 78101, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101010, 101011, 101012, 101013, 101014, 101015,  } , spawndeny = 0 },
	[78102] = {	id = 78102, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 101020, 101021, 101022, 101023, 101024, 101025, 101026, 101027,  } , spawndeny = 0 },
	[78103] = {	id = 78103, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101030, 101031, 101032, 101033, 101034, 101035, 101036, 101037,  } , spawndeny = 0 },
	[78104] = {	id = 78104, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 101040, 101041, 101042, 101043, 101044, 101045, 101046, 101047,  } , spawndeny = 0 },
	[78105] = {	id = 78105, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101050, 101051, 101052, 101053, 101054, 101055, 101056, 101057, 101058,  } , spawndeny = 0 },
	[78110] = {	id = 78110, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 101100, 101101, 101102, 101103,  } , spawndeny = 0 },
	[78111] = {	id = 78111, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101110, 101111, 101112, 101113, 101114, 101115,  } , spawndeny = 0 },
	[78112] = {	id = 78112, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 101120, 101121, 101122, 101123, 101124, 101125, 101126, 101127,  } , spawndeny = 0 },
	[78113] = {	id = 78113, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101130, 101131, 101132, 101133, 101134, 101135, 101136, 101137,  } , spawndeny = 0 },
	[78114] = {	id = 78114, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 101140, 101141, 101142, 101143, 101144, 101145, 101146, 101147,  } , spawndeny = 0 },
	[78115] = {	id = 78115, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101150, 101151, 101152, 101153, 101154, 101155, 101156, 101157, 101158,  } , spawndeny = 0 },
	[78120] = {	id = 78120, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 101200, 101201, 101202, 101203,  } , spawndeny = 0 },
	[78121] = {	id = 78121, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101210, 101211, 101212, 101213, 101214, 101215,  } , spawndeny = 0 },
	[78122] = {	id = 78122, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 101220, 101221, 101222, 101223, 101224, 101225, 101226, 101227,  } , spawndeny = 0 },
	[78123] = {	id = 78123, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101230, 101231, 101232, 101233, 101234, 101235, 101236, 101237,  } , spawndeny = 0 },
	[78124] = {	id = 78124, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 101240, 101241, 101242, 101243, 101244, 101245, 101246, 101247,  } , spawndeny = 0 },
	[78125] = {	id = 78125, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101250, 101251, 101252, 101253, 101254, 101255, 101256, 101257, 101258,  } , spawndeny = 0 },
	[78130] = {	id = 78130, range = 750.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3301,  }, EndOpen = { 3301,  }, EndClose = {  }, spawnPoints = { 101300, 101301, 101302, 101303,  } , spawndeny = 0 },
	[78131] = {	id = 78131, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101310, 101311, 101312, 101313, 101314, 101315,  } , spawndeny = 0 },
	[78132] = {	id = 78132, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3302,  }, EndOpen = { 3302,  }, EndClose = {  }, spawnPoints = { 101320, 101321, 101322, 101323, 101324, 101325, 101326, 101327,  } , spawndeny = 0 },
	[78133] = {	id = 78133, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101330, 101331, 101332, 101333, 101334, 101335, 101336, 101337,  } , spawndeny = 0 },
	[78134] = {	id = 78134, range = 1300.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3303,  }, EndOpen = { 3303, 3306,  }, EndClose = {  }, spawnPoints = { 101340, 101341, 101342, 101343, 101344, 101345, 101346, 101347,  } , spawndeny = 0 },
	[78135] = {	id = 78135, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 101350, 101351, 101352, 101353, 101354, 101355, 101356, 101357, 101358,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
