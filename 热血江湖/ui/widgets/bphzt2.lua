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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7320312,
			sizeY = 0.1388889,
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
				varName = "globle_btn",
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
				posX = 0.2937238,
				posY = 0.6619403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2209167,
				sizeY = 0.5047162,
				text = "名字",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz3",
				varName = "title_str",
				posX = 0.4633176,
				posY = 0.5119404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1251222,
				sizeY = 0.5652387,
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
				etype = "Image",
				name = "txk",
				varName = "roleHeadBg",
				posX = 0.06820177,
				posY = 0.429702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1063618,
				sizeY = 0.8,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8278491,
					posY = 0.2300532,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3430232,
					sizeY = 0.4375,
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
				posX = 0.1029795,
				posY = 0.2128254,
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
				etype = "RichText",
				name = "wza",
				varName = "desc",
				posX = 0.774963,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3878363,
				sizeY = 0.7539679,
				text = "副本挑战次数：99次",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz4",
				varName = "power",
				posX = 0.2563557,
				posY = 0.2719403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2422285,
				sizeY = 0.5047162,
				text = "战力：123456",
				color = "FFC93034",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "job_icon",
				posX = 0.1558428,
				posY = 0.6197894,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04802562,
				sizeY = 0.45,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "anniu",
				posX = 0.9144901,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1629239,
				sizeY = 0.5790544,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.118305,
					sizeY = 1.51723,
					text = "领取",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.118305,
					sizeY = 1.51723,
					text = "已领取",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
