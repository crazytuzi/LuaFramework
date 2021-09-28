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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.740625,
			sizeY = 0.2041667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tdt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9894515,
				sizeY = 0.972789,
				image = "g#g_c4.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dkds",
					varName = "power_icon",
					posX = 0.8543242,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06396588,
					sizeY = 0.4195804,
					image = "zm#dkds",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz2",
					varName = "count_label",
					posX = 0.9406241,
					posY = 0.5209789,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09366119,
					sizeY = 0.4773828,
					text = "x10",
					color = "FFFEDB45",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF00152E",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shb",
				varName = "stateImg",
				posX = 0.1148302,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1279342,
				sizeY = 0.8191934,
				image = "zm#zm_sheng.png",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "desc",
				posX = 0.4936846,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5855274,
				sizeY = 0.4773828,
				text = "名字七个字的人攻击了你的矿藏，并抢走了部分资源。（多少小时前）",
				color = "FF8FFFE3",
				fontSize = 22,
				fontOutlineEnable = true,
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
