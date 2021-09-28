----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99055] = {
		[1] = {cool = 7000, events = {{triTime = 375, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.9, }, }, {triTime = 725, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.9, }, }, {triTime = 1225, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.9, }, status = {{odds = 10000, buffID = 482, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
