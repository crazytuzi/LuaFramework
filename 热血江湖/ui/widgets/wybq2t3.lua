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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5304688,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9999998,
				sizeY = 0.9499999,
				image = "wybq2#lbt2",
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "img",
				posX = 0.07522229,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1104565,
				sizeY = 0.7499999,
				image = "tb#wg",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.4260561,
				posY = 0.679634,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5194387,
				sizeY = 0.55,
				text = "武功升级",
				color = "FF856951",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				posX = 0.3081195,
				posY = 0.6796341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4337496,
				sizeY = 0.55,
				text = "推荐度",
				color = "FF65944D",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc3",
				varName = "desc",
				posX = 0.4663367,
				posY = 0.279634,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.55,
				text = "武功升级",
				color = "FF856951",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "goto_btn",
				posX = 0.8417645,
				posY = 0.47,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2251975,
				sizeY = 0.58,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disableClick = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wbz",
					varName = "btn_txt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.002973,
					sizeY = 1.032597,
					text = "前 往",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
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
				name = "xx2",
				varName = "star1",
				posX = 0.5593626,
				posY = 0.6796341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05596464,
				sizeY = 0.38,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx3",
				varName = "star2",
				posX = 0.5949746,
				posY = 0.6796341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05596464,
				sizeY = 0.38,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx4",
				varName = "star3",
				posX = 0.6305867,
				posY = 0.6796341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05596464,
				sizeY = 0.38,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx",
				varName = "star4",
				posX = 0.6661987,
				posY = 0.6796341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05596464,
				sizeY = 0.38,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx5",
				varName = "star5",
				posX = 0.7018108,
				posY = 0.6796341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05596464,
				sizeY = 0.38,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "hide_btn",
				varName = "btn",
				posX = 0.2014953,
				posY = 0.6273934,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.002990677,
				sizeY = -0.004786682,
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
