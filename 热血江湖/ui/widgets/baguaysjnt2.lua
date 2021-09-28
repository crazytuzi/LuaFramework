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
			sizeX = 0.7633083,
			sizeY = 0.1666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.65,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "name",
				posX = 0.2912441,
				posY = 0.7205752,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3071522,
				sizeY = 0.4910634,
				text = "技能名称",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "lvDesc",
				posX = 0.3508123,
				posY = 0.7205752,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1880158,
				sizeY = 0.4910634,
				text = "阶位",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz3",
				posX = 0.4243843,
				posY = 0.7205752,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.143056,
				sizeY = 0.4910634,
				text = "专精需求：",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd",
				varName = "zj_bg",
				posX = 0.4795641,
				posY = 0.7205755,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0378697,
				sizeY = 0.2916666,
				image = "zd#djd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "djz",
					varName = "level",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.107802,
					sizeY = 1.309122,
					text = "10",
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "jnms",
				varName = "desc",
				posX = 0.4342999,
				posY = 0.3419264,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5932639,
				sizeY = 0.432622,
				text = "技能描述",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz4",
				varName = "wearNum",
				posX = 0.5773557,
				posY = 0.7205752,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3071522,
				sizeY = 0.4910634,
				text = "已装备：0/0",
				color = "FF966856",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sjan",
				varName = "cfgBtn",
				posX = 0.8780756,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1565032,
				sizeY = 0.4833332,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sjz",
					varName = "btnName",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9072005,
					sizeY = 1.071735,
					text = "升 级",
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
				name = "max",
				varName = "maxIcon",
				posX = 0.8790933,
				posY = 0.5165972,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.09109196,
				sizeY = 0.4083332,
				image = "zqqz#max",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt",
				varName = "icon",
				posX = 0.06672215,
				posY = 0.4887889,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09405266,
				sizeY = 0.7657719,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "mvan",
				varName = "skill_move",
				posX = 0.06672212,
				posY = 0.4554557,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0788099,
				sizeY = 0.6416665,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnd",
				varName = "icon_bg",
				posX = 0.06840654,
				posY = 0.4794419,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.101327,
				sizeY = 0.8166665,
				image = "yishu#yuan",
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
