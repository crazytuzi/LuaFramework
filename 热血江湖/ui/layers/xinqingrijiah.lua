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
				varName = "btn",
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
			sizeX = 0.7,
			sizeY = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.45,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.85,
				sizeY = 0.8,
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
					name = "tsbj",
					varName = "background",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.122636,
					sizeY = 1.391369,
					image = "ptbj2#ptbj2",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tsbt",
						varName = "title",
						posX = 0.5011696,
						posY = 0.8690475,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.294737,
						sizeY = 0.09625668,
						image = "ptbj#xzah",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk",
						varName = "fujin",
						posX = 0.5040859,
						posY = 0.509988,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8582393,
						sizeY = 0.6420081,
						image = "ptbj#dk",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sqxx",
					posX = 0.504587,
					posY = 0.5155097,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9005679,
					sizeY = 0.7825954,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbt",
						varName = "scroll",
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
						name = "wu",
						varName = "noneGifts",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.5190469,
						sizeY = 0.6323045,
						image = "ptbj#dw",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tswb",
							varName = "noneText",
							posX = 0.536517,
							posY = 0.2974762,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9322962,
							sizeY = 0.4814137,
							text = "您暂时还没有收到礼物",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "sure_btn",
					posX = 0.5,
					posY = 0.01679049,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1861421,
					sizeY = 0.1462415,
					image = "ptbj#zs",
					imageNormal = "ptbj#zs",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "sureText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.048375,
						sizeY = 1.203417,
						text = "确 定",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFEE07C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.8977595,
				posY = 0.8364428,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09263393,
				sizeY = 0.1587302,
				image = "ptbj#gb2",
				imageNormal = "ptbj#gb2",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
