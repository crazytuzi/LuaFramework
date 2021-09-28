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
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
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
			sizeX = 0.7,
			sizeY = 0.7,
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
				sizeX = 0.84,
				sizeY = 0.88,
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
					sizeX = 1.009779,
					sizeY = 0.9424604,
					image = "jiebai#dk3",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 0.9874691,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5592105,
						sizeY = 0.07894737,
						image = "jiebai#top",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dwbh6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.864768,
							sizeY = 2.515821,
							text = "金兰值",
							color = "FFFFF337",
							fontOutlineColor = "FF102E21",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dwbh7",
						varName = "desc",
						posX = 0.5,
						posY = 0.8059341,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8763291,
						sizeY = 0.2487891,
						text = "结拜前缀最长四字，包含1个系统字，后缀3字包含1个系统字。例如：风尘四侠之大侠。",
						color = "FFC93034",
						fontSize = 18,
						fontOutlineColor = "FF102E21",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a3",
						varName = "ok_btn",
						posX = 0.5,
						posY = 0.1049926,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1815789,
						sizeY = 0.138756,
						image = "jiebai#an1",
						imageNormal = "jiebai#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8995844,
							sizeY = 0.963034,
							text = "确 定",
							color = "FF914200",
							fontSize = 22,
							fontOutlineColor = "FF2A6953",
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
						name = "dk",
						posX = 0.5,
						posY = 0.4462855,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8450019,
						sizeY = 0.5311006,
						image = "jiebai#k2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
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
							sizeX = 1,
							sizeY = 1,
							horizontal = true,
							showScrollBar = false,
						},
					},
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
