----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1004002] = {
		[1] = {cool = 2000, events = {{triTime = 475, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 525, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1004001] = {
		[1] = {cool = 2000, events = {{triTime = 450, hitEffID = 30290, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1004003] = {
		[1] = {cool = 2000, events = {{triTime = 1025, hitEffID = 30289, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 1125, hitEffID = 30289, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
