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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "da",
				posX = 0.5,
				posY = 0.5693316,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2776528,
				sizeY = 0.07777778,
				image = "ts#dw",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "text1",
					posX = 0.320059,
					posY = 0.5356423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6802061,
					sizeY = 1.088929,
					text = "正在高级挂机。。。",
					color = "FFFFFC10",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "cancleBtn",
					posX = 0.8623781,
					posY = 0.4821634,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3460932,
					sizeY = 1.035714,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text2",
					posX = 0.8623781,
					posY = 0.4821637,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3460932,
					sizeY = 1.035714,
					text = "取 消",
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
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
	tanhao = {
		th = {
			scale = {{0, {0.9, 0.9, 1}}, {350, {1.1, 1.1, 1}}, {700, {0.9, 0.9, 1}}, },
		},
	},
	c_dakai = {
		{0,"tanhao", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
