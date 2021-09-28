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
			name = "lbdt1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6796875,
			sizeY = 0.1388889,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "globle_btn",
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
				etype = "Label",
				name = "lbtz1",
				varName = "name_label",
				posX = 0.3132319,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2209167,
				sizeY = 0.5047162,
				text = "名字",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz3",
				varName = "chongZhi",
				posX = 0.6383048,
				posY = 0.5119404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2564549,
				sizeY = 0.5652387,
				text = "50000",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF302A14",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "roleHeadBg",
				posX = 0.06820177,
				posY = 0.429702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1360315,
				sizeY = 0.9499999,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.7717487,
					posY = 0.2902991,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2957395,
					sizeY = 0.377193,
					image = "zdte#djd2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "gender",
				posX = 0.02326812,
				posY = 0.7742578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03619572,
				sizeY = 0.45172,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz2",
				varName = "level_label",
				posX = 0.1041289,
				posY = 0.2428254,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05188559,
				sizeY = 0.4359249,
				text = "85",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "job_icon",
				posX = 0.1558428,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05172414,
				sizeY = 0.45,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz4",
				varName = "hongli",
				posX = 0.8689362,
				posY = 0.5119404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2249176,
				sizeY = 0.5652387,
				text = "5000",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF302A14",
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
