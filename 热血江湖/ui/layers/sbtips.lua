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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "bgRoot",
				posX = 0.4539146,
				posY = 0.2477119,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3739489,
				sizeY = 0.3162983,
				image = "b#db5",
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
					name = "dw2",
					posX = 0.5000002,
					posY = 0.4756511,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9382885,
					sizeY = 0.5830544,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "skillName",
					posX = 0.5,
					posY = 0.8650372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "技能名字",
					color = "FFF1E9D7",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "skillLevel",
					posX = 0.8225187,
					posY = 0.8650372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2853454,
					sizeY = 0.25,
					text = "技能等级",
					color = "FF65944D",
					fontOutlineColor = "FFFCEBCF",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z3",
					varName = "skillDesc2",
					posX = 0.5052174,
					posY = 0.1124424,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9345663,
					sizeY = 0.2272621,
					text = "辅助介绍不同颜色",
					color = "FFC93034",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z6",
					varName = "skillDesc1",
					posX = 0.5012194,
					posY = 0.4631816,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9186528,
					sizeY = 0.5300117,
					text = "技能介绍",
					color = "FF966856",
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
