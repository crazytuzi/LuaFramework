----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900041] = {
		[1] = {events = {{triTime = 325, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 600, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 925, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[900042] = {
		[1] = {events = {{triTime = 550, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1100, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 2500, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[900043] = {
		[1] = {events = {{triTime = 1350, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 4.0, }, }, {triTime = 1775, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 2550, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[900044] = {
		[1] = {events = {},},
	},
	[900045] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, acrType = 1, arg2 = 500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
