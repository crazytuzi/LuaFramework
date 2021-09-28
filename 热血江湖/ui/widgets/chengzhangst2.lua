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
			sizeX = 0.3882813,
			sizeY = 0.09166667,
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
				sizeX = 0.9999999,
				sizeY = 0.9848485,
				image = "chengzhan#jingbiaochenggong",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "index",
				posX = 0.04237071,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1198177,
				sizeY = 0.8444229,
				text = "1",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z6",
				varName = "sectName",
				posX = 0.2269085,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4417671,
				sizeY = 0.5297912,
				text = "七八个字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z7",
				varName = "server",
				posX = 0.5848507,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2022059,
				sizeY = 0.5434933,
				text = "1区",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z8",
				varName = "price",
				posX = 0.863458,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2022059,
				sizeY = 0.5434933,
				text = "1000",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
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
