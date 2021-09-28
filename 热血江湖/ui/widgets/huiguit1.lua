--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "fk1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2203125,
			sizeY = 0.5402778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fs1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "huigui#d1",
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
					name = "fgx",
					posX = 0.5,
					posY = 0.8,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9154725,
					sizeY = 0.005246314,
					image = "huigui#fgx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "biaoti",
				varName = "title",
				posX = 0.5,
				posY = 0.8891339,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8373078,
				sizeY = 0.1520988,
				text = "每日登陆送大礼",
				color = "FFFFDB8E",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "desa",
				posX = 0.4929177,
				posY = 0.3182377,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8546434,
				sizeY = 0.1583064,
				text = "具体描述任务",
				color = "FFF8B981",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "plcs2",
				varName = "btn",
				posX = 0.5,
				posY = 0.1313836,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5141845,
				sizeY = 0.1413882,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys4",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9120977,
					sizeY = 1.156784,
					text = "领 取",
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
		{
			prop = {
				etype = "Image",
				name = "shu",
				varName = "index",
				posX = 0.1070282,
				posY = 0.9029342,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2198582,
				sizeY = 0.1902314,
				image = "huigui#1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jdd",
				posX = 0.5,
				posY = 0.4537274,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8865248,
				sizeY = 0.04627249,
				image = "huigui#jdd",
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jgt",
					varName = "process",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "huigui#jdt",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk1",
				varName = "award1",
				posX = 0.1928691,
				posY = 0.6361803,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2836879,
				sizeY = 0.2056555,
				image = "huigui#f",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb1",
					varName = "propBg1",
					posX = 0.5,
					posY = 0.4875,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.025,
					sizeY = 1.025,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "prop1",
						posX = 0.499749,
						posY = 0.5219063,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7492539,
						sizeY = 0.7552788,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl1",
						varName = "propNum1",
						posX = 0.5247005,
						posY = 0.247353,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn1",
						varName = "propBtn1",
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
					name = "suo1",
					varName = "lock1",
					posX = 0.1956176,
					posY = 0.2321186,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3414635,
					sizeY = 0.3414634,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk2",
				varName = "award2",
				posX = 0.4973327,
				posY = 0.6361802,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2836879,
				sizeY = 0.2056555,
				image = "huigui#f",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb2",
					varName = "propBg2",
					posX = 0.5,
					posY = 0.4875,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.025,
					sizeY = 1.025,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "prop2",
						posX = 0.499749,
						posY = 0.5219063,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7492539,
						sizeY = 0.7552788,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "propNum2",
						posX = 0.5247005,
						posY = 0.247353,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn2",
						varName = "propBtn2",
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
					name = "suo2",
					varName = "lock2",
					posX = 0.1956176,
					posY = 0.2321186,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3414635,
					sizeY = 0.3414634,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk3",
				varName = "award3",
				posX = 0.8017963,
				posY = 0.6361802,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2836879,
				sizeY = 0.2056555,
				image = "huigui#f",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb3",
					varName = "propBg3",
					posX = 0.5,
					posY = 0.4875,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.025,
					sizeY = 1.025,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "prop3",
						posX = 0.499749,
						posY = 0.5219063,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7492539,
						sizeY = 0.7552788,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl3",
						varName = "propNum3",
						posX = 0.5247005,
						posY = 0.247353,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn3",
						varName = "propBtn3",
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
					name = "suo3",
					varName = "lock3",
					posX = 0.1956176,
					posY = 0.2321186,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3414635,
					sizeY = 0.3414634,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ywc",
				varName = "finish",
				posX = 0.5,
				posY = 0.4897172,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.570922,
				sizeY = 0.2467866,
				image = "huigui#ywc",
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
