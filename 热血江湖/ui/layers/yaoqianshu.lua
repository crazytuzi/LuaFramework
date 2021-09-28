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
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.261084,
					sizeY = 1.241379,
					image = "yqsbj#yqsbj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9719509,
					posY = 0.956205,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0729064,
					sizeY = 0.1258621,
					image = "tml#gb",
					imageNormal = "tml#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
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
						name = "db",
						posX = 0.7754099,
						posY = 0.5137712,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3940887,
						sizeY = 0.8,
						image = "yqs#db",
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.4987495,
							posY = 0.3881132,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6913635,
							sizeY = 0.71004,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dw",
							posX = 0.4725424,
							posY = 0.04169935,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8324999,
							sizeY = 0.0387931,
							image = "yqs#dw",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "cs",
							varName = "haveShakeTimes",
							posX = 0.5,
							posY = 0.7969285,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "已摇x次",
							color = "FF6B25DF",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFFDE5A",
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
						name = "bz",
						varName = "helpBtn",
						posX = 0.9622947,
						posY = 0.2073812,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06009852,
						sizeY = 0.1137931,
						image = "tong#bz",
						imageNormal = "tong#bz",
						disablePressScale = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sj",
						varName = "actTime",
						posX = 0.3116399,
						posY = 0.9738923,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.610818,
						sizeY = 0.1353284,
						text = "活动时间：",
						color = "FFFEDC6B",
						fontOutlineEnable = true,
						fontOutlineColor = "FF2F0C0B",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Sprite3D",
						name = "mx",
						varName = "model",
						posX = 0.2958977,
						posY = 0.2130739,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2980398,
						sizeY = 0.6345104,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sj2",
						varName = "CDLabel",
						posX = 0.2949187,
						posY = 0.07035693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3747509,
						sizeY = 0.1353284,
						text = "剩余次数：",
						color = "FF6B25DF",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFDE5A",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "plcs2",
						varName = "shakeBtn",
						posX = 0.2958977,
						posY = 0.1616042,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1940887,
						sizeY = 0.1362069,
						image = "yqs#an",
						imageNormal = "yqs#an",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
