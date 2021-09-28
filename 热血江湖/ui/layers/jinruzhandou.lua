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
			name = "z1",
			posX = 0.501169,
			posY = 0.5013865,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9960193,
			sizeY = 0.9983599,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z14",
				posX = 1.372584,
				posY = 1.430683,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.178403,
				sizeY = 0.2504107,
				image = "uieffect/dimo.png",
				alpha = 0,
				rotation = -29,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z6",
				posX = 0.4909951,
				posY = 0.5208357,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.184103,
				sizeY = 0.2833319,
				image = "uieffect/bigblood2_1.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z5",
				posX = 0.9179839,
				posY = 0.8434101,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.1437202,
				sizeY = 0.1688537,
				image = "uieffect/bigblood2.png",
				alpha = 0,
				rotation = -25,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z4",
				posX = 0.609241,
				posY = 0.6701378,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.2018539,
				sizeY = 0.2696751,
				image = "uieffect/bigblood2.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z3",
				posX = 1.133517,
				posY = 1.10517,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.098121,
				sizeY = 0.2086756,
				image = "uieffect/065.png",
				alpha = 0,
				rotation = -25,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z2",
				posX = 1.133517,
				posY = 1.10517,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.098121,
				sizeY = 0.2782341,
				image = "uieffect/mo.png",
				alpha = 0,
				rotation = -25,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zz1",
			posX = 0.5027293,
			posY = 0.4972267,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9882197,
			sizeY = 0.9900403,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z11",
				posX = 0.612235,
				posY = 0.3744079,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2792079,
				sizeY = 0.551788,
				image = "uieffect/bigblood2_1.png",
				alpha = 0,
				rotation = 90,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z10",
				posX = 0.2826247,
				posY = 0.1053138,
				anchorX = 0,
				anchorY = 0.5,
				sizeX = 0.1437202,
				sizeY = 0.1688537,
				image = "uieffect/bigblood2.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z9",
				posX = 0.59037,
				posY = 0.4042061,
				anchorX = 0,
				anchorY = 0.5,
				sizeX = 0.2950608,
				sizeY = 0.4240833,
				image = "uieffect/bigblood2.png",
				alpha = 0,
				rotation = -10,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z8",
				posX = -0.3039074,
				posY = -0.05785019,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.581126,
				sizeY = 0.3086294,
				image = "uieffect/065.png",
				alpha = 0,
				rotation = 168,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z7",
				posX = -0.3039074,
				posY = -0.05785019,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.581126,
				sizeY = 0.4208583,
				image = "uieffect/mo.png",
				alpha = 0,
				rotation = 168,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z13",
				posX = -0.007094923,
				posY = -0.08223374,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.178403,
				sizeY = 0.4903153,
				image = "uieffect/dimo.png",
				alpha = 0,
				rotation = 165,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zz2",
			posX = 0.4988286,
			posY = 0.4993059,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9944606,
			sizeY = 0.9914256,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z23",
				posX = 1.264928,
				posY = -0.4142094,
				anchorX = 1,
				anchorY = 1,
				sizeX = 1.178403,
				sizeY = 0.7004504,
				image = "uieffect/go-0.png",
				alpha = 0,
				rotation = 75,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z12",
				posX = 1.194833,
				posY = -0.30923,
				anchorX = 1,
				anchorY = 1,
				sizeX = 1.178403,
				sizeY = 0.4903153,
				image = "uieffect/065.png",
				alpha = 0,
				rotation = 70,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z15",
				posX = 0.9417821,
				posY = -0.2849934,
				anchorX = 1,
				anchorY = 1,
				sizeX = 0.1964004,
				sizeY = 2.101351,
				image = "uieffect/z16_2.png",
				alpha = 0,
				rotation = 160,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zz3",
			posX = 0.5015591,
			posY = 0.4979193,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9921204,
			sizeY = 0.9941994,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z16",
				posX = 0.5431424,
				posY = 1.412476,
				anchorX = 1,
				anchorY = 1,
				sizeX = 1.178403,
				sizeY = 0.6286466,
				image = "uieffect/065.png",
				alpha = 0,
				rotation = -68,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z18",
				posX = 0.7978575,
				posY = 1.167011,
				anchorX = 1,
				anchorY = 1,
				sizeX = 0.2756092,
				sizeY = 2.095489,
				image = "uieffect/z16_2.png",
				alpha = 0,
				rotation = 20,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z21",
				posX = 0.5014756,
				posY = 1.408295,
				anchorX = 1,
				anchorY = 1,
				sizeX = 1.178403,
				sizeY = 0.6984962,
				image = "uieffect/go-0.png",
				alpha = 0,
				rotation = -68,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zz4",
			posX = 0.5015596,
			posY = 0.4993061,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9936796,
			sizeY = 0.9886518,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z22",
				posX = 0.5143396,
				posY = -0.4044189,
				anchorX = 1,
				anchorY = 1,
				sizeX = 1.178403,
				sizeY = 0.7024156,
				image = "uieffect/go-0.png",
				alpha = 0,
				rotation = 75,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z17",
				posX = 0.5386718,
				posY = -0.244533,
				anchorX = 1,
				anchorY = 1,
				sizeX = 1.178403,
				sizeY = 0.4916909,
				image = "uieffect/065.png",
				alpha = 0,
				rotation = 75,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z19",
				posX = 0.1694,
				posY = -0.3102801,
				anchorX = 1,
				anchorY = 1,
				sizeX = 0.2358658,
				sizeY = 2.101351,
				image = "uieffect/z16_2.png",
				alpha = 0,
				rotation = 160,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z26",
				posX = 0.1805334,
				posY = 0.5282835,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.255878,
				sizeY = 0.4017534,
				image = "uieffect/bigblood2.png",
				alpha = 0,
				rotation = 90,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zz6",
			posX = 0.5011691,
			posY = 0.4979226,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9960191,
			sizeY = 0.9941993,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z25",
				posX = -0.1110813,
				posY = 0.196972,
				anchorX = 1,
				anchorY = 0,
				sizeX = 0.2358658,
				sizeY = 2.095489,
				image = "uieffect/z16_2.png",
				alpha = 0,
				rotation = 85,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z24",
				posX = -0.3007737,
				posY = 0.3731096,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 1.725619,
				sizeY = 0.6984962,
				image = "uieffect/mo.png",
				alpha = 0,
				rotation = 175,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zz5",
			posX = 0.4988296,
			posY = 0.4999996,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9960191,
			sizeY = 0.9817205,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z20",
				posX = 0.501566,
				posY = 0.4964691,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.003132,
				sizeY = 1.024011,
				image = "uieffect/heid_1.png",
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
	z3 = {
		z2 = {
			scale = {{0, {0, 1, 1}}, {200, {1, 1, 1}}, },
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {1250, {1}}, {1300, {0}}, },
			move = {{0, {3000, 1500, 0}}, {150, {1445.126,794.4174,0}}, },
		},
		z3 = {
			scale = {{0, {0, 1, 1}}, {200, {0.9, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {1250, {1}}, {1300, {0}}, },
			move = {{0, {3000, 1500, 0}}, {150, {1445.126,794.4174,0}}, },
		},
		z4 = {
			alpha = {{0, {0}}, {150, {0}}, {200, {1}}, {1250, {1}}, {1300, {0}}, },
			scale = {{150, {0, 0, 1}}, {200, {1,1,1}}, {250, {1.2, 1.2, 1}}, },
		},
		z5 = {
			alpha = {{0, {0}}, {100, {0}}, {200, {1}}, {1250, {1}}, {1300, {0}}, },
			scale = {{0, {0, 0, 1}}, {150, {0, 0, 1}}, {200, {1,1,1}}, },
		},
		z6 = {
			alpha = {{0, {0}}, {150, {0}}, {200, {0.5}}, {1250, {1}}, {1300, {0}}, },
			scale = {{150, {0, 0, 1}}, {200, {1,1,1}}, {250, {1.2, 1.2, 1}}, },
		},
		z14 = {
			scale = {{0, {0, 1, 1}}, {200, {0.9, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {1250, {1}}, {1300, {0}}, },
		},
	},
	z33 = {
		z7 = {
			scale = {{0, {0, 1, 1}}, {200, {1, 1, 1}}, },
			alpha = {{0, {0}}, {50, {1}}, {1100, {1}}, {1150, {0}}, },
		},
		z8 = {
			scale = {{0, {0, 1, 1}}, {200, {1, 1, 1}}, },
			alpha = {{0, {0}}, {50, {1}}, {1100, {1}}, {1150, {0}}, },
		},
		z9 = {
			alpha = {{0, {0}}, {150, {0}}, {200, {1}}, {1100, {1}}, {1150, {0}}, },
			scale = {{150, {0, 0, 1}}, {200, {1,1,1}}, {250, {1.2, 1.2, 1}}, },
		},
		z10 = {
			alpha = {{0, {0}}, {100, {0}}, {200, {1}}, {1100, {1}}, {1150, {0}}, },
			scale = {{0, {0, 0, 1}}, {150, {0, 0, 1}}, {200, {1,1,1}}, },
		},
		z11 = {
			alpha = {{0, {0}}, {150, {0}}, {200, {0.4}}, {1100, {1}}, {1150, {0}}, },
			scale = {{150, {0, 0, 1}}, {200, {1,1,1}}, {250, {1.2, 1.2, 1}}, },
		},
		z13 = {
			scale = {{0, {0, 1, 1}}, {200, {1, 1, 1}}, },
			alpha = {{0, {0}}, {50, {1}}, {1100, {1}}, {1150, {0}}, },
		},
	},
	z333 = {
		z12 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {900, {1}}, {950, {0}}, },
			scale = {{0, {0, 1, 1}}, {150, {1, 1, 1}}, },
		},
		z15 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {900, {1}}, {950, {0}}, },
			scale = {{0, {1, 0, 1}}, {150, {1, 1, 1}}, },
		},
		z23 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {0.5}}, {900, {0.5}}, {950, {0}}, },
			scale = {{0, {1, 0, 1}}, {150, {1, 1, 1}}, },
		},
	},
	z3333 = {
		z16 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {800, {1}}, {850, {0}}, },
			scale = {{0, {0, 1, 1}}, {150, {1, 1, 1}}, },
		},
		z18 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {800, {1}}, {850, {0}}, },
			scale = {{0, {1, 0, 1}}, {150, {1, 1, 1}}, },
		},
		z21 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {0.5}}, {800, {0.5}}, {850, {0}}, },
			scale = {{0, {0, 1, 1}}, {150, {1, 1, 1}}, },
		},
	},
	z33333 = {
		z17 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {700, {1}}, {750, {0}}, },
			scale = {{0, {0, 1, 1}}, {150, {1, 1, 1}}, },
		},
		z19 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {700, {1}}, {750, {0}}, },
			scale = {{0, {1, 0, 1}}, {150, {1, 1, 1}}, },
		},
		z22 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {0.5}}, {700, {0.5}}, {750, {0}}, },
			scale = {{0, {0, 1, 1}}, {150, {1, 1, 1}}, },
		},
		z26 = {
			alpha = {{0, {0}}, {50, {0}}, {100, {1}}, {700, {1}}, {750, {0}}, },
			scale = {{50, {0, 0, 1}}, {100, {1,1,1}}, {150, {1.2, 1.2, 1}}, },
		},
	},
	z333333 = {
		z20 = {
			alpha = {{0, {0}}, {300, {1}}, {500, {1}}, {800, {0}}, },
		},
	},
	z33333333 = {
		z24 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {500, {1}}, {550, {0}}, },
			scale = {{0, {0, 1, 1}}, {150, {1,1,1}}, },
		},
		z25 = {
			alpha = {{0, {0}}, {50, {0}}, {150, {1}}, {500, {1}}, {550, {0}}, },
			scale = {{0, {1, 0, 1}}, {150, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"z3", 1, 0},
		{0,"z33", 1, 150},
		{0,"z333", 1, 300},
		{0,"z3333", 1, 450},
		{0,"z33333", 1, 600},
		{0,"z33333333", 1, 720},
		{0,"z333333", 1, 950},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
