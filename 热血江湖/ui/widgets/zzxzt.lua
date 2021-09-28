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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1367188,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5628573,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7028569,
				sizeY = 0.7714286,
				image = "chu1#huang",
				imageNormal = "chu1#huang",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wzz",
					varName = "career",
					posX = 0.5569106,
					posY = 0.4814815,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8964162,
					sizeY = 1.140581,
					text = "正客",
					color = "FFFB6818",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFFFFCAE",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zyt",
				varName = "careerIcon",
				posX = 0.2542851,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.400417,
				sizeY = 0.8571429,
				image = "dl2#dk2",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "bgIcon",
				posX = 0.4657142,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9828568,
				sizeY = 0.9857144,
				image = "zz#hei",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
