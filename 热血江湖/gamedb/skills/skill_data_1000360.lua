----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000371] = {
		[1] = {events = {{triTime = 650, hitEffID = 30180, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000372] = {
		[1] = {events = {{triTime = 775, hitEffID = 30180, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000373] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30180, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000374] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30180, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
