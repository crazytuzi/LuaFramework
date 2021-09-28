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
			varName = "typeImg",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1640625,
			sizeY = 0.0944953,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jie1",
				varName = "normalImage",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.947619,
				sizeY = 0.9994618,
				image = "phb#ph2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "itemBt",
					posX = 0.3729127,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7458254,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "name",
					posX = 0.5,
					posY = 0.6616464,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.791997,
					sizeY = 0.844031,
					text = "泫勃派1",
					color = "FF3B8972",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc2",
					varName = "des",
					posX = 0.5,
					posY = 0.3089499,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.791997,
					sizeY = 0.844031,
					text = "玩家备注几个字",
					color = "FFFF6F21",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xiugai",
					varName = "modify",
					posX = 0.8266351,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2060302,
					sizeY = 0.6764706,
					image = "sjdt2#xiugai",
					imageNormal = "sjdt2#xiugai",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jie2",
				varName = "addImage",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.947619,
				sizeY = 0.9994618,
				image = "phb#ph1",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btns2",
					varName = "addBt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8027048,
					sizeY = 0.7928208,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "jia",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.181547,
						sizeY = 0.5379155,
						image = "bp#jia",
						alpha = 0.5,
						imageNormal = "bp#jia",
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
