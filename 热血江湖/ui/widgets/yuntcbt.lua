--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6289063,
			sizeY = 0.7458333,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "a",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun1",
					posX = 0.7878109,
					posY = 0.8965713,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.068558,
					sizeY = 1.899658,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun3",
					posX = 0.1474587,
					posY = 0.6539165,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7050953,
					sizeY = 1.253502,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun6",
					posX = 0.426686,
					posY = 0.8258619,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.728501,
					sizeY = 1.295112,
					image = "uieffect/yun2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun2",
					posX = 0.8447486,
					posY = 0.3904612,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7050953,
					sizeY = 1.253502,
					image = "uieffect/yun2.png",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "b",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun4",
					posX = 0.1536998,
					posY = 0.09511296,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9149045,
					sizeY = 1.626496,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun5",
					posX = 0.4750454,
					posY = 0.4875198,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.068558,
					sizeY = 1.899658,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun8",
					posX = 0.0538647,
					posY = 0.9159855,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9149045,
					sizeY = 1.626496,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun12",
					posX = 0.8564509,
					posY = 0.09095231,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9149045,
					sizeY = 1.626496,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "c",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun7",
					posX = 0.1529193,
					posY = 0.377982,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7050953,
					sizeY = 1.253502,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun11",
					posX = 0.8252513,
					posY = 0.6885806,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7050953,
					sizeY = 1.253502,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun14",
					posX = 0.6536584,
					posY = 0.2226809,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3906824,
					sizeY = 0.6945461,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun15",
					posX = 0.3814474,
					posY = 0.7218582,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3088698,
					sizeY = 0.5491015,
					image = "uieffect/yun2.png",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "d",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun9",
					posX = 0.02500208,
					posY = 0.4805888,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6504845,
					sizeY = 1.156417,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun10",
					posX = 0.1591561,
					posY = 0.3100345,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4757735,
					sizeY = 0.845819,
					image = "uieffect/yun2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun13",
					posX = 0.5226235,
					posY = 0.05351454,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7050953,
					sizeY = 1.253502,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun16",
					posX = 0.6606752,
					posY = 0.712149,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4648591,
					sizeY = 0.826416,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "e",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun17",
					posX = 0.7947284,
					posY = 0.6015135,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5461748,
					sizeY = 0.8630515,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun18",
					posX = 0.06997969,
					posY = 0.7606838,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7742417,
					sizeY = 1.37643,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun19",
					posX = 0.4895217,
					posY = 0.3996273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7068815,
					sizeY = 1.115775,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun20",
					posX = 0.7436271,
					posY = 0.2840449,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7134445,
					sizeY = 1.524559,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "f",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun21",
					posX = 0.8853078,
					posY = 0.8660671,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.623981,
					sizeY = 1.109299,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun22",
					posX = 0.4961026,
					posY = 0.7149224,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8470373,
					sizeY = 1.505844,
					image = "uieffect/yun1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun23",
					posX = 0.4259083,
					posY = 0.192176,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.784639,
					sizeY = 1.394914,
					image = "uieffect/yun4.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun24",
					posX = 0.1973739,
					posY = 0.5443699,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4757735,
					sizeY = 0.845819,
					image = "uieffect/yun2.png",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "g",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "yun25",
					posX = 0.1505752,
					posY = 0.02578831,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4,
					sizeY = 0.7111111,
					image = "uieffect/yun2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun26",
					posX = 0.6809573,
					posY = 0.02716872,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.735214,
					sizeY = 1.307047,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun27",
					posX = 0.3011136,
					posY = 0.9173749,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3906824,
					sizeY = 0.6945461,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun28",
					posX = 0.9687662,
					posY = 0.2864667,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4383481,
					sizeY = 0.7792856,
					image = "uieffect/yun3.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yun29",
					posX = 0.9668621,
					posY = 0.6464418,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4,
					sizeY = 0.7111111,
					image = "uieffect/yun4.png",
					alpha = 0,
					rotation = 3,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fdj",
				posX = 0.5764347,
				posY = 0.4972245,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1169948,
				sizeY = 0.2079906,
				image = "uieffect/fdj.png",
				alpha = 0,
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	yun1 = {
		yun1 = {
			moveP = {{0, {1.5625, 0.8965713, 0}}, {500, {0.7878109, 0.8965713, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun3 = {
			moveP = {{0, {-0.546875, 0.6539165, 0}}, {500, {0.1474587, 0.6539165, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun6 = {
			moveP = {{0, {-0.78125, 0.8258618, 0}}, {500, {0.426686, 0.8258618, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun2 = {
			moveP = {{0, {1.5625, 0.3904613, 0}}, {500, {0.8447484, 0.3904613, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun4 = {
		yun4 = {
			moveP = {{0, {-0.390625, 0.09511296, 0}}, {500, {0.1536998, 0.09511296, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun5 = {
			moveP = {{0, {1.5625, 0.4875199, 0}}, {500, {0.4750454, 0.4875199, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun8 = {
			moveP = {{0, {-0.390625, 0.9159855, 0}}, {500, {0.05386471, 0.9159855, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun12 = {
			moveP = {{0, {1.5625, 0.0909523, 0}}, {500, {0.8564507, 0.0909523, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun7 = {
		yun7 = {
			moveP = {{0, {-0.390625, 0.377982, 0}}, {450, {0.1529193, 0.377982, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun11 = {
			moveP = {{0, {1.5625, 0.6885806, 0}}, {450, {0.8252516, 0.6885806, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun14 = {
			moveP = {{0, {1.171875, 0.2226808, 0}}, {450, {0.6536583, 0.2226808, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun15 = {
			moveP = {{0, {-0.390625, 0.7218582, 0}}, {450, {0.3814474, 0.7218582, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun10 = {
		yun9 = {
			moveP = {{0, {-0.390625, 0.4805887, 0}}, {450, {0.02500208, 0.4805887, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun10 = {
			moveP = {{0, {-0.3125, 0.3100346, 0}}, {450, {0.1591561, 0.3100346, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun13 = {
			moveP = {{0, {1.5625, 0.05351454, 0}}, {450, {0.5226235, 0.05351454, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun16 = {
			moveP = {{0, {1.328125, 0.712149, 0}}, {450, {0.6606752, 0.712149, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun2 = {
		yun1 = {
			moveP = {{0, {0.7878109, 0.8965713, 0}}, {500, {1.5625, 0.8965713, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun3 = {
			moveP = {{0, {0.1474587, 0.6539165, 0}}, {500, {-0.546875, 0.6539165, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun6 = {
			moveP = {{0, {0.426686, 0.8258618, 0}}, {500, {-0.78125, 0.8258618, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun2 = {
			moveP = {{0, {0.8447484, 0.3904613, 0}}, {500, {1.5625, 0.3904613, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun5 = {
		yun4 = {
			moveP = {{0, {0.1536998, 0.09511296, 0}}, {500, {-0.390625, 0.09511296, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun5 = {
			moveP = {{0, {0.4750454, 0.4875199, 0}}, {500, {1.5625, 0.4875199, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun8 = {
			moveP = {{0, {0.05386471, 0.9159855, 0}}, {500, {-0.390625, 0.9159855, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun12 = {
			moveP = {{0, {0.8564507, 0.0909523, 0}}, {500, {1.5625, 0.0909523, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun8 = {
		yun7 = {
			moveP = {{0, {0.1529193, 0.377982, 0}}, {450, {-0.390625, 0.377982, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun11 = {
			moveP = {{0, {0.8252516, 0.6885806, 0}}, {450, {1.5625, 0.6885806, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun14 = {
			moveP = {{0, {0.6536583, 0.2226808, 0}}, {450, {1.171875, 0.2226808, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun15 = {
			moveP = {{0, {0.3814474, 0.7218582, 0}}, {450, {-0.390625, 0.7218582, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun11 = {
		yun9 = {
			moveP = {{0, {0.02500208, 0.4805887, 0}}, {450, {-0.390625, 0.4805887, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun10 = {
			moveP = {{0, {0.1591561, 0.3100346, 0}}, {450, {-0.3125, 0.3100346, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun13 = {
			moveP = {{0, {0.5226235, 0.05351454, 0}}, {450, {1.5625, 0.05351454, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun16 = {
			moveP = {{0, {0.6606752, 0.712149, 0}}, {450, {1.328125, 0.712149, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	fdj = {
		fdj = {
			alpha = {{0, {1}}, },
			circle = {{0, {737.8364,358.0016,0}}, {2000, {650, 358.0016, 0}}, },
		},
	},
	yun13 = {
		yun17 = {
			moveP = {{0, {1.40625, 0.6015134, 0}}, {500, {0.7947282, 0.6015134, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun18 = {
			moveP = {{0, {-0.3125, 0.7606838, 0}}, {500, {0.0699797, 0.7606838, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun19 = {
			moveP = {{0, {-0.46875, 0.3996274, 0}}, {500, {0.4895217, 0.3996274, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun20 = {
			moveP = {{0, {1.5625, 0.2840449, 0}}, {500, {0.7436271, 0.2840449, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun14 = {
		yun17 = {
			moveP = {{0, {0.7947282, 0.6015134, 0}}, {500, {1.40625, 0.6015134, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun18 = {
			moveP = {{0, {0.0699797, 0.7606838, 0}}, {500, {-0.3125, 0.7606838, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun19 = {
			moveP = {{0, {0.4895217, 0.3996274, 0}}, {500, {-0.46875, 0.3996274, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun20 = {
			moveP = {{0, {0.7436271, 0.2840449, 0}}, {500, {1.5625, 0.2840449, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun16 = {
		yun21 = {
			moveP = {{0, {1.5625, 0.8660671, 0}}, {450, {0.8853078, 0.8660671, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun22 = {
			moveP = {{0, {1.5625, 0.7149223, 0}}, {450, {0.4961027, 0.7149223, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun23 = {
			moveP = {{0, {-0.46875, 0.192176, 0}}, {450, {0.4259083, 0.192176, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun24 = {
			moveP = {{0, {-0.390625, 0.5443698, 0}}, {450, {0.1973739, 0.5443698, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun17 = {
		yun21 = {
			moveP = {{0, {0.8853078, 0.8660671, 0}}, {450, {1.5625, 0.8660671, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun22 = {
			moveP = {{0, {0.4961027, 0.7149223, 0}}, {450, {1.5625, 0.7149223, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun23 = {
			moveP = {{0, {0.4259083, 0.192176, 0}}, {450, {-0.46875, 0.192176, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun24 = {
			moveP = {{0, {0.1973739, 0.5443698, 0}}, {450, {-0.390625, 0.5443698, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun19 = {
		yun25 = {
			moveP = {{0, {-0.390625, 0.02578831, 0}}, {450, {0.1505752, 0.02578831, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun26 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {1.40625, 0.02716872, 0}}, {450, {0.6809574, 0.02716872, 0}}, },
		},
		yun27 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {-0.4296875, 0.9173748, 0}}, {450, {0.3011136, 0.9173748, 0}}, },
		},
		yun28 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {1.328125, 0.2864667, 0}}, {450, {0.9687664, 0.2864667, 0}}, },
		},
		yun29 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {1.171875, 0.6464418, 0}}, {450, {0.9668617, 0.6464418, 0}}, },
		},
	},
	yun20 = {
		yun25 = {
			moveP = {{0, {0.1505752, 0.02578831, 0}}, {450, {-0.390625, 0.02578831, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun26 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.6809574, 0.02716872, 0}}, {450, {1.40625, 0.02716872, 0}}, },
		},
		yun27 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.3011136, 0.9173748, 0}}, {450, {-0.4296875, 0.9173748, 0}}, },
		},
		yun28 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.9687664, 0.2864667, 0}}, {450, {1.328125, 0.2864667, 0}}, },
		},
		yun29 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.9668617, 0.6464418, 0}}, {450, {1.171875, 0.6464418, 0}}, },
		},
	},
	yun21 = {
		yun1 = {
			moveP = {{0, {0.7878109, 0.8965713, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun3 = {
			moveP = {{0, {0.1474587, 0.6539165, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun6 = {
			moveP = {{0, {0.426686, 0.8258618, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun2 = {
			moveP = {{0, {0.8447484, 0.3904613, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun22 = {
		yun4 = {
			moveP = {{0, {0.1536998, 0.09511296, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun5 = {
			moveP = {{0, {0.4750454, 0.4875199, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun8 = {
			moveP = {{0, {0.05386471, 0.9159855, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun12 = {
			moveP = {{0, {0.8564507, 0.0909523, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun23 = {
		yun7 = {
			moveP = {{0, {0.1529193, 0.377982, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun11 = {
			moveP = {{0, {0.8252516, 0.6885806, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun14 = {
			moveP = {{0, {0.6536583, 0.2226808, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun15 = {
			moveP = {{0, {0.3814474, 0.7218582, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun24 = {
		yun9 = {
			moveP = {{0, {0.02500208, 0.4805887, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun10 = {
			moveP = {{0, {0.1591561, 0.3100346, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun13 = {
			moveP = {{0, {0.5226235, 0.05351454, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun16 = {
			moveP = {{0, {0.6606752, 0.712149, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun25 = {
		yun17 = {
			moveP = {{0, {0.7947282, 0.6015134, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun18 = {
			moveP = {{0, {0.0699797, 0.7606838, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun19 = {
			moveP = {{0, {0.4895217, 0.3996274, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun20 = {
			moveP = {{0, {0.7436271, 0.2840449, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun26 = {
		yun21 = {
			moveP = {{0, {0.8853078, 0.8660671, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun22 = {
			moveP = {{0, {0.4961027, 0.7149223, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun23 = {
			moveP = {{0, {0.4259083, 0.192176, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun24 = {
			moveP = {{0, {0.1973739, 0.5443698, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun27 = {
		yun25 = {
			moveP = {{0, {0.1505752, 0.02578831, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun26 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.6809574, 0.02716872, 0}}, },
		},
		yun27 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.3011136, 0.9173748, 0}}, },
		},
		yun28 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.9687664, 0.2864667, 0}}, },
		},
		yun29 = {
			alpha = {{0, {1}}, },
			moveP = {{0, {0.9668617, 0.6464418, 0}}, },
		},
	},
	c_yun = {
		{0,"yun1", 1, 0},
		{0,"yun4", 1, 0},
		{0,"yun7", 1, 0},
		{0,"yun10", 1, 0},
		{0,"yun13", 1, 0},
		{0,"yun16", 1, 0},
		{0,"yun19", 1, 0},
		{0,"fdj", -1, 500},
	},
	c_yun_san = {
		{0,"yun2", 1, 0},
		{0,"yun5", 1, 0},
		{0,"yun8", 1, 0},
		{0,"yun11", 1, 0},
		{0,"yun14", 1, 0},
		{0,"yun17", 1, 0},
		{0,"yun20", 1, 0},
	},
	c_fdj = {
		{0,"fdj", -1, 0},
	},
	c_yun2 = {
		{0,"yun1", 1, 0},
		{0,"yun4", 1, 0},
		{0,"yun7", 1, 0},
		{0,"yun10", 1, 0},
		{0,"yun13", 1, 0},
		{0,"yun16", 1, 0},
		{0,"yun19", 1, 0},
	},
	c_yun_zhu = {
		{0,"yun21", 1, 0},
		{0,"yun22", 1, 0},
		{0,"yun23", 1, 0},
		{0,"yun24", 1, 0},
		{0,"yun25", 1, 0},
		{0,"yun26", 1, 0},
		{0,"yun27", 1, 0},
	},
	c_yun_zhu2 = {
		{0,"yun21", 1, 0},
		{0,"yun22", 1, 0},
		{0,"yun23", 1, 0},
		{0,"yun24", 1, 0},
		{0,"yun25", 1, 0},
		{0,"yun26", 1, 0},
		{0,"yun27", 1, 0},
		{0,"fdj", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
