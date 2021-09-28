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
			etype = "Image",
			name = "wpk",
			posX = 0.3165175,
			posY = 0.4815163,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1247104,
			sizeY = 0.1777406,
			image = "djk#kcheng",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wp",
				posX = 0.5,
				posY = 0.5312501,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8512452,
				sizeY = 0.8423778,
				image = "items#items_zhongjishengxingshi.png",
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
