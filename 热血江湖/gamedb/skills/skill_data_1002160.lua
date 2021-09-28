----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002161] = {
		[1] = {events = {{triTime = 850, hitEffID = 30956, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002171] = {
		[1] = {events = {{triTime = 625, hitEffID = 30958, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002181] = {
		[1] = {events = {{triTime = 425, hitEffID = 30960, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002182] = {
		[1] = {events = {{triTime = 625, hitEffID = 30960, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002191] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30961, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002192] = {
		[1] = {events = {{triTime = 875, hitEffID = 30961, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002162] = {
		[1] = {events = {{triTime = 1275, hitEffID = 30957, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002172] = {
		[1] = {events = {{triTime = 1500, hitEffID = 30959, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
