----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99054] = {
		[1] = {cool = 7000, events = {{triTime = 500, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.2, }, }, {triTime = 825, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.2, }, }, {triTime = 1475, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.2, }, }, },},
	},

};
function get_db_table()
	return level;
end
