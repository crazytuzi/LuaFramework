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
			name = "zmcyt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.621875,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cyd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9655175,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "headBg",
				posX = 0.09012421,
				posY = 0.4315332,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1330275,
				sizeY = 0.7727271,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "head_icon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8479171,
					posY = 0.2300532,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3399758,
					sizeY = 0.4235294,
					image = "zdte#djd2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm",
				varName = "name_label",
				posX = 0.3083071,
				posY = 0.6906162,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2593903,
				sizeY = 0.438916,
				text = "棒槌一共八个汉字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm2",
				posX = 0.485563,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1109033,
				sizeY = 0.438916,
				text = "贡献：",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF1C4034",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm3",
				varName = "contribution",
				posX = 0.6296802,
				posY = 0.4999998,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1578557,
				sizeY = 0.438916,
				text = "1234567",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF1C4034",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj2",
				varName = "vip_level",
				posX = 0.2390736,
				posY = 0.3003193,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1209232,
				sizeY = 0.438916,
				text = "VIP 11",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
				colorTL = "FFFFFCC5",
				colorTR = "FFFFFCC5",
				colorBR = "FFFAB114",
				colorBL = "FFFAB114",
				useQuadColor = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "level_label",
				posX = 0.1361645,
				posY = 0.2310542,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05188559,
				sizeY = 0.4359249,
				text = "99",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm4",
				varName = "charm_lvl",
				posX = 0.3947467,
				posY = 0.3003192,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1209233,
				sizeY = 0.438916,
				text = "Lv.77",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "chdw",
				varName = "titleBg",
				posX = 0.8518359,
				posY = 0.4999999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6432161,
				sizeY = 1.163636,
				image = "chdw1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "chtp",
				varName = "charm_name",
				posX = 0.8518359,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.160804,
				sizeY = 0.581818,
				image = "weizhenbafang",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
