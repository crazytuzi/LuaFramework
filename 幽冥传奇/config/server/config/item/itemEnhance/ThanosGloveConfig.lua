
ThanosGloveEquipConfig =
{
	openSys = {
		openServerDay = 0,
		level = 300,
	},
	intervalTimes = 1800,
	makeCfg =
	{
		consume = {
		{type = 0, id = 306, count=50,},
		{type = 0, id = 307, count=50,},
		{type = 0, id = 308, count=20,},
		{type = 0, id = 309, count=10,},
		{type = 0, id = 310, count=5,},
		},
		quality = {
		{
			probability = 6000,
			probLv = 1,
			index = 7,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 299, count = 1,bind = 0,effectId = 1071,},
				},
			},
		},
		{
			probability = 2290,
			probLv = 1,
			index = 6,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 300, count = 1,bind = 0,effectId = 1072,},
				},
			},
		},
				{
			probability = 1000,
			probLv = 2,
			index = 5,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 301, count = 1,bind = 0,effectId = 1073,},
				},
			},
		},
				{
			probability = 500,
			probLv = 3,
			index = 4,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 302, count = 1,bind = 0,effectId = 1074,},
				},
			},
		},
				{
			probability = 150,
			probLv = 3,
			index = 3,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 303, count = 1,bind = 0,effectId = 1075,},
				},
			},
		},
				{
			probability = 50,
			probLv = 4,
			index = 2,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 304, count = 1,bind = 0,effectId = 1076,},
				},
			},
		},
				{
			probability = 10,
			probLv = 5,
			index = 1,
			itemlist = {
				{
					probability = 10000,
					item = {type = 0, id = 305, count = 1,bind = 0,effectId = 1077,},
				},
			},
		},
		},
	},
	IncreaseCfg =
	{
		maxEquipCount = 20,
		energy =
		{
			[299] = 1000,
			[300] = 2500,
			[301] = 6250,
			[302] = 15000,
			[303] = 40000,
			[304] = 100000,
			[305] = 250000,
		},
		lvCfg =
		{
{needEnergy = 350,attr = {{type=9,value=300,},{type=11,value=1000,},{type=21,value=177,},{type=23,value=588,},},},
{needEnergy = 400,attr = {{type=9,value=595,},{type=11,value=1980,},{type=21,value=350,},{type=23,value=1165,},},},
{needEnergy = 450,attr = {{type=9,value=889,},{type=11,value=2960,},{type=21,value=523,},{type=23,value=1741,},},},
{needEnergy = 500,attr = {{type=9,value=1183,},{type=11,value=3940,},{type=21,value=696,},{type=23,value=2318,},},},
{needEnergy = 550,attr = {{type=9,value=1477,},{type=11,value=4920,},{type=21,value=869,},{type=23,value=2894,},},},
{needEnergy = 600,attr = {{type=9,value=1772,},{type=11,value=5900,},{type=21,value=1042,},{type=23,value=3471,},},},
{needEnergy = 650,attr = {{type=9,value=2066,},{type=11,value=6880,},{type=21,value=1215,},{type=23,value=4047,},},},
{needEnergy = 700,attr = {{type=9,value=2360,},{type=11,value=7860,},{type=21,value=1389,},{type=23,value=4624,},},},
{needEnergy = 750,attr = {{type=9,value=2655,},{type=11,value=8840,},{type=21,value=1562,},{type=23,value=5200,},},},
{needEnergy = 800,attr = {{type=9,value=2949,},{type=11,value=9820,},{type=21,value=1735,},{type=23,value=5776,},},},
{needEnergy = 1000,attr = {{type=9,value=3343,},{type=11,value=11133,},{type=21,value=1967,},{type=23,value=6549,},},},
{needEnergy = 1200,attr = {{type=9,value=3738,},{type=11,value=12446,},{type=21,value=2198,},{type=23,value=7321,},},},
{needEnergy = 1400,attr = {{type=9,value=4132,},{type=11,value=13759,},{type=21,value=2431,},{type=23,value=8094,},},},
{needEnergy = 1600,attr = {{type=9,value=4526,},{type=11,value=15072,},{type=21,value=2662,},{type=23,value=8866,},},},
{needEnergy = 1800,attr = {{type=9,value=4920,},{type=11,value=16385,},{type=21,value=2894,},{type=23,value=9638,},},},
{needEnergy = 2000,attr = {{type=9,value=5315,},{type=11,value=17698,},{type=21,value=3126,},{type=23,value=10411,},},},
{needEnergy = 2200,attr = {{type=9,value=5709,},{type=11,value=19011,},{type=21,value=3358,},{type=23,value=11183,},},},
{needEnergy = 2400,attr = {{type=9,value=6103,},{type=11,value=20324,},{type=21,value=3590,},{type=23,value=11955,},},},
{needEnergy = 2700,attr = {{type=9,value=6498,},{type=11,value=21637,},{type=21,value=3822,},{type=23,value=12728,},},},
{needEnergy = 3000,attr = {{type=9,value=6892,},{type=11,value=22950,},{type=21,value=4054,},{type=23,value=13500,},},},
{needEnergy = 3500,attr = {{type=9,value=7386,},{type=11,value=24596,},{type=21,value=4345,},{type=23,value=14468,},},},
{needEnergy = 4000,attr = {{type=9,value=7880,},{type=11,value=26242,},{type=21,value=4635,},{type=23,value=15436,},},},
{needEnergy = 4500,attr = {{type=9,value=8375,},{type=11,value=27888,},{type=21,value=4926,},{type=23,value=16405,},},},
{needEnergy = 5000,attr = {{type=9,value=8869,},{type=11,value=29534,},{type=21,value=5217,},{type=23,value=17373,},},},
{needEnergy = 5500,attr = {{type=9,value=9363,},{type=11,value=31180,},{type=21,value=5508,},{type=23,value=18341,},},},
{needEnergy = 6000,attr = {{type=9,value=9858,},{type=11,value=32826,},{type=21,value=5798,},{type=23,value=19309,},},},
{needEnergy = 6500,attr = {{type=9,value=10352,},{type=11,value=34472,},{type=21,value=6089,},{type=23,value=20278,},},},
{needEnergy = 7000,attr = {{type=9,value=10846,},{type=11,value=36118,},{type=21,value=6380,},{type=23,value=21246,},},},
{needEnergy = 7500,attr = {{type=9,value=11341,},{type=11,value=37764,},{type=21,value=6671,},{type=23,value=22214,},},},
{needEnergy = 8000,attr = {{type=9,value=11835,},{type=11,value=39410,},{type=21,value=6962,},{type=23,value=23182,},},},
{needEnergy = 9000,attr = {{type=9,value=12429,},{type=11,value=41389,},{type=21,value=7311,},{type=23,value=24346,},},},
{needEnergy = 10000,attr = {{type=9,value=13023,},{type=11,value=43368,},{type=21,value=7661,},{type=23,value=25511,},},},
{needEnergy = 11000,attr = {{type=9,value=13618,},{type=11,value=45347,},{type=21,value=8011,},{type=23,value=26675,},},},
{needEnergy = 12000,attr = {{type=9,value=14212,},{type=11,value=47326,},{type=21,value=8360,},{type=23,value=27839,},},},
{needEnergy = 13000,attr = {{type=9,value=14806,},{type=11,value=49305,},{type=21,value=8710,},{type=23,value=29003,},},},
{needEnergy = 14000,attr = {{type=9,value=15401,},{type=11,value=51284,},{type=21,value=9059,},{type=23,value=30167,},},},
{needEnergy = 15000,attr = {{type=9,value=15995,},{type=11,value=53263,},{type=21,value=9409,},{type=23,value=31331,},},},
{needEnergy = 16000,attr = {{type=9,value=16589,},{type=11,value=55242,},{type=21,value=9758,},{type=23,value=32495,},},},
{needEnergy = 18000,attr = {{type=9,value=17183,},{type=11,value=57221,},{type=21,value=10108,},{type=23,value=33659,},},},
{needEnergy = 20000,attr = {{type=9,value=17778,},{type=11,value=59200,},{type=21,value=10458,},{type=23,value=34824,},},},
{needEnergy = 25000,attr = {{type=9,value=18472,},{type=11,value=61512,},{type=21,value=10866,},{type=23,value=36184,},},},
{needEnergy = 30000,attr = {{type=9,value=19166,},{type=11,value=63824,},{type=21,value=11274,},{type=23,value=37544,},},},
{needEnergy = 35000,attr = {{type=9,value=19861,},{type=11,value=66136,},{type=21,value=11683,},{type=23,value=38904,},},},
{needEnergy = 40000,attr = {{type=9,value=20555,},{type=11,value=68448,},{type=21,value=12091,},{type=23,value=40264,},},},
{needEnergy = 45000,attr = {{type=9,value=21249,},{type=11,value=70760,},{type=21,value=12500,},{type=23,value=41624,},},},
{needEnergy = 50000,attr = {{type=9,value=21944,},{type=11,value=73072,},{type=21,value=12908,},{type=23,value=42984,},},},
{needEnergy = 55000,attr = {{type=9,value=22638,},{type=11,value=75384,},{type=21,value=13317,},{type=23,value=44344,},},},
{needEnergy = 60000,attr = {{type=9,value=23332,},{type=11,value=77696,},{type=21,value=13725,},{type=23,value=45704,},},},
{needEnergy = 65000,attr = {{type=9,value=24026,},{type=11,value=80008,},{type=21,value=14133,},{type=23,value=47064,},},},
{needEnergy = 70000,attr = {{type=9,value=24721,},{type=11,value=82320,},{type=21,value=14542,},{type=23,value=48424,},},},
{needEnergy = 80000,attr = {{type=9,value=25515,},{type=11,value=84965,},{type=21,value=15009,},{type=23,value=49979,},},},
{needEnergy = 90000,attr = {{type=9,value=26309,},{type=11,value=87610,},{type=21,value=15476,},{type=23,value=51535,},},},
{needEnergy = 100000,attr = {{type=9,value=27104,},{type=11,value=90255,},{type=21,value=15943,},{type=23,value=53091,},},},
{needEnergy = 110000,attr = {{type=9,value=27898,},{type=11,value=92900,},{type=21,value=16411,},{type=23,value=54647,},},},
{needEnergy = 120000,attr = {{type=9,value=28692,},{type=11,value=95545,},{type=21,value=16878,},{type=23,value=56203,},},},
{needEnergy = 130000,attr = {{type=9,value=29486,},{type=11,value=98190,},{type=21,value=17345,},{type=23,value=57759,},},},
{needEnergy = 140000,attr = {{type=9,value=30281,},{type=11,value=100835,},{type=21,value=17812,},{type=23,value=59315,},},},
{needEnergy = 160000,attr = {{type=9,value=31075,},{type=11,value=103480,},{type=21,value=18280,},{type=23,value=60871,},},},
{needEnergy = 180000,attr = {{type=9,value=31869,},{type=11,value=106125,},{type=21,value=18747,},{type=23,value=62426,},},},
{needEnergy = 200000,attr = {{type=9,value=32664,},{type=11,value=108770,},{type=21,value=19214,},{type=23,value=63982,},},},
		},
	},
}