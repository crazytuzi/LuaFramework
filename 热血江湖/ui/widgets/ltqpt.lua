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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.221875,
			sizeY = 0.5888889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btt",
				varName = "btn",
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
				etype = "Image",
				name = "dk",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "b#d4",
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
					name = "top",
					posX = 0.5,
					posY = 0.9156623,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9152533,
					sizeY = 0.08663843,
					image = "chu1#top2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "titleName",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7820632,
						sizeY = 1.289768,
						text = "气泡名字",
						color = "FFFF5E17",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFCE8CD",
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
					name = "db",
					posX = 0.5,
					posY = 0.6898218,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9026282,
					sizeY = 0.2835755,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz1",
					posX = 0.362554,
					posY = 0.473598,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5690283,
					sizeY = 0.1298043,
					text = "获得途径：",
					color = "FF8F6747",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					varName = "getText",
					posX = 0.6997375,
					posY = 0.473598,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5690283,
					sizeY = 0.1298043,
					text = "花钱买吧没毛病",
					color = "FFFF5E17",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz3",
					varName = "timedesc",
					posX = 0.362554,
					posY = 0.3979325,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5690283,
					sizeY = 0.1298043,
					text = "获得途径：",
					color = "FF8F6747",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz4",
					varName = "time",
					posX = 0.6997374,
					posY = 0.3979325,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5690283,
					sizeY = 0.1298043,
					text = "255天",
					color = "FF2586FF",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wz5",
					varName = "desc",
					posX = 0.5024493,
					posY = 0.2537625,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.848819,
					sizeY = 0.1898021,
					text = "描述 你看着写吧~",
					color = "FF8F6747",
					fontSize = 18,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pp",
				varName = "boxImg",
				posX = 0.5,
				posY = 0.6816045,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7916739,
				sizeY = 0.1326651,
				image = "ltk#ltd2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zs",
					varName = "downImg",
					posX = 0.8818236,
					posY = 0.5532563,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3324873,
					sizeY = 1.084444,
					image = "ltk#gugujif",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "my",
					posX = 0.4999883,
					posY = 0.4996891,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8328426,
					sizeY = 0.7839567,
					text = "热血江湖",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					varName = "upImg",
					posX = 0.8818236,
					posY = 0.4821456,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.3324873,
					sizeY = 1.084444,
					image = "ltk#xiongmaof",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "activateBtn",
				posX = 0.5,
				posY = 0.1161963,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5384121,
				sizeY = 0.1367925,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb1",
					varName = "actTxt",
					posX = 0.5000001,
					posY = 0.5602431,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9336678,
					sizeY = 0.9122967,
					text = "购 买",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
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
				name = "an2",
				varName = "useBtn",
				posX = 0.5,
				posY = 0.1161963,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5384121,
				sizeY = 0.1367925,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "useTxt",
					posX = 0.5,
					posY = 0.5602431,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9336678,
					sizeY = 0.9122967,
					text = "使 用",
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
				name = "syz",
				varName = "useingImg",
				posX = 0.507018,
				posY = 0.09499929,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.556338,
				sizeY = 0.1627358,
				image = "zq#syz",
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
	gy3 = {
	},
	gy2 = {
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
