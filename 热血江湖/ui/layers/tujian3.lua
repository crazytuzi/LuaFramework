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
				varName = "close",
				posX = 0.5000001,
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
				name = "suicong",
				varName = "UIRoot",
				posX = 0.5,
				posY = 0.4791665,
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
					etype = "Button",
					name = "gb",
					posX = 1.088999,
					posY = 1.074975,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "k2",
					varName = "recruit_grid",
					posX = 0.5817716,
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
						name = "haoyou2",
						varName = "descImg",
						posX = 0.5732423,
						posY = 0.5009058,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4837438,
						sizeY = 0.7948276,
						image = "tujian2#chengdi",
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "fwb",
							varName = "desc",
							posX = 0.5834404,
							posY = 0.5833738,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6933615,
							sizeY = 0.4504526,
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 2,
							lineSpace = 2,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian",
							posX = 0.5242329,
							posY = 0.2856472,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.814664,
							sizeY = 0.004338395,
							image = "b#xian",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dw",
						posX = 0.6475351,
						posY = 0.2211899,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.525236,
						sizeY = 0.3098359,
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
							varName = "scroll1",
							posX = 0.3808721,
							posY = 0.5527785,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7476483,
							sizeY = 0.5277801,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "scroll2",
							posX = 0.3808721,
							posY = 1.619442,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7476483,
							sizeY = 1.505553,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ct",
						varName = "img",
						posX = 0.2088662,
						posY = 0.4947894,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2768473,
						sizeY = 0.7534482,
						image = "tujian#zhongli",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "zy",
							varName = "word",
							posX = 0.5,
							posY = 0.03693652,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.846015,
							sizeY = 0.1768578,
							text = "箴言",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ckt",
							varName = "back",
							posX = 0.4430609,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.195729,
							sizeY = 1.052632,
							image = "tujian3#zi4",
						},
					},
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
