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
			name = "njfwzya",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.223764,
			sizeY = 0.06814918,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "top3",
				posX = 0.444226,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6494007,
				sizeY = 0.7336845,
				image = "chu1#top2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "taz3",
					varName = "desc",
					posX = 0.4964413,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7293959,
					sizeY = 0.9861619,
					text = "符语属性",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xiaji",
				varName = "nextLab",
				posX = 0.863702,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4354587,
				sizeY = 0.6917841,
				text = "下级",
				color = "FF966856",
				hTextAlign = 1,
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
