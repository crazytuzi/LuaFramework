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
				sizeX = 0.53125,
				sizeY = 0.5208333,
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
					etype = "Grid",
					name = "pt3",
					posX = 0.5,
					posY = 0.4486107,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8337122,
					sizeY = 0.8424296,
					scale9 = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "db5",
						posX = 0.7184848,
						posY = 0.6547717,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6201178,
						sizeY = 0.7858127,
						image = "b#d5",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.44,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "hua",
							posX = 0.4772758,
							posY = 0.1983718,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.416544,
							sizeY = 1.115824,
							image = "hua1#hua1",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "sfw",
							varName = "desc",
							posX = 0.5069035,
							posY = 0.5048858,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9528599,
							sizeY = 0.8918923,
							text = "劫镖任务描述",
							color = "FF966856",
							fontSize = 22,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "yjzb",
						varName = "rob_escort_btn",
						posX = 0.894678,
						posY = 0.1260178,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2790176,
						sizeY = 0.1899268,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys2",
							varName = "rob_escort_label",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "我要劫镖",
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
						name = "plcs",
						varName = "escort_store",
						posX = 0.5433962,
						posY = 0.1260178,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2790176,
						sizeY = 0.1899268,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys3",
							varName = "no_desc",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "赏金商店",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF347468",
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
					varName = "close",
					posX = 0.9620771,
					posY = 0.9307036,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0933908,
					sizeY = 0.1619537,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "djs",
					varName = "rob_count",
					posX = 0.2243333,
					posY = 0.137023,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5263078,
					sizeY = 0.1668702,
					text = "劫镖次数：4/4",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3882353,
					sizeY = 0.1386667,
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
						sizeX = 0.3181818,
						sizeY = 0.4615383,
						image = "biaoti#jiebiao",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jbt",
					posX = 0.2137063,
					posY = 0.5745475,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3764706,
					sizeY = 0.6826667,
					image = "bp#jiebiao",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
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
