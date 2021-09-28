----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[20006] = {
		[1] = {events = {{triTime = 100, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 1.8, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 2.2, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 2.6, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 3.4, }, }, },},
	},

};
function get_db_table()
	return level;
end
