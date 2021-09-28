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
				name = "tt",
				varName = "title",
				posX = 0.5,
				posY = 0.1450796,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2046632,
				sizeY = 0.08607274,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jz1",
				posX = 0.3166791,
				posY = 0.4279296,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2570313,
				sizeY = 0.6299447,
				image = "jjt#jz",
				scale9 = true,
				scale9Top = 0.2,
				scale9Bottom = 0.75,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "xz3",
					varName = "arena_btn",
					posX = 0.493921,
					posY = 0.4604805,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8814588,
					sizeY = 0.9468107,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "fas",
						posX = 0.5,
						posY = 0.6623474,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.6753048,
						image = "jjt#jjc",
						imageNormal = "jjt#jjc",
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs",
					posX = 0.002336396,
					posY = 0.8059618,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1306991,
					sizeY = 0.2778022,
					image = "jjt#zs",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.4969605,
					posY = 0.2203971,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.81155,
					sizeY = 0.1278772,
					image = "jjt#dt",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "toa1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5243446,
						sizeY = 0.6551723,
						image = "jjt#bpjn",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jz2",
				posX = 0.6879429,
				posY = 0.4279296,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2570313,
				sizeY = 0.6299447,
				image = "jjt#jz",
				scale9 = true,
				scale9Top = 0.2,
				scale9Bottom = 0.75,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "xz4",
					varName = "colorhock_btn",
					posX = 0.493921,
					posY = 0.4604805,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8814588,
					sizeY = 0.9468107,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "fsax",
						posX = 0.5,
						posY = 0.6623474,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.6753048,
						image = "jjt#zxdc",
						imageNormal = "jjt#zxdc",
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = 0.002336396,
					posY = 0.8059618,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1306991,
					sizeY = 0.2778022,
					image = "jjt#zs",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.4969605,
					posY = 0.2203971,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.81155,
					sizeY = 0.1278772,
					image = "jjt#dt",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "toa2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.494382,
						sizeY = 0.6896551,
						image = "jjt#zcwg",
					},
				},
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "sad",
			posX = 0.5,
			posY = 0.9194159,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.1544992,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.9679385,
				posY = 0.6143321,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05234375,
				sizeY = 0.683211,
				image = "chu1#gb",
				layoutType = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
