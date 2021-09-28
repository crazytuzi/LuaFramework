----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[10301] = {	id = 10301, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10301, 10302,  } , spawndeny = 0 },
	[10302] = {	id = 10302, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10303, 10304,  } , spawndeny = 0 },
	[10303] = {	id = 10303, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10305, 10306,  } , spawndeny = 0 },
	[10304] = {	id = 10304, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10307, 10308,  } , spawndeny = 0 },
	[10305] = {	id = 10305, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10309, 10310,  } , spawndeny = 0 },
	[10306] = {	id = 10306, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10311, 10312,  } , spawndeny = 0 },
	[10307] = {	id = 10307, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10313, 10314,  } , spawndeny = 0 },
	[10308] = {	id = 10308, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10315, 10316,  } , spawndeny = 0 },
	[10309] = {	id = 10309, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10317, 10318,  } , spawndeny = 0 },
	[10310] = {	id = 10310, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10319, 10320,  } , spawndeny = 0 },
	[10311] = {	id = 10311, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10321, 10322,  } , spawndeny = 0 },
	[10312] = {	id = 10312, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10323, 10324,  } , spawndeny = 0 },
	[10313] = {	id = 10313, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10325, 10326,  } , spawndeny = 0 },
	[10314] = {	id = 10314, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10327, 10328,  } , spawndeny = 0 },
	[10315] = {	id = 10315, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10329, 10330,  } , spawndeny = 0 },
	[10316] = {	id = 10316, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10331, 10332,  } , spawndeny = 0 },
	[10317] = {	id = 10317, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10333, 10334,  } , spawndeny = 0 },
	[10318] = {	id = 10318, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10335, 10336,  } , spawndeny = 0 },
	[10319] = {	id = 10319, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10337, 10338,  } , spawndeny = 0 },
	[10320] = {	id = 10320, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10339, 10340,  } , spawndeny = 0 },
	[10321] = {	id = 10321, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10341, 10342,  } , spawndeny = 0 },
	[10322] = {	id = 10322, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10343, 10344,  } , spawndeny = 0 },
	[10323] = {	id = 10323, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10345, 10346,  } , spawndeny = 0 },
	[10324] = {	id = 10324, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10347, 10348,  } , spawndeny = 0 },
	[10325] = {	id = 10325, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10349, 10350,  } , spawndeny = 0 },
	[10326] = {	id = 10326, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10351, 10352,  } , spawndeny = 0 },
	[10327] = {	id = 10327, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10353, 10354,  } , spawndeny = 0 },
	[10328] = {	id = 10328, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10355, 10356,  } , spawndeny = 0 },
	[10329] = {	id = 10329, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10357, 10358,  } , spawndeny = 0 },
	[10330] = {	id = 10330, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10359, 10360,  } , spawndeny = 0 },
	[10331] = {	id = 10331, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10361, 10362,  } , spawndeny = 0 },
	[10332] = {	id = 10332, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10363, 10364,  } , spawndeny = 0 },
	[10333] = {	id = 10333, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10365, 10366,  } , spawndeny = 0 },
	[10334] = {	id = 10334, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10367, 10368,  } , spawndeny = 0 },
	[10335] = {	id = 10335, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10369, 10370,  } , spawndeny = 0 },
	[10336] = {	id = 10336, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10371, 10372,  } , spawndeny = 0 },
	[10337] = {	id = 10337, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10373, 10374,  } , spawndeny = 0 },
	[10338] = {	id = 10338, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10375, 10376,  } , spawndeny = 0 },
	[10339] = {	id = 10339, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10377, 10378,  } , spawndeny = 0 },
	[10340] = {	id = 10340, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10379, 10380,  } , spawndeny = 0 },
	[10341] = {	id = 10341, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10381, 10382,  } , spawndeny = 0 },
	[10342] = {	id = 10342, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10383, 10384,  } , spawndeny = 0 },
	[10343] = {	id = 10343, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10385, 10386,  } , spawndeny = 0 },
	[10344] = {	id = 10344, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10387, 10388,  } , spawndeny = 0 },
	[10345] = {	id = 10345, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10389, 10390,  } , spawndeny = 0 },
	[10346] = {	id = 10346, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10391, 10392,  } , spawndeny = 0 },
	[10347] = {	id = 10347, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10393, 10394,  } , spawndeny = 0 },
	[10348] = {	id = 10348, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 10395, 10396,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
