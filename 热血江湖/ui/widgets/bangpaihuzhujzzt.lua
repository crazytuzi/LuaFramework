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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1245224,
			sizeY = 0.238158,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "iconType",
				posX = 0.4949566,
				posY = 0.5344839,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9222738,
				sizeY = 0.688152,
				image = "zdtx#txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt",
					varName = "icon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8037993,
					posY = 0.2559153,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.244898,
					sizeY = 0.3050847,
					image = "zdte#djd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dj",
						varName = "lvl",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.278116,
						sizeY = 1,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "rm",
				varName = "name",
				posX = 0.5,
				posY = 0.1631555,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9476119,
				sizeY = 0.2796572,
				text = "人名六七个字",
				color = "FF966856",
				fontOutlineColor = "FF14332E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "zhiyeImg",
				posX = 0.8306733,
				posY = 0.8429148,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.225863,
				sizeY = 0.2099447,
				image = "zy#daoke",
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
