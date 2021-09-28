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
			lockHV = true,
			sizeX = 0.0859375,
			sizeY = 0.1521169,
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
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9818182,
				sizeY = 0.9860838,
				image = "jzhm#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "skillIcon",
					posX = 0.5,
					posY = 0.4969541,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8117078,
					sizeY = 0.8010864,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selected",
				posX = 0.5103564,
				posY = 0.5104311,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.086533,
				sizeY = 1.091253,
				image = "djk#xz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cz",
				varName = "battling",
				posX = 0.3975407,
				posY = 0.7643395,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7,
				sizeY = 0.4382595,
				image = "zq#cz",
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
