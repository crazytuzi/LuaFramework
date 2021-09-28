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
				etype = "Image",
				name = "tj",
				varName = "recommend",
				posX = 0.06163349,
				posY = 0.6797058,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1163475,
				sizeY = 0.58,
				image = "sc#tj",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.4260561,
				posY = 0.669634,
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
				varName = "sliderDesc",
				posX = 0.5510893,
				posY = 0.669634,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2624637,
				sizeY = 0.55,
				text = "武功升级",
				color = "FF966856",
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
				posY = 0.199634,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6,
				sizeY = 0.55,
				text = "武功升级",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jdt",
				varName = "sliderImg",
				posX = 0.424889,
				posY = 0.28,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5301914,
				sizeY = 0.3,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt2",
					varName = "slider",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9638888,
					sizeY = 0.5999999,
					image = "wybq2#lv",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text1",
					varName = "text1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.5881531,
					sizeY = 1.876427,
					text = "120/120",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF5B7838",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					autoWrap = false,
				},
			},
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
				lockHV = true,
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
				etype = "Button",
				name = "hide_btn",
				varName = "btn",
				posX = 0.4653542,
				posY = 0.8000925,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.009839684,
				sizeY = 0.1076934,
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
