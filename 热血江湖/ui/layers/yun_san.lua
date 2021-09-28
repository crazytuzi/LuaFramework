--version = 1
local l_fileType = "layer"

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
				posX = 0.4220056,
				posY = 0.247639,
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
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	yun1 = {
		yun1 = {
			move = {{0, {1008.398,645.5313,0}}, {500, {2000, 645.5313, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun3 = {
			move = {{0, {188.7471,470.8199,0}}, {500, {-700, 470.8199, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun6 = {
			move = {{0, {546.1581,594.6205,0}}, {500, {-1000, 594.6205, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun2 = {
			move = {{0, {1081.278,281.1321,0}}, {500, {2000, 281.1321, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun4 = {
		yun4 = {
			move = {{0, {196.7357,68.48133,0}}, {600, {-500, 68.48133, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun5 = {
			move = {{0, {608.0581,351.0143,0}}, {600, {2000, 351.0143, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun8 = {
			move = {{0, {68.94682,659.5096,0}}, {600, {-500, 659.5096, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun12 = {
			move = {{0, {1096.257,65.48566,0}}, {600, {2000, 65.48566, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun7 = {
		yun7 = {
			move = {{0, {195.7367,272.147,0}}, {550, {-500, 272.147, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun11 = {
			move = {{0, {1056.322,495.778,0}}, {550, {2000, 495.778, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun14 = {
			move = {{0, {836.6827,160.3302,0}}, {550, {1500, 160.3302, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun15 = {
			move = {{0, {488.2527,519.7379,0}}, {550, {-500, 519.7379, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	yun10 = {
		yun9 = {
			move = {{0, {32.00266,346.0239,0}}, {450, {-500, 346.0239, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun10 = {
			move = {{0, {540.1672,178.3001,0}}, {450, {-500, 178.3001, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun13 = {
			move = {{0, {668.9581,38.53047,0}}, {450, {2000, 38.53047, 0}}, },
			alpha = {{0, {1}}, },
		},
		yun16 = {
			move = {{0, {845.6643,512.7473,0}}, {450, {1700, 512.7473, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_yun = {
		{0,"yun1", 1, 0},
		{0,"yun4", 1, 0},
		{0,"yun7", 1, 0},
		{0,"yun10", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
