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
			name = "container",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2375012,
			sizeY = 0.3092152,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.4715083,
				posY = 0.4167593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.764688,
				sizeY = 1.663114,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.54,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t1",
				varName = "t1",
				posX = 0.06578919,
				posY = 0.9865367,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t2",
				varName = "t2",
				posX = 0.06578919,
				posY = 0.5813323,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t3",
				varName = "t3",
				posX = 0.06578919,
				posY = 0.1761279,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t3",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t4",
				varName = "t4",
				posX = 0.903225,
				posY = 0.9865368,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t4",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t5",
				varName = "t5",
				posX = 0.903225,
				posY = 0.5813324,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt5",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t5",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t6",
				varName = "t6",
				posX = 0.9032251,
				posY = 0.1761279,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723656,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt6",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t6",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btnClose",
				varName = "btnClose",
				posX = 1.30279,
				posY = 1.117591,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2203936,
				sizeY = 0.341366,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				imagePressed = "chu1#gb",
				imageDisable = "chu1#gb",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "t7",
				varName = "t7",
				posX = 0.9065097,
				posY = -0.2018103,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "textt7",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1612875,
					sizeY = 0.5965043,
					text = "t7",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "rkz",
				varName = "vedt",
				posX = 0.06907406,
				posY = -0.2018104,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5723655,
				sizeY = 0.2964494,
				image = "b#srk",
			},
			children = {
			{
				prop = {
					etype = "EditBox",
					name = "srk",
					sizeXAB = 174,
					sizeYAB = 65.99999,
					posXAB = 86.99999,
					posYAB = 33,
					varName = "e1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					color = "FF966856",
					fontSize = 26,
					vTextAlign = 1,
					phColor = "FF966856",
					phFontSize = 26,
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
