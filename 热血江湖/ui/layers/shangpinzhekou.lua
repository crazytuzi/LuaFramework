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
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.4673683,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.78125,
				sizeY = 0.7777778,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02057244,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05421687,
						sizeY = 0.3755943,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9442027,
						posY = 0.1851488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.5,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "da",
					posX = 0.5,
					posY = 0.4376625,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9099975,
					sizeY = 0.7755116,
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
					etype = "Scroll",
					name = "lb",
					varName = "listScroll",
					posX = 0.5000002,
					posY = 0.4376614,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9035137,
					sizeY = 0.7576823,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8415899,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7867187,
				sizeY = 0.2347222,
				image = "xstm#sp",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "sysj",
					varName = "time",
					posX = 0.5050834,
					posY = 0.1442325,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4458836,
					sizeY = 0.2971444,
					text = "剩余时间",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.8634598,
				posY = 0.8032944,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
	diguang14 = {
		diguang14 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang13 = {
		diguang13 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang15 = {
		diguang15 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx6 = {
		bx6 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	c_bx6 = {
		{0,"diguang14", -1, 0},
		{0,"diguang13", -1, 0},
		{0,"diguang15", -1, 0},
		{0,"bx6", -1, 0},
		{2,"qianlz5", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
