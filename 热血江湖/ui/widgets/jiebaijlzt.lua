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
			sizeX = 0.1488288,
			sizeY = 0.3083334,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.4954955,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8766364,
				sizeY = 0.8468467,
				image = "jiebai#dk1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb1",
					varName = "name",
					posX = 0.5,
					posY = 0.9089044,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.9277065,
					sizeY = 0.25,
					text = "无话不谈",
					color = "FF1EE2FF",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					posX = 0.5,
					posY = 0.6912059,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9277065,
					sizeY = 0.25,
					text = "金兰值",
					color = "FFFFDEBE",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb3",
					varName = "need_value",
					posX = 0.5,
					posY = 0.5318459,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9277065,
					sizeY = 0.25,
					text = "55555",
					color = "FFFFDEBE",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb4",
					varName = "exp_addition",
					posX = 0.5,
					posY = 0.3194618,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9277065,
					sizeY = 0.25,
					text = "经验+5%",
					color = "FF1E5D26",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ydc",
					varName = "finish_icon",
					posX = 0.5000001,
					posY = 0.07517537,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6934611,
					sizeY = 0.3139806,
					image = "wdxh#ydc",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "cht",
					varName = "title_icon",
					posX = 0.5,
					posY = 0.9089262,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 2.726054,
					sizeY = 0.6053869,
					image = "ch/gandanxiangzhao",
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
