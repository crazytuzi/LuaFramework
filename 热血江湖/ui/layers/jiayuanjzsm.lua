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
				sizeX = 0.625,
				sizeY = 0.625,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.689979,
					posY = 0.4955586,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5247399,
					sizeY = 0.7711112,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.7193422,
					posY = 0.3217388,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6225,
					sizeY = 0.6155556,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ds",
					posX = 0.2266993,
					posY = 0.4955586,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.33625,
					sizeY = 0.7711111,
					image = "jy#di",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						varName = "desc1",
						posX = 0.5,
						posY = 0.8452583,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8275891,
						sizeY = 0.293468,
						text = "钓鱼总精通7级",
						fontSize = 22,
						fontOutlineColor = "FFF9E0BF",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFD200FF",
						colorTR = "FFD200FF",
						colorBR = "FF280082",
						colorBL = "FF280082",
						useQuadColor = true,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "z2",
						varName = "desc2",
						posX = 0.5,
						posY = 0.5547544,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.827589,
						sizeY = 0.293468,
						text = "钓鱼总精通7级",
						color = "FF2A9079",
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "z3",
						varName = "desc3",
						posX = 0.5,
						posY = 0.327087,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.827589,
						sizeY = 0.293468,
						text = "钓鱼总精通7级",
						color = "FF2A9079",
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "z4",
						varName = "desc4",
						posX = 0.5,
						posY = 0.0965406,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.827589,
						sizeY = 0.293468,
						text = "钓鱼总精通7级",
						color = "FF2A9079",
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.9984095,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.33,
					sizeY = 0.1155556,
					image = "chu1#top",
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
						sizeX = 0.3068182,
						sizeY = 0.4807691,
						image = "biaoti#shuoming",
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scrollView1",
					posX = 0.689979,
					posY = 0.4955585,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5247399,
					sizeY = 0.7711112,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.9642393,
					posY = 0.9370661,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08125,
					sizeY = 0.14,
					image = "baishi#x",
					imageNormal = "baishi#x",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
