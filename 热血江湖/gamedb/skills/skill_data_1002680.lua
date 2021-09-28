----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002701] = {
		[1] = {events = {{triTime = 500, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002702] = {
		[1] = {events = {{triTime = 500, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002703] = {
		[1] = {events = {{triTime = 1500, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
