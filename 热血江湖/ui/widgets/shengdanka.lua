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
			name = "k1",
			posX = 0.5028733,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.725,
			sizeY = 0.1675085,
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
				name = "bplbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "hy#d2",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ms",
					varName = "time",
					posX = 0.4394704,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4982737,
					sizeY = 0.3631303,
					text = "xxxshijian",
					color = "FF65944D",
					fontSize = 22,
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ms2",
					varName = "brick_num",
					posX = 0.8111651,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2002877,
					sizeY = 0.4283511,
					text = "x500",
					color = "FF966856",
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zhuan",
						posX = -0.1553004,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1829265,
						sizeY = 0.5613436,
						image = "bgb#cai",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xyxt",
					posX = 0.09226552,
					posY = 0.5307251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1519396,
					sizeY = 0.621859,
					image = "heka#heka",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ms3",
					varName = "flower_num",
					posX = 0.9983575,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2002877,
					sizeY = 0.4283511,
					text = "x500",
					color = "FF966856",
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zhuan2",
						posX = -0.1553004,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1829265,
						sizeY = 0.8129804,
						image = "bgb#zan",
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
