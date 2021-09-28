----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001961] = {
		[1] = {events = {{triTime = 350, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001962] = {
		[1] = {events = {{triTime = 825, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1075, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001972] = {
		[1] = {events = {{triTime = 750, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001971] = {
		[1] = {events = {{triTime = 725, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001981] = {
		[1] = {events = {{triTime = 425, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 800, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001982] = {
		[1] = {events = {{triTime = 375, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 900, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1550, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001991] = {
		[1] = {events = {{triTime = 675, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001992] = {
		[1] = {events = {{triTime = 825, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1525, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
