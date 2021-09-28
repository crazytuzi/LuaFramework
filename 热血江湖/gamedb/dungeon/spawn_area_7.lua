----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[701] = {	id = 701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 901, 902, 903, 904, 905,  } , spawndeny = 0 },
	[711] = {	id = 711, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 911, 912, 913, 914, 915, 916,  } , spawndeny = 0 },
	[721] = {	id = 721, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 921, 922, 923, 924, 925, 926, 927,  } , spawndeny = 0 },
	[731] = {	id = 731, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 931, 932, 933, 934, 935, 936, 937,  } , spawndeny = 0 },
	[741] = {	id = 741, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 941, 942, 943, 944, 945, 946, 947,  } , spawndeny = 0 },
	[751] = {	id = 751, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 951, 952, 953, 954, 955, 956, 957,  } , spawndeny = 0 },
	[761] = {	id = 761, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 961, 962, 963, 964, 965, 966, 967,  } , spawndeny = 0 },
	[771] = {	id = 771, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 971, 972, 973, 974, 975, 976, 977,  } , spawndeny = 0 },
	[781] = {	id = 781, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7701,  }, EndClose = {  }, spawnPoints = { 981, 982, 983, 984, 985, 986, 987,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
