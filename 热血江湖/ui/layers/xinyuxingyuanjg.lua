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
					image = "xyxybj#xyxybj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dw",
						posX = 0.4968795,
						posY = 0.5497685,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3664062,
						sizeY = 0.4416668,
						image = "xyxy#bqd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9827704,
					posY = 0.8288265,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0729064,
					sizeY = 0.1258621,
					image = "xyxy#gb",
					imageNormal = "xyxy#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ggk",
					varName = "notice_info",
					posX = 0.5,
					posY = 0.3571562,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7204753,
					sizeY = 0.3821411,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "msz",
						varName = "des",
						posX = 0.5034853,
						posY = 0.4159958,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9735613,
						sizeY = 0.9367601,
						text = "标签描述",
						fontOutlineEnable = true,
						fontOutlineColor = "FF6895B0",
						fontOutlineSize = 2,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fx",
					varName = "share_btn",
					posX = 0.495074,
					posY = 0.0627878,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1763547,
					sizeY = 0.1724138,
					image = "xyxy#fx",
					imageNormal = "xyxy#fx",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bq",
					varName = "result_pic",
					posX = 0.5,
					posY = 0.6254359,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2699507,
					sizeY = 0.1275862,
					image = "xyxy#nuannan1",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz1",
					varName = "result_des",
					posX = 0.5,
					posY = 0.7597178,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "你的心语星愿",
					color = "FFF2FED0",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF73A8BA",
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
