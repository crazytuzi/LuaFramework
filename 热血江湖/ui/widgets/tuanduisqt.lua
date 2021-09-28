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
			name = "zdt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4921875,
			sizeY = 0.13,
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
				sizeX = 0.9905134,
				sizeY = 0.9722222,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zyb",
					varName = "zhiye",
					posX = 0.357825,
					posY = 0.2805196,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06410016,
					sizeY = 0.4395604,
					image = "zy#jianke",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name_label",
					posX = 0.3268981,
					posY = 0.6857284,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2800736,
					sizeY = 0.4839197,
					text = "我是一个大棒槌",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "talk_btn",
					posX = 0.6309412,
					posY = 0.4774217,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.197108,
					sizeY = 0.6373627,
					image = "chu1#an4",
					imageNormal = "chu1#an4",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "j3",
						varName = "cancelLabel",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "拒 绝",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF936D51",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "invite_btn",
					posX = 0.8626724,
					posY = 0.4774218,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.197108,
					sizeY = 0.6373627,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dj4",
						varName = "okLabel",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "同 意",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF008000",
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
					name = "txd",
					varName = "iconType",
					posX = 0.1096493,
					posY = 0.4560583,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1796706,
					sizeY = 0.989011,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "level_label",
					posX = 0.2790002,
					posY = 0.2470374,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1814135,
					sizeY = 0.4839197,
					text = "Lv.55",
					color = "FF966856",
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
