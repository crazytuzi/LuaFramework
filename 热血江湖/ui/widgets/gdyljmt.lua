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
			name = "k",
			posX = 0.5,
			posY = 0.4986127,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.203125,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.72,
				image = "guidaoyuling1#xiala",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb",
					varName = "name",
					posX = 0.5468588,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7671528,
					sizeY = 1,
					text = "碎片名称几个字",
					color = "FFFF8545",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.9268293,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jtxia",
					varName = "down",
					posX = 0.8580728,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06153846,
					sizeY = 0.2222222,
					image = "guidaoyuling1#jt",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jtshang",
					varName = "up",
					posX = 0.8580728,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.06153846,
					sizeY = 0.2222222,
					image = "guidaoyuling1#jt",
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1030645,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1541761,
					sizeY = 0.9983771,
					image = "wj#suo",
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
