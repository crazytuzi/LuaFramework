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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.06640625,
			sizeY = 0.1180556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "root1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 1,
				image = "bagua#gong1",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "btn1",
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
					name = "xz",
					varName = "choseBg",
					posX = 0.5,
					posY = 0.5235294,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.057059,
					sizeY = 1.057058,
					image = "djk#xz",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "title",
					posX = 0.5,
					posY = 0.264706,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.133917,
					sizeY = 0.6417955,
					text = "攻击",
					fontSize = 22,
					fontOutlineEnable = true,
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
