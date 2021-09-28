----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[60001] = {	id = 60001, pos = { x = -104.1267, y = 7.0, z = 7.617018 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6001},
	[60002] = {	id = 60002, pos = { x = -48.00001, y = 13.83619, z = 69.30001 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6002},
	[60003] = {	id = 60003, pos = { x = -16.28785, y = 3.436298, z = -4.380074 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6003},
	[60004] = {	id = 60004, pos = { x = -15.94727, y = 3.036188, z = -108.7438 }, dir = { x = 0.0, y = 0.0, z = 1.0 }, ResourcepointID = 6013},
	[60005] = {	id = 60005, pos = { x = -54.11092, y = 3.609921, z = 49.54676 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 6004},
	[60006] = {	id = 60006, pos = { x = -101.6283, y = 0.2000002, z = -39.44691 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6005},
	[60007] = {	id = 60007, pos = { x = -52.32294, y = 10.23619, z = -17.62316 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6006},
	[60008] = {	id = 60008, pos = { x = -110.6218, y = 17.16384, z = 113.5528 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6007},
	[60009] = {	id = 60009, pos = { x = 34.68972, y = 24.19971, z = 138.5055 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6008},
	[60010] = {	id = 60010, pos = { x = -48.23788, y = 7.726531, z = -79.36111 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6009},
	[60011] = {	id = 60011, pos = { x = 77.53997, y = 17.3917, z = 44.29248 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6010},
	[60012] = {	id = 60012, pos = { x = -158.0198, y = 4.163841, z = -107.5851 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6011},
	[60013] = {	id = 60013, pos = { x = 7.46048, y = 13.35855, z = 11.14395 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 6012},

};
function get_db_table()
	return res_area;
end
