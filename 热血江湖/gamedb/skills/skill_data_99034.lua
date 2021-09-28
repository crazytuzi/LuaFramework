----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99034] = {
		[1] = {cool = 7000, events = {{triTime = 525, hitEffID = 30089, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.9847, arg2 = 102.0, }, }, },spArgs1 = '198.47', spArgs2 = '102', spArgs3 = '60', spArgs4 = '1.15', },
	},

};
function get_db_table()
	return level;
end
