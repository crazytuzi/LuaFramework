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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3320313,
			sizeY = 0.09027778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ff",
				posX = 0.5564706,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6917647,
				sizeY = 0.857994,
				image = "d#tyd",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gxd",
					posX = -0.09429587,
					posY = 0.5208041,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1564626,
					sizeY = 0.8427528,
					image = "ty#zyd",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xzan",
					varName = "btn",
					posX = 0.3471653,
					posY = 0.5312061,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.09344,
					sizeY = 1.247934,
					disablePressScale = true,
					propagateToChildren = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xx1",
					varName = "text",
					posX = 0.5472867,
					posY = 0.5175903,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.026073,
					sizeY = 1.706197,
					text = "这个是什么问题这个是什么问题这个是什么问题这个",
					color = "FF634624",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xzt",
					varName = "selectImg",
					posX = -0.05710641,
					posY = 0.5796209,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2310238,
					sizeY = 0.9059886,
					image = "ty#xzjt",
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
