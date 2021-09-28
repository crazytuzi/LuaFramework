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
			sizeX = 0.0703125,
			sizeY = 0.1652778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wp1",
				varName = "refer_bg1",
				posX = 0.5,
				posY = 0.5924366,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9420554,
				sizeY = 0.6974789,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "gt1",
					varName = "refer_btn1",
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
					name = "tg1",
					varName = "refer_icon1",
					posX = 0.4994338,
					posY = 0.5194727,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8184823,
					sizeY = 0.8206159,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "as1",
					varName = "refer_count1",
					posX = 0.5,
					posY = -0.1427684,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.42107,
					sizeY = 0.7016174,
					text = "10/10",
					fontSize = 18,
					hTextAlign = 1,
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
