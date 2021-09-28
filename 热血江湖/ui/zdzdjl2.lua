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
			name = "jd",
			varName = "spiritSkill",
			posX = 0.4929691,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "rootBg",
				posX = 0.5842898,
				posY = 0.3063759,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.2800513,
				sizeY = 0.2198748,
				image = "d#tst",
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an4",
				varName = "descBtn",
				posX = 0.5226998,
				posY = 0.3035196,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.053125,
				sizeY = 0.1349206,
				image = "chu1#sx2",
				imageNormal = "chu1#sx2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a10",
				varName = "gundong2",
				posX = 0.442643,
				posY = 0.3035196,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07020731,
				sizeY = 0.1785714,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jndt6",
					posX = 0.5,
					posY = 0.5000002,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9114584,
					sizeY = 0.9100949,
					image = "zdte#jineng2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnwk9",
					varName = "uniqueskillk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.889757,
					sizeY = 0.8884259,
					image = "zdjn#bai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t12",
					varName = "dodgeIcon2",
					posX = 0.5,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7269968,
					sizeY = 0.725909,
				},
			},
			{
				prop = {
					etype = "ProgressTimer",
					name = "lq10",
					varName = "dodgeCool2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9,
					sizeY = 0.8986536,
					image = "zd#sbdt",
					percent = 100,
					reverse = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zzz7",
					varName = "cool1",
					posX = 0.5336735,
					posY = 0.4921957,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.68,
					sizeY = 0.706509,
					image = "zd#zd_jnd2.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz10",
					varName = "dodgeCoolWord2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8261181,
					sizeY = 0.7797815,
					text = "23",
					fontSize = 40,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dir",
				varName = "guide",
				posX = 0.3714392,
				posY = 0.3069374,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04652114,
				sizeY = 0.1174267,
				image = "zdte2#lv",
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
