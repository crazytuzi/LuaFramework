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
			name = "scczt",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1232329,
			sizeY = 0.2427713,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "chooseBtn",
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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.027295,
				sizeY = 1.04,
				image = "dw#d3",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zl1",
					varName = "state",
					posX = 0.5,
					posY = 0.1552658,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.283373,
					sizeY = 0.25,
					text = "状态",
					color = "FFC93034",
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl2",
					varName = "name",
					posX = 0.5,
					posY = 0.3092916,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9132032,
					sizeY = 0.25,
					text = "宠物名字",
					color = "FF966856",
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				varName = "petIconBg",
				posX = 0.5,
				posY = 0.6563874,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5959245,
				sizeY = 0.5377718,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt1",
					varName = "petIcon",
					posX = 0.5,
					posY = 0.5451064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.83,
					sizeY = 0.83,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.4580873,
					posY = 0.5515568,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9368423,
					sizeY = 0.8749999,
					image = "cl#sck",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					varName = "start_icon",
					posX = 0.490506,
					posY = 0.171298,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8999986,
					sizeY = 0.1833636,
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
