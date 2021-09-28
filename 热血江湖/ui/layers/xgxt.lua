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
			etype = "Grid",
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "xg",
				varName = "xiaoguai",
				posX = 0.4501871,
				posY = 0.8491697,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2493012,
				sizeY = 0.2783495,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "xgx",
					varName = "xiaoblood",
					posX = 0.5436703,
					posY = 0.4601516,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5327391,
					sizeY = 0.1397125,
					image = "zd#xgxt2",
					barDirection = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xgxd",
					posX = 0.5468039,
					posY = 0.4601516,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5327391,
					sizeY = 0.1397125,
					image = "zd#xgxt",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xgmz",
					varName = "xiaoname",
					posX = 0.4024538,
					posY = 0.6213188,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8071817,
					sizeY = 0.4257455,
					text = "小小小怪名字怪名字",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8598034,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1504205,
					sizeY = 0.4790141,
					image = "chu1#djk",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xgmz2",
					varName = "levellabel",
					posX = 0.8577047,
					posY = 0.492063,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3410184,
					sizeY = 0.4257455,
					text = "55",
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
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
