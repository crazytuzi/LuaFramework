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
			sizeX = 0.128125,
			sizeY = 0.3208333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "suicongBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.402439,
				sizeY = 0.6926408,
				image = "d#tyd",
				scale9Left = 0.3,
				scale9Right = 0.5,
				scale9Top = 0.3,
				scale9Bottom = 0.6,
				alpha = 0.5,
				rotation = 90,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "isSelete",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9695122,
				sizeY = 0.874459,
				image = "ll#cyxz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "iconBg",
				posX = 0.5,
				posY = 0.5573329,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8963415,
				sizeY = 0.5108226,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
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
					posX = 0.8185052,
					posY = 0.2731567,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2857143,
					sizeY = 0.3644068,
					image = "zdte#djd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mz2",
						varName = "desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.293714,
						sizeY = 1.304044,
						text = "55",
						fontOutlineEnable = true,
						fontOutlineColor = "FF002120",
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
				name = "mz",
				varName = "name",
				posX = 0.5,
				posY = 0.2024416,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.222737,
				sizeY = 0.2692693,
				text = "玩家名字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
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
