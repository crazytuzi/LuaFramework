--version = 1
local l_fileType = "layer"

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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "globel_bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3793512,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7009373,
				sizeY = 0.7510809,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.03,
					sizeY = 1.03,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk1",
					posX = 0.5,
					posY = 0.4707708,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9073174,
					sizeY = 0.4000016,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9835123,
						sizeY = 0.9615396,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz8",
					varName = "itemName_label",
					posX = 0.5,
					posY = 0.8694581,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8021439,
					sizeY = 0.1681958,
					text = "名字写六七个zi",
					color = "FFCE81FF",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zbd2",
					varName = "item_bg",
					posX = 0.5,
					posY = 0.869458,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.504317,
					sizeY = 0.3944932,
					image = "chdw1",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zbt2",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.25,
						sizeY = 0.5,
						image = "weizhenbafang",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz9",
					varName = "itemGrade_lable",
					posX = 0.5212184,
					posY = 0.7287076,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9490142,
					sizeY = 0.1254289,
					text = "时效：永久",
					color = "FFC93034",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "mz13",
					varName = "get_label",
					posX = 0.4999999,
					posY = 0.1376838,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9139997,
					sizeY = 0.2630748,
					text = "获得途径:圣殿任务",
					color = "FF65944D",
					fontOutlineColor = "FF400000",
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
