----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[142012] = {pos = { x = 60.33619, y = 23.69692, z = 41.26384 }, mapid = 62001},
	[142001] = {pos = { x = 26.92334, y = 32.2, z = 45.14256 }, mapid = 62001},
	[142002] = {pos = { x = 19.71225, y = 32.2, z = -16.57453 }, mapid = 62001},
	[142004] = {pos = { x = 4.167206, y = 16.24095, z = 103.9795 }, mapid = 62001},
	[142005] = {pos = { x = 6.016312, y = 16.2176, z = 104.605 }, mapid = 62001},
	[142006] = {pos = { x = 100.1613, y = 16.22451, z = 97.14647 }, mapid = 62001},
	[142007] = {pos = { x = 104.7286, y = 16.29207, z = 3.732468 }, mapid = 62001},
	[142008] = {pos = { x = 103.9627, y = 16.24124, z = -73.39664 }, mapid = 62001},
	[142009] = {pos = { x = -29.97532, y = 16.226, z = -96.04993 }, mapid = 62001},
	[142010] = {pos = { x = -64.3353, y = 16.11864, z = -17.7282 }, mapid = 62001},
	[142011] = {pos = { x = -0.8369751, y = 23.64383, z = -63.94284 }, mapid = 62001},
	[142015] = {pos = { x = 26.92334, y = 32.2, z = 45.14256 }, mapid = 62002},
	[142016] = {pos = { x = 19.71225, y = 32.2, z = -16.57453 }, mapid = 62002},
	[142018] = {pos = { x = 4.167206, y = 16.24095, z = 103.9795 }, mapid = 62002},
	[142019] = {pos = { x = 6.016312, y = 16.2176, z = 104.605 }, mapid = 62002},
	[142020] = {pos = { x = 100.1613, y = 16.22451, z = 97.14647 }, mapid = 62002},
	[142021] = {pos = { x = 104.7286, y = 16.29207, z = 3.732468 }, mapid = 62002},
	[142022] = {pos = { x = 103.9627, y = 16.24124, z = -73.39664 }, mapid = 62002},
	[142023] = {pos = { x = -29.97532, y = 16.226, z = -96.04993 }, mapid = 62002},
	[142024] = {pos = { x = -64.3353, y = 16.11864, z = -17.7282 }, mapid = 62002},
	[142025] = {pos = { x = -0.8369751, y = 23.64383, z = -63.94284 }, mapid = 62002},
	[142026] = {pos = { x = 60.33619, y = 23.69692, z = 41.26384 }, mapid = 62002},
	[142029] = {pos = { x = 26.92334, y = 32.2, z = 45.14256 }, mapid = 62003},
	[142030] = {pos = { x = 19.71225, y = 32.2, z = -16.57453 }, mapid = 62003},
	[142032] = {pos = { x = 4.167206, y = 16.24095, z = 103.9795 }, mapid = 62003},
	[142033] = {pos = { x = 6.016312, y = 16.2176, z = 104.605 }, mapid = 62003},
	[142034] = {pos = { x = 100.1613, y = 16.22451, z = 97.14647 }, mapid = 62003},
	[142035] = {pos = { x = 104.7286, y = 16.29207, z = 3.732468 }, mapid = 62003},
	[142036] = {pos = { x = 103.9627, y = 16.24124, z = -73.39664 }, mapid = 62003},
	[142037] = {pos = { x = -29.97532, y = 16.226, z = -96.04993 }, mapid = 62003},
	[142038] = {pos = { x = -64.3353, y = 16.11864, z = -17.7282 }, mapid = 62003},
	[142039] = {pos = { x = -0.8369751, y = 23.64383, z = -63.94284 }, mapid = 62003},
	[142040] = {pos = { x = 60.33619, y = 23.69692, z = 41.26384 }, mapid = 62003},

};
function get_db_table()
	return map;
end
