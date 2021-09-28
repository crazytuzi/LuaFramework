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
			name = "ysjm",
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
					posY = 0.5955939,
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
					posY = 0.5937449,
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
				varName = "taskRoot",
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
					posY = 0.4345995,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.609676,
					sizeY = 0.3905886,
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
						posY = 0.9500167,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.006829,
						sizeY = 0.1374943,
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
						text = "鬼岛驭灵",
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
						posY = 0.4429314,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.010483,
						sizeY = 0.8749539,
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
							etype = "RichText",
							name = "text1",
							varName = "desc1",
							posX = 0.5018587,
							posY = 0.8359232,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.988883,
							sizeY = 0.2150774,
							text = "任务说明",
							color = "FFFFFE97",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text2",
							varName = "countdown",
							posX = 0.5129586,
							posY = 0.09530029,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9148112,
							sizeY = 0.1746349,
							text = "大范甘迪发",
							color = "FF65944D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text3",
							varName = "desc2",
							posX = 0.5018587,
							posY = 0.6176206,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.988883,
							sizeY = 0.2150774,
							text = "任务说明",
							color = "FFFFFE97",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text4",
							varName = "desc3",
							posX = 0.5055587,
							posY = 0.3993181,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.988883,
							sizeY = 0.2150774,
							text = "任务说明",
							color = "FFFFFE97",
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
