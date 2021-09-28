----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[90716] = {pos = { x = -1.343121, y = 12.39662, z = 46.41647 }, mapid = 57},
	[90714] = {pos = { x = 1.00047, y = 12.38265, z = 41.87456 }, mapid = 57},
	[90713] = {pos = { x = 3.904606, y = 12.39663, z = 47.25355 }, mapid = 57},
	[90601] = {pos = { x = -37.58847, y = 11.58903, z = -66.91361 }, mapid = 50},
	[90602] = {pos = { x = -40.62629, y = 11.47584, z = -73.83395 }, mapid = 50},
	[90603] = {pos = { x = 9.720469, y = 11.38163, z = -76.32088 }, mapid = 50},
	[90604] = {pos = { x = -9.701036, y = 9.637915, z = -49.98682 }, mapid = 50},
	[90605] = {pos = { x = -15.77306, y = 9.268519, z = -42.64809 }, mapid = 50},
	[90606] = {pos = { x = -12.77918, y = 9.381625, z = -43.59319 }, mapid = 50},
	[90611] = {pos = { x = -37.49363, y = 11.38163, z = -63.20829 }, mapid = 51},
	[90612] = {pos = { x = -40.86953, y = 11.52282, z = -72.46466 }, mapid = 51},
	[90613] = {pos = { x = -40.34335, y = 11.38163, z = -64.82439 }, mapid = 51},
	[90614] = {pos = { x = -9.241899, y = 9.681313, z = -52.63168 }, mapid = 51},
	[90615] = {pos = { x = -16.58884, y = 9.316567, z = -44.90977 }, mapid = 51},
	[90616] = {pos = { x = -13.49046, y = 9.381625, z = -44.77201 }, mapid = 51},
	[90619] = {pos = { x = 35.79536, y = 13.97486, z = -8.783749 }, mapid = 51},
	[90617] = {pos = { x = 34.80945, y = 13.95455, z = -11.88401 }, mapid = 51},
	[90618] = {pos = { x = 36.98103, y = 13.86703, z = -12.86724 }, mapid = 51},
	[90621] = {pos = { x = -40.1225, y = 11.38163, z = -61.96347 }, mapid = 52},
	[90622] = {pos = { x = -41.9757, y = 11.47253, z = -73.28238 }, mapid = 52},
	[90623] = {pos = { x = 7.823785, y = 11.38163, z = -73.59138 }, mapid = 52},
	[90624] = {pos = { x = -8.257444, y = 9.724968, z = -52.80709 }, mapid = 52},
	[90625] = {pos = { x = -16.91927, y = 9.305968, z = -44.40629 }, mapid = 52},
	[90626] = {pos = { x = -14.54785, y = 9.344854, z = -44.79349 }, mapid = 52},
	[90629] = {pos = { x = 35.41484, y = 13.95815, z = -8.719515 }, mapid = 52},
	[90627] = {pos = { x = 36.58109, y = 13.911, z = -11.33597 }, mapid = 52},
	[90628] = {pos = { x = 38.49199, y = 13.90284, z = -9.516986 }, mapid = 52},
	[90631] = {pos = { x = -42.79887, y = 11.37133, z = -76.33125 }, mapid = 406},
	[90632] = {pos = { x = -36.99176, y = 11.38163, z = -63.32349 }, mapid = 406},
	[90633] = {pos = { x = -40.30273, y = 11.51234, z = -69.94406 }, mapid = 406},
	[90634] = {pos = { x = -7.877042, y = 9.741485, z = -52.90531 }, mapid = 406},
	[90635] = {pos = { x = -17.94424, y = 9.582618, z = -42.49358 }, mapid = 406},
	[90636] = {pos = { x = -15.16601, y = 9.270002, z = -42.77371 }, mapid = 406},
	[90701] = {pos = { x = -2.30995, y = 0.3458553, z = -34.72316 }, mapid = 56},
	[90702] = {pos = { x = 1.037706, y = 8.433211, z = -3.585737 }, mapid = 56},
	[90703] = {pos = { x = 41.85783, y = 3.025881, z = 30.84231 }, mapid = 56},
	[90705] = {pos = { x = -36.35271, y = 8.196625, z = -23.0067 }, mapid = 56},
	[90704] = {pos = { x = -32.17801, y = 8.196625, z = -22.73757 }, mapid = 56},
	[90706] = {pos = { x = 1.605928, y = 12.39662, z = 44.53877 }, mapid = 56},
	[90711] = {pos = { x = -2.996635, y = 0.3410247, z = -34.73306 }, mapid = 57},
	[90712] = {pos = { x = -3.377045, y = 8.193416, z = 4.915325 }, mapid = 57},
	[90715] = {pos = { x = -34.57533, y = 8.196625, z = -23.89133 }, mapid = 57},
	[90721] = {pos = { x = -3.053135, y = 0.1966242, z = -32.76231 }, mapid = 58},
	[90722] = {pos = { x = 0.8696826, y = 8.455522, z = -3.36493 }, mapid = 58},
	[90723] = {pos = { x = 37.4703, y = 3.125645, z = 30.85241 }, mapid = 58},
	[90725] = {pos = { x = -34.01676, y = 8.196625, z = -22.7917 }, mapid = 58},
	[90724] = {pos = { x = -34.50589, y = 8.196625, z = -26.29488 }, mapid = 58},
	[90726] = {pos = { x = -3.102395, y = 12.39662, z = 43.1241 }, mapid = 58},
	[90731] = {pos = { x = 1.067593, y = 0.1966242, z = -32.5651 }, mapid = 407},
	[90732] = {pos = { x = -2.895568, y = 8.582868, z = 2.447273 }, mapid = 407},
	[90733] = {pos = { x = 33.63847, y = 3.071354, z = 31.59551 }, mapid = 407},
	[90735] = {pos = { x = -34.29607, y = 8.196625, z = -26.02446 }, mapid = 407},
	[90734] = {pos = { x = -29.45268, y = 8.289554, z = -21.17038 }, mapid = 407},
	[90736] = {pos = { x = 3.533358, y = 12.39663, z = 48.83629 }, mapid = 407},
	[90609] = {pos = { x = 35.51321, y = 13.96042, z = -8.444727 }, mapid = 50},
	[90607] = {pos = { x = 35.15428, y = 13.96287, z = -10.9722 }, mapid = 50},
	[90608] = {pos = { x = 37.10925, y = 13.95854, z = -6.682499 }, mapid = 50},
	[90639] = {pos = { x = 35.77958, y = 13.97077, z = -8.298944 }, mapid = 406},
	[90637] = {pos = { x = 35.5002, y = 13.68962, z = -4.017431 }, mapid = 406},
	[90638] = {pos = { x = 39.51587, y = 13.91801, z = -9.219509 }, mapid = 406},

};
function get_db_table()
	return map;
end
