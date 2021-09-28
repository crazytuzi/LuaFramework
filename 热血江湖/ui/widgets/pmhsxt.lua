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
			posY = 0.5034661,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.246875,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an3",
				varName = "infoBtn",
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
					etype = "Image",
					name = "tb",
					varName = "gradeIcon",
					posX = 0.1661518,
					posY = 0.4893951,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2689873,
					sizeY = 0.8499997,
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
						etype = "FrameAni",
						name = "sd3",
						sizeXAB = 83.65922,
						sizeYAB = 80.60238,
						posXAB = 43.26888,
						posYAB = 45.5883,
						varName = "orangeTX",
						posX = 0.5090457,
						posY = 0.5363331,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9842263,
						sizeY = 0.9482635,
						frameEnd = 16,
						frameName = "uieffect/xl_003.png",
						delay = 0.05,
						frameWidth = 64,
						frameHeight = 64,
						column = 4,
						repeatLastFrame = 35,
					},
				},
				{
					prop = {
						etype = "FrameAni",
						name = "sd4",
						sizeXAB = 83.65922,
						sizeYAB = 80.60238,
						posXAB = 43.26888,
						posYAB = 45.5883,
						varName = "purpleTX",
						posX = 0.5090457,
						posY = 0.5363331,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9842263,
						sizeY = 0.9482635,
						frameEnd = 16,
						frameName = "uieffect/xll_001.png",
						delay = 0.05,
						frameWidth = 64,
						frameHeight = 64,
						column = 4,
						repeatLastFrame = 35,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id2",
					varName = "nameLabel",
					posX = 0.6345631,
					posY = 0.6997891,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5942848,
					sizeY = 0.4545346,
					text = "装备名字七个字",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "countLabel",
					posX = 0.6345632,
					posY = 0.294007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5942848,
					sizeY = 0.4545346,
					text = "x999",
					color = "FF65944D",
					fontOutlineColor = "FF27221D",
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
