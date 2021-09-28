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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.0703125,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tb2",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9111111,
				sizeY = 0.9111112,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "choose_btn",
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
					name = "djt2",
					varName = "item_icon",
					posX = 0.4986857,
					posY = 0.514829,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8510638,
					sizeY = 0.851064,
					image = "plp#plp",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					varName = "lock",
					posX = 0.202514,
					posY = 0.2238061,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3191489,
					sizeY = 0.319149,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "item_count",
					posX = 0.3400186,
					posY = 0.2207458,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.140995,
					sizeY = 0.4459296,
					text = "x1",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djxz",
					varName = "light_icon",
					posX = 0.5,
					posY = 0.5243902,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.133045,
					sizeY = 1.133045,
					image = "djk#xz",
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
