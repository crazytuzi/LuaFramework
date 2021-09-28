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
			sizeX = 0.0855085,
			sizeY = 0.1577156,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "mat_bg",
				posX = 0.5,
				posY = 0.5792567,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8040136,
				sizeY = 0.7749532,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djk",
					varName = "mat_img",
					posX = 0.5026884,
					posY = 0.5212724,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8402775,
					sizeY = 0.8416974,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "mat_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "mat_count",
					posX = 0.5000007,
					posY = -0.1126765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.14402,
					sizeY = 0.8651927,
					text = "55555",
					color = "FF966856",
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
