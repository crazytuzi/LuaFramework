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
			sizeX = 0.5835937,
			sizeY = 0.1013263,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
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
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9879518,
				sizeY = 0.9594964,
				image = "shijiebei#diban1",
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj2",
				varName = "check",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9879518,
				sizeY = 0.9594964,
				image = "shijiebei#diban2",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb1",
				varName = "rank",
				posX = 0.1818627,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2325496,
				sizeY = 1.039693,
				text = "获得第三名",
				color = "FFDEF9FF",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF011D32",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb2",
				varName = "date",
				posX = 0.5387504,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4813736,
				sizeY = 1.579662,
				text = "开奖日期：xxxxxxx",
				color = "FFFFDF30",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				posX = 0.7957805,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06693441,
				sizeY = 0.6853547,
				image = "tb#yuanbao",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					posX = 0.6398034,
					posY = 0.3202246,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5599998,
					sizeY = 0.56,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "coin",
					posX = 2.596299,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.955618,
					sizeY = 1.324514,
					text = "x5000",
					color = "FFFFDF30",
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
