----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[82001] = {	id = 82001, pos = { x = -10.99933, y = 16.04215, z = 121.596 }, dir = { x = 0.0, y = -90.0, z = 0.0 }, ResourcepointID = 38501},
	[82002] = {	id = 82002, pos = { x = 98.42888, y = 16.02733, z = 112.9709 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38501},
	[82003] = {	id = 82003, pos = { x = 87.08839, y = 16.16896, z = 4.784688 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38501},
	[82004] = {	id = 82004, pos = { x = 97.61105, y = 16.09491, z = -87.18808 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38501},
	[82005] = {	id = 82005, pos = { x = -31.51623, y = 16.23649, z = -104.8884 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38501},
	[82006] = {	id = 82006, pos = { x = -74.28429, y = 16.25608, z = -16.66685 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38501},
	[82007] = {	id = 82007, pos = { x = -10.27371, y = 23.2, z = -35.36606 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38501},
	[82008] = {	id = 82008, pos = { x = 64.4044, y = 23.2, z = 21.06555 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38501},
	[82009] = {	id = 82009, pos = { x = -10.99933, y = 16.04215, z = 121.596 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82010] = {	id = 82010, pos = { x = 98.42888, y = 16.02733, z = 112.9709 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82011] = {	id = 82011, pos = { x = 87.08839, y = 16.16896, z = 4.784688 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82012] = {	id = 82012, pos = { x = 97.61105, y = 16.09491, z = -87.18808 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82013] = {	id = 82013, pos = { x = -31.51623, y = 16.23649, z = -104.8884 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82014] = {	id = 82014, pos = { x = -74.28429, y = 16.25608, z = -16.66685 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82015] = {	id = 82015, pos = { x = -10.27371, y = 23.2, z = -35.36606 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82016] = {	id = 82016, pos = { x = 64.4044, y = 23.2, z = 21.06555 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38502},
	[82017] = {	id = 82017, pos = { x = -10.99933, y = 16.04215, z = 121.596 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82018] = {	id = 82018, pos = { x = 98.42888, y = 16.02733, z = 112.9709 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82019] = {	id = 82019, pos = { x = 87.08839, y = 16.16896, z = 4.784688 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82020] = {	id = 82020, pos = { x = 97.61105, y = 16.09491, z = -87.18808 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82021] = {	id = 82021, pos = { x = -31.51623, y = 16.23649, z = -104.8884 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82022] = {	id = 82022, pos = { x = -74.28429, y = 16.25608, z = -16.66685 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82023] = {	id = 82023, pos = { x = -10.27371, y = 23.2, z = -35.36606 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},
	[82024] = {	id = 82024, pos = { x = 64.4044, y = 23.2, z = 21.06555 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 38503},

};
function get_db_table()
	return res_area;
end
