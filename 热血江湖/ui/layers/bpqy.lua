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
			name = "aaa",
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
				name = "bbb",
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
			hTextAlign = 1,
			vTextAlign = 1,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "y1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "p1",
					posX = 0.5000001,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "p11",
						posX = 0.02390517,
						posY = 0.2151546,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06206896,
						sizeY = 0.4086207,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "p12",
						posX = 0.9357706,
						posY = 0.1987753,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.182266,
						sizeY = 0.4413793,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "p13",
						posX = 0.4832516,
						posY = 0.4879313,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9359605,
						sizeY = 0.9586207,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a11",
						varName = "closeBtn",
						posX = 0.9652708,
						posY = 0.9320853,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06600985,
						sizeY = 0.1310345,
						image = "chu1#gb",
						imageNormal = "chu1#gb",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "p2",
					posX = 0.4832516,
					posY = 0.4445791,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8374383,
					sizeY = 0.7167435,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
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
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2600985,
					sizeY = 0.08965518,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ww",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5113637,
						sizeY = 0.4807692,
						image = "biaoti#zdlb",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.973624,
					posY = 0.1075652,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06009852,
					sizeY = 0.1137931,
					image = "tong#bz",
					imageNormal = "tong#bz",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "bt",
				posX = 0.486719,
				posY = 0.7740825,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929689,
				sizeY = 0.1323897,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "biaoti",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8374382,
					sizeY = 0.6294549,
					image = "b#btd",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "w1",
						posX = 0.09138976,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1413108,
						sizeY = 0.6284145,
						text = "排名",
						color = "FF8B4513",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w2",
						posX = 0.2575636,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1413108,
						sizeY = 0.6284145,
						text = "帮派名称",
						color = "FF8B4513",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w3",
						posX = 0.4857316,
						posY = 0.4999995,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1413108,
						sizeY = 0.6284145,
						text = "帮主名称",
						color = "FF8B4513",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w4",
						posX = 0.7138996,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1413108,
						sizeY = 0.6284145,
						text = "帮派气运",
						color = "FF8B4513",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a1",
						varName = "refreshBtn",
						posX = 0.9070095,
						posY = 0.4889625,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1656108,
						sizeY = 0.6988566,
						propagateToChildren = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sx",
							posX = 0.6362118,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5997457,
							sizeY = 0.833551,
							text = "刷新",
							color = "FF804000",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a2",
							posX = 0.2864494,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3125684,
							sizeY = 0.9777875,
							image = "te#sx",
							imageNormal = "te#sx",
							disableClick = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian",
						posX = 0.1605562,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.003529412,
						sizeY = 1,
						image = "b#shuxian",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian2",
						posX = 0.3716476,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.003529412,
						sizeY = 1,
						image = "b#shuxian",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian3",
						posX = 0.5998156,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.003529412,
						sizeY = 1,
						image = "b#shuxian",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian4",
						posX = 0.8203408,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.003529412,
						sizeY = 1,
						image = "b#shuxian",
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
