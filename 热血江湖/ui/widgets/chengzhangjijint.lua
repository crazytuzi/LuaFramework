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
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4953125,
			sizeY = 0.09856305,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.95,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					varName = "Whole",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#scd2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "lq",
					varName = "GetBtn",
					posX = 0.8552041,
					posY = 0.4553149,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1979656,
					sizeY = 0.8603155,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lqz",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8247252,
						sizeY = 1.143941,
						text = "领 取",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "bt",
					varName = "GoalContent",
					posX = 0.2495963,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4044434,
					sizeY = 0.748539,
					text = "等级达到10级返利",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF00335D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yb",
					posX = 0.487147,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.08047382,
					sizeY = 0.7416513,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.630765,
						posY = 0.2811634,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.428571,
						sizeY = 0.4285715,
						image = "tb#suo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "Count",
					posX = 0.6344048,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1778788,
					sizeY = 0.748539,
					text = "1000",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF00152E",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ylq",
					varName = "GetImage",
					posX = 0.8535311,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1991623,
					sizeY = 1.112601,
					image = "czt#ylq",
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
