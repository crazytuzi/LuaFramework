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
			sizeX = 0.1061585,
			sizeY = 0.3930556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "chengt",
				varName = "CityImg",
				posX = 0.5,
				posY = 0.7034599,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9419876,
				sizeY = 0.5795053,
				image = "chengchit#1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "CityName",
				posX = 0.5,
				posY = 0.5162271,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8764269,
				sizeY = 0.4146064,
				text = "天水城",
				color = "FF5A268F",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb1",
				posX = 0.5,
				posY = 0.3808371,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.56371,
				sizeY = 0.2343633,
				text = "城池所属",
				color = "FFFFFF80",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb2",
				varName = "SectName",
				posX = 0.5,
				posY = 0.2977975,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.56371,
				sizeY = 0.2343633,
				text = "XXXX帮派",
				color = "FFFFFF80",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb3",
				varName = "leader",
				posX = 0.5,
				posY = 0.2147579,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.56371,
				sizeY = 0.2343633,
				text = "xxxx",
				color = "FFFFFF80",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "kq",
				varName = "open",
				posX = 0.5,
				posY = 0.09431694,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.852263,
				sizeY = 0.1314578,
				image = "chengzhan#btn",
				imageNormal = "chengzhan#btn",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "kqz",
					posX = 0.5,
					posY = 0.5268797,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9379315,
					sizeY = 1.493702,
					text = "开 启",
					color = "FF9F451D",
					fontSize = 18,
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
