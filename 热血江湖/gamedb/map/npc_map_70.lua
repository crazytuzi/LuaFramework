----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[35101] = {	pos = { x = -32.71845, y = 3.514347, z = 47.7732 }, mapid = 50000},
	[35101] = {	pos = { x = -32.71845, y = 3.514347, z = 47.7732 }, mapid = 50002},
	[35001] = {	pos = { x = -7.58408, y = 21.04498, z = 0.2969703 }, mapid = 40001},
	[35102] = {	pos = { x = 23.93613, y = 5.0, z = -26.49432 }, mapid = 50100},
	[35002] = {	pos = { x = -8.037815, y = 21.03806, z = -3.460566 }, mapid = 40044},
	[35103] = {	pos = { x = 9.89915, y = 9.443573, z = 10.70455 }, mapid = 50200},

};
function get_db_table()
	return map;
end
