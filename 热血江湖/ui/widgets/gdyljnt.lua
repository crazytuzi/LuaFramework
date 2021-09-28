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
			name = "ad",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.04296875,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9764832,
				sizeY = 0.9764832,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnn",
					varName = "skillIcon",
					posX = 0.4069015,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7820271,
					sizeY = 0.9558109,
					image = "skilldao#dao_10zangdaoshi",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jm",
					varName = "arrow",
					posX = 0.5892013,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7820271,
					sizeY = 1.092355,
					image = "guidaoyuling1#jny",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jb",
					varName = "skillBtn",
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
					name = "jm2",
					varName = "last",
					posX = 0.5892013,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5958302,
					sizeY = 1.001326,
					image = "guidaoyuling1#jny2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "boom",
				posX = 0.400127,
				posY = 0.4726532,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.22,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "fangshe01",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2,
					sizeY = 2,
					image = "uieffect/fangsheguang001911.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "glow01",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2,
					sizeY = 2,
					image = "uieffect/guangyun0145.png",
					alpha = 0,
					blendFunc = 1,
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
	boom = {
		fangshe01 = {
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
			scale = {{0, {0, 0, 1}}, {100, {1.5, 1.5, 1}}, {400, {2, 2, 1}}, },
		},
		glow01 = {
			alpha = {{0, {0}}, {150, {0.7}}, {400, {0}}, },
			scale = {{0, {0.8, 0.8, 1}}, {500, {1.1, 1.1, 1}}, },
		},
	},
	c_boom = {
		{0,"boom", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
