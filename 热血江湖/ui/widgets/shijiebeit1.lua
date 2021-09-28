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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1875,
			sizeY = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tops",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8833333,
				sizeY = 1.00463,
				image = "shijiebei#dk",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zum",
					varName = "groupName",
					posX = 0.5000003,
					posY = 0.877273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.61668,
					sizeY = 0.515278,
					text = "A",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "gj1",
				posX = 0.5,
				posY = 0.7237035,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7870315,
				sizeY = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb1",
					varName = "img1",
					posX = 0.144734,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2117662,
					sizeY = 0.9027777,
					image = "shijiebei#eluosi",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gjmz",
					varName = "name1",
					posX = 0.5683296,
					posY = 0.5000007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7291154,
					sizeY = 1.170308,
					text = "俄罗斯",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn1",
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
					name = "xz1",
					varName = "red1",
					posX = 0.1460311,
					posY = 0.1765729,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2541195,
					sizeY = 0.486111,
					image = "shijiebei#zhichi",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "gj2",
				posX = 0.5,
				posY = 0.5240239,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7870315,
				sizeY = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb2",
					varName = "img2",
					posX = 0.144734,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2117662,
					sizeY = 0.9027777,
					image = "shijiebei#shate",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gjmz2",
					varName = "name2",
					posX = 0.5683296,
					posY = 0.5000007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7291154,
					sizeY = 1.170308,
					text = "俄罗斯",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "btn2",
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
					name = "xz2",
					varName = "red2",
					posX = 0.1460311,
					posY = 0.1765729,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2541195,
					sizeY = 0.486111,
					image = "shijiebei#zhichi",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "gj3",
				posX = 0.5,
				posY = 0.3243445,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7870315,
				sizeY = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb3",
					varName = "img3",
					posX = 0.144734,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2117662,
					sizeY = 0.9027777,
					image = "tb#yuanbao",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gjmz3",
					varName = "name3",
					posX = 0.5683296,
					posY = 0.5000007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7291154,
					sizeY = 1.170308,
					text = "俄罗斯",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "btn3",
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
					name = "xz3",
					varName = "red3",
					posX = 0.1460311,
					posY = 0.1765729,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2541195,
					sizeY = 0.486111,
					image = "shijiebei#zhichi",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "gj4",
				posX = 0.5,
				posY = 0.1246648,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7870315,
				sizeY = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb4",
					varName = "img4",
					posX = 0.144734,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2117662,
					sizeY = 0.9027777,
					image = "tb#yuanbao",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gjmz4",
					varName = "name4",
					posX = 0.5683296,
					posY = 0.5000009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7291154,
					sizeY = 1.170308,
					text = "俄罗斯",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn4",
					varName = "btn4",
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
					name = "xz4",
					varName = "red4",
					posX = 0.1460311,
					posY = 0.1765729,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2541195,
					sizeY = 0.486111,
					image = "shijiebei#zhichi",
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
