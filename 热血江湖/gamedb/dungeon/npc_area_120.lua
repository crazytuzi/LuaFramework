----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local npc_area = 
{
	[60003] = {id = 60003, pos = { x = -100.1991, y = 15.53747, z = 22.2139 }, dir = { x = 0.0, y = 75.0, z = 0.0 }, NPCID = 60003},
	[60004] = {id = 60004, pos = { x = -25.62985, y = 3.296458, z = 82.95462 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, NPCID = 60004},
	[60005] = {id = 60005, pos = { x = 60.12202, y = 3.163843, z = -131.6414 }, dir = { x = 0.0, y = 15.0, z = 13.0 }, NPCID = 60005},
	[60006] = {id = 60006, pos = { x = 93.26209, y = 2.858551, z = -39.93617 }, dir = { x = 0.0, y = 45.0, z = 13.0 }, NPCID = 60006},
	[60008] = {id = 60008, pos = { x = -92.65519, y = 5.183387, z = -11.26926 }, dir = { x = 0.0, y = 75.0, z = 13.0 }, NPCID = 10332},
	[60009] = {id = 60009, pos = { x = -16.66317, y = 2.183387, z = -9.195343 }, dir = { x = 0.0, y = 90.0, z = 13.0 }, NPCID = 60008},
	[60010] = {id = 60010, pos = { x = 16.4136, y = 26.82833, z = 139.2582 }, dir = { x = 0.0, y = -390.0, z = 0.0 }, NPCID = 60009},
	[60011] = {id = 60011, pos = { x = 3.609679, y = 4.521851, z = -38.1633 }, dir = { x = 0.0, y = 45.0, z = 13.0 }, NPCID = 60011},
	[60012] = {id = 60012, pos = { x = 15.86505, y = 5.183387, z = 29.2005 }, dir = { x = 0.0, y = 45.0, z = 13.0 }, NPCID = 60012},
	[60014] = {id = 60014, pos = { x = -23.52366, y = 4.7599, z = 33.67189 }, dir = { x = 0.0, y = 60.0, z = 13.0 }, NPCID = 60013},
	[60015] = {id = 60015, pos = { x = 4.840296, y = 4.657439, z = 34.54038 }, dir = { x = 0.0, y = -270.0, z = 13.0 }, NPCID = 60014},
	[60018] = {id = 60018, pos = { x = 27.0, y = 11.0, z = 40.0 }, dir = { x = 0.0, y = -300.0, z = 13.0 }, NPCID = 60017},
	[60019] = {id = 60019, pos = { x = -15.88119, y = 16.08383, z = 82.89709 }, dir = { x = 0.0, y = -285.0, z = 13.0 }, NPCID = 60018},
	[60020] = {id = 60020, pos = { x = 1.563542, y = 14.28378, z = -15.00167 }, dir = { x = 0.0, y = -300.0, z = 13.0 }, NPCID = 60019},
	[60021] = {id = 60021, pos = { x = -18.67684, y = 3.036194, z = -44.02114 }, dir = { x = 0.0, y = -240.0, z = 13.0 }, NPCID = 60020},
	[60022] = {id = 60022, pos = { x = 28.92115, y = 16.08383, z = 73.21208 }, dir = { x = 0.0, y = -300.0, z = 13.0 }, NPCID = 60021},
	[60023] = {id = 60023, pos = { x = 64.28385, y = 14.68381, z = 63.39085 }, dir = { x = 0.0, y = -345.0, z = 13.0 }, NPCID = 60022},
	[60024] = {id = 60024, pos = { x = 117.9391, y = 20.08202, z = 53.67986 }, dir = { x = 0.0, y = -225.0, z = 13.0 }, NPCID = 60023},
	[60027] = {id = 60027, pos = { x = 37.10315, y = 17.08202, z = 166.759 }, dir = { x = 0.0, y = 120.0, z = 0.0 }, NPCID = 60026},
	[60030] = {id = 60030, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60030},
	[60031] = {id = 60031, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60031},
	[60032] = {id = 60032, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60032},
	[60033] = {id = 60033, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60033},
	[60034] = {id = 60034, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60034},
	[60035] = {id = 60035, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60035},
	[60036] = {id = 60036, pos = { x = -31.90126, y = 1.037781, z = -113.6216 }, dir = { x = 0.0, y = 465.0, z = 14.0 }, NPCID = 60036},
	[60037] = {id = 60037, pos = { x = -114.9566, y = 15.22632, z = -111.1691 }, dir = { x = 0.0, y = -255.0, z = 14.0 }, NPCID = 60037},
	[60038] = {id = 60038, pos = { x = 41.39185, y = 17.08202, z = 166.5888 }, dir = { x = 0.0, y = 120.0, z = 0.0 }, NPCID = 60038},
	[60039] = {id = 60039, pos = { x = 41.39185, y = 17.08202, z = 163.5888 }, dir = { x = 0.0, y = 120.0, z = 0.0 }, NPCID = 60039},
	[60040] = {id = 60040, pos = { x = 41.542, y = 17.08202, z = 160.7292 }, dir = { x = 0.0, y = 150.0, z = 0.0 }, NPCID = 60040},
	[60041] = {id = 60041, pos = { x = 41.44555, y = 17.08202, z = 169.489 }, dir = { x = 0.0, y = 120.0, z = 0.0 }, NPCID = 60041},
	[60044] = {id = 60044, pos = { x = -3.10289, y = 17.11288, z = 36.51411 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, NPCID = 60044},
	[60045] = {id = 60045, pos = { x = 198.727, y = 19.75932, z = -45.7174 }, dir = { x = 0.0, y = 75.0, z = 12.0 }, NPCID = 60045},
	[60052] = {id = 60052, pos = { x = -34.77315, y = 21.65471, z = 35.237 }, dir = { x = 0.0, y = 45.0, z = 0.0 }, NPCID = 60044},
	[60053] = {id = 60053, pos = { x = -44.84316, y = 16.08383, z = 70.00869 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, NPCID = 60052},
	[60054] = {id = 60054, pos = { x = 53.00648, y = 3.218069, z = 77.66278 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, NPCID = 60053},
	[60056] = {id = 60056, pos = { x = -61.31192, y = -2.339142, z = -68.5152 }, dir = { x = 0.0, y = -360.0, z = 13.0 }, NPCID = 60055},
	[60059] = {id = 60059, pos = { x = -44.07502, y = 16.08383, z = 35.92153 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60058},
	[60062] = {id = 60062, pos = { x = -5.752666, y = 18.03675, z = -68.81749 }, dir = { x = 0.0, y = 405.0, z = 0.0 }, NPCID = 60062},
	[60065] = {id = 60065, pos = { x = 51.54637, y = 0.245252, z = 179.2025 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60065},
	[60066] = {id = 60066, pos = { x = 99.39218, y = 0.3878674, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60066},
	[60067] = {id = 60067, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60067},
	[60068] = {id = 60068, pos = { x = -57.66952, y = 0.1962509, z = -163.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60068},
	[60069] = {id = 60069, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60069},
	[60070] = {id = 60070, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60070},
	[60073] = {id = 60073, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60073},
	[60074] = {id = 60074, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60074},
	[60075] = {id = 60075, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60075},
	[60076] = {id = 60076, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60076},
	[60077] = {id = 60077, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60077},
	[60078] = {id = 60078, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60078},
	[60081] = {id = 60081, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60081},
	[60082] = {id = 60082, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60082},
	[60083] = {id = 60083, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60083},
	[60084] = {id = 60084, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60084},
	[60085] = {id = 60085, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60085},
	[60086] = {id = 60086, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60086},
	[60089] = {id = 60089, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60089},
	[60090] = {id = 60090, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60090},
	[60091] = {id = 60091, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60091},
	[60092] = {id = 60092, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60092},
	[60093] = {id = 60093, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60093},
	[60094] = {id = 60094, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60094},
	[60097] = {id = 60097, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60097},
	[60098] = {id = 60098, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60098},
	[60099] = {id = 60099, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60099},
	[60100] = {id = 60100, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60100},
	[60101] = {id = 60101, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60101},
	[60102] = {id = 60102, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60102},
	[60107] = {id = 60107, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60108] = {id = 60108, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60109] = {id = 60109, pos = { x = -93.22623, y = 0.1962509, z = 165.2303 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60110] = {id = 60110, pos = { x = 89.831665, y = 0.1962509, z = -166.121979 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60111] = {id = 60111, pos = { x = 149.144745, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60112] = {id = 60112, pos = { x = -94.22623, y = 0.1962509, z = 166.230286 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60113] = {id = 60113, pos = { x = 89.831665, y = 0.1962509, z = -166.121979 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60114] = {id = 60114, pos = { x = 149.144745, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60115] = {id = 60115, pos = { x = -94.22623, y = 0.1962509, z = 166.230286 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60116] = {id = 60116, pos = { x = 89.831665, y = 0.1962509, z = -166.121979 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60117] = {id = 60117, pos = { x = 149.144745, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60118] = {id = 60118, pos = { x = -94.22623, y = 0.1962509, z = 166.230286 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60119] = {id = 60119, pos = { x = 89.831665, y = 0.1962509, z = -166.121979 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60120] = {id = 60120, pos = { x = 149.144745, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60121] = {id = 60121, pos = { x = -94.22623, y = 0.1962509, z = 166.230286 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60122] = {id = 60122, pos = { x = 93.83167, y = 0.1962509, z = -165.122 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60123] = {id = 60123, pos = { x = 150.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 435.0, z = 0.0 }, NPCID = 60110},
	[60124] = {id = 60124, pos = { x = -94.22623, y = 0.1962509, z = 180.2303 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60111},
	[60125] = {id = 60125, pos = { x = 92.83167, y = 0.1962509, z = -163.122 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60126] = {id = 60126, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60127] = {id = 60127, pos = { x = -93.22623, y = 0.1962509, z = 163.2303 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60128] = {id = 60128, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60129] = {id = 60129, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60130] = {id = 60130, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60131] = {id = 60131, pos = { x = 89.831665, y = 0.1962509, z = -166.121979 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60132] = {id = 60132, pos = { x = 149.144745, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60133] = {id = 60133, pos = { x = -94.22623, y = 0.1962509, z = 166.230286 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60134] = {id = 60134, pos = { x = 89.831665, y = 0.1962509, z = -166.121979 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60135] = {id = 60135, pos = { x = 149.144745, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60136] = {id = 60136, pos = { x = -94.22623, y = 0.1962509, z = 166.230286 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60137] = {id = 60137, pos = { x = -46.42033, y = 18.11816, z = -84.10485 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60112},
	[60138] = {id = 60138, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60115},
	[60139] = {id = 60139, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60116},
	[60140] = {id = 60140, pos = { x = 51.54637, y = 0.245252, z = 179.2025 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60117},
	[60141] = {id = 60141, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60118},
	[60142] = {id = 60142, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60119},
	[60143] = {id = 60143, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60120},
	[60144] = {id = 60144, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60121},
	[60145] = {id = 60145, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60122},
	[60146] = {id = 60146, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60123},
	[60147] = {id = 60147, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60124},
	[60148] = {id = 60148, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60125},
	[60149] = {id = 60149, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60126},
	[60150] = {id = 60150, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60127},
	[60151] = {id = 60151, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60128},
	[60152] = {id = 60152, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60129},
	[60153] = {id = 60153, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60130},
	[60154] = {id = 60154, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60131},
	[60155] = {id = 60155, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60132},
	[60156] = {id = 60156, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60133},
	[60157] = {id = 60157, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60134},
	[60158] = {id = 60158, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60135},
	[60159] = {id = 60159, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60136},
	[60160] = {id = 60160, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60137},
	[60161] = {id = 60161, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60138},
	[60162] = {id = 60162, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60139},
	[60163] = {id = 60163, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60140},
	[60164] = {id = 60164, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60141},
	[60165] = {id = 60165, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60142},
	[60166] = {id = 60166, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60143},
	[60167] = {id = 60167, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60144},
	[60168] = {id = 60168, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60145},
	[60169] = {id = 60169, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60146},
	[60170] = {id = 60170, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60147},
	[60171] = {id = 60171, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60148},
	[60172] = {id = 60172, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60149},
	[60173] = {id = 60173, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60150},
	[60174] = {id = 60174, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60151},
	[60175] = {id = 60175, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60152},
	[60176] = {id = 60176, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60153},
	[60177] = {id = 60177, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60154},
	[60180] = {id = 60180, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60157},
	[60181] = {id = 60181, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60158},
	[60182] = {id = 60182, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60159},
	[60183] = {id = 60183, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60160},
	[60184] = {id = 60184, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60161},
	[60185] = {id = 60185, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60162},
	[60188] = {id = 60188, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60165},
	[60189] = {id = 60189, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60166},
	[60190] = {id = 60190, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60167},
	[60191] = {id = 60191, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60168},
	[60192] = {id = 60192, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60169},
	[60193] = {id = 60193, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60170},
	[60196] = {id = 60196, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60173},
	[60197] = {id = 60197, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60174},
	[60198] = {id = 60198, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60175},
	[60199] = {id = 60199, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60176},
	[60200] = {id = 60200, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60177},
	[60201] = {id = 60201, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60178},
	[60204] = {id = 60204, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60181},
	[60205] = {id = 60205, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60182},
	[60206] = {id = 60206, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60183},
	[60207] = {id = 60207, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60184},
	[60208] = {id = 60208, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60185},
	[60209] = {id = 60209, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60186},
	[60212] = {id = 60212, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60189},
	[60213] = {id = 60213, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60190},
	[60214] = {id = 60214, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60191},
	[60215] = {id = 60215, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60192},
	[60216] = {id = 60216, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60193},
	[60217] = {id = 60217, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60194},
	[60218] = {id = 60218, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60195},
	[60219] = {id = 60219, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60196},
	[60220] = {id = 60220, pos = { x = 51.54637, y = 0.245252, z = 179.2025 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60197},
	[60221] = {id = 60221, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60198},
	[60222] = {id = 60222, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60199},
	[60223] = {id = 60223, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60200},
	[60224] = {id = 60224, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60201},
	[60225] = {id = 60225, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60202},
	[60226] = {id = 60226, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60203},
	[60227] = {id = 60227, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60204},
	[60228] = {id = 60228, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60205},
	[60229] = {id = 60229, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60206},
	[60230] = {id = 60230, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60207},
	[60231] = {id = 60231, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60208},
	[60232] = {id = 60232, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60209},
	[60233] = {id = 60233, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60210},
	[60234] = {id = 60234, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60211},
	[60235] = {id = 60235, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60212},
	[60236] = {id = 60236, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60213},
	[60237] = {id = 60237, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60214},
	[60238] = {id = 60238, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60215},
	[60239] = {id = 60239, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60216},
	[60240] = {id = 60240, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60217},
	[60241] = {id = 60241, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60218},
	[60242] = {id = 60242, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60219},
	[60243] = {id = 60243, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60220},
	[60244] = {id = 60244, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60221},
	[60245] = {id = 60245, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60222},
	[60246] = {id = 60246, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60223},
	[60247] = {id = 60247, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60224},
	[60248] = {id = 60248, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60225},
	[60249] = {id = 60249, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60226},
	[60250] = {id = 60250, pos = { x = 148.0699, y = 0.3205837, z = -106.8324 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60227},
	[60251] = {id = 60251, pos = { x = -49.53347, y = 0.1962509, z = -19.05539 }, dir = { x = 0.0, y = 360.0, z = 0.0 }, NPCID = 60228},
	[60252] = {id = 60252, pos = { x = 51.54637, y = 0.245252, z = 179.202469 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60229},
	[60253] = {id = 60253, pos = { x = 99.39218, y = 0.3873623, z = 95.03489 }, dir = { x = 0.0, y = 255.0, z = 0.0 }, NPCID = 60230},
	[60254] = {id = 60254, pos = { x = 31.53336, y = 0.2245448, z = 72.14496 }, dir = { x = 0.0, y = 180.0, z = 0.0 }, NPCID = 60231},
	[60255] = {id = 60255, pos = { x = -61.66952, y = 0.1962509, z = -166.0918 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60232},
	[60256] = {id = 60256, pos = { x = -84.19455, y = 0.2656285, z = -96.2981 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60233},
	[60257] = {id = 60257, pos = { x = -32.19664, y = 0.2237686, z = -71.72168 }, dir = { x = 0.0, y = 720.0, z = 0.0 }, NPCID = 60234},
	[60258] = {id = 60258, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60259] = {id = 60259, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60260] = {id = 60260, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60261] = {id = 60261, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60262] = {id = 60262, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60263] = {id = 60263, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60264] = {id = 60264, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 435.0, z = 0.0 }, NPCID = 60110},
	[60265] = {id = 60265, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60111},
	[60266] = {id = 60266, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60267] = {id = 60267, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60268] = {id = 60268, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60269] = {id = 60269, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60270] = {id = 60270, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60271] = {id = 60271, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60272] = {id = 60272, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60273] = {id = 60273, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60274] = {id = 60274, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60275] = {id = 60275, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60276] = {id = 60276, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60277] = {id = 60277, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60278] = {id = 60278, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60279] = {id = 60279, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60280] = {id = 60280, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60281] = {id = 60281, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60282] = {id = 60282, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 435.0, z = 0.0 }, NPCID = 60110},
	[60283] = {id = 60283, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 420.0, z = 0.0 }, NPCID = 60111},
	[60284] = {id = 60284, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60285] = {id = 60285, pos = { x = 89.83167, y = 0.1962509, z = -166.122 }, dir = { x = 0.0, y = 450.0, z = 0.0 }, NPCID = 60110},
	[60286] = {id = 60286, pos = { x = 149.1447, y = 0.1962509, z = -89.47555 }, dir = { x = 0.0, y = 270.0, z = 0.0 }, NPCID = 60111},
	[60287] = {id = 60287, pos = { x = -94.22623, y = 0.1962509, z = 166.2303 }, dir = { x = 0.0, y = 60.0, z = 0.0 }, NPCID = 60109},
	[60288] = {id = 60288, pos = { x = -105.3766, y = 5.183387, z = -30.85971 }, dir = { x = 0.0, y = 45.0, z = 0.0 }, NPCID = 60244},
	[60289] = {id = 60289, pos = { x = -145.6229, y = 15.10461, z = 60.68949 }, dir = { x = 0.0, y = 45.0, z = 0.0 }, NPCID = 60245},

};
function get_db_table()
	return npc_area;
end
