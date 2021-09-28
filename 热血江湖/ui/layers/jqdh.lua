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
			etype = "Grid",
			name = "jd",
			posX = 0.4992199,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "dt",
				posX = 0.461293,
				posY = 0.5243638,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2976562,
				sizeY = 0.3055556,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					posX = 0,
					posY = 0.5,
					anchorX = 0,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "zhiyin#dhd",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txd",
					posX = 0.02347752,
					posY = 0.2965777,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2122627,
					sizeY = 0.5251432,
					image = "zd#zd_bosstxd.png",
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txt",
						varName = "plotheadicon",
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
						name = "txk",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.112903,
						sizeY = 1.112903,
						image = "zd#zd_bosstxd2.png",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "dt2",
				posX = 0.461293,
				posY = 0.5243638,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2976562,
				sizeY = 0.3055556,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt3",
					posX = 0,
					posY = 0.5,
					anchorX = 0,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "zhiyin#dhd",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txd2",
					posX = -0.02396899,
					posY = 0.2964355,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3858268,
					sizeY = 0.7662336,
					image = "zdtx#txd",
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txt2",
						varName = "plotheadicon2",
						posX = 0.4918735,
						posY = 0.6913644,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.11017,
						image = "jstx2#daonan",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "plottext",
				posX = 0.4639084,
				posY = 0.5201366,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2219368,
				sizeY = 0.1902118,
				text = "一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六",
				color = "FF634624",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.4590667,
				posY = 0.5596748,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3533576,
				sizeY = 0.3444693,
				disablePressScale = true,
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
	txd2 = {
		txd2 = {
			scale = {{0, {0, 0, 1}}, {200, {1.2, 1.2, 1}}, {300, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	txt3 = {
		txt3 = {
			scale = {{0, {0, 1, 1}}, {250, {1.2, 1, 1}}, {350, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	txd = {
		txd = {
			scale = {{0, {0, 0, 1}}, {200, {1.2, 1.2, 1}}, {300, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	tp1 = {
		tp1 = {
			scale = {{0, {0, 1, 1}}, {250, {1.2, 1, 1}}, {350, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
		fwb = {
			alpha = {{200, {1}}, },
		},
	},
	c_dakai = {
		{0,"txd2", 1, 0},
		{0,"txt3", 1, 100},
		{0,"txd", 1, 0},
		{0,"tp1", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
