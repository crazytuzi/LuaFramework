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
			name = "f4",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.409375,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj4",
				posX = 0.6394269,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5642036,
				sizeY = 0.6790296,
				image = "pk#pk_dt.png",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "n7",
				varName = "attribute_name",
				posX = 0.2196007,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2022678,
				sizeY = 0.7300186,
				text = "气血：",
				color = "FF58E4D3",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "n9",
				varName = "old_value",
				posX = 0.5277166,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2180479,
				sizeY = 0.7300186,
				text = "11",
				color = "FF4BC5B7",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "n12",
				varName = "new_value",
				posX = 0.7790278,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1773974,
				sizeY = 0.7300186,
				text = "12",
				color = "FF9BFF4B",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				posX = 0.6592923,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05182555,
				sizeY = 0.5630158,
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
