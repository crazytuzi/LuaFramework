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
			name = "jd",
			posX = 0.5,
			posY = 0.4951067,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.334375,
			sizeY = 0.08743552,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sd",
				posX = 0.5,
				posY = 0.6397643,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9976636,
				sizeY = 0.7624666,
				image = "yaoqing#lb",
				scale9 = true,
				scale9Left = 0.25,
				scale9Right = 0.25,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sd1",
					varName = "btn",
					posX = 0.1263676,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0702576,
					sizeY = 0.6249999,
					image = "sz#xzd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sd2",
						varName = "flag",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8292683,
						sizeY = 0.8048781,
						image = "sz#xzt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "fg",
						varName = "txt",
						posX = 7.231598,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 9.830876,
						sizeY = 1.663918,
						text = "本次登录期间忽略好友请求",
						color = "FF966856",
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
	zdbd = {
		bd3 = {
			scale = {{0, {1,1,1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {100, {0}}, },
		},
	},
	zdbk = {
		bk2 = {
			alpha = {{0, {1}}, {400, {1}}, {1000, {0}}, },
		},
		bk7 = {
			alpha = {{0, {1}}, {500, {1}}, {1000, {0}}, },
		},
	},
	zdk = {
		bk8 = {
			scale = {{0, {5, 5, 1}}, {50, {3, 3, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {150, {1}}, {200, {0}}, },
		},
	},
	zdsztx = {
		bd4 = {
			scale = {{0, {1,1,1}}, {50, {1, 0.7, 1}}, {300, {0.8, 0.4, 1}}, },
			alpha = {{0, {1}}, {150, {1}}, {500, {0}}, },
		},
		ld4 = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.5, 1.5, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {200, {0}}, },
		},
	},
	kuang = {
		kuang = {
			alpha = {{0, {1}}, {800, {1}}, {1000, {0}}, },
		},
	},
	ss = {
		ss = {
			alpha = {{0, {1}}, {400, {0}}, },
			scale = {{0, {1, 0, 1}}, {200, {1,1,1}}, },
			move = {{0, {430.314,471.7226,0}}, {300, {430.314, 505, 0}}, },
		},
	},
	bk9 = {
		bk9 = {
			alpha = {{0, {1}}, {300, {1}}, {600, {0}}, },
		},
	},
	bao = {
		bao = {
			scale = {{0, {3, 3, 1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	bao1 = {
		bao3 = {
			scale = {{0, {3, 3, 1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {0}}, {500, {0}}, },
		},
		bao4 = {
			alpha = {{0, {1}}, {100, {1}}, {800, {0}}, },
		},
	},
	bao5 = {
		bao5 = {
			scale = {{0, {1,1,1}}, {150, {10, 10, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
		bao6 = {
			scale = {{0, {3, 3, 1}}, {500, {5, 5, 1}}, },
			alpha = {{0, {1}}, {500, {0}}, },
		},
	},
	bao7 = {
		bao7 = {
			scale = {{0, {1,1,1}}, {100, {8, 8, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	bao8 = {
		bao8 = {
			scale = {{0, {1, 1, 1}}, {400, {3, 3, 1}}, },
			alpha = {{0, {1}}, {400, {0}}, },
		},
	},
	c_zdqh = {
		{0,"zdbk", 1, 0},
		{0,"bao", 1, 150},
		{0,"bao1", 1, 200},
		{0,"bao5", 1, 200},
		{0,"bao8", 1, 150},
		{2,"lizi", 1, 250},
		{2,"lizi2", 1, 250},
		{2,"lz3", 1, 200},
		{2,"lz43", 1, 150},
		{2,"lz4", 1, 200},
	},
	c_lx = {
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{0,"kuang", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
