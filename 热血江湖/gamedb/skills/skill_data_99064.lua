----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99064] = {
		[1] = {cool = 7000, events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, {triTime = 1025, hitEffID = 30178, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
