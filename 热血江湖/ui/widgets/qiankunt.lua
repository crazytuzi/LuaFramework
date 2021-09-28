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
			etype = "Image",
			name = "shengxing",
			varName = "upStarRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.355906,
			sizeY = 0.1333333,
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bbb2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.979167,
				image = "h#njd2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "dj3",
					varName = "add_point_btn",
					posX = 0.9077869,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1844262,
					sizeY = 1,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "jia",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.678433,
						sizeY = 0.606383,
						image = "chu1#jia",
						imageNormal = "chu1#jia",
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk8",
					varName = "item_bg_icon2",
					posX = 0.1038019,
					posY = 0.4619654,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.09877959,
					sizeY = 0.4736843,
					image = "zy#daoke",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm2",
					varName = "item_name2",
					posX = 0.4443251,
					posY = 0.5141205,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5277218,
					sizeY = 0.6903037,
					text = "受刀系伤害减少10.",
					color = "FF634624",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl8",
					varName = "item_count2",
					posX = 0.8008658,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2003084,
					sizeY = 0.9308163,
					text = "1/10",
					color = "FF029133",
					fontSize = 22,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
