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
			sizeY = 0.15,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				varName = "root_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.009259,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "cdd",
					varName = "Whole",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item1_bg",
					posX = 0.5223833,
					posY = 0.4816886,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1340694,
					sizeY = 0.7798166,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "item1_btn",
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
						name = "wp",
						varName = "item1_icon",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "item1_suo",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3294118,
						sizeY = 0.3294118,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz",
						varName = "item1_count",
						posX = 0.5257913,
						posY = 0.2088165,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "lq",
					varName = "GetBtn",
					posX = 0.8649167,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1940063,
					sizeY = 0.5321102,
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
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8247252,
						sizeY = 1.143941,
						text = "领 取",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk2",
					varName = "item2_bg",
					posX = 0.6717144,
					posY = 0.4816886,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1340694,
					sizeY = 0.7798166,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "item2_btn",
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
						name = "wp2",
						varName = "item2_icon",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo2",
						varName = "item2_suo",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3294118,
						sizeY = 0.3294118,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz2",
						varName = "item2_count",
						posX = 0.5257913,
						posY = 0.2088165,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb2",
					varName = "count_info",
					posX = 0.2389781,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3929064,
					sizeY = 0.4334541,
					text = "购买",
					color = "FF966856",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ylq",
					varName = "got_icon",
					posX = 0.8747787,
					posY = 0.4816777,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.2124509,
					sizeY = 0.7339451,
					image = "gq#ylq",
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
