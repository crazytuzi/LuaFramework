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
			sizeX = 0.7357854,
			sizeY = 0.1458333,
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
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "assistTimes",
				posX = 0.8467553,
				posY = 0.493062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1482045,
				sizeY = 0.6239706,
				text = "65次",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF856343",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ttxk",
				varName = "occupation",
				posX = 0.5027965,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04778057,
				sizeY = 0.4285715,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj",
				varName = "lvlLabel",
				posX = 0.370646,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2483947,
				sizeY = 0.4088546,
				text = "Lv.40",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.2682475,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "你是一个大大草包",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm3",
				varName = "fightPower",
				posX = 0.6724117,
				posY = 0.493062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1482045,
				sizeY = 0.6239706,
				text = "65次",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF856343",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx",
				varName = "headBorder",
				posX = 0.07069835,
				posY = 0.4239028,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1279054,
				sizeY = 0.9209281,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tou",
					varName = "headIcon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
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
