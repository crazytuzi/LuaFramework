----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001342] = {
		[1] = {events = {{triTime = 475, hitEffID = 30416, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001331] = {
		[1] = {events = {{triTime = 450, hitEffID = 30456, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001332] = {
		[1] = {events = {{triTime = 550, hitEffID = 30456, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001322] = {
		[1] = {events = {{triTime = 400, hitEffID = 30427, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001341] = {
		[1] = {events = {{triTime = 475, hitEffID = 30416, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001351] = {
		[1] = {events = {{triTime = 475, hitEffID = 30442, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001352] = {
		[1] = {events = {{triTime = 550, hitEffID = 30442, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001321] = {
		[1] = {events = {{triTime = 425, hitEffID = 30427, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
