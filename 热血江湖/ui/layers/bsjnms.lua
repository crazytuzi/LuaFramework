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
			sizeX = 0.6,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.4970857,
				posY = 0.4699568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6869993,
				sizeY = 0.790368,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.4999999,
					posY = 0.4970755,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.002429,
					sizeY = 1.525004,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hehua",
						posX = 0.6392078,
						posY = 0.27417,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9415821,
						sizeY = 0.5319804,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dw",
						posX = 0.5,
						posY = 0.3983798,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8996481,
						sizeY = 0.6979172,
						image = "b#d5",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "bsjnsm",
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
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "item_count",
					posX = 0.5843276,
					posY = 1.039708,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5815343,
					sizeY = 0.2783221,
					text = "变身说明写在这里",
					color = "FF966856",
					fontSize = 22,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "d2",
					varName = "boss",
					posX = 0.1709456,
					posY = 1.075096,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3335595,
					sizeY = 0.3782666,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "btd2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8352692,
						sizeY = 0.9136311,
						image = "zdtx#txd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "btx",
						varName = "bosstx",
						posX = 0.4999999,
						posY = 0.5232279,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4894537,
						sizeY = 0.666947,
						image = "tx#qiansanye",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.7981811,
				posY = 0.9944479,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07697517,
				sizeY = 0.1326341,
				image = "baishi#x",
				imageNormal = "baishi#x",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
