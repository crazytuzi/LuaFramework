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
			scale9Left = 0.4,
			scale9Right = 0.4,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
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
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.491941,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7088287,
				sizeY = 0.6630406,
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
					name = "smd",
					posX = 0.5,
					posY = 0.9046384,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9526536,
					sizeY = 0.08105706,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						posX = 0.2311348,
						posY = 0.421547,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4287419,
						sizeY = 1.015651,
						text = "本副本掉落道具如下：",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "left_times",
						posX = 0.6449566,
						posY = 0.421547,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.626663,
						sizeY = 1.318501,
						text = "今日剩余自取次数：3/3",
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbd",
					posX = 0.5,
					posY = 0.4496774,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9344612,
					sizeY = 0.8058286,
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
						name = "lb2",
						varName = "item_scroll",
						posX = 0.4984399,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9853551,
						sizeY = 0.9803475,
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
				posY = 0.8192096,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.234375,
				sizeY = 0.07369614,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tt2",
					posX = 0.5026901,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5151515,
					sizeY = 0.4807693,
					image = "biaoti#jlfp",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.8406813,
				posY = 0.7789327,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05948153,
				sizeY = 0.1077097,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
