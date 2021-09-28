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
			sizeX = 0.734375,
			sizeY = 0.7027778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "haoyou",
				varName = "ShouChong",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9451359,
				sizeY = 0.8937886,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "crossfr_scroll",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.988269,
					sizeY = 1.194011,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mhy",
					varName = "no_friends",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4007079,
					sizeY = 0.4731822,
					image = "ptbj#dw",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wbz",
						varName = "noFri_label",
						posX = 0.5,
						posY = 0.1547739,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.975935,
						sizeY = 0.3908244,
						text = "您还没有添加任何好友，赶快邀请好友一起闯荡江湖吧！",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "help_btn",
					posX = 0.8989274,
					posY = -0.02759433,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07653971,
					sizeY = 0.150357,
					image = "chu1#bz",
					imageNormal = "chu1#bz",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.007905138,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5308511,
				sizeY = 0.1185771,
				image = "kfhy#by",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an8",
				varName = "add_friend",
				posX = 0.7,
				posY = 0.05397243,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1521277,
				sizeY = 0.2035573,
				image = "kfhy#qydt",
				imageNormal = "kfhy#qydt",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an10",
				varName = "friends_apply",
				posX = 0.3,
				posY = 0.05397251,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1521277,
				sizeY = 0.2035573,
				image = "kfhy#hysq",
				imageNormal = "kfhy#hysq",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "crossFri_red",
					posX = 0.7872577,
					posY = 0.8424164,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1888112,
					sizeY = 0.2718447,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb",
				varName = "crossFri_cnt",
				posX = 0.5,
				posY = -0.01503597,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "当前好友数量2/5",
				color = "FFB6C5FF",
				fontOutlineEnable = true,
				fontOutlineColor = "FF7A5038",
				fontOutlineSize = 2,
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
