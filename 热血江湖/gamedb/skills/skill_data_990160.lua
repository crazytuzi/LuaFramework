----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[990161] = {
		[1] = {events = {{triTime = 525, hitEffID = 30053, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[990162] = {
		[1] = {events = {{triTime = 550, hitEffID = 30053, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[990163] = {
		[1] = {events = {{triTime = 775, hitEffID = 30053, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[990164] = {
		[1] = {events = {{triTime = 800, hitEffID = 30053, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
