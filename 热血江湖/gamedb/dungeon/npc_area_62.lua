----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local npc_area = 
{
	[31001] = {id = 31001, pos = { x = 28.60888, y = 13.42542, z = -3.742979 }, dir = { x = 0.0, y = -330.0, z = 1.0 }, NPCID = 31001},
	[31002] = {id = 31002, pos = { x = 48.89212, y = 13.35855, z = -26.46763 }, dir = { x = 0.0, y = -345.0, z = 1.0 }, NPCID = 31002},

};
function get_db_table()
	return npc_area;
end
