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
			name = "ltwz",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7195312,
			sizeY = 0.2357103,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ltd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.96,
				sizeY = 0.95,
				image = "g#g_dhk.png",
				scale9 = true,
				scale9Left = 0.15,
				scale9Right = 0.15,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "ltnr",
					varName = "text",
					posX = 0.5117424,
					posY = 0.3286804,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9550051,
					sizeY = 0.553173,
					text = "文本长度需要自我调整，外框也要自我调整、",
					color = "FF83DECA",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "pd",
					posX = 0.1622855,
					posY = 0.8027859,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2350547,
					sizeY = 0.2711957,
					image = "lt#lt_d1.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "pdz",
						varName = "msgType",
						posX = 0.5149037,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8452902,
						sizeY = 0.9719283,
						text = "什么类型任务",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
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
