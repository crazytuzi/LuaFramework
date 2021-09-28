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
			sizeX = 0.4203123,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.7777778,
				image = "rydt#t",
				scale9Left = 0.45,
				scale9Right = 0.45,
				alpha = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "c2",
					varName = "desc",
					posX = 0.6400697,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5519859,
					sizeY = 1.849221,
					text = "14821",
					color = "FFED6114",
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "name",
					posX = 0.3394884,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5057375,
					sizeY = 1.669595,
					text = "家园名称：",
					color = "FFED6114",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xg",
					varName = "changeNameBtn",
					posX = 0.9611196,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.07620819,
					sizeY = 1.314286,
					image = "sjdt2#xiugai",
					imageNormal = "sjdt2#xiugai",
					disablePressScale = true,
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
