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
			name = "ka",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2017439,
			sizeY = 0.5047781,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
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
				name = "kpd",
				varName = "image",
				posX = 0.538725,
				posY = 0.5632845,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7422865,
				sizeY = 0.8202084,
				image = "tujian#zhongli",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kpk",
					varName = "back",
					posX = 0.4582642,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.166679,
					sizeY = 1.027056,
					image = "tujian3#zi4",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "selected",
				posX = 0.5056038,
				posY = 0.5674286,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.901196,
				sizeY = 0.8692603,
				image = "tujian3#xz",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.5,
				posY = 0.08024263,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.127057,
				sizeY = 0.2359127,
				text = "名称",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "red",
				posX = 0.890161,
				posY = 0.9594454,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1045571,
				sizeY = 0.07704156,
				image = "zdte#hd",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
