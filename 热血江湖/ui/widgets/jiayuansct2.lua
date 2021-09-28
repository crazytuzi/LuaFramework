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
			name = "zbsct2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2390625,
			sizeY = 0.1569444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "productionselect",
				posX = 0.5,
				posY = 0.5044159,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9630281,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tan1",
				varName = "production_btn",
				posX = 0.5068921,
				posY = 0.4939595,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.00203,
				sizeY = 0.9520091,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzd1",
				varName = "production_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "twpk",
				varName = "production_rank",
				posX = 0.1761778,
				posY = 0.4736682,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2821468,
				sizeY = 0.7479585,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "twp1",
					varName = "production_icon",
					posX = 0.5052387,
					posY = 0.5407326,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.1993724,
					posY = 0.2283533,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3243108,
					sizeY = 0.3312854,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tmz1",
				varName = "production_name",
				posX = 0.6549421,
				posY = 0.6918433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6427943,
				sizeY = 0.3484159,
				text = "装备名字",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tmz2",
				varName = "production_lvl",
				posX = 0.4687131,
				posY = 0.3391714,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2743618,
				sizeY = 0.3484159,
				text = "50级",
				color = "FF65944D",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tmz3",
				varName = "production_exp",
				posX = 0.740832,
				posY = 0.3391714,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3652756,
				sizeY = 0.3484159,
				text = "熟练+200",
				color = "FF65944D",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jzz",
				varName = "suo",
				posX = 0.1078561,
				posY = 0.2874594,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.09912273,
				sizeY = 0.2684209,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tts1",
				varName = "need_text",
				posX = 0.5877269,
				posY = 0.3434554,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6204885,
				sizeY = 0.4190837,
				text = "需要生产等级10",
				color = "FFC93034",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "red_icon",
				posX = 0.9632931,
				posY = 0.897585,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.0882353,
				sizeY = 0.2477877,
				image = "zdte#hd",
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
