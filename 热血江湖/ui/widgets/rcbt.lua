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
			name = "xjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.384375,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "item_btn",
				posX = 0.4999979,
				posY = 0.4999971,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9933699,
				sizeY = 0.9605715,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dtl",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt",
					posX = 0.1124284,
					posY = 0.5082114,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1808943,
					sizeY = 0.8090907,
					image = "rcb#dk",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon_img",
					posX = 0.1108573,
					posY = 0.5090909,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1411052,
					sizeY = 0.6311251,
					image = "rwt#zhimianduijue",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tj",
						varName = "groom_img",
						posX = -0.06217652,
						posY = 0.736222,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4033201,
						sizeY = 1.0083,
						image = "rcb#tuijian",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bt",
					varName = "name_txt",
					posX = 0.5149637,
					posY = 0.6958417,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.3614475,
					text = "参加个人竞技场",
					color = "FFC93034",
					fontSize = 24,
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "hy",
						varName = "act_txt",
						posX = 0.2580374,
						posY = -0.5816739,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5084136,
						sizeY = 1.079957,
						text = "5活跃/次",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "cjcs",
						varName = "num_txt",
						posX = 0.6765766,
						posY = -0.5816741,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4433119,
						sizeY = 0.9541997,
						text = "0/2",
						color = "FF634624",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "cjcs2",
						varName = "weekly_time",
						posX = 0.5697,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.5750844,
						sizeY = 0.9541997,
						text = "0/2",
						color = "FF65944D",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qw",
				varName = "go_btn",
				posX = 0.809246,
				posY = 0.4727273,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3313008,
				sizeY = 0.581818,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "qwz",
					varName = "goBtn_txt",
					posX = 0.5,
					posY = 0.5468745,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8268573,
					sizeY = 0.8111666,
					text = "前 往",
					fontSize = 24,
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
				etype = "Label",
				name = "sj",
				varName = "time_txt",
				posX = 0.807518,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4646803,
				sizeY = 0.4154294,
				text = "15:00:00~20:00:00",
				color = "FFC93034",
				hTextAlign = 1,
				vTextAlign = 1,
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
