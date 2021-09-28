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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02057244,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05421687,
						sizeY = 0.3755943,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9442027,
						posY = 0.1851488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.5,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd1",
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
						name = "db1",
						posX = 0.16185,
						posY = 0.4937823,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2783505,
						sizeY = 0.8660001,
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
							name = "fgx",
							posX = 0.5347877,
							posY = 0.5131859,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9403864,
							sizeY = 1.069345,
							image = "d2#dw2",
							scale9 = true,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Sprite3D",
							name = "mx",
							varName = "model",
							posX = 0.5178582,
							posY = 0.1387338,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8923814,
							sizeY = 0.6376118,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dhk",
							posX = 0.01298947,
							posY = 0.924962,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8671775,
							sizeY = 0.2807199,
							image = "wg2#tsk",
							flippedX = true,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wz",
							varName = "talkTxt",
							posX = 0.01298941,
							posY = 0.924962,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8671775,
							sizeY = 0.2807199,
							text = "答对我的三个问题，我就告诉你驱散符影的方法。",
							color = "FFFFFF00",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "dati",
						varName = "answerSheet",
						posX = 0.6307916,
						posY = 0.4972138,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6334949,
						sizeY = 0.775494,
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
				posY = 0.8793491,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3181818,
					sizeY = 0.4807692,
					image = "dati#dati",
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
