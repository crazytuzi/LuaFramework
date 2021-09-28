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
			etype = "Button",
			name = "an",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			fontSize = 24,
			fontOutlineEnable = true,
			fontOutlineColor = "FFB35F1D",
			fontOutlineSize = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.5,
				posY = 0.5131724,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3177942,
				sizeY = 0.4007314,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.8068755,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6858802,
					sizeY = 0.1732942,
					image = "chu1#zld",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "npc_desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6770836,
						sizeY = 0.8848473,
						text = "xxx身上的物品",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk",
					posX = 0.5,
					posY = 0.4162456,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9008036,
					sizeY = 0.4380222,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djk",
						varName = "item_rank",
						posX = 0.1703251,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2183252,
						sizeY = 0.6330063,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dt",
							varName = "item_icon",
							posX = 0.5066378,
							posY = 0.5123134,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8064516,
							sizeY = 0.8064516,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							posX = 0.1846533,
							posY = 0.2284948,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3157895,
							sizeY = 0.3225807,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "bt",
							varName = "item_btn",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8805485,
							sizeY = 0.8805485,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb",
							varName = "item_name",
							posX = 1.679059,
							posY = 0.5148838,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.186023,
							sizeY = 0.7862057,
							text = "红灯笼×1",
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "buy_btn",
						posX = 0.7860774,
						posY = 0.6397756,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3733581,
						sizeY = 0.4747547,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							text = "购买",
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tb",
						posX = 0.6390892,
						posY = 0.2820024,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1144348,
						sizeY = 0.349252,
						image = "tb#tb_tongqian.png",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb3",
							varName = "coin_num",
							posX = 2.272579,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.690442,
							sizeY = 1.132789,
							text = "×888888",
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo2",
							posX = 0.6295284,
							posY = 0.3189422,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6053097,
							sizeY = 0.6345931,
							image = "tb#suo",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt3",
					varName = "close_btn",
					posX = 0.9270517,
					posY = 0.9013827,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1597929,
					sizeY = 0.2183507,
					image = "baishi#x",
					imageNormal = "baishi#x",
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
