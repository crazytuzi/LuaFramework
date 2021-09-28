----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1003102] = {
		[1] = {cool = 6000, events = {{triTime = 400, hitEffID = 30891, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 500, hitEffID = 30891, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 700, hitEffID = 30891, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, },},
	},
	[1003101] = {
		[1] = {cool = 6000, events = {{triTime = 1250, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003103] = {
		[1] = {cool = 6000, events = {{triTime = 650, hitEffID = 30890, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003104] = {
		[1] = {cool = 6000, events = {{triTime = 1250, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003105] = {
		[1] = {cool = 6000, events = {{triTime = 425, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 825, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
