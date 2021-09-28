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
			name = "qm1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1305556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "onClickBtn",
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
				name = "sxt",
				varName = "iconBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.82,
				sizeY = 0.8723401,
				image = "zdjn#bai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lockImg",
					posX = 0.2481447,
					posY = 0.2738265,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2978723,
					sizeY = 0.2978723,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "itemIcon",
					posX = 0.5061201,
					posY = 0.5060851,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8157407,
					sizeY = 0.7913715,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sld",
				posX = 0.7179276,
				posY = 0.2132719,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3,
				sizeY = 0.2234042,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "js1",
					varName = "itemCount",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.971357,
					sizeY = 1.885289,
					text = "66",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "ProgressTimer",
				name = "cd",
				varName = "itemCD",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7587244,
				sizeY = 0.8071535,
				image = "zd#sbdt",
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
