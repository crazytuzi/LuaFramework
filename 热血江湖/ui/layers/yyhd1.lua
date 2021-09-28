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
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					varName = "rootView",
					posX = 0.534425,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9770473,
					sizeY = 0.8940562,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g1",
						varName = "g1",
						posX = 0.1090611,
						posY = 0.4872172,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.05848525,
						sizeY = 0.09449378,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.089655,
					sizeY = 0.9827586,
					image = "czhddt2#czhddt2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.089655,
					sizeY = 0.9827586,
					image = "czhddt#czhddt",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.1065578,
					posY = 1.08352,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3635468,
					sizeY = 0.2310345,
					image = "czhd1#bt2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb1",
				varName = "ActivitiesList",
				posX = 0.1286708,
				posY = 0.5003824,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1948466,
				sizeY = 0.7791666,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "g2",
				varName = "g2",
				posX = 0.5766222,
				posY = 0.8213916,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6672938,
				sizeY = 0.08814137,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "ActivitiesList2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					horizontal = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "ls",
				varName = "RightView2",
				posX = 0.5760165,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7101563,
				sizeY = 0.6378398,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "ls2",
				varName = "RightView",
				posX = 0.5760165,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7101563,
				sizeY = 0.6378398,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.9305564,
				posY = 0.8716394,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0484375,
				sizeY = 0.0875,
				image = "czhd#gb",
				imageNormal = "czhd#gb",
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
	dk = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
