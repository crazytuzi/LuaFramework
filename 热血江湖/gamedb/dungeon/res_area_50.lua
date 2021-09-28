----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[50001] = {	id = 50001, pos = { x = 11.2029, y = 3.386841, z = -10.03488 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 5001},
	[50002] = {	id = 50002, pos = { x = 104.4189, y = 3.075851, z = -65.33102 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5002},
	[50003] = {	id = 50003, pos = { x = 33.44353, y = 9.275856, z = 94.45356 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5003},
	[50004] = {	id = 50004, pos = { x = 102.0627, y = 7.434466, z = 125.3691 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5004},
	[50005] = {	id = 50005, pos = { x = -54.30712, y = 17.03447, z = -90.21226 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5005},
	[50006] = {	id = 50006, pos = { x = 67.26618, y = 3.039565, z = -83.04103 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5006},
	[50007] = {	id = 50007, pos = { x = -28.79845, y = 1.786804, z = -132.4717 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5007},
	[50008] = {	id = 50008, pos = { x = -30.60137, y = 3.036194, z = -38.08411 }, dir = { x = 0.0, y = -15.0, z = 0.0 }, ResourcepointID = 5008},

};
function get_db_table()
	return res_area;
end
