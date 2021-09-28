----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[76111] = {	id = 76111, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761101, 761102, 761103, 761104,  } , spawndeny = 0 },
	[76112] = {	id = 76112, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761105, 761106, 761107, 761108,  } , spawndeny = 0 },
	[76113] = {	id = 76113, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761109,  } , spawndeny = 0 },
	[76114] = {	id = 76114, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761110,  } , spawndeny = 0 },
	[76115] = {	id = 76115, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761111, 761112,  } , spawndeny = 0 },
	[76121] = {	id = 76121, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761201, 761202, 761203, 761204,  } , spawndeny = 0 },
	[76122] = {	id = 76122, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761205, 761206, 761207, 761208,  } , spawndeny = 0 },
	[76123] = {	id = 76123, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761209,  } , spawndeny = 0 },
	[76124] = {	id = 76124, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761210,  } , spawndeny = 0 },
	[76125] = {	id = 76125, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761211, 761212,  } , spawndeny = 0 },
	[76131] = {	id = 76131, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761301, 761302, 761303, 761304,  } , spawndeny = 0 },
	[76132] = {	id = 76132, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761305, 761306, 761307, 761308,  } , spawndeny = 0 },
	[76133] = {	id = 76133, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761309,  } , spawndeny = 0 },
	[76134] = {	id = 76134, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761310,  } , spawndeny = 0 },
	[76135] = {	id = 76135, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761311, 761312,  } , spawndeny = 0 },
	[76141] = {	id = 76141, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761401, 761402, 761403, 761404,  } , spawndeny = 0 },
	[76142] = {	id = 76142, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761405, 761406, 761407, 761408,  } , spawndeny = 0 },
	[76143] = {	id = 76143, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761409,  } , spawndeny = 0 },
	[76144] = {	id = 76144, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761410,  } , spawndeny = 0 },
	[76145] = {	id = 76145, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761411, 761412,  } , spawndeny = 0 },
	[76151] = {	id = 76151, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761501, 761502, 761503, 761504,  } , spawndeny = 0 },
	[76152] = {	id = 76152, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761505, 761506, 761507, 761508,  } , spawndeny = 0 },
	[76153] = {	id = 76153, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761509,  } , spawndeny = 0 },
	[76154] = {	id = 76154, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761510,  } , spawndeny = 0 },
	[76155] = {	id = 76155, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761511, 761512,  } , spawndeny = 0 },
	[76161] = {	id = 76161, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761601, 761602, 761603, 761604,  } , spawndeny = 0 },
	[76162] = {	id = 76162, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761605, 761606, 761607, 761608,  } , spawndeny = 0 },
	[76163] = {	id = 76163, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761609,  } , spawndeny = 0 },
	[76164] = {	id = 76164, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761610,  } , spawndeny = 0 },
	[76165] = {	id = 76165, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761611, 761612,  } , spawndeny = 0 },
	[76171] = {	id = 76171, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761701, 761702, 761703, 761704,  } , spawndeny = 0 },
	[76172] = {	id = 76172, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761705, 761706, 761707, 761708,  } , spawndeny = 0 },
	[76173] = {	id = 76173, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761709,  } , spawndeny = 0 },
	[76174] = {	id = 76174, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761710,  } , spawndeny = 0 },
	[76175] = {	id = 76175, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761711, 761712,  } , spawndeny = 0 },
	[76181] = {	id = 76181, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761801, 761802, 761803, 761804,  } , spawndeny = 0 },
	[76182] = {	id = 76182, range = 400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761805, 761806, 761807, 761808,  } , spawndeny = 0 },
	[76183] = {	id = 76183, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761809,  } , spawndeny = 0 },
	[76184] = {	id = 76184, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761810,  } , spawndeny = 0 },
	[76185] = {	id = 76185, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 761811, 761812,  } , spawndeny = 0 },
	[76101] = {	id = 76101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76101, 76102, 76103,  } , spawndeny = 0 },
	[76102] = {	id = 76102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76104, 76105, 76106,  } , spawndeny = 0 },
	[76103] = {	id = 76103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76107, 76108, 76109,  } , spawndeny = 0 },
	[76104] = {	id = 76104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76110, 76111, 76112,  } , spawndeny = 0 },
	[76105] = {	id = 76105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76113, 76114, 76115,  } , spawndeny = 0 },
	[76106] = {	id = 76106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76116, 76117, 76118,  } , spawndeny = 0 },
	[76107] = {	id = 76107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76119, 76120, 76121,  } , spawndeny = 0 },
	[76108] = {	id = 76108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76122, 76123, 76124,  } , spawndeny = 0 },
	[76109] = {	id = 76109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76125, 76126, 76127,  } , spawndeny = 0 },
	[76110] = {	id = 76110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 76128, 76129, 76130,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
