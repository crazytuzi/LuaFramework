----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002201] = {
		[1] = {events = {{triTime = 325, hitEffID = 30964, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002211] = {
		[1] = {events = {{triTime = 325, hitEffID = 30963, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002212] = {
		[1] = {events = {{triTime = 750, hitEffID = 30963, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002222] = {
		[1] = {events = {{triTime = 325, hitEffID = 30913, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 950, hitEffID = 30913, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002231] = {
		[1] = {events = {{triTime = 950, hitEffID = 30967, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1200, hitEffID = 30967, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1450, hitEffID = 30967, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002232] = {
		[1] = {events = {{triTime = 1050, hitEffID = 30968, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1300, hitEffID = 30968, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1550, hitEffID = 30968, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002221] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30913, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002202] = {
		[1] = {events = {{triTime = 750, hitEffID = 30964, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
