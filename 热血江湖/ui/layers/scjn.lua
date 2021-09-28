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
				varName = "close_btn",
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
				etype = "Button",
				name = "gb",
				posX = 0.5027293,
				posY = 0.6275676,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4032439,
				sizeY = 0.3549728,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3984375,
				sizeY = 0.8611111,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wasd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.386629,
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
						etype = "Label",
						name = "tswb2",
						varName = "tips",
						posX = 0.5,
						posY = 0.1113529,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9211552,
						sizeY = 0.2074997,
						text = "该技能战斗时自动释放",
						color = "FFC93034",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.2246099,
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
						etype = "Label",
						name = "x1",
						varName = "now_label",
						posX = 0.3465345,
						posY = 0.7866575,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2855532,
						sizeY = 0.278841,
						text = "等级：",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF402B00",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "x2",
						varName = "skill_lvl",
						posX = 0.6603864,
						posY = 0.7866575,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2855534,
						sizeY = 0.278841,
						text = "1级",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF402B00",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "wb1",
						varName = "skill_desc",
						posX = 0.5,
						posY = 0.3543607,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9727883,
						sizeY = 0.5920838,
						text = "13231231231323123123132312312313231231231323123123132312312313",
						color = "FF966856",
						fontSize = 22,
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
				posX = 0.5,
				posY = 0.6309371,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2195313,
				sizeY = 0.04444445,
				image = "chu1#top3",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sbjn",
					varName = "skill_name",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6549187,
					sizeY = 1.53183,
					text = "技能名称",
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
