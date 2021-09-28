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
			name = "lbjd",
			varName = "rootLayer",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1835938,
			sizeY = 0.13,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zz",
				varName = "kungfuRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8974359,
				image = "wg2#jnd",
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
					name = "jnd",
					posX = 0.1689104,
					posY = 0.5343925,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3308038,
					sizeY = 0.8300543,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					varName = "skill_icon",
					posX = 0.1689104,
					posY = 0.5343925,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2340425,
					sizeY = 0.6547622,
					image = "skillelse#blx_3qingyunhuifeng",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "bt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.009115,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "skill_name",
					posX = 0.6286855,
					posY = 0.6782866,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7197378,
					sizeY = 0.6977946,
					text = "武功名字名字",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "s",
					varName = "score",
					posX = 0.8979998,
					posY = 0.3335514,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1811669,
					sizeY = 0.5227994,
					image = "pf#you",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bq",
					varName = "is_use",
					posX = 0.1803197,
					posY = 0.6966792,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.347961,
					sizeY = 0.5952381,
					image = "wg#sy",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zz2",
				varName = "expandRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8226496,
				image = "d#smd2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tz",
					posX = 0.5798447,
					posY = 0.487013,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.724548,
					sizeY = 0.6977946,
					text = "【点击拓展】",
					color = "FF43261D",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "djz",
					varName = "expandBtn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "dsa",
						posX = 0.1680866,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.280851,
						sizeY = 0.8181818,
						image = "wg2#jia",
						imageNormal = "wg2#jia",
						disableClick = true,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zz3",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 0.8226496,
				image = "d#smd2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tz2",
					posX = 0.5,
					posY = 0.5251383,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7947363,
					sizeY = 0.6977946,
					text = "空",
					color = "FF43261D",
					fontSize = 24,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
