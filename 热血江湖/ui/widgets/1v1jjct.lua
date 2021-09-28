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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1445313,
			sizeY = 0.4319444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				posX = 0.4859464,
				posY = 0.6390712,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 0.7218578,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				posX = 0.5,
				posY = 0.5785337,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9539552,
				sizeY = 0.734867,
				image = "b#db5",
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
					name = "dt1",
					posX = 0.5396641,
					posY = 0.3476419,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.810282,
					sizeY = 0.06125746,
					image = "d2#fgt",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dt4",
						posX = 0.4,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9999999,
						image = "d2#fgt",
						flippedX = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt3",
					posX = 0.5,
					posY = 0.2270194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8245596,
					sizeY = 0.1356415,
					image = "b#pmd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				posX = 0.2305751,
				posY = 0.3773702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4185059,
				sizeY = 0.1542647,
				text = "排名：",
				color = "FFFC8067",
				fontOutlineEnable = true,
				fontOutlineColor = "FFFFF0D9",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "iconType",
				posX = 0.4949566,
				posY = 0.7042062,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7945943,
				sizeY = 0.3794213,
				image = "zdtx#txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt",
					varName = "icon",
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
					posX = 0.8037993,
					posY = 0.2559153,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2857143,
					sizeY = 0.3644068,
					image = "zdte#djd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dj",
						varName = "lvl",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.278116,
						sizeY = 1,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
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
				etype = "Label",
				name = "mz2",
				varName = "rank",
				posX = 0.7291517,
				posY = 0.3773702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5105248,
				sizeY = 0.1542647,
				text = "9999",
				color = "FFFC8067",
				fontOutlineEnable = true,
				fontOutlineColor = "FFFFF0D9",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "rm",
				varName = "name",
				posX = 0.5,
				posY = 0.4976501,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8701633,
				sizeY = 0.13909,
				text = "人名六七个字",
				color = "FF966856",
				fontOutlineColor = "FF14332E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tz",
				varName = "challenge",
				posX = 0.5,
				posY = 0.116921,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8108106,
				sizeY = 0.1829471,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tzz",
					posX = 0.5,
					posY = 0.5527272,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8538287,
					sizeY = 1.056949,
					text = "挑 战",
					fontSize = 24,
					fontOutlineEnable = true,
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
				etype = "Label",
				name = "rm2",
				posX = 0.2143591,
				posY = 0.2842293,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4185059,
				sizeY = 0.1542647,
				text = "战力：",
				color = "FF966856",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "rm3",
				varName = "power",
				posX = 0.764806,
				posY = 0.2842293,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6575093,
				sizeY = 0.1542647,
				text = "123123",
				color = "FFFFD97F",
				fontOutlineEnable = true,
				fontOutlineColor = "FF895F30",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "zhiyeImg",
				posX = 0.8118947,
				posY = 0.8450597,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2432432,
				sizeY = 0.1446946,
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
