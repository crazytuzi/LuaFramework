----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000573] = {
		[1] = {events = {{triTime = 500, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1000574] = {
		[1] = {events = {{triTime = 475, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 975, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
	},
	[1000561] = {
		[1] = {events = {{triTime = 475, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000562] = {
		[1] = {events = {{triTime = 475, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000563] = {
		[1] = {events = {{triTime = 500, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1000564] = {
		[1] = {events = {{triTime = 475, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 975, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
	},
	[1000571] = {
		[1] = {events = {{triTime = 475, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000572] = {
		[1] = {events = {{triTime = 475, hitEffID = 30199, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000581] = {
		[1] = {events = {{triTime = 600, hitEffID = 30212, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000582] = {
		[1] = {events = {{triTime = 775, hitEffID = 30212, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000583] = {
		[1] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 10000, buffID = 1, }, }, }, },},
		[3] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 10000, buffID = 1, }, }, }, },},
	},
	[1000584] = {
		[1] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 11, }, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 11, }, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1000585] = {
		[1] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1000586] = {
		[1] = {events = {{triTime = 500, damage = {odds = 10000, arg2 = 100000.0, }, }, },},
	},
	[1000591] = {
		[1] = {events = {{triTime = 375, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000592] = {
		[1] = {events = {{triTime = 600, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000593] = {
		[1] = {events = {{triTime = 950, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 950, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},
	[1000594] = {
		[1] = {events = {{hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.32, }, }, },},
		[2] = {events = {{hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.32, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
