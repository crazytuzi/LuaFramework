----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[621] = {	id = 621, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 683, 684, 685,  } , spawndeny = 0 },
	[623] = {	id = 623, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 693, 694, 695, 696,  } , spawndeny = 0 },
	[624] = {	id = 624, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 703, 704, 705, 706,  } , spawndeny = 0 },
	[625] = {	id = 625, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 713, 714, 715, 716,  } , spawndeny = 0 },
	[627] = {	id = 627, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 720, 721, 722, 723,  } , spawndeny = 0 },
	[628] = {	id = 628, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 730, 731, 732, 733,  } , spawndeny = 0 },
	[629] = {	id = 629, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 740, 741, 742, 743,  } , spawndeny = 0 },
	[661] = {	id = 661, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 801, 802, 803, 804, 805,  } , spawndeny = 0 },
	[662] = {	id = 662, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 806,  } , spawndeny = 0 },
	[663] = {	id = 663, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 811, 812, 813, 814, 815,  } , spawndeny = 0 },
	[664] = {	id = 664, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 816,  } , spawndeny = 0 },
	[665] = {	id = 665, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 821, 822, 823, 824, 825,  } , spawndeny = 0 },
	[666] = {	id = 666, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 826,  } , spawndeny = 0 },
	[667] = {	id = 667, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 831, 832, 833, 834, 835,  } , spawndeny = 0 },
	[668] = {	id = 668, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 836,  } , spawndeny = 0 },
	[669] = {	id = 669, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 841, 842, 843, 844, 845,  } , spawndeny = 0 },
	[670] = {	id = 670, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 846,  } , spawndeny = 0 },
	[671] = {	id = 671, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 851, 852, 853, 854, 855,  } , spawndeny = 0 },
	[672] = {	id = 672, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 856,  } , spawndeny = 0 },
	[673] = {	id = 673, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 861, 862, 863, 864, 865,  } , spawndeny = 0 },
	[674] = {	id = 674, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 866,  } , spawndeny = 0 },
	[675] = {	id = 675, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 871, 872, 873, 874, 875,  } , spawndeny = 0 },
	[676] = {	id = 676, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 876,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
