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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.78125,
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbdt1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "w#w_smd3.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
				alpha = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "pmd",
					varName = "rank_icon",
					posX = 0.0460026,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.062,
					sizeY = 1.181818,
					image = "jjc#jjc_1st.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name_label",
					posX = 0.5771131,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.25,
					sizeY = 0.7865212,
					text = "我的名字很长",
					color = "FFBDFF8C",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "pm",
					varName = "rank_label",
					posX = 0.04574548,
					posY = 0.4818394,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08186686,
					sizeY = 0.9076124,
					text = "100",
					color = "FF6EDBBD",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zmm",
					varName = "clan_name",
					posX = 0.2171232,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.245,
					sizeY = 0.7865212,
					text = "全世界最屌宗门",
					color = "FF6EDBBD",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "lvl_label",
					posX = 0.3958682,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.131,
					sizeY = 0.7865212,
					text = "12",
					color = "FF6EDBBD",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl",
					varName = "power_label",
					posX = 0.770358,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.155,
					sizeY = 0.7865212,
					text = "1200000",
					color = "FF6EDBBD",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mw",
					varName = "fame_label",
					posX = 0.916103,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.155,
					sizeY = 0.7865212,
					text = "1200000",
					color = "FF6EDBBD",
					fontSize = 22,
					fontOutlineEnable = true,
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
