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
				varName = "close_btn",
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
				etype = "Grid",
				name = "ysjm2",
				posX = 0.5007801,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				fontOutlineColor = "FFA47848",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3984375,
					sizeY = 0.7202775,
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
						name = "wasd2",
						posX = 0.5,
						posY = 0.5334194,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.561002,
						sizeY = 0.9485363,
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
							name = "dw",
							posX = 0.5,
							posY = 0.536766,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9094649,
							sizeY = 0.7690991,
							image = "b#d2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.568341,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.399662,
						sizeY = 0.7065124,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "sj3",
						varName = "up_btn2",
						posX = 0.5,
						posY = 0.1323802,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3101604,
						sizeY = 0.1156962,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ff3",
							varName = "nextBtn",
							posX = 0.5,
							posY = 0.530303,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9625977,
							sizeY = 1.028664,
							text = "下一步",
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top2",
					posX = 0.5,
					posY = 0.8667846,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.20625,
					sizeY = 0.07222223,
					image = "chu1#top",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hy2",
						posX = 0.517013,
						posY = 0.5284417,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5113636,
						sizeY = 0.4807692,
						image = "biaoti#bphz",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb2",
					varName = "close_btn2",
					posX = 0.7863306,
					posY = 0.8229026,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05078125,
					sizeY = 0.0875,
					image = "baishi#x",
					imageNormal = "baishi#x",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
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
