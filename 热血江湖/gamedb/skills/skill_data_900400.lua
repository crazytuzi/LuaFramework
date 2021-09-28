----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900401] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 1200, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.15, arg2 = 181.0, }, }, },skillpower = 24, },
	},
	[900402] = {
		[1] = {addSP = 50, cool = 8000, events = {{triTime = 350, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.1875, arg2 = 100.0, }, }, {triTime = 750, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.1875, arg2 = 100.0, }, }, },skillpower = 24, },
	},
	[900403] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 600, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.75, arg2 = 231.0, }, }, },skillpower = 24, },
	},
	[900404] = {
		[1] = {addSP = 50, cool = 11000, events = {{triTime = 300, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8875, arg2 = 75.0, }, }, {triTime = 625, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8875, arg2 = 75.0, }, }, {triTime = 925, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8875, arg2 = 75.0, realmAddon = 0.05, }, }, },skillpower = 24, },
	},

};
function get_db_table()
	return level;
end
