----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1010121] = {
		[1] = {events = {{triTime = 500, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010122] = {
		[1] = {events = {{triTime = 550, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010123] = {
		[1] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3859, arg2 = 27.0, }, status = {{odds = 10000, buffID = 40051, }, }, }, },spArgs1 = '192.95', spArgs2 = '135', spArgs3 = '132', },
		[2] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3946, arg2 = 33.0, }, status = {{odds = 10000, buffID = 40052, }, }, }, },spArgs1 = '197.3', spArgs2 = '165', spArgs3 = '173', },
		[3] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4032, arg2 = 39.0, }, status = {{odds = 10000, buffID = 40053, }, }, }, },spArgs1 = '201.6', spArgs2 = '195', spArgs3 = '215', },
		[4] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4118, arg2 = 45.0, }, status = {{odds = 10000, buffID = 40054, }, }, }, },spArgs1 = '205.9', spArgs2 = '225', spArgs3 = '257', },
		[5] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4205, arg2 = 52.0, }, status = {{odds = 10000, buffID = 40055, }, }, }, },spArgs1 = '210.25', spArgs2 = '260', spArgs3 = '299', },
		[6] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4291, arg2 = 59.0, }, status = {{odds = 10000, buffID = 40056, }, }, }, },spArgs1 = '214.55', spArgs2 = '295', spArgs3 = '341', },
		[7] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4378, arg2 = 66.0, }, status = {{odds = 10000, buffID = 40057, }, }, }, },spArgs1 = '218.9', spArgs2 = '330', spArgs3 = '383', },
		[8] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4464, arg2 = 74.0, }, status = {{odds = 10000, buffID = 40058, }, }, }, },spArgs1 = '223.2', spArgs2 = '370', spArgs3 = '425', },
		[9] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.455, arg2 = 82.0, }, status = {{odds = 10000, buffID = 40059, }, }, }, },spArgs1 = '227.5', spArgs2 = '410', spArgs3 = '467', },
		[10] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4637, arg2 = 90.0, }, status = {{odds = 10000, buffID = 40060, }, }, }, },spArgs1 = '231.85', spArgs2 = '450', spArgs3 = '509', },
		[11] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4723, arg2 = 98.0, }, status = {{odds = 10000, buffID = 40061, }, }, }, },spArgs1 = '236.15', spArgs2 = '490', spArgs3 = '551', },
		[12] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.481, arg2 = 107.0, }, status = {{odds = 10000, buffID = 40062, }, }, }, },spArgs1 = '240.5', spArgs2 = '535', spArgs3 = '593', },
		[13] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4896, arg2 = 116.0, }, status = {{odds = 10000, buffID = 40063, }, }, }, },spArgs1 = '244.8', spArgs2 = '580', spArgs3 = '635', },
		[14] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4982, arg2 = 125.0, }, status = {{odds = 10000, buffID = 40064, }, }, }, },spArgs1 = '249.1', spArgs2 = '625', spArgs3 = '677', },
		[15] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5069, arg2 = 135.0, }, status = {{odds = 10000, buffID = 40065, }, }, }, },spArgs1 = '253.45', spArgs2 = '675', spArgs3 = '719', },
		[16] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5155, arg2 = 145.0, }, status = {{odds = 10000, buffID = 40066, }, }, }, },spArgs1 = '257.75', spArgs2 = '725', spArgs3 = '761', },
		[17] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5242, arg2 = 155.0, }, status = {{odds = 10000, buffID = 40067, }, }, }, },spArgs1 = '262.1', spArgs2 = '775', spArgs3 = '803', },
		[18] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5357, arg2 = 169.0, }, status = {{odds = 10000, buffID = 40068, }, }, }, },spArgs1 = '267.85', spArgs2 = '845', spArgs3 = '845', },
		[19] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5472, arg2 = 183.0, }, status = {{odds = 10000, buffID = 40069, }, }, }, },spArgs1 = '273.6', spArgs2 = '915', spArgs3 = '887', },
		[20] = {addSP = 114, cool = 5000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5587, arg2 = 198.0, }, status = {{odds = 10000, buffID = 40070, }, }, }, },spArgs1 = '279.35', spArgs2 = '990', spArgs3 = '967', },
	},
	[1010124] = {
		[1] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7504, arg2 = 52.0, }, status = {{odds = 10000, buffID = 40101, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7504, arg2 = 52.0, }, status = {{odds = 10000, buffID = 40101, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7504, arg2 = 52.0, }, status = {{odds = 10000, buffID = 40101, }, }, }, },spArgs1 = '225.12', spArgs2 = '156', spArgs3 = '734', },
		[2] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7672, arg2 = 64.0, }, status = {{odds = 10000, buffID = 40102, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7672, arg2 = 64.0, }, status = {{odds = 10000, buffID = 40102, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7672, arg2 = 64.0, }, status = {{odds = 10000, buffID = 40102, }, }, }, },spArgs1 = '230.16', spArgs2 = '192', spArgs3 = '927', },
		[3] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.784, arg2 = 76.0, }, status = {{odds = 10000, buffID = 40103, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.784, arg2 = 76.0, }, status = {{odds = 10000, buffID = 40103, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.784, arg2 = 76.0, }, status = {{odds = 10000, buffID = 40103, }, }, }, },spArgs1 = '235.2', spArgs2 = '228', spArgs3 = '1149', },
		[4] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8008, arg2 = 88.0, }, status = {{odds = 10000, buffID = 40104, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8008, arg2 = 88.0, }, status = {{odds = 10000, buffID = 40104, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8008, arg2 = 88.0, }, status = {{odds = 10000, buffID = 40104, }, }, }, },spArgs1 = '240.24', spArgs2 = '264', spArgs3 = '1399', },
		[5] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8176, arg2 = 101.0, }, status = {{odds = 10000, buffID = 40105, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8176, arg2 = 101.0, }, status = {{odds = 10000, buffID = 40105, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8176, arg2 = 101.0, }, status = {{odds = 10000, buffID = 40105, }, }, }, },spArgs1 = '245.28', spArgs2 = '303', spArgs3 = '1678', },
		[6] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8344, arg2 = 115.0, }, status = {{odds = 10000, buffID = 40106, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8344, arg2 = 115.0, }, status = {{odds = 10000, buffID = 40106, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8344, arg2 = 115.0, }, status = {{odds = 10000, buffID = 40106, }, }, }, },spArgs1 = '250.32', spArgs2 = '345', spArgs3 = '1985', },
		[7] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8512, arg2 = 129.0, }, status = {{odds = 10000, buffID = 40107, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8512, arg2 = 129.0, }, status = {{odds = 10000, buffID = 40107, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8512, arg2 = 129.0, }, status = {{odds = 10000, buffID = 40107, }, }, }, },spArgs1 = '255.36', spArgs2 = '387', spArgs3 = '2321', },
		[8] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.868, arg2 = 144.0, }, status = {{odds = 10000, buffID = 40108, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.868, arg2 = 144.0, }, status = {{odds = 10000, buffID = 40108, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.868, arg2 = 144.0, }, status = {{odds = 10000, buffID = 40108, }, }, }, },spArgs1 = '260.4', spArgs2 = '432', spArgs3 = '2685', },
		[9] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8848, arg2 = 159.0, }, status = {{odds = 10000, buffID = 40109, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8848, arg2 = 159.0, }, status = {{odds = 10000, buffID = 40109, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8848, arg2 = 159.0, }, status = {{odds = 10000, buffID = 40109, }, }, }, },spArgs1 = '265.44', spArgs2 = '477', spArgs3 = '3078', },
		[10] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9016, arg2 = 175.0, }, status = {{odds = 10000, buffID = 40110, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9016, arg2 = 175.0, }, status = {{odds = 10000, buffID = 40110, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9016, arg2 = 175.0, }, status = {{odds = 10000, buffID = 40110, }, }, }, },spArgs1 = '270.48', spArgs2 = '525', spArgs3 = '3499', },
		[11] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9184, arg2 = 191.0, }, status = {{odds = 10000, buffID = 40111, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9184, arg2 = 191.0, }, status = {{odds = 10000, buffID = 40111, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9184, arg2 = 191.0, }, status = {{odds = 10000, buffID = 40111, }, }, }, },spArgs1 = '275.52', spArgs2 = '573', spArgs3 = '3948', },
		[12] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9352, arg2 = 208.0, }, status = {{odds = 10000, buffID = 40112, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9352, arg2 = 208.0, }, status = {{odds = 10000, buffID = 40112, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9352, arg2 = 208.0, }, status = {{odds = 10000, buffID = 40112, }, }, }, },spArgs1 = '280.56', spArgs2 = '624', spArgs3 = '4426', },
		[13] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.952, arg2 = 225.0, }, status = {{odds = 10000, buffID = 40113, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.952, arg2 = 225.0, }, status = {{odds = 10000, buffID = 40113, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.952, arg2 = 225.0, }, status = {{odds = 10000, buffID = 40113, }, }, }, },spArgs1 = '285.6', spArgs2 = '675', spArgs3 = '4933', },
		[14] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9688, arg2 = 243.0, }, status = {{odds = 10000, buffID = 40114, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9688, arg2 = 243.0, }, status = {{odds = 10000, buffID = 40114, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9688, arg2 = 243.0, }, status = {{odds = 10000, buffID = 40114, }, }, }, },spArgs1 = '290.64', spArgs2 = '729', spArgs3 = '5468', },
		[15] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9856, arg2 = 262.0, }, status = {{odds = 10000, buffID = 40115, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9856, arg2 = 262.0, }, status = {{odds = 10000, buffID = 40115, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9856, arg2 = 262.0, }, status = {{odds = 10000, buffID = 40115, }, }, }, },spArgs1 = '295.68', spArgs2 = '786', spArgs3 = '6031', },
		[16] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0024, arg2 = 281.0, }, status = {{odds = 10000, buffID = 40116, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0024, arg2 = 281.0, }, status = {{odds = 10000, buffID = 40116, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0024, arg2 = 281.0, }, status = {{odds = 10000, buffID = 40116, }, }, }, },spArgs1 = '300.72', spArgs2 = '843', spArgs3 = '6623', },
		[17] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0192, arg2 = 301.0, }, status = {{odds = 10000, buffID = 40117, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0192, arg2 = 301.0, }, status = {{odds = 10000, buffID = 40117, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0192, arg2 = 301.0, }, status = {{odds = 10000, buffID = 40117, }, }, }, },spArgs1 = '305.76', spArgs2 = '903', spArgs3 = '7244', },
		[18] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0416, arg2 = 328.0, }, status = {{odds = 10000, buffID = 40118, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0416, arg2 = 328.0, }, status = {{odds = 10000, buffID = 40118, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0416, arg2 = 328.0, }, status = {{odds = 10000, buffID = 40118, }, }, }, },spArgs1 = '312.48', spArgs2 = '984', spArgs3 = '8115', },
		[19] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.064, arg2 = 356.0, }, status = {{odds = 10000, buffID = 40119, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.064, arg2 = 356.0, }, status = {{odds = 10000, buffID = 40119, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.064, arg2 = 356.0, }, status = {{odds = 10000, buffID = 40119, }, }, }, },spArgs1 = '319.2', spArgs2 = '1068', spArgs3 = '9037', },
		[20] = {addSP = 114, cool = 6000, events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0864, arg2 = 385.0, }, status = {{odds = 10000, buffID = 40120, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0864, arg2 = 385.0, }, status = {{odds = 10000, buffID = 40120, }, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0864, arg2 = 385.0, }, status = {{odds = 10000, buffID = 40120, }, }, }, },spArgs1 = '325.92', spArgs2 = '1155', spArgs3 = '10010', },
	},
	[1010125] = {
		[1] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4181, arg2 = 29.0, }, status = {{odds = 10000, buffID = 40051, }, }, }, },spArgs1 = '209.05', spArgs2 = '145', spArgs3 = '132', },
		[2] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4274, arg2 = 36.0, }, status = {{odds = 10000, buffID = 40052, }, }, }, },spArgs1 = '213.7', spArgs2 = '180', spArgs3 = '173', },
		[3] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4368, arg2 = 42.0, }, status = {{odds = 10000, buffID = 40053, }, }, }, },spArgs1 = '218.4', spArgs2 = '210', spArgs3 = '215', },
		[4] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4462, arg2 = 49.0, }, status = {{odds = 10000, buffID = 40054, }, }, }, },spArgs1 = '223.1', spArgs2 = '245', spArgs3 = '257', },
		[5] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4555, arg2 = 56.0, }, status = {{odds = 10000, buffID = 40055, }, }, }, },spArgs1 = '227.75', spArgs2 = '280', spArgs3 = '299', },
		[6] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4649, arg2 = 64.0, }, status = {{odds = 10000, buffID = 40056, }, }, }, },spArgs1 = '232.45', spArgs2 = '320', spArgs3 = '341', },
		[7] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4742, arg2 = 72.0, }, status = {{odds = 10000, buffID = 40057, }, }, }, },spArgs1 = '237.1', spArgs2 = '360', spArgs3 = '383', },
		[8] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4836, arg2 = 80.0, }, status = {{odds = 10000, buffID = 40058, }, }, }, },spArgs1 = '241.8', spArgs2 = '400', spArgs3 = '425', },
		[9] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.493, arg2 = 88.0, }, status = {{odds = 10000, buffID = 40059, }, }, }, },spArgs1 = '246.5', spArgs2 = '440', spArgs3 = '467', },
		[10] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5023, arg2 = 97.0, }, status = {{odds = 10000, buffID = 40060, }, }, }, },spArgs1 = '251.15', spArgs2 = '485', spArgs3 = '509', },
		[11] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5117, arg2 = 106.0, }, status = {{odds = 10000, buffID = 40061, }, }, }, },spArgs1 = '255.85', spArgs2 = '530', spArgs3 = '551', },
		[12] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.521, arg2 = 116.0, }, status = {{odds = 10000, buffID = 40062, }, }, }, },spArgs1 = '260.5', spArgs2 = '580', spArgs3 = '593', },
		[13] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5304, arg2 = 126.0, }, status = {{odds = 10000, buffID = 40063, }, }, }, },spArgs1 = '265.2', spArgs2 = '630', spArgs3 = '635', },
		[14] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5398, arg2 = 136.0, }, status = {{odds = 10000, buffID = 40064, }, }, }, },spArgs1 = '269.9', spArgs2 = '680', spArgs3 = '677', },
		[15] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5491, arg2 = 146.0, }, status = {{odds = 10000, buffID = 40065, }, }, }, },spArgs1 = '274.55', spArgs2 = '730', spArgs3 = '719', },
		[16] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5585, arg2 = 157.0, }, status = {{odds = 10000, buffID = 40066, }, }, }, },spArgs1 = '279.25', spArgs2 = '785', spArgs3 = '761', },
		[17] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5678, arg2 = 168.0, }, status = {{odds = 10000, buffID = 40067, }, }, }, },spArgs1 = '283.9', spArgs2 = '840', spArgs3 = '803', },
		[18] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5803, arg2 = 183.0, }, status = {{odds = 10000, buffID = 40068, }, }, }, },spArgs1 = '290.15', spArgs2 = '915', spArgs3 = '845', },
		[19] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5928, arg2 = 198.0, }, status = {{odds = 10000, buffID = 40069, }, }, }, },spArgs1 = '296.4', spArgs2 = '990', spArgs3 = '887', },
		[20] = {addSP = 114, cool = 7000, events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.6053, arg2 = 215.0, }, status = {{odds = 10000, buffID = 40070, }, }, }, },spArgs1 = '302.65', spArgs2 = '1075', spArgs3 = '967', },
	},
	[1010126] = {
		[1] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.6331, arg2 = 184.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40201, }, }, }, },spArgs1 = '263.31', spArgs2 = '184', spArgs3 = '2447', },
		[2] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.6921, arg2 = 224.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40202, }, }, }, },spArgs1 = '269.21', spArgs2 = '224', spArgs3 = '3091', },
		[3] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.751, arg2 = 265.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40203, }, }, }, },spArgs1 = '275.1', spArgs2 = '265', spArgs3 = '3830', },
		[4] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.81, arg2 = 309.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40204, }, }, }, },spArgs1 = '281', spArgs2 = '309', spArgs3 = '4664', },
		[5] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.8689, arg2 = 355.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40205, }, }, }, },spArgs1 = '286.89', spArgs2 = '355', spArgs3 = '5593', },
		[6] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.9279, arg2 = 403.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40206, }, }, }, },spArgs1 = '292.79', spArgs2 = '403', spArgs3 = '6617', },
		[7] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.9868, arg2 = 452.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40207, }, }, }, },spArgs1 = '298.68', spArgs2 = '452', spArgs3 = '7736', },
		[8] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0458, arg2 = 504.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40208, }, }, }, },spArgs1 = '304.58', spArgs2 = '504', spArgs3 = '8950', },
		[9] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.1047, arg2 = 557.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40209, }, }, }, },spArgs1 = '310.47', spArgs2 = '557', spArgs3 = '10258', },
		[10] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.1637, arg2 = 613.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40210, }, }, }, },spArgs1 = '316.37', spArgs2 = '613', spArgs3 = '11662', },
		[11] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.2226, arg2 = 670.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40211, }, }, }, },spArgs1 = '322.26', spArgs2 = '670', spArgs3 = '13161', },
		[12] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.2816, arg2 = 729.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40212, }, }, }, },spArgs1 = '328.16', spArgs2 = '729', spArgs3 = '14754', },
		[13] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.3405, arg2 = 791.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40213, }, }, }, },spArgs1 = '334.05', spArgs2 = '791', spArgs3 = '16442', },
		[14] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.3995, arg2 = 854.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40214, }, }, }, },spArgs1 = '339.95', spArgs2 = '854', spArgs3 = '18226', },
		[15] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.4584, arg2 = 919.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40215, }, }, }, },spArgs1 = '345.84', spArgs2 = '919', spArgs3 = '20104', },
		[16] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.5174, arg2 = 986.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40216, }, }, }, },spArgs1 = '351.74', spArgs2 = '986', spArgs3 = '22077', },
		[17] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.5763, arg2 = 1055.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40217, }, }, }, },spArgs1 = '357.63', spArgs2 = '1055', spArgs3 = '24145', },
		[18] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.6549, arg2 = 1150.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40218, }, }, }, },spArgs1 = '365.49', spArgs2 = '1150', spArgs3 = '27050', },
		[19] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.7335, arg2 = 1249.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40219, }, }, }, },spArgs1 = '373.35', spArgs2 = '1249', spArgs3 = '30124', },
		[20] = {cool = 20000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.8121, arg2 = 1351.0, }, status = {{odds = 10000, buffID = 429, }, {odds = 10000, buffID = 40220, }, }, }, },spArgs1 = '381.21', spArgs2 = '1351', spArgs3 = '33367', },
	},
	[1010131] = {
		[1] = {events = {{triTime = 325, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, }, }, },},
	},
	[1010132] = {
		[1] = {events = {{triTime = 300, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, }, }, },},
	},
	[1010133] = {
		[1] = {events = {{triTime = 625, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 180.0, }, }, },},
	},
	[1010134] = {
		[1] = {events = {{triTime = 875, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 180.0, }, }, },},
	},
	[1010135] = {
		[1] = {events = {{triTime = 625, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 260.0, }, }, },},
	},
	[1010136] = {
		[1] = {events = {{triTime = 875, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 260.0, }, }, },},
	},
	[1010137] = {
		[1] = {events = {{triTime = 650, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 340.0, }, }, },},
	},
	[1010138] = {
		[1] = {events = {{triTime = 550, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 340.0, }, }, },},
	},
	[1010139] = {
		[1] = {events = {{triTime = 650, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 420.0, }, }, },},
	},
	[1010140] = {
		[1] = {events = {{triTime = 550, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 420.0, }, }, },},
	},
	[1010141] = {
		[1] = {events = {{triTime = 675, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 500.0, }, }, },},
	},
	[1010142] = {
		[1] = {events = {{triTime = 675, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 500.0, }, }, },},
	},
	[1010143] = {
		[1] = {events = {{triTime = 325, hitEffID = 30925, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010144] = {
		[1] = {events = {{triTime = 400, hitEffID = 30925, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010145] = {
		[1] = {events = {{triTime = 325, hitEffID = 30925, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 663, }, }, }, },},
	},
	[1010146] = {
		[1] = {events = {{triTime = 400, hitEffID = 30927, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010147] = {
		[1] = {events = {{triTime = 425, hitEffID = 30927, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010148] = {
		[1] = {events = {{triTime = 400, hitEffID = 30926, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 663, }, {odds = 10000, buffID = 662, }, }, }, },},
	},
	[1010149] = {
		[1] = {events = {{triTime = 425, hitEffID = 30927, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010150] = {
		[1] = {events = {{triTime = 400, hitEffID = 30927, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1010151] = {
		[1] = {events = {{triTime = 425, hitEffID = 30926, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 663, }, {odds = 10000, buffID = 662, }, }, }, },},
	},
	[1010152] = {
		[1] = {events = {{triTime = 675, hitEffID = 30051, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 500.0, }, status = {{odds = 10000, buffID = 666, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
