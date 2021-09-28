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
			name = "f1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.3551306,
			sizeY = 0.1374791,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bfcht",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "d#bt",
				alpha = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zz1",
					varName = "progress_label",
					posX = 0.1216722,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2079054,
					sizeY = 0.3885808,
					text = "30%",
					color = "FFC93034",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "k1",
					varName = "item_bg1",
					posX = 0.324839,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t1",
						varName = "item_icon1",
						posX = 0.4978101,
						posY = 0.5301265,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7870306,
						sizeY = 0.8192696,
						image = "items#items_chujijjinengshu.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "k2",
					varName = "item_bg2",
					posX = 0.4955461,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t2",
						varName = "item_icon2",
						posX = 0.4978101,
						posY = 0.5301265,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7870306,
						sizeY = 0.8192696,
						image = "items#items_chujijjinengshu.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "k3",
					varName = "item_bg3",
					posX = 0.6662533,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t3",
						varName = "item_icon3",
						posX = 0.4978101,
						posY = 0.5301265,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7870306,
						sizeY = 0.8192696,
						image = "items#items_chujijjinengshu.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "k4",
					varName = "item_bg4",
					posX = 0.8369604,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t4",
						varName = "item_icon4",
						posX = 0.4978101,
						posY = 0.5301265,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7870306,
						sizeY = 0.8192696,
						image = "items#items_chujijjinengshu.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.5,
					posY = 0.01030872,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.95,
					sizeY = 0.02061744,
					image = "b#xian",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "item_bt1",
					posX = 0.3248391,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "item_bt2",
					posX = 0.4955462,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "item_bt3",
					posX = 0.6662533,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an4",
					varName = "item_bt4",
					posX = 0.8369604,
					posY = 0.4599165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1799962,
					sizeY = 0.8352951,
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
