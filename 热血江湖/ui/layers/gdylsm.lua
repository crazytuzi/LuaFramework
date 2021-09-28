--version = 1
local l_fileType = "layer"

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
			name = "ddd",
			posX = 0.4994668,
			posY = 0.4998969,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "mask",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9967992,
			sizeY = 0.9858795,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.003211,
				sizeY = 1.014323,
				image = "gdylbj#gdylbj",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "roolTip",
					posX = 0.7648017,
					posY = 0.554096,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07734376,
					sizeY = 0.2124999,
					image = "tong#yq1",
					imageNormal = "tong#yq1",
					imagePressed = "chu1#yq2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yq1",
						posX = 0.5232738,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3592769,
						sizeY = 0.7177746,
						text = "玩法说明",
						color = "FFEBC6B4",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "skillTip",
					posX = 0.765583,
					posY = 0.373541,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07734376,
					sizeY = 0.2124999,
					image = "tong#yq1",
					imageNormal = "tong#yq1",
					imagePressed = "chu1#yq2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yq2",
						posX = 0.5232738,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3592769,
						sizeY = 0.7177746,
						text = "技能说明",
						color = "FFEBC6B4",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.744144,
					posY = 0.6977029,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.04988795,
					sizeY = 0.1006031,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wanfa",
					varName = "wanfaRoot",
					posX = 0.5070195,
					posY = 0.4306216,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4274217,
					sizeY = 0.5103873,
					image = "guidaoyuling1#db",
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
						name = "lb1",
						varName = "scroll1",
						posX = 0.5,
						posY = 0.4972787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9744531,
						sizeY = 0.9617406,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jineng",
					varName = "jinengRoot",
					posX = 0.5070195,
					posY = 0.4306216,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4274217,
					sizeY = 0.5103873,
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
						name = "lb2",
						varName = "scroll2",
						posX = 0.5,
						posY = 0.4972787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9744531,
						sizeY = 0.9617406,
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
