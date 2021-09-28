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
			etype = "Grid",
			name = "jd1",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "ss",
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
					etype = "Button",
					name = "zuo",
					varName = "openBtn",
					posX = 0.0580231,
					posY = 0.6955919,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1026786,
					sizeY = 0.08518519,
					image = "zdte#suojin",
					imageNormal = "zdte#suojin",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "you",
					varName = "closeBtn",
					posX = 0.6595172,
					posY = 0.693743,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1026786,
					sizeY = 0.08518519,
					image = "zdte#suojin",
					imageNormal = "zdte#suojin",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp",
					posX = 1.101689,
					posY = 0.8327866,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "dyjd",
				varName = "teamRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gg",
					varName = "leftRoots",
					posX = 0.3089054,
					posY = 0.4825689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.609676,
					sizeY = 0.5124117,
					image = "b#rwd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5030074,
						posY = 0.9500167,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.001065,
						sizeY = 0.1068279,
						image = "bpzd#db",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "mz",
						varName = "titleName",
						posX = 0.4946368,
						posY = 0.938356,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8666124,
						sizeY = 0.2500002,
						text = "任务目标",
						color = "FFD7B886",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "taskBtn",
						posX = 0.4993735,
						posY = 0.4149427,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.010483,
						sizeY = 0.8189768,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dt",
						posX = 0.4991188,
						posY = 0.4697696,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9869037,
						sizeY = 0.8239337,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "text1",
							varName = "title",
							posX = 0.4981498,
							posY = 0.8492271,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.988883,
							sizeY = 0.3148557,
							text = "第一阶段第第一阶段第一阶段第一阶段一阶段第一阶段第一阶段第一阶段第一阶段",
							color = "FFFFFE97",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text2",
							varName = "task1",
							posX = 0.4981498,
							posY = 0.5843294,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9888831,
							sizeY = 0.1334634,
							text = "111",
							color = "FFD7B886",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text3",
							varName = "task2",
							posX = 0.4981498,
							posY = 0.4327279,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9888831,
							sizeY = 0.1334634,
							text = "xxxx",
							color = "FFD7B886",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "text4",
							varName = "task3",
							posX = 0.4981498,
							posY = 0.3880323,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9888831,
							sizeY = 0.1334634,
							text = "xxxx",
							color = "FFD7B886",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "text5",
							varName = "score",
							posX = 0.4981498,
							posY = 0.2811264,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9888831,
							sizeY = 0.1334634,
							text = "我的积分：",
							color = "FFFFFE97",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "text6",
							varName = "tips",
							posX = 0.4981498,
							posY = 0.0628576,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9888831,
							sizeY = 0.2419397,
							text = "xxxxxxxxx",
							color = "FFD7B886",
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "reverseBt",
				posX = 2.271271,
				posY = 0.908601,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1361607,
				sizeY = 0.1333333,
				image = "zdsjzh#fuwei",
				imageNormal = "zdsjzh#fuwei",
			},
		},
		},
	},
	{
		prop = {
			etype = "Label",
			name = "djs",
			varName = "time",
			posX = 0.7964886,
			posY = 0.8631863,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1237282,
			sizeY = 0.05844354,
			text = "00：00",
			color = "FFC93034",
			fontSize = 22,
			hTextAlign = 1,
			vTextAlign = 1,
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	chu = {
		dyjd = {
			moveP = {{0, {-0.3, 0.5, 0}}, {300, {0.5, 0.5, 0}}, },
		},
	},
	ru = {
		dyjd = {
			moveP = {{0, {0.5, 0.5, 0}}, {200, {-0.3, 0.5, 0}}, },
		},
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
