----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001882] = {
		[1] = {events = {{triTime = 375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1100, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1675, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
		[2] = {events = {{triTime = 375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 395, }, }, }, {triTime = 1100, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 395, }, }, }, {triTime = 1675, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 395, }, }, }, },},
		[3] = {events = {{triTime = 375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, {triTime = 1100, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1675, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, {triTime = 1100, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1675, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, {triTime = 1100, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1675, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[6] = {events = {{triTime = 375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, {triTime = 1100, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1675, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001902] = {
		[1] = {events = {{triTime = 525, status = {{odds = 10000, buffID = 534, }, }, }, },},
		[2] = {events = {{triTime = 525, status = {{odds = 10000, buffID = 534, }, }, }, },},
		[3] = {events = {{triTime = 525, status = {{odds = 10000, buffID = 534, }, }, }, },},
		[4] = {events = {{triTime = 525, status = {{odds = 10000, buffID = 534, }, }, }, },},
		[5] = {events = {{triTime = 525, status = {{odds = 10000, buffID = 534, }, }, }, },},
		[6] = {events = {{triTime = 525, status = {{odds = 10000, buffID = 534, }, }, }, },},
	},
	[1001881] = {
		[1] = {events = {{triTime = 825, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1375, hitEffID = 30169, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001914] = {
		[1] = {events = {{triTime = 825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 543, }, }, }, {triTime = 1325, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
		[2] = {events = {{triTime = 825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, {odds = 10000, buffID = 75022, }, }, }, {triTime = 1325, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, {odds = 10000, buffID = 75023, }, }, }, {triTime = 1325, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, {odds = 10000, buffID = 75024, }, }, }, {triTime = 1325, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001883] = {
		[1] = {events = {{triTime = 550, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 925, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
		[2] = {events = {{triTime = 550, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 85, }, {odds = 10000, buffID = 392, }, }, }, {triTime = 925, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 85, }, {odds = 10000, buffID = 392, }, }, }, },},
		[3] = {events = {{triTime = 550, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75004, }, }, }, {triTime = 925, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 550, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75005, }, }, }, {triTime = 925, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 550, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75006, }, }, }, {triTime = 925, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[6] = {events = {{triTime = 550, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75004, }, }, }, {triTime = 925, hitEffID = 30791, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001892] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30793, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 1000, hitEffID = 30793, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 525, }, }, }, },},
	},
	[1001893] = {
		[1] = {events = {{triTime = 700, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1100, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1500, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
		[2] = {events = {{triTime = 700, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 398, }, }, }, {triTime = 1100, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 398, }, }, }, {triTime = 1500, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 398, }, }, }, },},
	},
	[1001901] = {
		[1] = {events = {{triTime = 500, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 535, }, }, }, },},
		[2] = {events = {{triTime = 500, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 536, }, }, }, },},
		[3] = {events = {{triTime = 500, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 537, }, }, }, },},
		[4] = {events = {{triTime = 500, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 538, }, }, }, },},
		[5] = {events = {{triTime = 500, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 539, }, }, }, },},
		[6] = {events = {{triTime = 500, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 540, }, }, }, },},
	},
	[1001891] = {
		[1] = {events = {{triTime = 475, hitEffID = 30792, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 950, hitEffID = 30792, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001911] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, {triTime = 2000, hitEffID = 30403, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},
	[1001912] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 11, }, }, }, },},
		[2] = {events = {{triTime = 1125, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75010, }, {odds = 10000, buffID = 75004, }, }, }, },},
		[3] = {events = {{triTime = 1125, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75011, }, {odds = 10000, buffID = 75005, }, }, }, },},
		[4] = {events = {{triTime = 1125, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75012, }, {odds = 10000, buffID = 75006, }, }, }, },},
	},
	[1001913] = {
		[1] = {events = {{triTime = 1400, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, status = {{odds = 10000, buffID = 544, }, }, }, },},
		[2] = {events = {{triTime = 1400, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, },},
		[3] = {events = {{triTime = 1400, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, },},
		[4] = {events = {{triTime = 1400, hitEffID = 30796, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, },},
	},
	[1001915] = {
		[1] = {events = {{triTime = 3325, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 543, }, }, }, {triTime = 3825, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 4325, hitEffID = 30748, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001894] = {
		[1] = {events = {{triTime = 875, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1250, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1625, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
		[2] = {events = {{triTime = 2000, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 398, }, }, }, {triTime = 2375, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 398, }, }, }, {triTime = 2750, hitEffID = 30794, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 398, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
