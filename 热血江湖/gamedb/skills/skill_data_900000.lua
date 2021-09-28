----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900037] = {
		[1] = {events = {{triTime = 825, hitEffID = 30404, hitSoundID = 3, damage = {odds = 10000, atrType = 1, arg1 = 0.8, }, }, },},
	},
	[900038] = {
		[1] = {events = {{hitEffID = 30404, hitSoundID = 3, damage = {odds = 10000, atrType = 1, arg1 = 0.8, }, }, },},
	},
	[900031] = {
		[1] = {events = {{triTime = 425, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[900033] = {
		[1] = {events = {{triTime = 780, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.2, }, }, },},
	},
	[900034] = {
		[1] = {events = {{hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.75, }, }, },},
	},
	[900035] = {
		[1] = {events = {{triTime = 275, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.8, }, }, {triTime = 825, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.8, }, }, },},
	},
	[900036] = {
		[1] = {events = {{triTime = 250, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.6, }, }, {triTime = 650, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.6, }, }, {triTime = 1300, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[900032] = {
		[1] = {events = {{triTime = 125, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
