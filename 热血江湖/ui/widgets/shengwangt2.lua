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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5623568,
			sizeY = 0.08596946,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9833561,
				sizeY = 0.8885585,
				image = "bg2#du",
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txd1",
					posX = 0.06837634,
					posY = 0.4999995,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.08318689,
					sizeY = 1.070594,
					image = "zdte#bossd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx2",
						varName = "icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.9090917,
						sizeY = 0.9090908,
						image = "tx#songbaotongzi",
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
						sizeX = 1.030769,
						sizeY = 1.030769,
						image = "zdte#bossk",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc3",
					varName = "name",
					posX = 0.3759781,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5,
					sizeY = 1.161917,
					text = "送宝童子",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "csan",
				varName = "transBtn",
				posX = 0.4666443,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1959264,
				sizeY = 0.9693363,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "scz",
				varName = "transLabel",
				posX = 0.5232916,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2380565,
				sizeY = 0.9186496,
				text = "寻路",
				color = "FF65944D",
				fontUnderlineEnable = true,
				vTextAlign = 1,
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
