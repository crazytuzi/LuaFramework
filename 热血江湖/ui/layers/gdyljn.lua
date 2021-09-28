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
				etype = "Grid",
				name = "dk",
				posX = 0.4184926,
				posY = 0.1993063,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3080878,
				sizeY = 0.1375,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t1",
					varName = "bg1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.5443009,
					sizeY = 0.5555556,
					image = "guidaoyuling1#zdjndb",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t2",
					varName = "bg2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6835439,
					sizeY = 0.5555556,
					image = "guidaoyuling1#zdjndb",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t3",
					varName = "bg3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8378776,
					sizeY = 0.5555556,
					image = "guidaoyuling1#zdjndb",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt",
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
						etype = "Scroll",
						name = "lb",
						varName = "scroll1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4987338,
						sizeY = 0.5028098,
						horizontal = true,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6227839,
						sizeY = 0.4949495,
						horizontal = true,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb3",
						varName = "scroll3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7386835,
						sizeY = 0.4949495,
						horizontal = true,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "ad",
				varName = "animate",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04296875,
				sizeY = 0.0625,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "boom",
					posX = 0.400127,
					posY = 0.4726532,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.22,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "fangshe01",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2,
						sizeY = 2,
						image = "uieffect/fangsheguang001911.png",
						alpha = 0,
						blendFunc = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "glow01",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2,
						sizeY = 2,
						image = "uieffect/guangyun0145.png",
						alpha = 0,
						blendFunc = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	boom = {
		fangshe01 = {
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
			scale = {{0, {0, 0, 1}}, {100, {1.5, 1.5, 1}}, {400, {2, 2, 1}}, },
		},
		glow01 = {
			alpha = {{0, {0}}, {150, {0.7}}, {400, {0}}, },
			scale = {{0, {0.8, 0.8, 1}}, {500, {1.1, 1.1, 1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_boom = {
		{0,"boom", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
