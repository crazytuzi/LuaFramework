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
			name = "jnj1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5651745,
			sizeY = 0.2510822,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "jna1",
				varName = "skill_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk",
					varName = "noticeBg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98,
					sizeY = 0.98,
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.2,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "noticeLabel",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7835759,
				sizeY = 0.8780845,
				scale9 = true,
				text = "这个是写具体公告的地方",
				fontSize = 22,
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
