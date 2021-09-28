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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.734375,
			sizeY = 0.7027778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "haoyou",
				varName = "ShouChong",
				posX = 0.5,
				posY = 0.4970394,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.024008,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.5017942,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.988269,
					sizeY = 0.9764031,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mhy",
					varName = "mhy",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4265957,
					sizeY = 0.8963168,
					image = "hw1#hw1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wbz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.975935,
						sizeY = 0.3908244,
						text = "您还没有添加任何好友，赶快邀请好友一起闯荡江湖吧！",
						color = "FF43261D",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
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
