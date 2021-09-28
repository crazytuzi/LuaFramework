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
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "d2",
				varName = "boss",
				posX = 0.2927108,
				posY = 0.9802468,
				anchorX = 0,
				anchorY = 1,
				sizeX = 0.315416,
				sizeY = 0.3561389,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xd",
					varName = "xd",
					posX = 0.4806519,
					posY = 0.6052059,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.418594,
					sizeY = 0.1403947,
					image = "zd#zd_zi.png",
				},
			},
			{
				prop = {
					etype = "LoadingBar",
					name = "bx",
					varName = "bossxt",
					posX = 0.4676689,
					posY = 0.6009825,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4582242,
					sizeY = 0.1559941,
					percent = 50,
					barDirection = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bossx",
					posX = 0.4657905,
					posY = 0.6052059,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4582242,
					sizeY = 0.1559941,
					image = "zd#bossxk",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "nsd",
					varName = "neishangNode",
					posX = 0.5049638,
					posY = 0.5077346,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4582242,
					sizeY = 0.09359644,
					image = "zd#nsd2",
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "nst",
						varName = "neishangBar",
						posX = 0.5270271,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8864865,
						sizeY = 0.4166666,
						image = "zd#nst3",
						barDirection = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "btd",
					varName = "bossHead",
					posX = 0.7792488,
					posY = 0.6316072,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.296219,
					sizeY = 0.7487715,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "btx",
						varName = "bosstx",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bmz",
					varName = "bossName",
					posX = 0.2243137,
					posY = 0.7590114,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9299108,
					sizeY = 0.3507861,
					text = "九个字九个字九个字",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bmz2",
					varName = "bossxl",
					posX = 0.5864337,
					posY = 0.6048089,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1958397,
					sizeY = 0.2593438,
					text = "x123",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jnt",
					varName = "shifa",
					posX = 0.3447414,
					posY = 0.08767096,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4581647,
					sizeY = 0.2561658,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "btb",
					varName = "skull",
					posX = 0.685426,
					posY = 0.382287,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.06686629,
					sizeY = 0.2047746,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.6928754,
					posY = 0.4299003,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.08467501,
					sizeY = 0.2729896,
					image = "zdte#djd2",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gwdj",
					varName = "bosslevel",
					posX = 0.692324,
					posY = 0.4372583,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1811859,
					sizeY = 0.2823068,
					text = "60",
					color = "FFFFFF00",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "buff2",
				varName = "buffbar2",
				posX = 0.4731136,
				posY = 0.6752787,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1848523,
				sizeY = 0.2634574,
				showScrollBar = false,
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
