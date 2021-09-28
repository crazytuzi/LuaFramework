----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001582] = {
		[1] = {events = {{triTime = 550, hitEffID = 30431, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001572] = {
		[1] = {events = {{triTime = 550, hitEffID = 30430, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001561] = {
		[1] = {events = {{triTime = 450, hitEffID = 30435, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001562] = {
		[1] = {events = {{triTime = 475, hitEffID = 30435, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001571] = {
		[1] = {events = {{triTime = 550, hitEffID = 30430, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001581] = {
		[1] = {events = {{triTime = 450, hitEffID = 30431, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001591] = {
		[1] = {events = {{triTime = 475, hitEffID = 30418, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001592] = {
		[1] = {events = {{triTime = 475, hitEffID = 30418, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
