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
			sizeX = 0.1715198,
			sizeY = 0.1577156,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "icon_bg",
				posX = 0.2317529,
				posY = 0.5089287,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3871637,
				sizeY = 0.7485344,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djk",
					varName = "item_icon",
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
					varName = "btn",
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
					varName = "count",
					posX = 2.261823,
					posY = 0.2394484,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.14402,
					sizeY = 0.8651927,
					text = "55555",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz2",
					varName = "name",
					posX = 2.261823,
					posY = 0.7335658,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.14402,
					sizeY = 0.8651927,
					text = "道具名字",
					color = "FF966856",
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
