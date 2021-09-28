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
					varName = "roots",
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
						posX = 0.495685,
						posY = 0.9427887,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.9864505,
						sizeY = 0.1052683,
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
						text = "今日目标",
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
							name = "t1",
							varName = "desc",
							posX = 0.5092633,
							posY = 0.1179228,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.988883,
							sizeY = 0.2447871,
							text = "击杀敌方可获得积分",
							color = "FFFFFE97",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "t5",
							varName = "score",
							posX = 0.1851893,
							posY = 0.9248517,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3407266,
							sizeY = 0.1334634,
							text = "当前积分：",
							color = "FFFFFE97",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "t8",
							varName = "score_text",
							posX = 0.6740758,
							posY = 0.9248514,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6444303,
							sizeY = 0.1521478,
							text = "5",
							color = "FFFFFE97",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.494441,
							posY = 0.4378151,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9962912,
							sizeY = 0.8320221,
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
	{
		prop = {
			etype = "Grid",
			name = "jd2",
			posX = 0.5,
			posY = 0.2781415,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "exitPanel",
				posX = 0.3583881,
				posY = 0.4916768,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.8818808,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "t6",
					posX = 0.5,
					posY = 0.7075458,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "任务已完成，可以离开战场了",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "exit_btn",
					posX = 0.5,
					posY = 0.2735823,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2669271,
					sizeY = 0.3653807,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "t7",
					posX = 0.5,
					posY = 0.2735823,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2669271,
					sizeY = 0.3653807,
					text = "离开",
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
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
			etype = "Grid",
			name = "xjs",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "change_btn",
				posX = 0.8724257,
				posY = 0.2969036,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0515625,
				sizeY = 0.2111111,
				image = "mitanfengyun#wz",
				imageNormal = "mitanfengyun#wz",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
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
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
	gy55 = {
	},
	gy56 = {
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_dakai3 = {
	},
	c_dakai4 = {
	},
	c_dakai5 = {
	},
	c_dakai6 = {
	},
	c_dakai7 = {
	},
	c_dakai8 = {
	},
	c_dakai9 = {
	},
	c_dakai10 = {
	},
	c_dakai11 = {
	},
	c_dakai12 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
