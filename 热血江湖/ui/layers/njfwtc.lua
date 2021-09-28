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
				varName = "close",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disableClick = true,
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
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "xjd",
				varName = "soltUI",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "z3",
					posX = 0.2918364,
					posY = 0.4590964,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4274222,
					sizeY = 0.8333525,
					scale9 = true,
					scale9Left = 0.41,
					scale9Right = 0.37,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tbd",
						varName = "SoltItem2_bg",
						posX = 0.8595101,
						posY = 0.7548965,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.160848,
						sizeY = 0.1633296,
						image = "njfw#dk",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp",
							varName = "SoltItem2_icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8749999,
							sizeY = 0.8061222,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tb",
							varName = "SoltItem2_btn",
							posX = 0.4648292,
							posY = 0.5471647,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.297655,
							sizeY = 1.256675,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tbd2",
						varName = "SoltItem1_bg",
						posX = 0.1508902,
						posY = 0.7548965,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.160848,
						sizeY = 0.1633296,
						image = "njfw#dk",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp2",
							varName = "SoltItem1_icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8749999,
							sizeY = 0.8061222,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tb2",
							varName = "SoltItem1_btn",
							posX = 0.4761928,
							posY = 0.5471647,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.297655,
							sizeY = 1.256675,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tbd3",
						varName = "SoltItem5_bg",
						posX = 0.1508902,
						posY = 0.3132475,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.160848,
						sizeY = 0.1633296,
						image = "njfw#dk",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp3",
							varName = "SoltItem5_icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8749999,
							sizeY = 0.8061222,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tb3",
							varName = "SoltItem5_btn",
							posX = 0.4761928,
							posY = 0.5471647,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.297655,
							sizeY = 1.256675,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tbd4",
						varName = "SoltItem3_bg",
						posX = 0.1508902,
						posY = 0.534072,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.160848,
						sizeY = 0.1633296,
						image = "njfw#dk",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp4",
							varName = "SoltItem3_icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8749999,
							sizeY = 0.8061222,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tb4",
							varName = "SoltItem3_btn",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.297655,
							sizeY = 1.256675,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tbd5",
						varName = "SoltItem6_bg",
						posX = 0.8595101,
						posY = 0.3132475,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.160848,
						sizeY = 0.1633296,
						image = "njfw#dk",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp5",
							varName = "SoltItem6_icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8749999,
							sizeY = 0.8061222,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tb5",
							varName = "SoltItem6_btn",
							posX = 0.4761928,
							posY = 0.5471647,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.297655,
							sizeY = 1.256675,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tbd6",
						varName = "SoltItem4_bg",
						posX = 0.8595101,
						posY = 0.534072,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.160848,
						sizeY = 0.1633296,
						image = "njfw#dk",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp6",
							varName = "SoltItem4_icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8749999,
							sizeY = 0.8061222,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tb6",
							varName = "SoltItem4_btn",
							posX = 0.4761928,
							posY = 0.5471647,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.297655,
							sizeY = 1.256675,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wzdt",
					posX = 0.7265704,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3311327,
					sizeY = 0.2018507,
					image = "h#d4",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz",
					posX = 0.6913742,
					posY = 0.5366426,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2456895,
					sizeY = 0.1013132,
					text = "点击插槽进行装备/更换",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					posX = 0.6888016,
					posY = 0.4679864,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2024777,
					sizeY = 0.1028142,
					text = "点击空白位置取消",
					fontSize = 26,
					hTextAlign = 1,
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
