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
			sizeX = 0.2554688,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sjzb",
				varName = "icon",
				posX = 0.1523233,
				posY = 0.5002264,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2018348,
				sizeY = 0.7499999,
				image = "bs#sjzb",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "sjzbms",
				varName = "desc",
				posX = 0.6523355,
				posY = 0.5002261,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.764067,
				sizeY = 0.6933144,
				text = "描述资讯哈哈哈",
				color = "FF8F61AC",
				fontSize = 18,
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
