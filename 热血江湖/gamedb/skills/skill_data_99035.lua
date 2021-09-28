----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99035] = {
		[1] = {cool = 15000, events = {{triTime = 1875, hitEffID = 30090, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.417, arg2 = 124.0, }, }, },spArgs1 = '241.7', spArgs2 = '124', spArgs3 = '0', },
	},

};
function get_db_table()
	return level;
end
