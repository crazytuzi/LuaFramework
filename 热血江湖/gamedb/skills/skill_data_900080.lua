----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900101] = {
		[1] = {addSP = 50, cool = 8000, events = {{triTime = 350, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.2125, arg2 = 102.0, }, }, {triTime = 775, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.2125, arg2 = 102.0, }, }, },},
	},
	[900102] = {
		[1] = {addSP = 50, cool = 9000, events = {{triTime = 675, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.1875, arg2 = 184.0, }, }, },},
	},
	[900103] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 800, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.875, arg2 = 242.0, }, }, },},
	},
	[900104] = {
		[1] = {addSP = 50, cool = 10000, events = {{hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.6, arg2 = 50.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
