----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001481] = {
		[1] = {events = {{triTime = 425, hitEffID = 30414, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001482] = {
		[1] = {events = {{triTime = 600, hitEffID = 30414, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001491] = {
		[1] = {events = {{triTime = 500, hitEffID = 30439, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001492] = {
		[1] = {events = {{triTime = 525, hitEffID = 30439, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001501] = {
		[1] = {events = {{triTime = 400, hitEffID = 30436, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001511] = {
		[1] = {events = {{triTime = 400, hitEffID = 30440, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001512] = {
		[1] = {events = {{triTime = 600, hitEffID = 30440, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001502] = {
		[1] = {events = {{triTime = 500, hitEffID = 30436, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
