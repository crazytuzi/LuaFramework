----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99081] = {
		[1] = {cool = 4000, events = {{triTime = 850, hitEffID = 30991, hitSoundID = 2, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
