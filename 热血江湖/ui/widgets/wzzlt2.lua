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
			name = "jd2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6953125,
			sizeY = 0.1803734,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "ms2",
				varName = "des1",
				posX = 0.5778687,
				posY = 0.5347528,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5341507,
				sizeY = 0.4403509,
				text = "条件1",
				color = "FFCD1616",
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dian1",
					varName = "img1",
					posX = -0.03971803,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04838091,
					sizeY = 0.3147521,
					image = "wzzl#hong",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mzd",
				posX = 0.429143,
				posY = 0.7920855,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3202247,
				sizeY = 0.2387024,
				image = "wzzl#a",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tjz",
					varName = "taskName",
					posX = 0.5480001,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8351665,
					sizeY = 1.977805,
					text = "条件",
					color = "FFF4E1C5",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms3",
				varName = "des2",
				posX = 0.5778687,
				posY = 0.2920973,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5341507,
				sizeY = 0.4403509,
				text = "条件2",
				color = "FFCD1616",
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dian2",
					varName = "img2",
					posX = -0.03971803,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04838091,
					sizeY = 0.3147521,
					image = "wzzl#hong",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "wc",
				varName = "finish",
				posX = 0.8946053,
				posY = 0.3921986,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.142107,
				sizeY = 0.4466044,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wcz",
					posX = 0.5,
					posY = 0.5172414,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7292893,
					sizeY = 1.123365,
					text = "完成",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
