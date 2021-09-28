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
				name = "wp3",
				varName = "coinRoot",
				posX = 0.5881464,
				posY = 0.9466151,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1974032,
				sizeY = 0.09027779,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zsd3",
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
					name = "sl3",
					varName = "coin",
					posX = 0.4952299,
					posY = 0.4789422,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.456257,
					sizeY = 0.8239378,
					text = "10.3万",
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
					name = "cz2",
					varName = "add_coin",
					posX = 0.4890573,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7707335,
					sizeY = 0.9438011,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "j2",
						posX = 0.8633726,
						posY = 0.4999995,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2567448,
						sizeY = 0.7824333,
						image = "tong#jia",
						imageNormal = "tong#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tq",
					posX = 0.2098029,
					posY = 0.4811117,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2206897,
					sizeY = 0.9014091,
					image = "uieffect/tq.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx2",
					posX = 0.2098029,
					posY = 0.4811119,
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
		{
			prop = {
				etype = "Image",
				name = "wp4",
				varName = "coinLockRoot",
				posX = 0.7576817,
				posY = 0.9466151,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1974032,
				sizeY = 0.09027779,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zsd4",
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
					name = "sl4",
					varName = "coinLock",
					posX = 0.5091326,
					posY = 0.4789422,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6661124,
					sizeY = 0.8239378,
					text = "9942万",
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
					name = "stq",
					posX = 0.2098029,
					posY = 0.4811117,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2206897,
					sizeY = 0.9014091,
					image = "uieffect/tq.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo2",
						posX = 0.7009149,
						posY = 0.3206291,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4687501,
						sizeY = 0.46875,
						image = "tb#tb_suo.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx3",
					posX = 0.209803,
					posY = 0.4811112,
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
