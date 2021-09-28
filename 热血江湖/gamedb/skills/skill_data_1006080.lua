----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1006101] = {
		[1] = {cool = 6000, events = {{triTime = 600, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1006102] = {
		[1] = {cool = 6000, events = {{triTime = 625, hitEffID = 30315, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 725, hitEffID = 30315, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1006103] = {
		[1] = {cool = 6000, events = {{triTime = 600, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1006104] = {
		[1] = {cool = 6000, events = {{triTime = 800, hitEffID = 30156, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
