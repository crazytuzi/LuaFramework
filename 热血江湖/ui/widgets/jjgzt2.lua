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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.775,
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "rank",
				posX = 0.1136245,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1467626,
				sizeY = 0.812758,
				text = "第一名：",
				color = "FF43261D",
				fontSize = 24,
				fontOutlineColor = "FF2E1410",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "reward1",
				posX = 0.2081378,
				posY = 0.4667118,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05322002,
				sizeY = 0.97,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "rewardIcon1",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "rewardCount1",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 0.6252117,
					text = "x10000",
					color = "FF43261D",
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					posX = 0.2643296,
					posY = 0.3229533,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4735363,
					sizeY = 0.4686036,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj2",
				varName = "reward2",
				posX = 0.3525866,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05322002,
				sizeY = 0.97,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt2",
					varName = "rewardIcon2",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "rewardCount2",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 0.6252117,
					text = "x10000",
					color = "FF43261D",
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj3",
				varName = "reward3",
				posX = 0.4869545,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05322002,
				sizeY = 0.97,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt3",
					varName = "rewardIcon3",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl3",
					varName = "rewardCount3",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 0.6252117,
					text = "x10000",
					color = "FF43261D",
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					posX = 0.2643296,
					posY = 0.3229533,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4735363,
					sizeY = 0.4686036,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj4",
				varName = "reward4",
				posX = 0.6213223,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05322002,
				sizeY = 0.97,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt4",
					varName = "rewardIcon4",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl4",
					varName = "rewardCount4",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 0.6252117,
					text = "x10000",
					color = "FF43261D",
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj5",
				varName = "reward5",
				posX = 0.7556901,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05322002,
				sizeY = 0.97,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt5",
					varName = "rewardIcon5",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl5",
					varName = "rewardCount5",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 0.6252117,
					text = "x10000",
					color = "FF43261D",
					fontOutlineColor = "FF2E1410",
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
