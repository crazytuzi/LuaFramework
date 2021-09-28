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
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2148438,
			sizeY = 0.2851125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				posX = 0.5,
				posY = 0.5048714,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.981818,
				sizeY = 1.052216,
				image = "sc#sc_dt.png",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "item_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm",
					varName = "item_name",
					posX = 0.5,
					posY = 0.8538464,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9237462,
					sizeY = 0.2100926,
					text = "普通强化石",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg",
					posX = 0.4968534,
					posY = 0.516847,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3489394,
					sizeY = 0.4361744,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb",
					varName = "money_icon",
					posX = 0.3330723,
					posY = 0.1656177,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1484849,
					sizeY = 0.1856061,
					image = "tb#tb_tongqian.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "money_count",
						posX = 3.022787,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.919373,
						sizeY = 0.9843265,
						text = "999999",
						color = "FF634624",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFF6AB",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb2",
					varName = "money_icon2",
					posX = 0.173452,
					posY = 0.1656177,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1484849,
					sizeY = 0.1856061,
					image = "tb#tb_tongqian.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "money_count2",
						posX = 2.911709,
						posY = 0.4999681,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.919373,
						sizeY = 0.9843265,
						text = "9999",
						color = "FF634624",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFF6AB",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb3",
					varName = "money_icon1",
					posX = 0.5669346,
					posY = 0.1656177,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1484849,
					sizeY = 0.1856061,
					image = "tb#tb_tongqian.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sl3",
						varName = "money_count1",
						posX = 2.956121,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.919373,
						sizeY = 0.9843265,
						text = "9999",
						color = "FF634624",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFF6AB",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zk",
					varName = "discount",
					posX = 0.1746284,
					posY = 0.6664023,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2925926,
					sizeY = 0.2083334,
					image = "sc#1z",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ycs",
					varName = "out_icon",
					posX = 0.4999997,
					posY = 0.4915198,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.001186,
					sizeY = 0.9425245,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ct",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6117744,
						sizeY = 0.4824649,
						image = "sc#sc_ysw.png",
					},
				},
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
