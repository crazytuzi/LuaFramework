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
			etype = "Grid",
			name = "jd1",
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wp1",
				varName = "ingotRoot",
				posX = 0.2490764,
				posY = 0.9466151,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1974032,
				sizeY = 0.09027778,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zsd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6886286,
					sizeY = 0.7230768,
					image = "tong#sld",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "diamond",
					posX = 0.4952299,
					posY = 0.4789422,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.456257,
					sizeY = 0.8239378,
					text = "3421万",
					color = "FFF4CA64",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF804000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "cz",
					varName = "add_diamond",
					posX = 0.4890573,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7707335,
					sizeY = 0.9438011,
					alphaCascade = true,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "tp",
						posX = 0.8633726,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2567448,
						sizeY = 0.7824333,
						image = "tong#jia",
						imageNormal = "tong#jia",
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "FrameAni",
					name = "yb",
					sizeXAB = 55.76301,
					sizeYAB = 58.5916,
					posXAB = 53.01218,
					posYAB = 31.27226,
					posX = 0.2098029,
					posY = 0.4811117,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2206897,
					sizeY = 0.9014091,
					effect = "21",
					alpha = 0,
					frameEnd = 16,
					frameName = "uieffect/yuanbao.png",
					delay = 0.1,
					frameWidth = 64,
					frameHeight = 64,
					column = 4,
					repeatLastFrame = 15,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx",
					posX = 0.2098029,
					posY = 0.4811118,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2206897,
					sizeY = 0.9014091,
					image = "uieffect/lizi041161121.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wp2",
				varName = "ingotLockRoot",
				posX = 0.4186115,
				posY = 0.9466151,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1974032,
				sizeY = 0.09027779,
				scale9 = true,
				disable = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zsd2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6886286,
					sizeY = 0.7230768,
					image = "tong#sld",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "diamondLock",
					posX = 0.4952299,
					posY = 0.4789422,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.456257,
					sizeY = 0.8239378,
					text = "22亿",
					color = "FFF4CA64",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF804000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "syb",
					posX = 0.2098029,
					posY = 0.4811117,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2206897,
					sizeY = 0.9014091,
					image = "uieffect/01.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo1",
						posX = 0.6747323,
						posY = 0.3538701,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.46875,
						sizeY = 0.4687499,
						image = "tb#tb_suo.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					posX = 0.2098029,
					posY = 0.481111,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2206897,
					sizeY = 0.8461537,
					image = "uieffect/lizi041161121.png",
					alpha = 0,
					blendFunc = 1,
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
