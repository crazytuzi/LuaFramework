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
			sizeX = 0.5009849,
			sizeY = 0.1263873,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bfsqt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.95,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "pm",
					varName = "rank",
					posX = 0.0905024,
					posY = 0.511551,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1644108,
					sizeY = 0.619791,
					text = "100.",
					color = "FF966856",
					fontSize = 30,
					fontOutlineColor = "FF235C4F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "roleHeadBg",
					posX = 0.2624474,
					posY = 0.4534945,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1585859,
					sizeY = 0.925402,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "js",
					varName = "name",
					posX = 0.5436857,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3860403,
					sizeY = 0.6570855,
					text = "公认热血最强人",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.1822723,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.00477376,
					sizeY = 0.95,
					image = "b#shuxian",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "level",
					posX = 0.8757122,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1763379,
					sizeY = 0.6570855,
					text = "Lv.88",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF235C4F",
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
