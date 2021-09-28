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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0,
			alphaCascade = true,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "backGround",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "zdan",
				posX = 0.498974,
				posY = 0.9320314,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9988506,
				sizeY = 0.1319349,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "zdan2",
				posX = 0.9558907,
				posY = 0.5007961,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0850172,
				sizeY = 0.9944057,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "zdan3",
				posX = 0.498974,
				posY = 0.05628383,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9988506,
				sizeY = 0.1164763,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.08671895,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1710938,
				sizeY = 1,
				image = "zjm3#bb",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zz",
				posX = 0.07803541,
				posY = 0.928167,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.153125,
				sizeY = 0.1430556,
				image = "zjm3#fhd",
				scale9Left = 0.45,
				scale9Right = 0.45,
				alpha = 0,
				alphaCascade = true,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "ht",
					varName = "closeBtn",
					posX = 0.4833455,
					posY = 0.6924155,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9400069,
					sizeY = 0.5939342,
					alphaCascade = true,
					layoutType = 1,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "hta",
						posX = 0.2344714,
						posY = 0.5815728,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3419428,
						sizeY = 0.8336706,
						image = "zjm3#jt",
						imageNormal = "zjm3#jt",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jda",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "dib",
				posX = 0.25,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5,
				sizeY = 1,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bk1",
					posX = 0.1630244,
					posY = 0.8009013,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.228125,
					sizeY = 0.2041667,
					image = "zjm3#db",
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xian1",
						posX = 0.4999902,
						posY = 1.070467,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04794521,
						sizeY = 0.2789115,
						image = "zjm3#hx",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bk2",
					posX = 0.1630244,
					posY = 0.5928898,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.228125,
					sizeY = 0.2041667,
					image = "zjm3#db",
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xian2",
						posX = 0.4999902,
						posY = 1.063664,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04794521,
						sizeY = 0.2789115,
						image = "zjm3#hx",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bk3",
					posX = 0.1630244,
					posY = 0.3862672,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.228125,
					sizeY = 0.2041667,
					image = "zjm3#db",
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xian3",
						posX = 0.4999902,
						posY = 1.063664,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04794521,
						sizeY = 0.2789115,
						image = "zjm3#hx",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bk4",
					posX = 0.1630244,
					posY = 0.1796446,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.228125,
					sizeY = 0.2041667,
					image = "zjm3#db",
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xian4",
						posX = 0.4999902,
						posY = 1.063664,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04794521,
						sizeY = 0.2789115,
						image = "zjm3#hx",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zhui",
						posX = 0.5068152,
						posY = -0.1112563,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2123288,
						sizeY = 0.4829932,
						image = "zjm3#zhui",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "btnPVP",
				posX = 0.08120821,
				posY = 0.1908525,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1203125,
				sizeY = 0.2097222,
				image = "zjm3#jj",
				alpha = 0,
				alphaCascade = true,
				imageNormal = "zjm3#jj",
				imagePressed = "zjm3#jj2",
				imageDisable = "zjm3#jj",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "fg4",
					varName = "selectPVP",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.070856,
					sizeY = 1.248517,
					image = "zjm3#xz",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd2",
					varName = "arenaRed",
					posX = 0.9259584,
					posY = 0.4963318,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1753247,
					sizeY = 0.1854305,
					image = "zdte#hd",
					alphaCascade = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a4",
				varName = "btnDungeon",
				posX = 0.08120599,
				posY = 0.3981657,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1203125,
				sizeY = 0.2097222,
				image = "zjm3#fb",
				alpha = 0,
				alphaCascade = true,
				imageNormal = "zjm3#fb",
				imagePressed = "zjm3#fb2",
				imageDisable = "zjm3#fb",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "fg2",
					varName = "selectDungeon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.070856,
					sizeY = 1.248517,
					image = "zjm3#xz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a3",
				varName = "btnAct",
				posX = 0.08121552,
				posY = 0.6027541,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1203125,
				sizeY = 0.2097222,
				image = "zjm3#hd",
				alpha = 0,
				alphaCascade = true,
				imageNormal = "zjm3#hd",
				imagePressed = "zjm3#hd2",
				imageDisable = "zjm3#hd",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "fg3",
					varName = "selectAct",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.070856,
					sizeY = 1.248517,
					image = "zjm3#xz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "btnDailyTask",
				posX = 0.0812127,
				posY = 0.8114076,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1203125,
				sizeY = 0.2097222,
				image = "zjm3#rc",
				alpha = 0,
				alphaCascade = true,
				imageNormal = "zjm3#rc",
				imagePressed = "zjm3#rc2",
				imageDisable = "zjm3#rc",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "fg",
					varName = "selectDaily",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.070856,
					sizeY = 1.248517,
					image = "zjm3#xz",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "red",
					posX = 0.9259785,
					posY = 0.5227755,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1753247,
					sizeY = 0.1854305,
					image = "zdte#hd",
				},
			},
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
	richang = {
		a1 = {
			alpha = {{0, {1}}, },
			scale = {{0, {1, 0, 1}}, {250, {1,1,1}}, },
		},
	},
	huodong = {
		a3 = {
			alpha = {{0, {1}}, },
			scale = {{0, {1, 0, 1}}, {250, {1,1,1}}, },
		},
	},
	fuben = {
		a4 = {
			alpha = {{0, {1}}, },
			scale = {{0, {1, 0, 1}}, {250, {1,1,1}}, },
		},
	},
	jingji = {
		a2 = {
			alpha = {{0, {1}}, },
			scale = {{0, {1, 0, 1}}, {250, {1,1,1}}, },
		},
	},
	zz = {
		zz = {
			move = {{0, {640, 800, 0}}, {250, {640, 667.262, 0}}, {350, {640,677.262,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	zz1 = {
		zz = {
			move = {{0, {640,677.262,0}}, {200, {640, 800, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	richang1 = {
		a1 = {
			alpha = {{0, {1}}, },
			move = {{0, {178.8278,545.3101,0}}, {200, {-171.1722, 545.3101, 0}}, },
		},
	},
	huodong1 = {
		a3 = {
			alpha = {{0, {1}}, },
			move = {{0, {178.8278,401.0221,0}}, {200, {-171.1722, 401.0221, 0}}, },
		},
	},
	fuben1 = {
		a4 = {
			alpha = {{0, {1}}, },
			move = {{0, {178.8278,256.7341,0}}, {200, {-171.1722, 256.7341, 0}}, },
		},
	},
	jingji1 = {
		a2 = {
			alpha = {{0, {1}}, },
			move = {{0, {178.8278,112.446,0}}, {200, {-171.1722, 112.446, 0}}, },
		},
	},
	dib = {
		dib = {
			alpha = {{0, {1}}, {50, {1}}, },
			move = {{0, {100, 360, 0}}, {300, {330, 360, 0}}, {400, {320,360,0}}, },
		},
	},
	a1 = {
		a1 = {
			alpha = {{0, {1}}, {50, {1}}, },
			scale = {{0, {0, 0, 1}}, {200, {1,1,1}}, },
		},
	},
	a2 = {
		a2 = {
			alpha = {{0, {1}}, {50, {1}}, },
			scale = {{0, {0, 0, 1}}, {200, {1,1,1}}, },
		},
	},
	a3 = {
		a3 = {
			alpha = {{0, {1}}, {50, {1}}, },
			scale = {{0, {0, 0, 1}}, {200, {1,1,1}}, },
		},
	},
	a4 = {
		a4 = {
			alpha = {{0, {1}}, {50, {1}}, },
			scale = {{0, {0, 0, 1}}, {200, {1,1,1}}, },
		},
	},
	zzz = {
		zz = {
			alpha = {{0, {1}}, {100, {1}}, },
			move = {{0, {-121.8853, 668.2802, 0}}, {200, {109.8853, 668.2802, 0}}, {250, {99.88532,668.2802,0}}, },
		},
	},
	ddd = {
		ddd = {
			move = {{0, {420, 360, 0}}, {200, {640,360,0}}, },
			alpha = {{50, {0.7}}, },
		},
	},
	dib2 = {
		dib = {
			alpha = {{0, {1}}, {50, {1}}, },
			move = {{0, {320,360,0}}, {200, {100, 360, 0}}, },
		},
	},
	ddd2 = {
		ddd = {
			move = {{0, {640,360,0}}, {300, {420, 360, 0}}, },
			alpha = {{50, {0.7}}, },
		},
	},
	zzz2 = {
		zz = {
			alpha = {{0, {1}}, {100, {1}}, },
			move = {{0, {99.88532,668.2802,0}}, {200, {-121.8853, 668.2802, 0}}, },
		},
	},
	a11 = {
		a1 = {
			alpha = {{0, {1}}, {50, {1}}, },
			move = {{0, {103.9523,584.2135,0}}, {200, {-117, 584.2135, 0}}, },
		},
	},
	a22 = {
		a2 = {
			alpha = {{0, {1}}, {50, {1}}, },
			move = {{0, {103.9465,137.4138,0}}, {200, {-117, 137.4138, 0}}, },
		},
	},
	a33 = {
		a3 = {
			alpha = {{0, {1}}, {50, {1}}, },
			move = {{0, {103.9559,433.983,0}}, {200, {-117, 433.983, 0}}, },
		},
	},
	a44 = {
		a4 = {
			alpha = {{0, {1}}, {50, {1}}, },
			move = {{0, {103.9437,286.6793,0}}, {200, {-117, 286.6793, 0}}, },
		},
	},
	bk1 = {
		bk1 = {
			scale = {{0, {0, 1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	bk2 = {
		bk2 = {
			scale = {{0, {0, 1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	bk3 = {
		bk3 = {
			scale = {{0, {0, 1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	bk4 = {
		bk4 = {
			scale = {{0, {0, 1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"bk1", 1, 50},
		{0,"bk2", 1, 100},
		{0,"bk3", 1, 150},
		{0,"bk4", 1, 200},
		{0,"ddd", 1, 0},
		{0,"zzz", 1, 0},
		{0,"a1", 1, 50},
		{0,"a3", 1, 100},
		{0,"a4", 1, 150},
		{0,"a2", 1, 200},
	},
	c_guanbi = {
		{0,"ddd2", 1, 0},
		{0,"zzz2", 1, 0},
		{0,"a11", 1, 0},
		{0,"a22", 1, 0},
		{0,"a33", 1, 0},
		{0,"a44", 1, 0},
		{0,"dib2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
