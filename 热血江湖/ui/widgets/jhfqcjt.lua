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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.8015625,
			sizeY = 0.1886029,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "rcht1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.88,
				scale9 = true,
				scale9Left = 0.1,
				scale9Right = 0.1,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wwcd",
					varName = "noFinish",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.1,
					image = "jh3#an",
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
					name = "ywcd",
					varName = "complete",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1,
					sizeY = 1.1,
					image = "jh3#liang",
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
					name = "icok",
					posX = 0.07569498,
					posY = 0.4734227,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0943332,
					sizeY = 0.8184572,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ico",
						varName = "task_icon",
						posX = 0.4976835,
						posY = 0.5379093,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwmc",
					varName = "task_name",
					posX = 0.2347022,
					posY = 0.7230291,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1958373,
					sizeY = 0.4602557,
					text = "任务名称",
					color = "FFBB1F1F",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk1",
					varName = "image1",
					posX = 0.2455702,
					posY = 0.2514948,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.04447684,
					sizeY = 0.3858916,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp1",
						varName = "icon1",
						posX = 0.495363,
						posY = 0.505856,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7918583,
						sizeY = 0.7705002,
						image = "ty#exp",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "lock1",
						posX = 0.3030844,
						posY = 0.3484074,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.5478463,
						sizeY = 0.5421396,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "tips1",
						varName = "tips1",
						posX = 0.4700288,
						posY = 0.4944787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8751135,
						sizeY = 0.8659979,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk2",
					varName = "image2",
					posX = 0.4302987,
					posY = 0.2514945,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04447684,
					sizeY = 0.3858916,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp2",
						varName = "icon2",
						posX = 0.495363,
						posY = 0.5492285,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7918583,
						sizeY = 0.7705001,
						image = "items#items_zhongjijinengshu.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo2",
						varName = "lock2",
						posX = 0.3030844,
						posY = 0.3484074,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.5478463,
						sizeY = 0.5421396,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "tips2",
						varName = "tips2",
						posX = 0.4700288,
						posY = 0.4944787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8751135,
						sizeY = 0.8659979,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk3",
					varName = "image3",
					posX = 0.6150272,
					posY = 0.2514947,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04447684,
					sizeY = 0.3858916,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp3",
						varName = "icon3",
						posX = 0.495363,
						posY = 0.5492285,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7918583,
						sizeY = 0.7705001,
						image = "items#items_zhongjijinengshu.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo3",
						varName = "lock3",
						posX = 0.3030844,
						posY = 0.3484074,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.5478463,
						sizeY = 0.5421396,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "tips3",
						varName = "tips3",
						posX = 0.4700288,
						posY = 0.4944787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8751135,
						sizeY = 0.8659979,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj2",
					varName = "rewardLabel",
					posX = 0.1816678,
					posY = 0.2514947,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0897685,
					sizeY = 0.4602557,
					text = "奖励：",
					color = "FFBB1F1F",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj3",
					varName = "count1",
					posX = 0.3296795,
					posY = 0.2514948,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1095003,
					sizeY = 0.4602557,
					text = "×30000",
					color = "FFBB1F1F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj4",
					varName = "count2",
					posX = 0.5089879,
					posY = 0.2514946,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1044375,
					sizeY = 0.4602557,
					text = "×30000",
					color = "FFBB1F1F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj5",
					varName = "count3",
					posX = 0.7096503,
					posY = 0.2514946,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1331708,
					sizeY = 0.4602557,
					text = "×30000",
					color = "FFBB1F1F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "qw",
					varName = "go_btn",
					posX = 0.8789726,
					posY = 0.4864227,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2923063,
					sizeY = 0.879311,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aas",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5435031,
						sizeY = 0.6090794,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disableClick = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "az",
						varName = "goLabel",
						posX = 0.5,
						posY = 0.5285507,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.953678,
						sizeY = 0.8150085,
						text = "立即前往",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "tj",
					varName = "condition",
					posX = 0.5816908,
					posY = 0.7230292,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4438057,
					sizeY = 0.4602557,
					text = "完成条件:(0/3)",
					color = "FFBB1F1F",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "lq",
					varName = "take_btn",
					posX = 0.8789726,
					posY = 0.4864227,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2923063,
					sizeY = 0.879311,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aas2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5435031,
						sizeY = 0.6090794,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						disableClick = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "az2",
						varName = "goLabel2",
						posX = 0.5,
						posY = 0.5285507,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.953678,
						sizeY = 0.8150085,
						text = "领取奖励",
						fontSize = 24,
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
					etype = "Image",
					name = "fdz",
					varName = "notCanJump",
					posX = 0.8778836,
					posY = 0.5249466,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1725146,
					sizeY = 0.3765728,
					image = "rw#fdz",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "cjds",
					varName = "achPoint",
					posX = 0.8430061,
					posY = 0.1365266,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2753758,
					sizeY = 0.7435396,
					text = "成就点数：100",
					color = "FFBB1F1F",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ywc",
					varName = "finish_icon",
					posX = 0.8746287,
					posY = 0.5334152,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1569201,
					sizeY = 0.8033554,
					image = "huigui#ywc",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tswb",
					varName = "not_reward_text",
					posX = 0.5118251,
					posY = 0.2514948,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.5763499,
					sizeY = 0.7181786,
					text = "奖励提示",
					color = "FFBB1F1F",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
