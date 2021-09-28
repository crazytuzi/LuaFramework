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
			name = "cheng",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1289063,
			sizeY = 0.1347222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "City",
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
				name = "chengt",
				varName = "icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 0.9959989,
				image = "chengchit#wxz1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jb",
				varName = "doneImg",
				posX = 0.3344844,
				posY = 0.8314459,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.612121,
				sizeY = 0.2886598,
				image = "chengzhan#yibaoming",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectImg",
				posX = 0.5059524,
				posY = 0.5132124,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.030303,
				sizeY = 1.051547,
				image = "chengchit#xzk2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.5,
				posY = 0.2387988,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8764269,
				sizeY = 0.6047584,
				text = "天水城",
				color = "FFDD4212",
				fontSize = 22,
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
