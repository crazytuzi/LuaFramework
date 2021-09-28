----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001201] = {
		[1] = {events = {{triTime = 550, hitEffID = 30452, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001202] = {
		[1] = {events = {{triTime = 625, hitEffID = 30452, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001212] = {
		[1] = {events = {{triTime = 550, hitEffID = 30424, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001222] = {
		[1] = {events = {{triTime = 475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001231] = {
		[1] = {events = {{triTime = 400, hitEffID = 30445, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001232] = {
		[1] = {events = {{triTime = 375, hitEffID = 30445, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001221] = {
		[1] = {events = {{triTime = 375, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001211] = {
		[1] = {events = {{triTime = 350, hitEffID = 30424, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
