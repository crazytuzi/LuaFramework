----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1004101] = {
		[1] = {cool = 6000, events = {{triTime = 750, hitEffID = 30291, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1004102] = {
		[1] = {cool = 6000, events = {{triTime = 550, hitEffID = 30858, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 750, hitEffID = 30858, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1004103] = {
		[1] = {cool = 6000, events = {{triTime = 525, hitEffID = 30859, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1004104] = {
		[1] = {cool = 6000, events = {{triTime = 700, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 800, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 900, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
