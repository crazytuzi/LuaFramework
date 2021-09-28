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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2554688,
			sizeY = 0.09027778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "djan",
				varName = "select_btn",
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
				name = "dw1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.8307691,
				image = "b#ff1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xzt2",
					posX = 0.08250624,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09361541,
					sizeY = 0.5555556,
					image = "chu1#gxd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selected_img",
				posX = 0.4999999,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.8307691,
				image = "b#ff2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xzt",
					posX = 0.08250624,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09361541,
					sizeY = 0.5555556,
					image = "chu1#gxd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj",
						posX = 0.6000001,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.266667,
						sizeY = 1.133333,
						image = "chu1#dj",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				posX = 0.2239712,
				posY = 0.4773118,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1223241,
				sizeY = 0.7272727,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "buff",
					varName = "icon",
					posX = 0.4993889,
					posY = 0.5163771,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9000003,
					sizeY = 0.7615384,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "des",
				posX = 0.6705374,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7288595,
				sizeY = 1,
				text = "buff描述时间",
				color = "FF7F5845",
				fontSize = 18,
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
