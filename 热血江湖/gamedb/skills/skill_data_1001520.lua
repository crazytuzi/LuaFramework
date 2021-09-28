----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001521] = {
		[1] = {events = {{triTime = 525, hitEffID = 30450, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001522] = {
		[1] = {events = {{triTime = 600, hitEffID = 30450, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001531] = {
		[1] = {events = {{triTime = 525, hitEffID = 30443, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001532] = {
		[1] = {events = {{triTime = 600, hitEffID = 30443, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001541] = {
		[1] = {events = {{triTime = 550, hitEffID = 30455, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001542] = {
		[1] = {events = {{triTime = 625, hitEffID = 30455, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001552] = {
		[1] = {events = {{triTime = 675, hitEffID = 30430, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001551] = {
		[1] = {events = {{triTime = 525, hitEffID = 30430, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
