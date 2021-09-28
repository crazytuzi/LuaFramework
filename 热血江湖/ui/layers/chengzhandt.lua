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
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9566502,
					sizeY = 1.02931,
					image = "chengzhanbj#chengzhanbj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					posX = 0.5,
					posY = 0.4991326,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.9688949,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g2",
						varName = "abc",
						posX = 0.4001755,
						posY = 0.4485191,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.445542,
						sizeY = 0.6729627,
						image = "chengzhan#zikuang",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "ScrollView",
							name = "cjdt",
							varName = "scroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9875121,
							sizeY = 0.9695007,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "beib",
						posX = 0.7383968,
						posY = 0.4485191,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2122702,
						sizeY = 0.6729627,
						image = "chengzhan#zikuang",
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
							name = "lb1",
							varName = "scrollList",
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.7862928,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1617188,
				sizeY = 0.1625,
				image = "chengzhan#cz",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "Close",
				posX = 0.7589543,
				posY = 0.7690282,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04140625,
				sizeY = 0.07083333,
				image = "rydt#gb",
				imageNormal = "rydt#gb",
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
	yuanquan = {
		dian2 = {
			scale = {{0, {1.2, 1.2, 1}}, {200, {1,1,1}}, {500, {1.2, 1.2, 1}}, {700, {1.2, 1.2, 1}}, },
		},
	},
	jt = {
		dian = {
			move = {{0, {48.32199,51.73396,0}}, {200, {48.32199, 47, 0}}, {500, {48.32199,51.73396,0}}, {700, {48.32199,51.73396,0}}, },
		},
	},
	c_dakai = {
		{0,"yuanquan", -1, 0},
		{0,"jt", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
