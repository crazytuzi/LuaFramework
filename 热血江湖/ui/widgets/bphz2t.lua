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
			etype = "Image",
			name = "lbdt1",
			varName = "memberBg",
			posX = 0.4851539,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.7671875,
			sizeY = 0.1181231,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "detail_btn",
				posX = 0.9066982,
				posY = 0.4882593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1484326,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz1",
				varName = "name_label",
				posX = 0.1884378,
				posY = 0.5119403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1738133,
				sizeY = 0.7054787,
				text = "名字六个字啊",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz3",
				varName = "job_label",
				posX = 0.6288121,
				posY = 0.5119404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1251222,
				sizeY = 0.7054787,
				text = "帮主",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF302A14",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz5",
				varName = "old_contri",
				posX = 0.4835859,
				posY = 0.5119403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1781897,
				sizeY = 0.7054787,
				text = "666654",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF0E3B2F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz6",
				varName = "state",
				posX = 0.7676855,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1497242,
				sizeY = 0.7054787,
				text = "24小时前",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "roleHeadBg",
				posX = 0.05432768,
				posY = 0.449702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09638526,
				sizeY = 0.8933458,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon",
					posX = 0.4986762,
					posY = 0.7264316,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7794118,
					sizeY = 1.12931,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8056563,
					posY = 0.2563766,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3095851,
					sizeY = 0.394852,
					image = "zdte#djd2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "gender",
				posX = 0.02326812,
				posY = 0.7742578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03619572,
				sizeY = 0.45172,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz2",
				varName = "level_label",
				posX = 0.08367278,
				posY = 0.2256572,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05188559,
				sizeY = 0.4359249,
				text = "85",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "job_icon",
				posX = 0.3441744,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0426945,
				sizeY = 0.4929647,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxd",
				posX = 0.9015819,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0305499,
				sizeY = 0.3527394,
				image = "chu1#gxd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djs",
					varName = "selected",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.266667,
					sizeY = 1.133333,
					image = "chu1#dj",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
