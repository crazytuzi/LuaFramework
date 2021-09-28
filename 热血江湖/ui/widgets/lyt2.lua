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
			name = "qm1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.15625,
			sizeY = 0.1027778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jndt",
				varName = "shillBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9864863,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk",
					posX = 0.195428,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3902296,
					sizeY = 0.9589041,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnt",
					varName = "skillIron",
					posX = 0.1954282,
					posY = 0.4999996,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2749999,
					sizeY = 0.7534246,
					image = "skillelse#blx_3qingyunhuifeng",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "js1",
				varName = "attrLabel1",
				posX = 0.752567,
				posY = 0.2982178,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8024787,
				sizeY = 0.500003,
				text = "技能等级+1",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc1",
				varName = "nameLabel1",
				posX = 0.7325985,
				posY = 0.7074115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7625419,
				sizeY = 0.5227517,
				text = "技能名字在这",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
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
