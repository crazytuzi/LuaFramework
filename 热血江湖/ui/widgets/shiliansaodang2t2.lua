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
			sizeX = 0.1171875,
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9666666,
				sizeY = 0.4909091,
				image = "b#tqd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tq",
					varName = "icon",
					posX = 0.1626876,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3793104,
					sizeY = 2.037037,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "suo",
						posX = 0.6872017,
						posY = 0.375209,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4375,
						sizeY = 0.4375,
						image = "tb#suo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					posX = 0.2329443,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5891753,
					sizeY = 1.825916,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "value",
					posX = 0.5599946,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7199892,
					sizeY = 2.121744,
					text = "x0",
					color = "FF65944D",
					hTextAlign = 2,
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
