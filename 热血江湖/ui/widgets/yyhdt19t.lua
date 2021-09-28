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
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.4931263,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5117188,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9454544,
				image = "czhd#lb1",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					varName = "Whole",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "lq",
					varName = "GetBtn",
					posX = 0.8920919,
					posY = 0.4865088,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2086461,
					sizeY = 0.6226415,
					image = "chu1#fy2",
					imageNormal = "chu1#fy2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lqz",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8247252,
						sizeY = 1.143941,
						text = "领 取",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF8F4E1B",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "bt",
					varName = "GoalContent",
					posX = 0.2495963,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4044434,
					sizeY = 0.748539,
					text = "第一次",
					color = "FF914A15",
					fontSize = 22,
					fontOutlineColor = "FF00335D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ylq",
					varName = "GetImage",
					posX = 0.8917096,
					posY = 0.5151466,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2052717,
					sizeY = 0.7649565,
					image = "czt#ylq",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					posX = 0.2771342,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1221374,
					sizeY = 0.7692307,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "yb",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8,
						sizeY = 0.8,
						image = "tb#yuanbao",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl1",
						varName = "Count",
						posX = 0.5257913,
						posY = 0.2088165,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "1000",
						fontSize = 18,
						fontOutlineColor = "FF00152E",
						hTextAlign = 2,
						vTextAlign = 1,
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
