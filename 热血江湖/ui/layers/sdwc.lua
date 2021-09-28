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
				varName = "close_btn",
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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.78,
				sizeY = 0.65,
				scale9 = true,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.242572,
					sizeY = 1,
					image = "d#diban",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "item_scroll",
					posX = 0.5,
					posY = 0.485859,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9215167,
					sizeY = 0.87726,
					alphaCascade = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sg",
					posX = 0.5,
					posY = 1.0436,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.1,
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sg2",
					posX = 0.5,
					posY = -0.0436072,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.1,
					alpha = 0,
					flippedY = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "dh",
				posX = 0.4981864,
				posY = 0.8317473,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3120678,
				sizeY = 0.3719787,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dg",
					posX = 0.5,
					posY = 0.4812512,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3978805,
					sizeY = 0.5454776,
					image = "top#top_dg2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "max",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7557418,
					sizeY = 0.4286689,
					image = "top#top_sdwc.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi",
					sizeXAB = 210.9079,
					sizeYAB = 65.61704,
					posXAB = 278.5873,
					posYAB = 162.1824,
					posX = 0.7925372,
					posY = 0.6179128,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					angle = 0,
					angleVariance = 360,
					duration = 999999,
					emitterType = 0,
					finishColorBlue = 0,
					finishColorGreen = 0,
					finishColorRed = 0,
					middleColorAlpha = 1,
					middleColorBlue = 1,
					middleColorGreen = 1,
					middleColorRed = 1,
					startParticleSize = 30,
					maxParticles = 10,
					particleLifespan = 2,
					particleLifespanVariance = 0.5,
					particleLifeMiddle = 0.3,
					sourcePositionVariancex = 140,
					sourcePositionVariancey = 35,
					textureFileName = "uieffect/xxing.png",
					useMiddleFrame = true,
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
	max = {
		max = {
			move = {{0, {175.7566, 400, 0}}, {150, {175.7566,131.2341,0}}, {200, {175.7566, 145, 0}}, {250, {175.7566,131.2341,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	dg = {
		dg = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {3000, {180}}, },
		},
	},
	sg = {
		sg = {
			alpha = {{0, {0}}, {300, {0.8}}, },
		},
		sg2 = {
			alpha = {{0, {0}}, {300, {0.8}}, },
		},
	},
	wk4 = {
		wk4 = {
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"max", 1, 200},
		{0,"dg", -1, 350},
		{0,"sg", 1, 200},
		{0,"wk4", 1, 0},
		{2,"lizi", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
