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
			posX = 0.4992188,
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
				sizeX = 0.6094162,
				sizeY = 0.8055556,
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
					name = "das",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7217461,
					sizeY = 0.74311,
					image = "jh5#db",
					scale9 = true,
					scale9Top = 0.48,
					scale9Bottom = 0.48,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8674734,
					posY = 0.7857881,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08845556,
					sizeY = 0.1396552,
					image = "jh1#gb",
					imageNormal = "jh1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d9",
					posX = 0.5,
					posY = 0.5379303,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7007456,
					sizeY = 0.5062075,
					image = "d#bt",
					scale9 = true,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xct",
						posX = 0.5021112,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9366678,
						sizeY = 0.9400533,
						image = "yanxi#yanxi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smda2",
					posX = 0.4987199,
					posY = 0.2221128,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5193428,
					sizeY = 0.1015577,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "zx4",
						varName = "openWenddingBtn",
						posX = 0.5,
						posY = 0.533954,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6028742,
						sizeY = 1.086524,
						image = "jh1#an",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						imageNormal = "jh1#an",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9086144,
							sizeY = 1.137135,
							text = "开启宴席",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.7739822,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1703125,
				sizeY = 0.07361111,
				image = "jh5#top",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6146789,
					sizeY = 0.5283019,
					image = "jh5#djyy",
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
