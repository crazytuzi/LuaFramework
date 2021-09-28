----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001281] = {
		[1] = {events = {{triTime = 375, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001282] = {
		[1] = {events = {{triTime = 400, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001291] = {
		[1] = {events = {{triTime = 500, hitEffID = 30415, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001292] = {
		[1] = {events = {{triTime = 600, hitEffID = 30415, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001301] = {
		[1] = {events = {{triTime = 375, hitEffID = 30444, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001302] = {
		[1] = {events = {{triTime = 400, hitEffID = 30444, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001311] = {
		[1] = {events = {{triTime = 550, hitEffID = 30419, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001312] = {
		[1] = {events = {{triTime = 475, hitEffID = 30419, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
