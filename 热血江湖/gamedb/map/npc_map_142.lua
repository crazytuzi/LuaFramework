----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[71013] = {	pos = { x = 21.65683, y = 34.79926, z = 100.9731 }, mapid = 70023},
	[71021] = {	pos = { x = 70.1716843, y = 7.59582329, z = -97.6421356 }, mapid = 8888},
	[71025] = {	pos = { x = -130.85, y = 19.83134, z = -66.19167 }, mapid = 8889},
	[71026] = {	pos = { x = -116.1322, y = 18.50963, z = -86.60684 }, mapid = 8889},
	[71022] = {	pos = { x = 67.9240952, y = 7.5231657, z = -111.291351 }, mapid = 8888},
	[71023] = {	pos = { x = 83.4452438, y = 7.157895, z = -99.5495758 }, mapid = 8888},
	[71024] = {	pos = { x = -133.408, y = 19.84318, z = -84.03376 }, mapid = 8889},
	[71001] = {	pos = { x = -36.0025, y = 30.0189, z = 25.90174 }, mapid = 70021},
	[71002] = {	pos = { x = -33.73912, y = 35.63726, z = 92.22607 }, mapid = 70021},
	[71003] = {	pos = { x = 21.65683, y = 34.79926, z = 100.9731 }, mapid = 70021},
	[71004] = {	pos = { x = -39.43065, y = 17.6, z = -102.6836 }, mapid = 70021},
	[71005] = {	pos = { x = -28.23949, y = 24.0, z = -35.01253 }, mapid = 70021},
	[71006] = {	pos = { x = -36.0025, y = 30.0189, z = 25.90174 }, mapid = 70022},
	[71007] = {	pos = { x = -33.73912, y = 35.63726, z = 92.22607 }, mapid = 70022},
	[71008] = {	pos = { x = 21.65683, y = 34.79926, z = 100.9731 }, mapid = 70022},
	[71009] = {	pos = { x = -39.43065, y = 17.6, z = -102.6836 }, mapid = 70022},
	[71010] = {	pos = { x = -28.23949, y = 24.0, z = -35.01253 }, mapid = 70022},
	[71011] = {	pos = { x = -36.0025, y = 30.0189, z = 25.90174 }, mapid = 70023},
	[71012] = {	pos = { x = -33.73912, y = 35.63726, z = 92.22607 }, mapid = 70023},
	[71014] = {	pos = { x = -39.43065, y = 17.6, z = -102.6836 }, mapid = 70023},
	[71015] = {	pos = { x = -28.23949, y = 24.0, z = -35.01253 }, mapid = 70023},
	[71016] = {	pos = { x = -36.0025, y = 30.0189, z = 25.90174 }, mapid = 70024},
	[71017] = {	pos = { x = -33.73912, y = 35.63726, z = 92.22607 }, mapid = 70024},
	[71018] = {	pos = { x = 21.65683, y = 34.79926, z = 100.9731 }, mapid = 70024},
	[71019] = {	pos = { x = -39.43065, y = 17.6, z = -102.6836 }, mapid = 70024},
	[71020] = {	pos = { x = -28.23949, y = 24.0, z = -35.01253 }, mapid = 70024},

};
function get_db_table()
	return map;
end
