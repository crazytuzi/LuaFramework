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
				varName = "imgBK",
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
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5167629,
				sizeY = 0.3328168,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "zza",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5030192,
					posY = 0.5155398,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902511,
					sizeY = 0.4893779,
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
						etype = "Image",
						name = "top1",
						posX = 0.5,
						posY = 1.221702,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4771912,
						sizeY = 0.2728776,
						image = "chu1#top3",
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "zi1",
							posX = 0.5,
							posY = 0.4375,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9655706,
							sizeY = 1.452217,
							text = "奖励物品",
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
				{
					prop = {
						etype = "Scroll",
						name = "lb1",
						varName = "content",
						posX = 0.5000001,
						posY = 0.4940777,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9393435,
						sizeY = 0.8336803,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.7285662,
					posY = 0.5181538,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6447972,
					sizeY = 0.9900046,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "des",
					posX = 0.5,
					posY = 0.1375374,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6501644,
					sizeY = 0.3916438,
					text = "排名越高奖励越好",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9528023,
					posY = 0.8708135,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09826799,
					sizeY = 0.2629074,
					image = "baishi#x",
					imageNormal = "baishi#x",
					disablePressScale = true,
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
