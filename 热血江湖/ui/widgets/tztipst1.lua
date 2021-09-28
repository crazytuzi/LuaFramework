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
			name = "jd2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3203381,
			sizeY = 0.08333334,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bba2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9799021,
				sizeY = 1,
				image = "ty#hw",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z3",
					varName = "title",
					posX = 0.3905974,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4896204,
					sizeY = 0.794755,
					text = "全身强化",
					color = "FFFFCB40",
					fontSize = 26,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z6",
					varName = "awardValue",
					posX = 0.6107196,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4896204,
					sizeY = 0.794755,
					text = "+30",
					color = "FFFFCB40",
					fontSize = 26,
					fontOutlineEnable = true,
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
