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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9566502,
					sizeY = 1.02931,
					image = "chengzhanbj#chengzhanbj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d10",
					posX = 0.5,
					posY = 0.4948223,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7013106,
					sizeY = 0.5164208,
					image = "chengzhan#zitiao",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "tswb",
						varName = "Desc",
						posX = 0.5,
						posY = -0.1182744,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9080468,
						sizeY = 0.2033208,
						text = "提示文本",
						color = "FFC49DE5",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "Scroll",
						posX = 0.4976868,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9476917,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "Help",
					posX = 0.8265642,
					posY = 0.1755326,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04926108,
					sizeY = 0.0862069,
					image = "chengzhan#bz",
					imageNormal = "chengzhan#bz",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "Close",
				posX = 0.7589543,
				posY = 0.7690282,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04140625,
				sizeY = 0.07083333,
				image = "rydt#gb",
				imageNormal = "rydt#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.7862928,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3210937,
				sizeY = 0.1763889,
				image = "chengzhan#czzg",
				scale9Left = 0.4,
				scale9Right = 0.4,
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
