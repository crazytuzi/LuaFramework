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
			sizeX = 0.5898438,
			sizeY = 0.155383,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tdt",
				varName = "sharder",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9,
				image = "d#bt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "cdd",
					posX = 0.5,
					posY = 1.059592,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.09931652,
					image = "d#cdd",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "cdd2",
					posX = 0.5,
					posY = -0.0397266,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.09931652,
					image = "d#cdd",
					flippedY = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ttxk",
				varName = "item_bg",
				posX = 0.1066867,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1201713,
				sizeY = 0.8109826,
				image = "zdte#bossd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "item_icon",
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
					name = "wka",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.030769,
					sizeY = 1.030769,
					image = "zdte#bossk",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj",
				varName = "faction",
				posX = 0.6090959,
				posY = 0.6698313,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2188368,
				sizeY = 0.6205857,
				text = "20",
				color = "FF966856",
				fontSize = 26,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "self",
				posX = 0.3473396,
				posY = 0.6698315,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2188368,
				sizeY = 0.6205857,
				text = "20",
				color = "FF65944D",
				fontSize = 26,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl",
				varName = "server",
				posX = 0.8708522,
				posY = 0.6698313,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2188368,
				sizeY = 0.6205857,
				text = "55",
				color = "FFC93034",
				fontSize = 26,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "self_name",
				posX = 0.3473396,
				posY = 0.2950386,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2638718,
				sizeY = 0.6205857,
				text = "名字六个字啊",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj2",
				varName = "faction_name",
				posX = 0.6090959,
				posY = 0.2950389,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2638718,
				sizeY = 0.6205857,
				text = "20",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl2",
				varName = "server_name",
				posX = 0.8708522,
				posY = 0.2950389,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2638718,
				sizeY = 0.6205857,
				text = "55",
				color = "FFC93034",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
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
