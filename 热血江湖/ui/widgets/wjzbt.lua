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
			sizeX = 0.3842364,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "hh",
				varName = "round",
				posX = 0.3454704,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 1.323046,
				text = "第一回合：",
				color = "FFFFEEA0",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sm1",
				posX = 0.2641388,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05489784,
				sizeY = 0.5,
				image = "zd#shengming",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sz1",
					varName = "damage1",
					posX = 3.532762,
					posY = 0.4999988,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.595392,
					sizeY = 2.640872,
					text = "-22",
					color = "FFFFEEA0",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt",
				varName = "skillIcon1",
				posX = 0.4430681,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.08527951,
				sizeY = 0.8388477,
				image = "skillbuff#baoyulihuazhen",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "kz",
				varName = "state",
				posX = 0.549814,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08539665,
				sizeY = 0.9399999,
				image = "wjzb#ping",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt2",
				varName = "skillIcon2",
				posX = 0.6565593,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.08527951,
				sizeY = 0.8388477,
				image = "skillbuff#baoyulihuazhen",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sm2",
				posX = 0.7451763,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05489784,
				sizeY = 0.5,
				image = "zd#shengming",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sz2",
					varName = "damage2",
					posX = 3.532762,
					posY = 0.4999988,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.595392,
					sizeY = 2.640872,
					text = "-22",
					color = "FFFFEEA0",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cd",
				varName = "right2",
				posX = 0.6643413,
				posY = 0.6796994,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.128095,
				sizeY = 0.8799999,
				image = "wjzb#caidui",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cd2",
				varName = "right1",
				posX = 0.439014,
				posY = 0.6997861,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.128095,
				sizeY = 0.8799999,
				image = "wjzb#caidui",
				rotation = -25,
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
