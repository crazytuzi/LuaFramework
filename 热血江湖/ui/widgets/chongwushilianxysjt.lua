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
			sizeX = 0.5097226,
			sizeY = 0.1130939,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "xunyang#tiao1",
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "name",
					posX = 0.4357563,
					posY = 0.7396646,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7559947,
					sizeY = 1.003567,
					text = "风雨森林",
					color = "FF8F61AC",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc2",
					varName = "level",
					posX = 1.005767,
					posY = 0.4866854,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5983863,
					sizeY = 1.003567,
					text = "剩余次数：",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc3",
					varName = "des",
					posX = 0.3553795,
					posY = 0.3403178,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.595241,
					sizeY = 1.003567,
					text = "建议所有试炼技能",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
					lineSpaceAdd = -2,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc4",
					varName = "count",
					posX = 1.083041,
					posY = 0.486685,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.443839,
					sizeY = 1.003567,
					text = "5",
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
