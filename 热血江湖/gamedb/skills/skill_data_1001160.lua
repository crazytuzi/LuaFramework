----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001161] = {
		[1] = {events = {{triTime = 525, hitEffID = 30423, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001162] = {
		[1] = {events = {{triTime = 550, hitEffID = 30423, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001171] = {
		[1] = {events = {{triTime = 425, hitEffID = 30446, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001172] = {
		[1] = {events = {{triTime = 425, hitEffID = 30446, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001181] = {
		[1] = {events = {{triTime = 600, hitEffID = 30421, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001182] = {
		[1] = {events = {{triTime = 600, hitEffID = 30421, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001191] = {
		[1] = {events = {{triTime = 550, hitEffID = 30441, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001192] = {
		[1] = {events = {{triTime = 625, hitEffID = 30441, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
