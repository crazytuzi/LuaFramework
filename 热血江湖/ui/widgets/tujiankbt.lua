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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.265625,
			sizeY = 0.5277778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bjt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.017647,
				sizeY = 0.9131579,
				image = "whbj2#whbj2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kb",
					varName = "image",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4097279,
					sizeY = 0.595798,
					image = "tujian2#chengbei",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8704488,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6411765,
				sizeY = 0.1342105,
				image = "wh#top",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name",
					posX = 0.5,
					posY = 0.4215689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9319838,
					sizeY = 1.142969,
					text = "卡背名字",
					color = "FFFFD974",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gm",
				varName = "unlockBtn",
				posX = 0.5,
				posY = 0.1158801,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4652407,
				sizeY = 0.1578947,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "gmz",
					varName = "lockText",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9493306,
					sizeY = 0.8995697,
					text = "解 锁",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xhd",
					varName = "lockRed",
					posX = 0.8977249,
					posY = 0.8270545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1551724,
					sizeY = 0.4242425,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sy",
				varName = "useBtn",
				posX = 0.5,
				posY = 0.1158801,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4652407,
				sizeY = 0.1578947,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "syz",
					varName = "useText",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9493306,
					sizeY = 0.8995697,
					text = "使 用",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shi",
				varName = "inUse",
				posX = 0.5,
				posY = 0.09214338,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4647059,
				sizeY = 0.1815789,
				image = "zq#syz",
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
