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
				varName = "imgBK",
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
				sizeX = 0.4935887,
				sizeY = 0.4828084,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db1",
					posX = 0.5,
					posY = 0.6019524,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9198374,
					sizeY = 0.3106822,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scrollConds",
						posX = 0.5021896,
						posY = 0.4370766,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8631595,
						sizeY = 0.7795783,
						horizontal = true,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tops",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3200565,
						sizeY = 0.3410401,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9660027,
							sizeY = 1.525127,
							text = "支持正确",
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
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5040882,
					posY = 1.001694,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.417858,
					sizeY = 0.1495877,
					image = "chu1#top",
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
						sizeX = 0.6116014,
						sizeY = 1.068354,
						text = "支持者奖励",
						color = "FF6E4228",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.5,
					posY = 0.2109989,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9198374,
					sizeY = 0.3106822,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scrollConds2",
						posX = 0.5021896,
						posY = 0.4370766,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8631595,
						sizeY = 0.7795783,
						horizontal = true,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tops2",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3200565,
						sizeY = 0.3410401,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9660027,
							sizeY = 1.525127,
							text = "支持错误",
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
			{
				prop = {
					etype = "Label",
					name = "hsz",
					varName = "npcName",
					posX = 0.5,
					posY = 0.8676124,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "本期获胜者：",
					color = "FF65944D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "btnClose",
				posX = 0.7253571,
				posY = 0.7024672,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				disablePressScale = true,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
