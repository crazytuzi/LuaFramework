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
			etype = "Image",
			name = "sxdw5",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2557089,
			sizeY = 0.0531529,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "jcmc5",
				varName = "name",
				posX = 0.2291045,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4258893,
				sizeY = 1.306504,
				text = "气功继承：",
				color = "FF966856",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "cssz5",
				varName = "from",
				posX = 0.5824663,
				posY = 0.4477399,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3961317,
				sizeY = 1.306504,
				text = "+10%",
				color = "FFF1E9D7",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "jcjg5",
				varName = "to",
				posX = 0.8341926,
				posY = 0.4477399,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.374543,
				sizeY = 1.306504,
				text = "+20%",
				color = "FF76D646",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt5",
				posX = 0.5,
				posY = 0,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.04836659,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt7",
				varName = "arrow",
				posX = 0.6061968,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04277325,
				sizeY = 0.3919511,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "th",
				varName = "btn",
				posX = 0.9216178,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1038779,
				sizeY = 0.8361621,
				image = "tong#tsf",
				imageNormal = "tong#tsf",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp1",
				varName = "img1",
				posX = 0.4450064,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2408541,
				sizeY = 0.8622921,
				image = "anqi#jipin",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp2",
				varName = "img2",
				posX = 0.750799,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.2408541,
				sizeY = 0.8622922,
				image = "anqi#zhenpin",
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
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
