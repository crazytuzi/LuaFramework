----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001121] = {
		[1] = {events = {{triTime = 650, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001122] = {
		[1] = {events = {{triTime = 650, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001123] = {
		[1] = {events = {{triTime = 700, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},
	[1001152] = {
		[1] = {events = {{triTime = 675, hitEffID = 30765, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001151] = {
		[1] = {events = {{triTime = 625, hitEffID = 30765, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
