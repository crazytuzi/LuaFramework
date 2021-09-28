----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1007102] = {
		[1] = {cool = 6000, events = {{triTime = 300, hitEffID = 30136, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 575, hitEffID = 30138, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 825, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, },},
	},
	[1007103] = {
		[1] = {cool = 6000, events = {{triTime = 700, hitEffID = 30293, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 800, hitEffID = 30293, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1007101] = {
		[1] = {cool = 6000, events = {{triTime = 450, hitEffID = 30941, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 550, hitEffID = 30941, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
