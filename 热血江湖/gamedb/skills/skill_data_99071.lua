----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99071] = {
		[1] = {cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.1, }, }, },},
	},

};
function get_db_table()
	return level;
end
