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
			lockHV = true,
			sizeX = 0.2148438,
			sizeY = 0.3008786,
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
				sizeX = 0.9795916,
				sizeY = 0.9948185,
				image = "sc#sc_dt.png",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "item_btn",
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
					etype = "Label",
					name = "wpm",
					varName = "item_name",
					posX = 0.5,
					posY = 0.8434298,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9237462,
					sizeY = 0.2100926,
					text = "普通强化石",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg",
					posX = 0.4968534,
					posY = 0.516847,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3489394,
					sizeY = 0.4361744,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5280647,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbs",
						varName = "itemlockicon",
						posX = 0.2056179,
						posY = 0.2294305,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3157895,
						sizeY = 0.3125,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hs",
						varName = "item_filter",
						posX = 0.5,
						posY = 0.5312501,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.8421053,
						sizeY = 0.8333333,
						image = "ty#hong",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb",
					varName = "money_icon",
					posX = 0.3330723,
					posY = 0.1656177,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1670455,
					sizeY = 0.2088069,
					image = "tb#tb_tongqian.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "moneylockicon",
						posX = 0.6295284,
						posY = 0.3189422,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6053097,
						sizeY = 0.6345931,
						image = "tb#suo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "money_count",
					posX = 0.7489184,
					posY = 0.1621381,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6584754,
					sizeY = 0.3007356,
					text = "999999",
					color = "FF634624",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFFFF6AB",
					fontOutlineSize = 2,
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
