--version = 1
local l_fileType = "layer"

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
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				posX = 0.1455064,
				posY = 0.2763921,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2800065,
				sizeY = 0.2532758,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.1186117,
				posY = 0.3041038,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2961404,
				sizeY = 0.1590105,
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "vs",
					varName = "nameImage",
					posX = 0.6454584,
					posY = 0.05629743,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.084262,
					sizeY = 2.67278,
					image = "zdbpz#zdbpz",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz1",
					varName = "defScore",
					posX = 0.7403116,
					posY = 0.639607,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2888854,
					sizeY = 0.8122289,
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF800000",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz2",
					varName = "myScore",
					posX = 0.4523805,
					posY = 0.6570514,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2764279,
					sizeY = 0.8122289,
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF6846A2",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "infoBtn",
				posX = 0.1487682,
				posY = 0.2833815,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2797197,
				sizeY = 0.2728021,
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
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
