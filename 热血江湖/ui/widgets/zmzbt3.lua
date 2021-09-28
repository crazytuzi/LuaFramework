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
			name = "zmzbt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7390625,
			sizeY = 0.1041667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9978858,
				sizeY = 0.9945354,
				image = "g#zbd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sdd",
					posX = 0.5701227,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8221169,
					sizeY = 0.774478,
					image = "d#sld3",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang",
					posX = 0.4999533,
					posY = 0.8491613,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9984502,
					sizeY = 0.2677595,
					image = "e#dkg",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms1",
				varName = "title_label",
				posX = 0.4904661,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8885343,
				sizeY = 0.7264475,
				text = "宗门名字几个字（正派宗门）攻击了我方宗门，我方胜利。",
				color = "FF8FFFE3",
				fontSize = 24,
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
