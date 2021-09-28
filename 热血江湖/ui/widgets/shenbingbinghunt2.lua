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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6813368,
			sizeY = 0.15,
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
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jndt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.092592,
					image = "b#tzt",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "tz",
					varName = "skill_move",
					posX = 0.06183673,
					posY = 0.4907406,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08869024,
					sizeY = 0.7678282,
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnd",
					posX = 0.09485809,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1146643,
					sizeY = 0.9259259,
					image = "sbjx#q",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnd2",
						varName = "skill_lv_icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.168675,
						sizeY = 1.060976,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "t",
						varName = "skill_icon",
						posX = 0.5,
						posY = 0.49,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.716994,
						sizeY = 0.7257386,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "skill_name",
					posX = 0.2541095,
					posY = 0.7591256,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.155516,
					sizeY = 0.5555555,
					text = "技能名字",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF1A4841",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "skill_lv",
					posX = 0.4363579,
					posY = 0.7591257,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2208128,
					sizeY = 0.4986942,
					text = "等级",
					color = "FF65944D",
					fontSize = 24,
					fontOutlineColor = "FF1A4841",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z6",
					varName = "skill_desc",
					posX = 0.4834608,
					posY = 0.336253,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6169048,
					sizeY = 0.5555555,
					text = "技能简单描述",
					color = "FF966856",
					fontOutlineColor = "FF1A4841",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "redPoint1",
					posX = 0.01572799,
					posY = 0.8577472,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.028877,
					sizeY = 0.2592593,
					image = "zdte#hd",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z7",
					varName = "des2",
					posX = 0.7439018,
					posY = 0.7591257,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6524064,
					sizeY = 0.5555555,
					text = "条件要求写在这里",
					color = "FFC93034",
					fontOutlineColor = "FF1A4841",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sjan",
				varName = "sj_btn",
				posX = 0.8812065,
				posY = 0.4630378,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1753322,
				sizeY = 0.537037,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz",
					posX = 0.5065312,
					posY = 0.5344119,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8336015,
					sizeY = 1.108241,
					text = "升 级",
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
				name = "max",
				varName = "max",
				posX = 0.8880765,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1593833,
				sizeY = 1.175926,
				image = "sui#max",
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
