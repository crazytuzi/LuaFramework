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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.721468,
			sizeY = 0.09983491,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xuan",
				posX = 0.5,
				posY = 0.01733121,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.04258968,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs1",
				varName = "name",
				posX = 0.19013,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1962223,
				sizeY = 0.991278,
				text = "4",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs2",
				varName = "level",
				posX = 0.342701,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1884028,
				sizeY = 0.9912785,
				text = "4",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs3",
				varName = "time",
				posX = 0.5454043,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1624292,
				sizeY = 0.9912775,
				text = "4",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs4",
				varName = "stateTxt",
				posX = 0.7232425,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1000621,
				sizeY = 0.9912775,
				text = "4",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bt1",
				varName = "goBtn",
				posX = 0.8983784,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.140772,
				sizeY = 0.7095047,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "btz1",
					varName = "goBtnTxt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7953417,
					sizeY = 0.8290088,
					text = "前 往",
					fontSize = 22,
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
				etype = "Grid",
				name = "d2",
				varName = "boss",
				posX = 0.04769106,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.130212,
				sizeY = 1.081712,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "btd",
					varName = "headIcon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5156009,
					sizeY = 0.7899109,
					image = "zdte#bossd",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "btx",
					varName = "bosstx",
					posX = 0.5000001,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5156009,
					sizeY = 0.7899109,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bdt2",
					varName = "headframe",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5738139,
					sizeY = 0.8790944,
					image = "zdte#bossk",
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
