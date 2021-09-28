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
			sizeX = 1,
			sizeY = 1,
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
				sizeX = 0.651915,
				sizeY = 0.296699,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "zdb",
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
					name = "dw2",
					posX = 0.5023934,
					posY = 0.4673024,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8746617,
					sizeY = 0.4860394,
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
						etype = "Image",
						name = "jnt",
						posX = 0.07459017,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1329017,
						sizeY = 0.8379135,
						image = "jn#jnbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jn",
							varName = "ImageName",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.731959,
							sizeY = 0.816092,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "jnmz",
						varName = "lableName",
						posX = 0.3028071,
						posY = 0.7500679,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2603304,
						sizeY = 0.4615784,
						text = "骑术名称",
						color = "FF911D02",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "z4",
						varName = "desa",
						posX = 0.5674903,
						posY = 0.3265006,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7896969,
						sizeY = 0.5393835,
						text = "骑术描述",
						color = "FF911D02",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z3",
					varName = "itemDesc_label",
					posX = 0.5,
					posY = 0.128663,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7393639,
					sizeY = 0.2400203,
					text = "主角40级以上，并且坐骑升到2星时开放先天骑术",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.8329923,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3367483,
					sizeY = 0.1497964,
					image = "chu1#top3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6126512,
						sizeY = 1.723983,
						text = "骑术效果",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
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
