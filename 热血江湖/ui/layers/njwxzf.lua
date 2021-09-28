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
				varName = "closeBtn",
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
				etype = "Button",
				name = "gb",
				posX = 0.5002095,
				posY = 0.4993667,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3677244,
				sizeY = 0.6948139,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3707401,
				sizeY = 0.6882592,
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
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9833558,
					sizeY = 1.000533,
					image = "b#db5",
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
						name = "dw1",
						posX = 0.5,
						posY = 0.5251696,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8921396,
						sizeY = 0.658445,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.5499609,
						posY = 0.2985451,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.067184,
						sizeY = 0.558681,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian",
						posX = 0.5,
						posY = 0.1053338,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.88,
						sizeY = 0.01008449,
						image = "b#xian2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top3",
						posX = 0.5,
						posY = 0.9200906,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6021658,
						sizeY = 0.06454076,
						image = "chu1#top3",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7293959,
							sizeY = 0.9861619,
							text = "武勋祝福",
							color = "FFF1E9D7",
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
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
				etype = "Label",
				name = "sm1",
				posX = 0.5,
				posY = 0.2647026,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.229804,
				sizeY = 0.08478788,
				text = "参加势力战获得武勋",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sm2",
				posX = 0.5,
				posY = 0.2023194,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.3270521,
				sizeY = 0.09312899,
				text = "提升量不超过当前祝福值上限的15%",
				color = "FFC93034",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "Scroll",
				posX = 0.5,
				posY = 0.5166322,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.316861,
				sizeY = 0.438156,
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
