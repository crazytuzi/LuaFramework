----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900501] = {
		[1] = {addSP = 50, cool = 5000, events = {{triTime = 450, hitEffID = 30092, hitSoundID = 3, damage = {odds = 10000, arg1 = 0.6375, arg2 = 54.0, }, }, {triTime = 1150, hitEffID = 30092, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.6375, arg2 = 54.0, }, }, },skillpower = 24, },
	},
	[900502] = {
		[1] = {addSP = 50, cool = 8000, events = {{triTime = 575, hitEffID = 30093, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.5625, arg2 = 47.0, }, }, {triTime = 1250, hitEffID = 30093, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.5625, arg2 = 47.0, }, }, {triTime = 1800, hitEffID = 30093, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.5625, arg2 = 47.0, realmAddon = 0.05, }, }, },skillpower = 24, },
	},
	[900503] = {
		[1] = {addSP = 50, cool = 9000, events = {{triTime = 400, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.9, arg2 = 76.0, }, }, {triTime = 875, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.9, arg2 = 76.0, }, }, },skillpower = 24, },
	},
	[900504] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 750, damage = {odds = 10000, atrType = 1, arg1 = 1.1875, arg2 = 128.0, }, }, },skillpower = 24, },
	},

};
function get_db_table()
	return level;
end
