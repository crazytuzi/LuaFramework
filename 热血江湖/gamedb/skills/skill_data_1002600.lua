----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002621] = {
		[1] = {events = {{triTime = 950, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002602] = {
		[1] = {events = {{triTime = 800, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 15000, buffID = 849, }, }, }, },},
	},
	[1002603] = {
		[1] = {events = {{triTime = 1550, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002605] = {
		[1] = {events = {{triTime = 375, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002615] = {
		[1] = {events = {{triTime = 550, }, },},
	},
	[1002606] = {
		[1] = {events = {{triTime = 250, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3, }, }, {triTime = 550, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3, }, }, {triTime = 875, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, },},
	},
	[1002607] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 550000.0, }, }, },},
	},
	[1002608] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 5500000.0, }, }, },},
	},
	[1002609] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 6500000.0, }, }, },},
	},
	[1002610] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 30000000.0, }, }, },},
	},
	[1002611] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 20000000.0, }, }, },},
	},
	[1002612] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 100000000.0, }, }, },},
	},
	[1002613] = {
		[1] = {events = {{triTime = 550, }, },},
	},
	[1002614] = {
		[1] = {events = {{hitEffID = 30890, hitSoundID = 10, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 982, }, {odds = 10000, buffID = 983, }, }, }, },},
	},
	[1002616] = {
		[1] = {events = {{hitEffID = 30890, hitSoundID = 10, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 984, }, {odds = 10000, buffID = 985, }, }, }, },},
	},
	[1002617] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 986, }, }, }, },},
	},
	[1002618] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 987, }, }, }, },},
	},
	[1002619] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71335, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71336, }, }, }, },},
	},
	[1002620] = {
		[1] = {events = {{triTime = 625, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002622] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 75000000.0, }, }, },},
	},
	[1002623] = {
		[1] = {events = {{triTime = 50, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.01, arg2 = 400000000.0, }, }, },},
	},
	[1002601] = {
		[1] = {events = {{triTime = 950, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002604] = {
		[1] = {events = {{triTime = 450, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3, }, }, {triTime = 1000, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3, }, }, {triTime = 1550, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, },},
	},

};
function get_db_table()
	return level;
end
