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
			sizeX = 0.08203125,
			sizeY = 0.1458333,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "petRoot",
				posX = 0.5857142,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.151079,
				sizeY = 1,
				image = "dw#dw_txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dak",
					posX = 0.4625,
					posY = 0.4712229,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7166085,
					sizeY = 0.8335562,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tb",
						varName = "icon",
						posX = 0.4803783,
						posY = 0.5454763,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8582698,
						sizeY = 0.8493294,
						image = "tx#xiaoxiangf",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sk",
						posX = 0.4580873,
						posY = 0.5515568,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9368423,
						sizeY = 0.8749999,
						image = "cl#sck",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "kong",
				varName = "noPetRoot",
				posX = 0.5857145,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.151079,
				sizeY = 1,
				image = "dw#dw_txd2.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kt",
					posX = 0.4159518,
					posY = 0.4717633,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6209151,
					sizeY = 0.7954546,
					image = "dw#dw_kong.png",
					alpha = 0.7,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "noOpenRoot",
				posX = 0.5857143,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.151079,
				sizeY = 1,
				image = "dw#dw_suo.png",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wza",
					varName = "desc",
					posX = 0.4420834,
					posY = 0.2629861,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.068068,
					sizeY = 0.4577895,
					text = "50级开放",
					color = "FF804040",
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
