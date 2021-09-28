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
				varName = "close",
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
			sizeX = 0.3793512,
			sizeY = 0.6,
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
				sizeX = 0.7009373,
				sizeY = 0.7510809,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5029382,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.776523,
					sizeY = 1.966302,
					image = "zhounianqingbj2#zhounianqingbj2",
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
						name = "mss",
						varName = "condition",
						posX = 0.5,
						posY = 0.4584663,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8460076,
						sizeY = 0.25,
						text = "完成对应任务即可增长对应进度，并领取奖励",
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
					name = "dk1",
					posX = 0.5,
					posY = 0.1152746,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37815,
					sizeY = 0.3138483,
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
						varName = "awardScroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9779047,
						sizeY = 0.9695086,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "receiveAwardBtn",
					posX = 0.8999999,
					posY = -0.1683938,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4492651,
					sizeY = 0.1787547,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8223209,
						sizeY = 1.037352,
						text = "领取奖励",
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
					etype = "Button",
					name = "btn2",
					varName = "receiveTaskBtn",
					posX = 0.09999996,
					posY = -0.1683938,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4492651,
					sizeY = 0.1787547,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8223209,
						sizeY = 1.037352,
						text = "领取任务",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB35F1D",
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
					name = "gxd",
					posX = 0.2946688,
					posY = 0.8723242,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08814358,
					sizeY = 0.09245934,
					image = "chu1#gxd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj",
						varName = "selectIcon1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.266667,
						sizeY = 1.133333,
						image = "chu1#dj",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "gxz",
						varName = "taksName1",
						posX = 3.661199,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.526398,
						sizeY = 1.622539,
						text = "xx任务",
						color = "FF7A5047",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "gxan",
						varName = "task1Btn",
						posX = 1.964015,
						posY = 0.5292293,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.925702,
						sizeY = 1.788927,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gxd2",
					posX = 0.2946688,
					posY = 0.7184777,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08814358,
					sizeY = 0.09245934,
					image = "chu1#gxd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "selectIcon2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.266667,
						sizeY = 1.133333,
						image = "chu1#dj",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "gxz2",
						varName = "taksName2",
						posX = 3.661199,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.526398,
						sizeY = 1.622539,
						text = "xx任务",
						color = "FF7A5047",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "gxan2",
						varName = "task2Btn",
						posX = 1.964015,
						posY = 0.5292293,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.925702,
						sizeY = 1.788927,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gxd3",
					posX = 0.2946687,
					posY = 0.5646311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08814358,
					sizeY = 0.09245934,
					image = "chu1#gxd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "selectIcon3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.266667,
						sizeY = 1.133333,
						image = "chu1#dj",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "gxz3",
						varName = "taksName3",
						posX = 3.661199,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.526398,
						sizeY = 1.622539,
						text = "xx任务",
						color = "FF7A5047",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "gxan3",
						varName = "task3Btn",
						posX = 1.964015,
						posY = 0.5292293,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.925702,
						sizeY = 1.788927,
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
