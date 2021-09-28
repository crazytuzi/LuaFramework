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
			name = "layoutRoot",
			posX = 0.5,
			posY = 0.4837063,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.408703,
			sizeY = 0.1920441,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "ltwz",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 0.8244635,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ltd",
					posX = 0.5938336,
					posY = 0.4688649,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7914902,
					sizeY = 0.8877298,
					scale9 = true,
					scale9Left = 0.15,
					scale9Right = 0.15,
					scale9Top = 0.45,
					scale9Bottom = 0.2,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ltd2",
						varName = "bg_img",
						posX = 0.5000028,
						posY = 0.6624014,
						anchorX = 0.5,
						anchorY = 1,
						sizeX = 0.9660434,
						sizeY = 0.8830523,
						image = "ltk#guguji",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "ltnr",
						varName = "text",
						posX = 0.4889514,
						posY = 0.2166764,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.826604,
						sizeY = 0.6954087,
						text = "快来加入我的帮派吧",
						color = "FF634624",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "pd",
						varName = "set_image",
						posX = 0.1111736,
						posY = 0.8180949,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1666425,
						sizeY = 0.2060456,
						image = "lt#sj",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "fromName",
						posX = 0.5,
						posY = 0.8180947,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5810848,
						sizeY = 0.4036733,
						text = "[死恩国资]公认热血最强玩家",
						color = "FF964C4C",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz2",
						varName = "chattime",
						posX = 0.8733564,
						posY = 0.8180944,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2507591,
						sizeY = 0.4526497,
						text = "13:06",
						color = "FF4C6644",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsxia",
						varName = "downImg",
						posX = 0.8735793,
						posY = -0.2194676,
						anchorX = 0.5,
						anchorY = 0,
						visible = false,
						sizeX = 0.3018886,
						sizeY = 1.007893,
						image = "ltk#gugujif",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsshang",
						varName = "upImg",
						posX = 0.8735792,
						posY = 0.6726596,
						anchorX = 0.5,
						anchorY = 1,
						visible = false,
						sizeX = 0.3018886,
						sizeY = 1.007893,
						image = "ltk#xiongmaof",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "joinBtn",
						posX = 0.5137535,
						posY = 0.2130238,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.940957,
						sizeY = 0.8633977,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "txb_img",
					posX = 0.1029549,
					posY = 0.560451,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2381318,
					sizeY = 0.8710132,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "txa",
						varName = "btn",
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
						name = "xt",
						varName = "newIcon",
						posX = 0.4976691,
						posY = 0.5398087,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.5699322,
						sizeY = 0.71,
						image = "jstx2#xt",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "vip",
						varName = "vipIcon",
						posX = 0.5,
						posY = -0.010714,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7786397,
						sizeY = 0.43,
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
