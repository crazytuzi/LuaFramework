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
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "CjSl",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.6301695,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.257274,
					sizeY = 1.043084,
					image = "xinnianhongbao#xinnianhongbao",
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "gz",
						varName = "des",
						posX = 0.3436522,
						posY = 0.7342956,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5239401,
						sizeY = 0.130016,
						text = "规则写在这里",
						color = "FFFFF9C4",
						fontOutlineEnable = true,
						fontOutlineColor = "FF440D01",
						fontOutlineSize = 2,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "sj",
						varName = "actTime",
						posX = 0.3436522,
						posY = 0.577047,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5239401,
						sizeY = 0.1844812,
						text = "规则写在这里",
						color = "FFFFF153",
						fontOutlineEnable = true,
						fontOutlineColor = "FF440D01",
						fontOutlineSize = 2,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk",
					posX = 0.5213782,
					posY = 0.2396631,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.4210772,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "redPackList",
						posX = 0.420911,
						posY = 0.3837386,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8242863,
						sizeY = 0.9747165,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "ts",
					varName = "des2",
					posX = 0.4042294,
					posY = 0.4198937,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6000001,
					sizeY = 0.1114083,
					text = "提示文字",
					color = "FFFFF9C4",
					fontOutlineEnable = true,
					fontOutlineColor = "FF440D01",
					fontOutlineSize = 2,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.8195346,
					posY = 0.7739392,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05819296,
					sizeY = 0.0861678,
					image = "xnhb2#bz",
					imageNormal = "xnhb2#bz",
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
