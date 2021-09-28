----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99046] = {
		[1] = {cool = 5000, events = {{triTime = 500, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},

};
function get_db_table()
	return level;
end
