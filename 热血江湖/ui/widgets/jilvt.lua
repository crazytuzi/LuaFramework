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
			posX = 0.5028733,
			posY = 0.5034661,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.8609375,
			sizeY = 0.1208333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an3",
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
				name = "bplbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "id2",
					varName = "nameLabel",
					posX = 0.2127927,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2332283,
					sizeY = 0.4545346,
					text = "装备名字七个字",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id3",
					posX = 0.4280974,
					posY = 0.8726215,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1361806,
					sizeY = 0.2501273,
					text = "我的名字很长啊",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id4",
					varName = "dateLabel",
					posX = 0.4494534,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1830333,
					sizeY = 0.5342133,
					text = "2015-12-22",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF1C3A35",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id5",
					varName = "priceLabel",
					posX = 0.8989048,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1322692,
					sizeY = 0.5342133,
					text = "+95222",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF1C3A35",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id6",
					varName = "stateLabel",
					posX = 0.6688374,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.106663,
					sizeY = 0.5342133,
					text = "售出",
					color = "FFC93034",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "gradeIcon",
					posX = 0.05059797,
					posY = 0.4546216,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07183906,
					sizeY = 0.9195405,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.5,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "countLabel",
						posX = 0.4775722,
						posY = 0.2253265,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8302227,
						sizeY = 0.3639861,
						text = "x999",
						fontSize = 18,
						fontOutlineEnable = true,
						fontOutlineColor = "FF27221D",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yb",
					posX = 0.8071173,
					posY = 0.5114943,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.04537205,
					sizeY = 0.5747128,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "lock",
						posX = 0.6996362,
						posY = 0.3202484,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5,
						sizeY = 0.5,
						image = "tb#suo",
					},
				},
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
