----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[60101] = {pos = { x = -3.09016, y = 10.22435, z = 2.788742 }, mapid = 10000},
	[60102] = {pos = { x = 2.4926, y = 10.38969, z = 8.950838 }, mapid = 10000},
	[60103] = {pos = { x = 10.43148, y = 10.33302, z = 4.954974 }, mapid = 10000},
	[60104] = {pos = { x = 10.45337, y = 10.4111, z = 2.606727 }, mapid = 10000},
	[60105] = {pos = { x = -3.38278, y = 10.22122, z = 1.715755 }, mapid = 10000},
	[60106] = {pos = { x = 5.196612, y = 10.29495, z = 9.914443 }, mapid = 10000},
	[60107] = {pos = { x = 4.195862, y = 10.94761, z = 2.088566 }, mapid = 10000},
	[60111] = {pos = { x = 2.426624, y = 10.82643, z = 4.729521 }, mapid = 10001},
	[60112] = {pos = { x = 6.982471, y = 10.68305, z = 4.095728 }, mapid = 10001},
	[60113] = {pos = { x = 3.901076, y = 10.80013, z = 0.6723747 }, mapid = 10001},
	[60121] = {pos = { x = -0.7086272, y = 10.37106, z = -0.3055496 }, mapid = 10002},
	[60122] = {pos = { x = 8.42424, y = 10.49363, z = -0.3434715 }, mapid = 10002},
	[60123] = {pos = { x = -0.5034184, y = 10.34486, z = 5.373335 }, mapid = 10002},
	[60124] = {pos = { x = 7.319819, y = 10.54681, z = 5.525237 }, mapid = 10002},
	[60125] = {pos = { x = 3.591201, y = 10.98854, z = 2.302944 }, mapid = 10002},
	[60131] = {pos = { x = -0.446053, y = 10.22021, z = -5.080027 }, mapid = 10003},
	[60132] = {pos = { x = 7.691615, y = 10.23467, z = -4.579508 }, mapid = 10003},
	[60133] = {pos = { x = -3.010232, y = 10.22743, z = 2.122168 }, mapid = 10003},
	[60134] = {pos = { x = 10.46887, y = 10.40659, z = 2.519594 }, mapid = 10003},
	[60135] = {pos = { x = -0.2686491, y = 10.41567, z = 0.0481052 }, mapid = 10003},
	[60136] = {pos = { x = 6.953423, y = 10.30222, z = 0.0 }, mapid = 10003},
	[60137] = {pos = { x = 3.473464, y = 10.89972, z = 1.68018 }, mapid = 10003},
	[60141] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10004},
	[60142] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10004},
	[60143] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10004},
	[60144] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10004},
	[60145] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10004},
	[60146] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10004},
	[60147] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10004},
	[60151] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10005},
	[60152] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10005},
	[60153] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10005},
	[60154] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10005},
	[60155] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10005},
	[60156] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10005},
	[60157] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10005},
	[60158] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10006},
	[60159] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10006},
	[60160] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10006},
	[60161] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10006},
	[60162] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10006},
	[60163] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10006},
	[60164] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10006},
	[60165] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10007},
	[60166] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10007},
	[60167] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10007},
	[60168] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10007},
	[60169] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10007},
	[60170] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10007},
	[60171] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10007},
	[60172] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10008},
	[60173] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10008},
	[60174] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10008},
	[60175] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10008},
	[60176] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10008},
	[60177] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10008},
	[60178] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10008},
	[60179] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10009},
	[60180] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10009},
	[60181] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10009},
	[60182] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10009},
	[60183] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10009},
	[60184] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10009},
	[60185] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10009},
	[60186] = {pos = { x = -0.5815963, y = 10.38476, z = 1.1556 }, mapid = 10010},
	[60187] = {pos = { x = 9.500523, y = 10.49581, z = 1.449732 }, mapid = 10010},
	[60188] = {pos = { x = -2.936273, y = 10.21973, z = 6.063234 }, mapid = 10010},
	[60189] = {pos = { x = 11.24822, y = 10.23467, z = 5.311024 }, mapid = 10010},
	[60190] = {pos = { x = 2.562013, y = 10.64759, z = 6.382236 }, mapid = 10010},
	[60191] = {pos = { x = 6.225073, y = 10.5069, z = 6.935352 }, mapid = 10010},
	[60192] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 10010},

};
function get_db_table()
	return map;
end
