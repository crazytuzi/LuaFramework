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
			name = "txjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.075,
			sizeY = 0.1208333,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "tx",
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
					name = "dian2",
					posX = 0.5000154,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 0.3678162,
					image = "sjdt2#yq",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dian",
					posX = 0.5103474,
					posY = 0.5914623,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 0.3678162,
					image = "sjdt2#jiantou",
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
	yuanquan = {
		dian2 = {
			scale = {{0, {1.2, 1.2, 1}}, {200, {1,1,1}}, {500, {1.2, 1.2, 1}}, {700, {1.2, 1.2, 1}}, },
		},
	},
	jt = {
		dian = {
			moveP = {{0, {0.5103474,0.5914623,0}}, {200, {0.5103474, 0.53, 0}}, {500, {0.5103474,0.5914623,0}}, {700, {0.5103474,0.5914623,0}}, },
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
