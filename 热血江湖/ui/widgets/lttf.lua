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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.408703,
			sizeY = 0.1916667,
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
				sizeY = 0.9057969,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ltd",
					posX = 0.4057345,
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
						posX = 0.5,
						posY = 0.6624014,
						anchorX = 0.5,
						anchorY = 1,
						sizeX = 0.9660434,
						sizeY = 0.8110576,
						image = "ltk#guguji",
						scale9 = true,
						scale9Top = 0.7,
						scale9Bottom = 0.2,
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "ltnr",
						varName = "text",
						posX = 0.5147258,
						posY = 0.2166767,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8184057,
						sizeY = 0.6954087,
						text = "五大服务费无法无法我付完费玩法为发我份慰安妇而法尔法尔",
						color = "FF634624",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "pd",
						varName = "set_image",
						posX = 0.89,
						posY = 0.8180949,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1666425,
						sizeY = 0.18806,
						image = "lt#dw",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "fromName",
						posX = 0.5,
						posY = 0.820664,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5922352,
						sizeY = 0.4036733,
						text = "公认热血最强玩家",
						color = "FF964C4C",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz2",
						varName = "chattime",
						posX = 0.126,
						posY = 0.8206643,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2507591,
						sizeY = 0.4526497,
						text = "13:06",
						color = "FF4C6644",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsxia",
						varName = "downImg",
						posX = 0.1340379,
						posY = -0.1546462,
						anchorX = 0.5,
						anchorY = 0,
						visible = false,
						sizeX = 0.3018886,
						sizeY = 0.9191986,
						image = "ltk#gugujif",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsshang",
						varName = "upImg",
						posX = 0.1340379,
						posY = 0.6749232,
						anchorX = 0.5,
						anchorY = 1,
						visible = false,
						sizeX = 0.3018886,
						sizeY = 0.9191986,
						image = "ltk#gugujif",
						flippedX = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "txb_img",
					posX = 0.9,
					posY = 0.5343206,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2381319,
					sizeY = 0.7949832,
					image = "zdtx#txd",
				},
				children = {
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
						name = "vip",
						varName = "vipIcon",
						posX = 0.5111111,
						posY = -0.010714,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7786394,
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
