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
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
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
					sizeX = 1,
					sizeY = 0.9485363,
					image = "jiebai#dk3",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xt3",
					posX = 0.5058762,
					posY = 0.4980718,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.2502648,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xt1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.232454,
						sizeY = 0.5999753,
						image = "jiebai#t1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xwb2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4469763,
							sizeY = 0.6666912,
							text = "消耗：",
							color = "FFFC4718",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xwb3",
							varName = "need",
							posX = 0.8083999,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4469763,
							sizeY = 0.6666912,
							text = "300",
							color = "FFFC4718",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xt4",
							varName = "levelCan",
							posX = 0.5,
							posY = 0.5019175,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1125081,
							sizeY = 0.5448921,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "xsuo",
								posX = 0.7197425,
								posY = 0.2921742,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.5843511,
								sizeY = 0.5843512,
								image = "tb#suo",
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xt2",
						posX = 0.5,
						posY = 0.1378697,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.232454,
						sizeY = 0.5999753,
						image = "jiebai#t1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xt6",
							varName = "levelCan2",
							posX = 0.5,
							posY = 0.5019175,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1125081,
							sizeY = 0.5448921,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "xsuo3",
								posX = 0.7197425,
								posY = 0.2921742,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.5843511,
								sizeY = 0.5843512,
								image = "tb#suo",
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xwb4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4469763,
							sizeY = 0.6666912,
							text = "拥有：",
							color = "FF5BDCA6",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xwb5",
							varName = "got",
							posX = 0.8849117,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.5153871,
							text = "3456456",
							color = "FF5BDCA6",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jy2",
					varName = "origin",
					posX = 0.4980443,
					posY = 0.6366839,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1655589,
					text = "不求同生，但求同死",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sj3",
					varName = "close",
					posX = 0.2924916,
					posY = 0.2113316,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.268895,
					sizeY = 0.1003033,
					image = "jiebai#an2",
					imageNormal = "jiebai#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "qx",
						varName = "btn_label3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9625977,
						sizeY = 1.028664,
						text = "取消",
						color = "FF514D7F",
						fontSize = 22,
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
					etype = "Button",
					name = "sj4",
					varName = "confirm",
					posX = 0.7015546,
					posY = 0.2113316,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.268895,
					sizeY = 0.1003033,
					image = "jiebai#an1",
					imageNormal = "jiebai#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "qd",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9625977,
						sizeY = 1.028664,
						text = "确定",
						color = "FF914200",
						fontSize = 22,
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
					etype = "Image",
					name = "shuruk",
					posX = 0.5,
					posY = 0.8080156,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5636024,
					sizeY = 0.1655566,
					image = "jiebai#k1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "EditBox",
					name = "jy",
					sizeXAB = 275.5469,
					sizeYAB = 73.87837,
					posXAB = 255,
					posYAB = 419.0373,
					varName = "msg",
					posX = 0.5,
					posY = 0.8080168,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.540288,
					sizeY = 0.1424574,
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bt1",
					posX = 0.5,
					posY = 0.9986017,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8333334,
					sizeY = 0.06363288,
					image = "jiebai#top",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "bt",
						posX = 0.5056257,
						posY = 0.5453801,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6042012,
						sizeY = 1.179905,
						text = "金兰寄语修改",
						color = "FFFFF337",
						hTextAlign = 1,
						vTextAlign = 1,
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
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
