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
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "czsl",
				varName = "CZSL",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5030629,
					posY = 0.7913808,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9938744,
					sizeY = 0.4331066,
					image = "kaigongsongli#kaigongsongli",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.6773024,
						posY = 0.7357919,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6183231,
						sizeY = 0.4972313,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = -0.3244555,
							posY = -0.7736271,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.7248285,
							text = "活动期限：",
							color = "FF5E006F",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb12",
							posX = -0.3244555,
							posY = -0.09153357,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.7248285,
							text = "活动说明：",
							fontOutlineEnable = true,
							fontOutlineColor = "FFBD0403",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb11",
							varName = "ActivitiesTime",
							posX = 0.08435237,
							posY = -0.7736271,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6524516,
							sizeY = 0.7248285,
							text = "3天23小时22分钟",
							color = "FF5E006F",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb13",
							varName = "ActivitiesContent",
							posX = 0.2332267,
							posY = -0.2836804,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9501999,
							sizeY = 0.6630784,
							text = "说明写两句",
							fontOutlineEnable = true,
							fontOutlineColor = "FFBD0403",
							fontOutlineSize = 2,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk4",
					posX = 0.4999731,
					posY = 0.2909168,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.5743719,
					image = "b#d5",
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
						name = "lb4",
						varName = "LuckyGiftList",
						posX = 0.5,
						posY = 0.4995568,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9664534,
					},
				},
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
