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
			lockHV = true,
			sizeX = 0.07812502,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
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
				name = "djk",
				varName = "weaponBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.95,
				sizeY = 0.9600002,
				image = "shen#sbd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sbt",
					varName = "icon",
					posX = 0.5081546,
					posY = 0.5490907,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7566569,
					sizeY = 0.7395833,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zbz",
				varName = "equip",
				posX = 0.4500983,
				posY = 0.7296365,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7799998,
				sizeY = 0.48,
				image = "shen#zb",
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
	jn6 = {
	},
	bj = {
	},
	c_hld = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
