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
			name = "jn1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5296875,
			sizeY = 0.1388889,
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
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnk1",
				varName = "skillBG1",
				posX = 0.1083156,
				posY = 0.49,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1327434,
				sizeY = 0.8999999,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt1",
					varName = "skill_icon",
					posX = 0.495706,
					posY = 0.5213076,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7520278,
					sizeY = 0.7648352,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jnm",
				varName = "name",
				posX = 0.3242304,
				posY = 0.78,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2484609,
				sizeY = 0.5343311,
				text = "技能名字",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "desc",
				posX = 0.5833914,
				posY = 0.210629,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7667829,
				sizeY = 0.81387,
				text = "对怪物造成伤害",
				color = "FF966856",
				fontSize = 18,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnk2",
				varName = "skillBG2",
				posX = 0.1083156,
				posY = 0.49,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.120944,
				sizeY = 0.8199999,
				image = "zdjn#bai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt2",
					varName = "skill_icon2",
					posX = 0.5,
					posY = 0.5009825,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8232079,
					sizeY = 0.8054853,
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
