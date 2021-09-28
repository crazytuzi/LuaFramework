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
			sizeX = 0.07421875,
			sizeY = 0.1319444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "jl2",
				varName = "stoneBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8897675,
				sizeY = 0.815313,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jl1",
				varName = "stoneBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9894737,
				sizeY = 0.989474,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jiangli",
					varName = "stoneIcon",
					posX = 0.4946854,
					posY = 0.5108859,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7965636,
					sizeY = 0.7864825,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "stoneLock",
					posX = 0.2012943,
					posY = 0.2258877,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3191489,
					sizeY = 0.3191489,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "shul",
					varName = "stoneCount",
					posX = 0.3869621,
					posY = 0.1898871,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.07553,
					sizeY = 0.6331646,
					text = "x500",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
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
