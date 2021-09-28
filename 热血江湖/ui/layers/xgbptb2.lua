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
			sizeX = 1,
			sizeY = 1,
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
				sizeX = 0.5492796,
				sizeY = 0.5880812,
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
					sizeX = 1.01,
					sizeY = 1.02,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d9",
					posX = 0.6164278,
					posY = 0.4882104,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6957934,
					sizeY = 0.8488283,
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
						varName = "item_scroll",
						posX = 0.5,
						posY = 0.4930542,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9811999,
						sizeY = 0.9694449,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d10",
					posX = 0.1457126,
					posY = 0.4882104,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2314575,
					sizeY = 0.8488283,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.5000001,
						posY = 0.5291677,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.4027777,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "cdd",
							posX = 0.4569845,
							posY = 1.08586,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.01381577,
							image = "b#xian",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cdd3",
							posX = 0.4569846,
							posY = -0.08400822,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.01381577,
							image = "b#xian",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz",
						posX = 0.4508394,
						posY = 0.8874673,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9165752,
						sizeY = 0.1361101,
						text = "帮派图示",
						color = "FF966856",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a1",
						varName = "sure_btn",
						posX = 0.4508394,
						posY = 0.1461947,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.755841,
						sizeY = 0.1613758,
						image = "chu1#an3",
						imageNormal = "chu1#an3",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz1",
							varName = "cancel_word",
							posX = 0.5,
							posY = 0.5517241,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8313715,
							sizeY = 0.8905213,
							text = "保 存",
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
						name = "mjd",
						posX = 0.4569845,
						posY = 0.5291677,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6698103,
						sizeY = 0.2893635,
						image = "bp#bp_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tx",
							varName = "faction_icon",
							posX = 0.4908257,
							posY = 0.5096154,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.9633027,
							sizeY = 1.009615,
							image = "bptb2#101",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tx3",
							varName = "faction_bg",
							posX = 0.5,
							posY = 0.4999055,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9266055,
							sizeY = 1.009615,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.007307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3754918,
					sizeY = 0.12281,
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
						sizeX = 0.5151516,
						sizeY = 0.4807691,
						image = "biaoti#xgtb",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tc",
				varName = "close_btn",
				posX = 0.7638631,
				posY = 0.7535491,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				imagePressed = "chu1#gb",
				imageDisable = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
