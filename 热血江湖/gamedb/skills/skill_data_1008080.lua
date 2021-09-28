----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1008101] = {
		[1] = {cool = 6000, events = {{triTime = 400, hitEffID = 30945, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 700, hitEffID = 30945, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 1000, hitEffID = 30945, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, },},
	},
	[1008102] = {
		[1] = {cool = 6000, events = {{triTime = 500, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1008103] = {
		[1] = {cool = 6000, events = {{triTime = 675, hitEffID = 30299, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 825, hitEffID = 30299, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1008104] = {
		[1] = {cool = 6000, events = {{triTime = 250, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 650, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, {triTime = 1300, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 5000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
