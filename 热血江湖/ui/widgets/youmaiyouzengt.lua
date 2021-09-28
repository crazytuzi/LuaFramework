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
					name = "mb2",
					posX = 0.4481241,
					posY = 0.2973056,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1608833,
					sizeY = 0.2568808,
					image = "zeng#db",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mb1",
					posX = 0.1252456,
					posY = 0.2973056,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1608833,
					sizeY = 0.2568808,
					image = "zeng#db",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "gm",
						posX = 0.5391591,
						posY = 1.426779,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8235294,
						sizeY = 1.607142,
						image = "zeng#gm",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "buyItemBg",
					posX = 0.2654712,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1419558,
					sizeY = 0.8256882,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "buyItemBtn",
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
						varName = "buyItemIcon",
						posX = 0.5,
						posY = 0.5275919,
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
						varName = "buyItemSuo",
						posX = 0.1951712,
						posY = 0.218144,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3111112,
						sizeY = 0.3111112,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz",
						varName = "buyItemCount",
						posX = 0.503096,
						posY = 0.1977054,
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
					varName = "buyBtn",
					posX = 0.8270637,
					posY = 0.4724771,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2287066,
					sizeY = 0.5045872,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
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
						text = "购 买",
						fontSize = 24,
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
					varName = "getItemBg",
					posX = 0.57253,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1419558,
					sizeY = 0.8256882,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "getItemBtn",
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
						varName = "getItemIcon",
						posX = 0.5,
						posY = 0.5275919,
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
						varName = "getItemSuo",
						posX = 0.1951712,
						posY = 0.218144,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3111112,
						sizeY = 0.3111112,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz2",
						varName = "getItemCount",
						posX = 0.503096,
						posY = 0.1977054,
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
					etype = "Image",
					name = "gm2",
					posX = 0.482379,
					posY = 0.5228574,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07886435,
					sizeY = 0.7431194,
					image = "zeng#zeng",
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
