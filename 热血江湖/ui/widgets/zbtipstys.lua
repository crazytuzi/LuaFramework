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
			name = "k2",
			varName = "node",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2554688,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "sx",
				varName = "desc",
				posX = 0.7812737,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4025645,
				sizeY = 1.527778,
				text = "三阶",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx2",
				varName = "name",
				posX = 0.4143023,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4025645,
				sizeY = 1.527778,
				text = "技能名称",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt",
				varName = "icon",
				posX = 0.133028,
				posY = 0.5277778,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1160138,
				sizeY = 1.043148,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnk",
				varName = "icon_bg",
				posX = 0.1360861,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1160138,
				sizeY = 1.043148,
				image = "yishu#fang",
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
