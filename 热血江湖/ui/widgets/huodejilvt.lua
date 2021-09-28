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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5402524,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.65,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bg",
				posX = 0.09576035,
				posY = 0.49,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.112606,
				sizeY = 0.7786962,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5039981,
					posY = 0.5146999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8416507,
					sizeY = 0.8365787,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2238522,
					posY = 0.2345026,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.319149,
					sizeY = 0.319149,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "nameCount",
				posX = 0.4812494,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.5243454,
				text = "道具名称x999",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				varName = "time",
				posX = 0.6487006,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6063595,
				sizeY = 0.5243454,
				text = "2019-01-01 15:00:00",
				color = "FF966856",
				hTextAlign = 2,
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
