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
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8453202,
					sizeY = 0.9758621,
					image = "jydb#jydb",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d5",
						posX = 0.5000002,
						posY = 0.5212185,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.896921,
						sizeY = 0.7725659,
						image = "b#jyd",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.5,
							posY = 0.4988469,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9431473,
							sizeY = 0.9018431,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8883433,
					posY = 0.93899,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05221675,
					sizeY = 0.08793104,
					image = "rydt#gb",
					imageNormal = "rydt#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
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
						etype = "Label",
						name = "wb1",
						posX = 0.2816405,
						posY = 0.08397316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2891797,
						sizeY = 0.1284003,
						text = "家园等级：",
						color = "FFFFFF80",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						varName = "homeLevel",
						posX = 0.3799892,
						posY = 0.08397316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2891797,
						sizeY = 0.1284003,
						text = "0",
						color = "FFFFFF80",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb3",
						posX = 0.5777057,
						posY = 0.08397316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2891797,
						sizeY = 0.1284003,
						text = "善缘值：",
						color = "FFFFFF80",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb4",
						varName = "kindValue",
						posX = 0.6553841,
						posY = 0.08397316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2891797,
						sizeY = 0.1284003,
						text = "0",
						color = "FFFFFF80",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn",
						varName = "batchBtn",
						posX = 0.7636013,
						posY = 0.07997633,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1558442,
						sizeY = 0.1034483,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "btnz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9185178,
							sizeY = 1.0564,
							text = "一键互动",
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
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.9298405,
					posY = 0.2418038,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06009852,
					sizeY = 0.1137931,
					image = "tong#bz",
					imageNormal = "tong#bz",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8404599,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5304687,
				sizeY = 0.1236111,
				image = "jy#jiayuanfangding",
				scale9Left = 0.4,
				scale9Right = 0.4,
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
