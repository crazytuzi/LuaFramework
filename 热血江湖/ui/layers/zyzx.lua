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
				posY = 0.4708331,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.443985,
				sizeY = 0.8472222,
				image = "zyzxbj#zyzxbj",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					varName = "kk1",
					posX = 0.5,
					posY = 0.4913747,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 0.9601052,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g1",
						varName = "imagebg",
						posX = 0.2002285,
						posY = 0.547822,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3184612,
						sizeY = 0.333261,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.4,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "getAllAnnex",
						posX = 0.5035192,
						posY = 0.04311721,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3061759,
						sizeY = 0.1126926,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "qw",
							posX = 0.5,
							posY = 0.5454545,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9253865,
							sizeY = 0.921809,
							text = "立即前往",
							fontSize = 24,
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
						name = "fwb",
						varName = "desc",
						posX = 0.5456737,
						posY = 0.8857704,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8713469,
						sizeY = 0.1704668,
						text = "西这里",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sycs",
						posX = 0.6947343,
						posY = 0.9939975,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.260852,
						sizeY = 0.07665017,
						text = "剩余次数：",
						color = "FF70FF88",
						fontSize = 22,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sycs2",
						varName = "lefttime",
						posX = 0.8901033,
						posY = 0.9939975,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.272076,
						sizeY = 0.07665017,
						text = "0",
						color = "FF70FF88",
						fontSize = 22,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sycs3",
						posX = 0.3041207,
						posY = 0.9939975,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.388241,
						sizeY = 0.07665017,
						text = "规则说明：",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9635146,
					posY = 0.9442112,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1178953,
					sizeY = 0.1245902,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "descbtn",
					posX = 1.053376,
					posY = 0.08035488,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1073375,
					sizeY = 0.1081967,
					image = "tong#bz",
					imageNormal = "tong#bz",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.05553943,
					posY = 0.8126034,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1073375,
					sizeY = 0.404918,
					image = "zyzx#top",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
