----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local npc_area = 
{
	[22001] = {id = 22001, pos = { x = -60.70387, y = 8.117817, z = 124.6406 }, dir = { x = 0.0, y = 120.0, z = 0.0 }, NPCID = 20201},
	[22002] = {id = 22002, pos = { x = -21.51144, y = 8.450823, z = 79.21377 }, dir = { x = 0.0, y = -270.0, z = 0.0 }, NPCID = 20202},
	[22101] = {id = 22101, pos = { x = -52.2265, y = 3.213403, z = 52.74388 }, dir = { x = 0.0, y = -270.0, z = 0.0 }, NPCID = 20211},
	[22102] = {id = 22102, pos = { x = -107.0523, y = 17.26384, z = 98.24489 }, dir = { x = 0.0, y = -270.0, z = 0.0 }, NPCID = 20212},

};
function get_db_table()
	return npc_area;
end
