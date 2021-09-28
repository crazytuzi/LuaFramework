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
				name = "sss",
				varName = "closeBtn",
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
			sizeX = 0.7929688,
			sizeY = 0.8055556,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 1,
				image = "b#db1",
				scale9 = true,
				scale9Left = 0.47,
				scale9Right = 0.47,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zh",
					posX = 0.02391203,
					posY = 0.2151591,
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
					name = "yh",
					posX = 0.9357447,
					posY = 0.1987797,
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
					name = "bj",
					posX = 0.5,
					posY = 0.4896554,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9359605,
					sizeY = 0.9586207,
					image = "b#db3",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
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
						etype = "Label",
						name = "qhb",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "抢红包",
						color = "FF804000",
						fontSize = 30,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "w1",
					varName = "leftTimes",
					posX = 0.8506803,
					posY = 0.9179646,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2350818,
					sizeY = 0.1542626,
					text = "剩余次数：xx",
					color = "FF804000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					posX = 0.9544336,
					posY = 0.9182876,
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
				name = "db2",
				posX = 0.5000001,
				posY = 0.5501868,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.093596,
				sizeY = 0.9655172,
				scale9 = true,
				scale9Left = 0.47,
				scale9Right = 0.47,
				scale9Top = 0.47,
				scale9Bottom = 0.47,
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
				etype = "Button",
				name = "an",
				varName = "toSendBtn",
				posX = 0.7,
				posY = -0.008083798,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1714286,
				sizeY = 0.1137931,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "fhb",
					varName = "sendBtn",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "我要发红包",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF107661",
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
				name = "yjzb",
				varName = "refresh_btn",
				posX = 0.3,
				posY = -0.008083783,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1714286,
				sizeY = 0.1137931,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys2",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9120977,
					sizeY = 1.156784,
					text = "刷 新",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
