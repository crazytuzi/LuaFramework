----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[801] = {	id = 801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1001, 1002, 1003, 1004,  } , spawndeny = 500 },
	[802] = {	id = 802, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1005,  } , spawndeny = 2500 },
	[803] = {	id = 803, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1006, 1007,  } , spawndeny = 2500 },
	[804] = {	id = 804, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1008,  } , spawndeny = 2500 },
	[811] = {	id = 811, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1011, 1012, 1013, 1014,  } , spawndeny = 500 },
	[812] = {	id = 812, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1015,  } , spawndeny = 2500 },
	[813] = {	id = 813, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1016, 1017,  } , spawndeny = 2500 },
	[814] = {	id = 814, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1018,  } , spawndeny = 2500 },
	[821] = {	id = 821, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1021, 1022, 1023, 1024,  } , spawndeny = 500 },
	[822] = {	id = 822, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1025,  } , spawndeny = 2500 },
	[823] = {	id = 823, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1026, 1027,  } , spawndeny = 2500 },
	[824] = {	id = 824, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1028,  } , spawndeny = 2500 },
	[831] = {	id = 831, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1031, 1032, 1033, 1034,  } , spawndeny = 500 },
	[832] = {	id = 832, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1035,  } , spawndeny = 2500 },
	[833] = {	id = 833, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1036, 1037,  } , spawndeny = 2500 },
	[834] = {	id = 834, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1038,  } , spawndeny = 2500 },
	[841] = {	id = 841, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1041, 1042, 1043, 1044,  } , spawndeny = 500 },
	[842] = {	id = 842, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1045,  } , spawndeny = 2500 },
	[843] = {	id = 843, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1046, 1047,  } , spawndeny = 2500 },
	[844] = {	id = 844, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1048,  } , spawndeny = 2500 },
	[851] = {	id = 851, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1051, 1052, 1053, 1054,  } , spawndeny = 500 },
	[852] = {	id = 852, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1055,  } , spawndeny = 2500 },
	[853] = {	id = 853, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1056, 1057,  } , spawndeny = 2500 },
	[854] = {	id = 854, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1058,  } , spawndeny = 2500 },
	[861] = {	id = 861, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1061, 1062, 1063, 1064,  } , spawndeny = 500 },
	[862] = {	id = 862, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1065,  } , spawndeny = 2500 },
	[863] = {	id = 863, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1066, 1067,  } , spawndeny = 2500 },
	[864] = {	id = 864, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1068,  } , spawndeny = 2500 },
	[871] = {	id = 871, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1071, 1072, 1073, 1074,  } , spawndeny = 500 },
	[872] = {	id = 872, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1075,  } , spawndeny = 2500 },
	[873] = {	id = 873, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1076, 1077,  } , spawndeny = 2500 },
	[874] = {	id = 874, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1078,  } , spawndeny = 2500 },
	[881] = {	id = 881, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1081, 1082, 1083, 1084,  } , spawndeny = 500 },
	[882] = {	id = 882, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1085,  } , spawndeny = 2500 },
	[883] = {	id = 883, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1086, 1087,  } , spawndeny = 2500 },
	[884] = {	id = 884, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1088,  } , spawndeny = 2500 },
	[891] = {	id = 891, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1091, 1092, 1093, 1094,  } , spawndeny = 500 },
	[892] = {	id = 892, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1095,  } , spawndeny = 2500 },
	[893] = {	id = 893, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1096, 1097,  } , spawndeny = 2500 },
	[894] = {	id = 894, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 1098,  } , spawndeny = 2500 },

};
function get_db_table()
	return spawn_area;
end
