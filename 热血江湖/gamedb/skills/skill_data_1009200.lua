----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1009203] = {
		[1] = {cool = 6000, events = {{triTime = 500, hitEffID = 30966, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1009201] = {
		[1] = {cool = 6000, events = {{triTime = 450, hitEffID = 30404, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1009202] = {
		[1] = {cool = 6000, events = {{triTime = 500, hitEffID = 30966, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 750, hitEffID = 30966, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 1000, hitEffID = 30966, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
