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
				posX = 0.5000001,
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
				name = "kk2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.393623,
				sizeY = 0.7738956,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhuxian",
				varName = "otherRoot",
				posX = 0.4992188,
				posY = 0.4986111,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.75,
				sizeY = 0.7619047,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "mhd4",
					posX = 0.5,
					posY = 0.2807788,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4793611,
					sizeY = 0.3440415,
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
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.3945579,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9740928,
						sizeY = 0.7557,
						horizontal = true,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "nr4",
						varName = "taskName",
						posX = 0.5,
						posY = 0.8741133,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.061587,
						sizeY = 0.4057859,
						text = "捐赠以下物品改善您和xxx的关系",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mjd",
					posX = 0.5,
					posY = 0.4260011,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4055117,
					sizeY = 0.06761695,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "yq",
						varName = "commitLabel",
						posX = 0.5,
						posY = 1.901877,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.013886,
						sizeY = 1.702317,
						text = "今日已捐赠：",
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
				posY = 0.8849047,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5113636,
					sizeY = 0.4807692,
					image = "biaoti#swjz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.6757059,
				posY = 0.85099,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.4992188,
				posY = 0.6357573,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3595208,
				sizeY = 0.1358877,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xhd",
					posX = 0.5413082,
					posY = 1.546642,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.48024,
					sizeY = 0.5200772,
					image = "d2#xhd",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "nr5",
					varName = "desc",
					posX = 0.503256,
					posY = 0.4815937,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.956735,
					sizeY = 0.875463,
					text = "剧情描述",
					color = "FF966856",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.2809819,
					posY = 1.537861,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2607638,
					sizeY = 1.226503,
					image = "bg2#huajianpingsu",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc",
					varName = "name",
					posX = 0.7149371,
					posY = 1.537861,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.738069,
					text = "势力声望名称",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tsz",
				posX = 0.5,
				posY = 0.1589828,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "点击道具选择数量进行捐赠",
				color = "FFC93034",
				hTextAlign = 1,
				vTextAlign = 1,
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
