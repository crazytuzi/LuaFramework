----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94033] = {
		[1] = {cool = 15000, events = {{triTime = 300, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.65, }, status = {{odds = 10000, buffID = 1506, }, }, }, {triTime = 775, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.65, }, }, },},
	},

};
function get_db_table()
	return level;
end
