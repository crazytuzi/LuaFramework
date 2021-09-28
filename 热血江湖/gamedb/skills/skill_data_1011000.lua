----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1011001] = {
		[1] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 800.0, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 1600.0, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 3200.0, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 4800.0, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 7200.0, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 10800.0, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 16200.0, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 22600.0, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 31700.0, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 45000.0, }, }, },},
	},
	[1011002] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.64, arg2 = 137.0, }, }, },},
		[2] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.72, arg2 = 189.0, }, }, },},
		[3] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.79, arg2 = 246.0, }, }, },},
		[4] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.86, arg2 = 308.0, }, }, },},
		[5] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.93, arg2 = 374.0, }, }, },},
		[6] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 2.0, arg2 = 445.0, }, }, },},
		[7] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 2.08, arg2 = 521.0, }, }, },},
		[8] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 2.15, arg2 = 602.0, }, }, },},
		[9] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 2.23, arg2 = 703.0, }, }, },},
		[10] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 2.33, arg2 = 825.0, }, }, },},
	},
	[1011003] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.44, arg2 = 119.0, }, }, },},
		[2] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.5, arg2 = 165.0, }, }, },},
		[3] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.56, arg2 = 215.0, }, }, },},
		[4] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.63, arg2 = 269.0, }, }, },},
		[5] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.69, arg2 = 327.0, }, }, },},
		[6] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.75, arg2 = 390.0, }, }, },},
		[7] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.82, arg2 = 456.0, }, }, },},
		[8] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.88, arg2 = 527.0, }, }, },},
		[9] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.95, arg2 = 615.0, }, }, },},
		[10] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 2.04, arg2 = 722.0, }, }, },},
	},
	[1011004] = {
		[1] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.23, arg2 = 102.0, }, }, },},
		[2] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.29, arg2 = 142.0, }, }, },},
		[3] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.34, arg2 = 184.0, }, }, },},
		[4] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.4, arg2 = 231.0, }, }, },},
		[5] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.45, arg2 = 281.0, }, }, },},
		[6] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.5, arg2 = 334.0, }, }, },},
		[7] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.56, arg2 = 391.0, }, }, },},
		[8] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.61, arg2 = 452.0, }, }, },},
		[9] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.67, arg2 = 527.0, }, }, },},
		[10] = {events = {{triTime = 1000, damage = {odds = 10000, atrType = 1, arg1 = 1.75, arg2 = 619.0, }, }, },},
	},
	[1011005] = {
		[1] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73001, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73002, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73003, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73004, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73005, }, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73006, }, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73007, }, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73008, }, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73009, }, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30770, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73010, }, }, }, },},
	},
	[1011006] = {
		[1] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73011, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73012, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73013, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73014, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73015, }, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73016, }, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73017, }, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73018, }, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73019, }, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30771, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73020, }, }, }, },},
	},
	[1011007] = {
		[1] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71101, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71102, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71103, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71104, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71105, }, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71106, }, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71107, }, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71108, }, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71109, }, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30772, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 71110, }, }, }, },},
	},
	[1011008] = {
		[1] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 646.0, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 975.0, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 1383.0, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 1870.0, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 2438.0, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 3083.0, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 3809.0, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 4614.0, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 5654.0, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30094, damage = {odds = 10000, arg2 = 6974.0, }, }, },},
	},
	[1011009] = {
		[1] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73021, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73022, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73023, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73024, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73025, }, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73026, }, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73027, }, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73028, }, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73029, }, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30774, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73030, }, }, }, },},
	},
	[1011010] = {
		[1] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73031, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73032, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73033, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73034, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73035, }, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73036, }, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73037, }, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73038, }, }, }, },},
		[9] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73039, }, }, }, },},
		[10] = {events = {{triTime = 100, hitEffID = 30769, damage = {odds = 10000, atrType = 1, }, status = {{odds = 10000, buffID = 73040, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
