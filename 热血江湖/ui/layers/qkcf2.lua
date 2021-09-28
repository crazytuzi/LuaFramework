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
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
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
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5410988,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4888662,
				sizeY = 0.4450141,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.4443218,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 1.141356,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.6350562,
						posY = 0.402485,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8866382,
						sizeY = 0.7729053,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz",
						posX = 0.5,
						posY = 0.05691573,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8672091,
						sizeY = 0.25,
						text = "帮派宴席开启时间：9点~24点",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz2",
						varName = "desc",
						posX = 0.5,
						posY = 0.3108326,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8672091,
						sizeY = 0.25,
						text = "想用宴席大餐，可获得体力值",
						color = "FF65944D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tsf",
						posX = 0.1782834,
						posY = 0.3161389,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06053354,
						sizeY = 0.0892887,
						image = "tong#tsf",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "qx",
					varName = "start_btn",
					posX = 0.291361,
					posY = 0.07575828,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2776839,
					sizeY = 0.1847122,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.96,
						sizeY = 1.034483,
						text = "开启宴席",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB35F1D",
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
					name = "qx2",
					varName = "join_btn",
					posX = 0.7087678,
					posY = 0.07575838,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2776839,
					sizeY = 0.1847122,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.96,
						sizeY = 1.034483,
						text = "参与宴席",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xhd",
						varName = "add_dine_point",
						posX = 0.9100185,
						posY = 0.8743874,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1551724,
						sizeY = 0.4242424,
						image = "zdte#hd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9539871,
					posY = 0.922262,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1180404,
					sizeY = 0.2006357,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yxt",
					posX = 0.5,
					posY = 0.6082798,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6780701,
					sizeY = 0.5960491,
					image = "bp#bp_hhyxt.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.7694608,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.234375,
				sizeY = 0.07369614,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5113636,
					sizeY = 0.4807693,
					image = "biaoti#bpyx",
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
	dk = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
