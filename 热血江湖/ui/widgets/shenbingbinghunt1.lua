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
				etype = "Button",
				name = "dj",
				varName = "globel_btn",
				posX = 0.4586054,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6803853,
				sizeY = 1,
			},
		},
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.697022,
						sizeY = 0.7055229,
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
					posY = 0.7128289,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.155516,
					sizeY = 0.4986942,
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
					posY = 0.7128289,
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
					posX = 0.5012117,
					posY = 0.29301,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6524064,
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
