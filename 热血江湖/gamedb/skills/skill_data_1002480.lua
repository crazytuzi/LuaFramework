----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002502] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30997, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 848, }, }, }, },},
	},
	[1002501] = {
		[1] = {events = {{triTime = 525, hitEffID = 30996, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 15000, buffID = 846, }, }, }, {triTime = 1050, hitEffID = 30996, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 10000, buffID = 847, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
