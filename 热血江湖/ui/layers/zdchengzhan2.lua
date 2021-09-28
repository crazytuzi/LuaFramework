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
			etype = "Button",
			name = "gb",
			varName = "close_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			disablePressScale = true,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zjd",
			posX = 0.7858183,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4265639,
			sizeY = 1,
			layoutType = 6,
			layoutTypeW = 6,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "renwu",
				varName = "taskRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "htj",
					posX = 0.4065935,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07875432,
					sizeY = 0.2527778,
					image = "lt#lt_an.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zzz",
					posX = 0.7151138,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5697724,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.714094,
					posY = 0.4697773,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5860787,
					sizeY = 0.9395548,
					image = "b#db2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hh",
						posX = 0.509362,
						posY = 0.1842378,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.40118,
						sizeY = 0.3358753,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "d2",
						posX = 0.5000001,
						posY = 0.4797769,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9047638,
						sizeY = 0.9135281,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll_schedule",
						posX = 0.5000002,
						posY = 0.4642802,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9047638,
						sizeY = 0.8825347,
						alphaCascade = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 0.9412684,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9813157,
						sizeY = 0.0783468,
						image = "phb#top4",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mc1",
							posX = 0.3,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6003223,
							sizeY = 1.259045,
							text = "名 字",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mc2",
							posX = 0.7,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6003223,
							sizeY = 1.259045,
							text = "战 力",
							color = "FF966856",
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
					etype = "Image",
					name = "btd",
					posX = 0.7140942,
					posY = 0.9645239,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5677335,
					sizeY = 0.06388889,
					image = "zd#cdd",
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zb",
						varName = "dungeon_title",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9011545,
						sizeY = 1,
						text = "城池内成员列表",
						color = "FFC4FCFF",
						fontSize = 24,
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
	ren = {
		renwu = {
			moveP = {{0, {0.5,0.5,0}}, {200, {1.2, 0.5, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	chu = {
		renwu = {
			moveP = {{0, {1.2, 0.5, 0}}, {300, {0.5,0.5,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ren", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
