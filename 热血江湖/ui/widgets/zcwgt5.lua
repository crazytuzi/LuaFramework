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
			varName = "rootLayer",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1835938,
			sizeY = 0.13,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zz",
				varName = "kungfuRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8974359,
				image = "wg2#jnd",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "bt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.009115,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnd",
					posX = 0.1690223,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3083884,
					sizeY = 0.7738096,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					varName = "skill_icon",
					posX = 0.1647669,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2340425,
					sizeY = 0.6547619,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "skill_name",
					posX = 0.6286855,
					posY = 0.654477,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7197378,
					sizeY = 0.6977946,
					text = "武功名字名字",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bq",
					varName = "is_use",
					posX = 0.1796197,
					posY = 0.6966794,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3479609,
					sizeY = 0.5952381,
					image = "wg#sy",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "s",
					varName = "score",
					posX = 0.8979998,
					posY = 0.3335514,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1811669,
					sizeY = 0.5227994,
					image = "pf#you",
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
