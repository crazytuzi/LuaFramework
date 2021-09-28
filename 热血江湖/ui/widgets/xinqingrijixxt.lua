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
			sizeX = 0.5358379,
			sizeY = 0.08607165,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "qp",
				varName = "pop",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.048868,
				image = "ptbj#qp",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.5,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "ms1",
					varName = "des",
					posX = 0.383479,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6813676,
					sizeY = 0.7086524,
					text = "您送给了皮卡丘100个江湖大火箭",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rq",
					varName = "time",
					posX = 0.755457,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3740892,
					sizeY = 0.7086524,
					text = "时间",
					color = "FF966856",
					fontSize = 18,
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
