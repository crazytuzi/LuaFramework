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
			name = "ltyy",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4,
			sizeY = 0.1208333,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "txk2",
				varName = "frame",
				posX = 0.8856062,
				posY = 0.4559245,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2189818,
				sizeY = 1.034483,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "txa2",
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
					name = "tx2",
					varName = "headIcon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "yyt",
				varName = "playBtn",
				posX = 0.4676242,
				posY = 0.5028791,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6999997,
				sizeY = 0.4475724,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yt",
				posX = 0.4763601,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6582031,
				sizeY = 0.7356324,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ydz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "lt#yuyin",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sts2",
					varName = "anim",
					posX = 0.8502405,
					posY = 0.5034732,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1008902,
					sizeY = 0.5937499,
					image = "lt#bf",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "redPoint",
					posX = -0.03,
					posY = 0.8744736,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04747774,
					sizeY = 0.25,
					image = "lt#hd",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sjz",
					varName = "msgSec",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5671099,
					sizeY = 0.6581978,
					text = "12",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "tx",
				posX = 0.4763601,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6582031,
				sizeY = 0.7356324,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "x",
					posX = 0.8776671,
					posY = 0.5161068,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09495549,
					sizeY = 0.5,
					image = "uieffect/011..png",
					alpha = 0,
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "x2",
					posX = 0.8509614,
					posY = 0.5161068,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09495549,
					sizeY = 0.5,
					image = "uieffect/022.png",
					alpha = 0,
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "x3",
					posX = 0.8212882,
					posY = 0.5317318,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.189911,
					sizeY = 1,
					image = "uieffect/033.png",
					alpha = 0,
					flippedX = true,
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
	x = {
		x = {
			alpha = {{0, {0}}, {100, {1}}, },
		},
		x2 = {
			alpha = {{0, {0}}, {500, {1}}, },
		},
		x3 = {
			alpha = {{0, {0}}, {1000, {1}}, },
		},
	},
	c_bofang = {
		{0,"x", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
