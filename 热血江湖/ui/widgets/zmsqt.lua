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
			name = "zmsqt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.86875,
			sizeY = 0.1285805,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sqd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9655175,
				image = "g#g_c4.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.8269313,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.280547,
				sizeY = 0.7399586,
				image = "w#w_smd3.png",
				alpha = 0.4,
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
				sizeX = 0.07011346,
				sizeY = 0.8020647,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "head_icon",
					posX = 0.5158275,
					posY = 0.6914104,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8412699,
					sizeY = 1.091667,
					image = "tx#tx_yishengnan.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm",
				varName = "name_label",
				posX = 0.2136319,
				posY = 0.5000137,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2124534,
				sizeY = 0.438916,
				text = "棒槌一共八个汉字",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF1C4034",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm2",
				posX = 0.4746208,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07202154,
				sizeY = 0.438916,
				text = "战力",
				color = "FFAFFFE0",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF1C4034",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm3",
				varName = "power_count",
				posX = 0.6002757,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1578557,
				sizeY = 0.438916,
				text = "1234567",
				color = "FFAFFFE0",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF1C4034",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tan",
				varName = "agree_btn",
				posX = 0.7552523,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1052158,
				sizeY = 0.550887,
				image = "w#w_ss4.png",
				imageNormal = "w#w_ss4.png",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tanz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6675901,
					sizeY = 0.9333947,
					text = "同 意",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF917029",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tan2",
				varName = "refuse_btn",
				posX = 0.8930461,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1052158,
				sizeY = 0.550887,
				image = "w#w_hh4.png",
				imageNormal = "w#w_hh4.png",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tanz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6675901,
					sizeY = 0.9333947,
					text = "拒 绝",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2B6A56",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "level_label",
				posX = 0.3715906,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09989687,
				sizeY = 0.6705977,
				text = "Lv. 99",
				color = "FFAFFFE0",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF1C4034",
				vTextAlign = 1,
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
