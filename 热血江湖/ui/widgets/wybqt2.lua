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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5148438,
			sizeY = 0.1607127,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "suicongBg",
				posX = 0.5091206,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9817587,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				alpha = 0.6,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name_txt",
				posX = 0.2502027,
				posY = 0.7958971,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3660836,
				sizeY = 0.4292258,
				text = "宠物名字",
				color = "FFF1E9D7",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "re_image",
				posX = 0.02757126,
				posY = 0.6730314,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04248861,
				sizeY = 0.6049442,
				image = "wybq#tj",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "desc_txt",
				posX = 0.412352,
				posY = 0.362402,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6903816,
				sizeY = 0.5702807,
				text = "宠物名字",
				color = "FF966856",
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "go_btn1",
				posX = 0.8863258,
				posY = 0.75,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1972685,
				sizeY = 0.4407451,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "qwz",
					varName = "go_txt1",
					posX = 0.5,
					posY = 0.5196078,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7760878,
					sizeY = 0.9080302,
					text = "前 往",
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "go_btn2",
				posX = 0.8848083,
				posY = 0.25,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1972685,
				sizeY = 0.4407451,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "qwz2",
					varName = "go_txt2",
					posX = 0.5,
					posY = 0.5196078,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7760878,
					sizeY = 0.9080302,
					text = "前 往",
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a3",
				varName = "go_btn3",
				posX = 0.8848083,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1972685,
				sizeY = 0.4407451,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "qwz3",
					varName = "go_txt3",
					posX = 0.5,
					posY = 0.5196078,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7760878,
					sizeY = 0.9080302,
					text = "前 往",
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
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
