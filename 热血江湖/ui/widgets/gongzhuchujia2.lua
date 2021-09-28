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
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z2",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
				image = "a",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.6220188,
					posY = 0.4905233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6549055,
					sizeY = 0.8787524,
					image = "gongzhuchujia#gongzhuchujia",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t1",
						posX = 0.3250119,
						posY = 0.8525041,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7517416,
						sizeY = 0.3564813,
						image = "gzcj#jb",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "t2",
						posX = 0.6452025,
						posY = 0.1491109,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9023497,
						sizeY = 0.6808624,
						image = "gzcj#pve",
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
