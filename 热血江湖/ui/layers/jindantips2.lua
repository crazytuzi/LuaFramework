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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "globel_bt",
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
			sizeX = 0.3793512,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7009373,
				sizeY = 0.7510809,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.819478,
					sizeY = 1.48,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zsx",
						posX = 0.5,
						posY = 0.9190164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4537629,
						sizeY = 0.06663736,
						image = "chu1#top3",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk1",
					posX = 0.5,
					posY = 0.53082,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.618676,
					sizeY = 0.9554741,
					image = "b#d2",
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
						varName = "itemScroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9779047,
						sizeY = 0.9695086,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz9",
					varName = "itemGrade_lable",
					posX = 0.5,
					posY = 1.119589,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6177265,
					sizeY = 0.1254289,
					text = "礼包内容",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "lq",
					posX = 0.5,
					posY = -0.08153608,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4260272,
					sizeY = 0.1695088,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zzz",
						varName = "close_btn",
						posX = 0.5,
						posY = 0.5363636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.112455,
						sizeY = 0.9418657,
						text = "确 定",
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
