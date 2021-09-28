----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[501] = {	id = 501, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 101,  }, EndClose = {  }, spawnPoints = { 501,  } , spawndeny = 0 },
	[502] = {	id = 502, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 102,  }, EndClose = {  }, spawnPoints = { 502,  } , spawndeny = 0 },
	[503] = {	id = 503, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 503,  } , spawndeny = 0 },
	[504] = {	id = 504, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 103,  }, EndClose = {  }, spawnPoints = { 504, 505,  } , spawndeny = 0 },
	[505] = {	id = 505, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 506, 507, 508,  } , spawndeny = 0 },
	[511] = {	id = 511, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 111,  }, EndClose = {  }, spawnPoints = { 511,  } , spawndeny = 0 },
	[512] = {	id = 512, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 512,  } , spawndeny = 0 },
	[513] = {	id = 513, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 112,  }, EndClose = {  }, spawnPoints = { 513,  } , spawndeny = 0 },
	[514] = {	id = 514, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 113,  }, EndClose = {  }, spawnPoints = { 514, 515,  } , spawndeny = 0 },
	[515] = {	id = 515, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 516, 517, 518,  } , spawndeny = 0 },
	[521] = {	id = 521, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 121,  }, EndClose = {  }, spawnPoints = { 521,  } , spawndeny = 0 },
	[522] = {	id = 522, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 522,  } , spawndeny = 0 },
	[523] = {	id = 523, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 122,  }, EndClose = {  }, spawnPoints = { 523,  } , spawndeny = 0 },
	[524] = {	id = 524, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 123,  }, EndClose = {  }, spawnPoints = { 524, 525,  } , spawndeny = 0 },
	[525] = {	id = 525, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 526, 527, 528,  } , spawndeny = 0 },
	[531] = {	id = 531, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 131,  }, EndClose = {  }, spawnPoints = { 531,  } , spawndeny = 0 },
	[532] = {	id = 532, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 532,  } , spawndeny = 0 },
	[533] = {	id = 533, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 132,  }, EndClose = {  }, spawnPoints = { 533,  } , spawndeny = 0 },
	[534] = {	id = 534, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 133,  }, EndClose = {  }, spawnPoints = { 534, 535,  } , spawndeny = 0 },
	[535] = {	id = 535, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 536, 537, 538, 539,  } , spawndeny = 0 },
	[541] = {	id = 541, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 141,  }, EndClose = {  }, spawnPoints = { 541,  } , spawndeny = 0 },
	[542] = {	id = 542, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 542,  } , spawndeny = 0 },
	[543] = {	id = 543, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 142,  }, EndClose = {  }, spawnPoints = { 543,  } , spawndeny = 0 },
	[544] = {	id = 544, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 143,  }, EndClose = {  }, spawnPoints = { 544, 545,  } , spawndeny = 0 },
	[545] = {	id = 545, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 546, 547, 548, 549,  } , spawndeny = 0 },
	[551] = {	id = 551, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 151,  }, EndClose = {  }, spawnPoints = { 551,  } , spawndeny = 0 },
	[552] = {	id = 552, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 552,  } , spawndeny = 0 },
	[553] = {	id = 553, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 152,  }, EndClose = {  }, spawnPoints = { 553,  } , spawndeny = 0 },
	[554] = {	id = 554, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 153,  }, EndClose = {  }, spawnPoints = { 554, 555,  } , spawndeny = 0 },
	[555] = {	id = 555, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 556, 557, 558, 559,  } , spawndeny = 0 },
	[561] = {	id = 561, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 161,  }, EndClose = {  }, spawnPoints = { 561,  } , spawndeny = 0 },
	[562] = {	id = 562, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 562,  } , spawndeny = 0 },
	[563] = {	id = 563, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 162,  }, EndClose = {  }, spawnPoints = { 563,  } , spawndeny = 0 },
	[564] = {	id = 564, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 163,  }, EndClose = {  }, spawnPoints = { 564, 565,  } , spawndeny = 0 },
	[565] = {	id = 565, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 566, 567, 568, 569,  } , spawndeny = 0 },
	[571] = {	id = 571, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 161,  }, EndClose = {  }, spawnPoints = { 571,  } , spawndeny = 0 },
	[572] = {	id = 572, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 572,  } , spawndeny = 0 },
	[573] = {	id = 573, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 162,  }, EndClose = {  }, spawnPoints = { 573,  } , spawndeny = 0 },
	[574] = {	id = 574, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 163,  }, EndClose = {  }, spawnPoints = { 574, 575,  } , spawndeny = 0 },
	[575] = {	id = 575, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 576, 577, 578, 579,  } , spawndeny = 0 },
	[581] = {	id = 581, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 161,  }, EndClose = {  }, spawnPoints = { 581,  } , spawndeny = 0 },
	[582] = {	id = 582, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 582,  } , spawndeny = 0 },
	[583] = {	id = 583, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 162,  }, EndClose = {  }, spawnPoints = { 583,  } , spawndeny = 0 },
	[584] = {	id = 584, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 163,  }, EndClose = {  }, spawnPoints = { 584, 585,  } , spawndeny = 0 },
	[585] = {	id = 585, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 586, 587, 588, 589,  } , spawndeny = 0 },
	[591] = {	id = 591, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 161,  }, EndClose = {  }, spawnPoints = { 591,  } , spawndeny = 0 },
	[592] = {	id = 592, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 592,  } , spawndeny = 0 },
	[593] = {	id = 593, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 162,  }, EndClose = {  }, spawnPoints = { 593,  } , spawndeny = 0 },
	[594] = {	id = 594, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 163,  }, EndClose = {  }, spawnPoints = { 594, 595,  } , spawndeny = 0 },
	[595] = {	id = 595, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 596, 597, 598, 599,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
