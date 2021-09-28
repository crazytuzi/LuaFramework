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
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbdt1",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "swmd",
					varName = "self_bg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "pmd",
					varName = "rank_icon",
					posX = 0.0420915,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.127,
					sizeY = 0.7625,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "kill_label",
					posX = 0.4407731,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1492833,
					sizeY = 0.7865212,
					text = "55",
					color = "FF65944D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "pm",
					varName = "rank_label",
					posX = 0.0420915,
					posY = 0.4818394,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08186686,
					sizeY = 0.9076124,
					text = "100",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF856343",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zmm",
					varName = "name_label",
					posX = 0.1892174,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.245,
					sizeY = 0.7865212,
					text = "全世界最屌宗门",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "lvl_label",
					posX = 0.3347756,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.131,
					sizeY = 0.7865212,
					text = "12",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl",
					varName = "dead_label",
					posX = 0.6527149,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1134722,
					sizeY = 0.7865212,
					text = "10",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mw",
					varName = "killnpc_label",
					posX = 0.7813571,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.155,
					sizeY = 0.7865212,
					text = "20",
					color = "FF65944D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mw2",
					varName = "score_label",
					posX = 0.932354,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.155,
					sizeY = 0.7865212,
					text = "20",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian8",
					posX = 0.5,
					posY = 0,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.05454545,
					image = "b#xian",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz2",
					varName = "assist_lable",
					posX = 0.5470088,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1538658,
					sizeY = 0.7865212,
					text = "55",
					color = "FF65944D",
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
