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
			etype = "Image",
			name = "lbdt1",
			varName = "memberBg",
			posX = 0.4851539,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.7671875,
			sizeY = 0.1181231,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "detail_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz1",
				varName = "name_label",
				posX = 0.1884378,
				posY = 0.5119403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1738133,
				sizeY = 0.7054787,
				text = "名字六个字啊",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz3",
				varName = "job_label",
				posX = 0.5819668,
				posY = 0.5119404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1251222,
				sizeY = 0.7054787,
				text = "帮主",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF302A14",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz5",
				varName = "old_contri",
				posX = 0.4438721,
				posY = 0.5119403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1781897,
				sizeY = 0.7054787,
				text = "666654",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF0E3B2F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz6",
				varName = "state",
				posX = 0.7198219,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1497242,
				sizeY = 0.7054787,
				text = "24小时前",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "roleHeadBg",
				posX = 0.05432768,
				posY = 0.449702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09638526,
				sizeY = 0.8933458,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon",
					posX = 0.4986762,
					posY = 0.7264316,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7794118,
					sizeY = 1.12931,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8056563,
					posY = 0.2563766,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3095851,
					sizeY = 0.394852,
					image = "zdte#djd2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "gender",
				posX = 0.02326812,
				posY = 0.7742578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03619572,
				sizeY = 0.45172,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz2",
				varName = "level_label",
				posX = 0.08367278,
				posY = 0.2256572,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05188559,
				sizeY = 0.4359249,
				text = "85",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lba2",
				varName = "kneel_btn",
				posX = 0.9012692,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1176471,
				sizeY = 0.6353768,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz6",
					varName = "btnDesc",
					posX = 0.5086558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401152,
					sizeY = 1.00501,
					text = "膜 拜",
					color = "FF914A15",
					fontSize = 24,
					fontOutlineColor = "FF1C7760",
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
				name = "zy",
				varName = "job_icon",
				posX = 0.3197352,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0426945,
				sizeY = 0.4929647,
				image = "zy#daoke",
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
