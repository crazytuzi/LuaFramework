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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1117188,
			sizeY = 0.1375,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jnk",
				varName = "skill_iconCont",
				posX = 0.5,
				posY = 0.530303,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6783214,
				sizeY = 0.8787879,
				image = "jn#jnbai",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "skill_btn",
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
				name = "jnt",
				varName = "skill_icon",
				posX = 0.5,
				posY = 0.530303,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4895103,
				sizeY = 0.7070705,
				image = "skilldao#dao_15huofengjizhuan",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.146465,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7539981,
				sizeY = 0.2372316,
				image = "zd#jnmzd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "skill_name",
				posX = 0.5,
				posY = 0.1550959,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.043263,
				sizeY = 0.581119,
				text = "名字五个字",
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
