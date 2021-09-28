----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[31000] = {resPosId = 70350, pos = { x = -0.2825464, y = 8.305712, z = 52.59652 }, mapid = 35330},
	[31001] = {resPosId = 70351, pos = { x = -0.06124, y = 8.305712, z = 52.61918 }, mapid = 35331},
	[31002] = {resPosId = 70352, pos = { x = -0.137486, y = 8.305712, z = 52.30104 }, mapid = 35332},
	[31003] = {resPosId = 70353, pos = { x = 0.0437015, y = 8.305712, z = 52.29247 }, mapid = 35333},
	[31004] = {resPosId = 70354, pos = { x = 0.0437015, y = 8.305712, z = 52.29247 }, mapid = 35334},

};
function get_db_table()
	return map;
end
