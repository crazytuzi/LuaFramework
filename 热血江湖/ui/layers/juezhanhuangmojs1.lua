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
			scale9Left = 0.3,
			scale9Right = 0.3,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
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
				name = "db1",
				posX = 0.5,
				posY = 0.4347217,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.859375,
				sizeY = 0.875,
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
					posY = 0.5380954,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.05,
					sizeY = 1.046032,
					image = "jzhmbj#jzhmbj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 0.9302512,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.361039,
						sizeY = 0.08042487,
						image = "jzhm#jf",
					},
				},
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
						name = "dw",
						posX = 0.5,
						posY = 0.7242852,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6371338,
						sizeY = 0.3206349,
						image = "jzhm#d1",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb1",
							varName = "scoreScroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9102586,
							sizeY = 0.6523629,
							horizontal = true,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "fgx",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.943078,
							sizeY = 0.06930693,
							image = "jzhm#fgx",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk",
						posX = 0.5,
						posY = 0.237761,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8703874,
						sizeY = 0.1822961,
						image = "d#tyd",
						alpha = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "rewardScroll",
							posX = 0.5,
							posY = 1.466949,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6776351,
							sizeY = 0.7087042,
							horizontal = true,
							showScrollBar = false,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "qd",
							varName = "closeBtn",
							posX = 0.5,
							posY = 0.4414339,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1441365,
							sizeY = 0.5050218,
							image = "jiebai#an1",
							imageNormal = "jiebai#an1",
							disablePressScale = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "qdz",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.884392,
								sizeY = 1.226486,
								text = "离 开",
								color = "FFA34116",
								fontSize = 22,
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
							etype = "Label",
							name = "pm15",
							varName = "rewardType",
							posX = 0.5,
							posY = 2.054603,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2753481,
							sizeY = 0.4957687,
							text = "积分奖励",
							fontSize = 26,
							fontOutlineEnable = true,
							fontOutlineColor = "FF562812",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
							colorTL = "FFFFFDD1",
							colorTR = "FFFFFDD1",
							colorBR = "FFF0A618",
							colorBL = "FFF0A618",
							useQuadColor = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "djs",
						varName = "countDown",
						posX = 0.6912583,
						posY = 0.2217853,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2419139,
						sizeY = 0.1788799,
						text = "5秒",
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
				name = "bz2",
				varName = "ShareBtn",
				posX = 0.9094115,
				posY = 0.2339576,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#fx",
				imageNormal = "tong#fx",
				disablePressScale = true,
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
