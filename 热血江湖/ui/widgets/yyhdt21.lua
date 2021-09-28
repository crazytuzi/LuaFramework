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
			sizeX = 0.709375,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "CjSl",
				posX = 0.5134497,
				posY = 0.4194325,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9724669,
				sizeY = 0.9755149,
				image = "njmzbanner#njmzbanner",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "lbk",
					posX = 0.5066809,
					posY = 0.239663,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.4210772,
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
						name = "lb",
						varName = "redPackList",
						posX = 0.420911,
						posY = 0.3837386,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8242863,
						sizeY = 0.9747165,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "ts",
					varName = "desc",
					posX = 0.3370745,
					posY = 0.7657647,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6489904,
					sizeY = 0.1114083,
					text = "提示文字",
					color = "FFFFF9C4",
					fontOutlineEnable = true,
					fontOutlineColor = "FF440D01",
					fontOutlineSize = 2,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "ActivitiesTime1",
					posX = 0.4076299,
					posY = 0.7813645,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.8149725,
					sizeY = 0.1114083,
					text = "活动时限",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj",
					posX = 0.0937769,
					posY = 0.7775815,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.140315,
					sizeY = 0.07353906,
					text = "活动时间：",
					color = "FFF6C07F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj2",
					varName = "ActivitiesTime",
					posX = 0.3962334,
					posY = 0.7775815,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4942083,
					sizeY = 0.07353906,
					text = "活动时间：",
					color = "FFF6C07F",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb2",
				varName = "gradeGiftList",
				posX = 0.3378206,
				posY = 0.2956596,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6102319,
				sizeY = 0.7086976,
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
