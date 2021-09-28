----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[990071] = {
		[1] = {events = {{triTime = 550, hitEffID = 30758, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[990072] = {
		[1] = {events = {{triTime = 450, hitEffID = 30758, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[990073] = {
		[1] = {events = {{triTime = 450, hitEffID = 30758, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 10000, buffID = 5, }, }, }, },},
	},
	[990074] = {
		[1] = {events = {{triTime = 125, hitEffID = 30758, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.45, }, }, },},
	},
	[990075] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30758, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
