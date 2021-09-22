local ContainerXuanHun = {}
local var = {}

local equip_info = {
	{pos = GameConst.ITEM_WEAPON_POSITION,	etype = GameConst.EQUIP_TAG.WEAPON},
	{pos = GameConst.ITEM_CLOTH_POSITION,	etype = GameConst.EQUIP_TAG.CLOTH},
	{pos = GameConst.ITEM_GLOVE1_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING1_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BOOT_POSITION,	etype = GameConst.EQUIP_TAG.BOOT},

	{pos = GameConst.ITEM_HAT_POSITION,		etype = GameConst.EQUIP_TAG.HAT},
	{pos = GameConst.ITEM_NICKLACE_POSITION,etype = GameConst.EQUIP_TAG.NECKLACE},
	{pos = GameConst.ITEM_GLOVE2_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING2_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BELT_POSITION,	etype = GameConst.EQUIP_TAG.BELT},
	

	--{pos = GameConst.ITEM_JADE_PENDANT_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_JADE_PENDANT_POSITION,	},
	--{pos = GameConst.ITEM_SHIELD_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_SHIELD_POSITION,			},
	{pos = GameConst.ITEM_MIRROR_ARMOUR_POSITION,	},
	{pos = GameConst.ITEM_FACE_CLOTH_POSITION,		},
	--{pos = GameConst.ITEM_DRAGON_HEART_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_DRAGON_HEART_POSITION,	},
	--{pos = GameConst.ITEM_WOLFANG_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_WOLFANG_POSITION,	},
	{pos = GameConst.ITEM_DRAGON_BONE_POSITION,		},
	{pos = GameConst.ITEM_CATILLA_POSITION,			},
	
	{pos = GameConst.ITEM_XUEFU_POSITION,	etype = GameConst.EQUIP_TAG.XUEFU},
	{pos = GameConst.ITEM_FABAO_POSITION,	etype = GameConst.EQUIP_TAG.FABAO},
	{pos = GameConst.ITEM_LINGFU_POSITION,	etype = GameConst.EQUIP_TAG.LINGFU},
	{pos = GameConst.ITEM_YINGHUN_POSITION,	etype = GameConst.EQUIP_TAG.YINGHUN},
	{pos = GameConst.ITEM_BAODING_POSITION,	etype = GameConst.EQUIP_TAG.BAODING},
	{pos = GameConst.ITEM_ZHANQI_POSITION,	etype = GameConst.EQUIP_TAG.ZHANQI},
	{pos = GameConst.ITEM_SHOUHU_POSITION,	etype = GameConst.EQUIP_TAG.SHOUHU},
	{pos = GameConst.ITEM_ZHANDUN_POSITION,	etype = GameConst.EQUIP_TAG.ZHANDUN},
	
	{pos = GameConst.ITEM_ZHUZHUANGPLUS1_POSITION,	etype = GameConst.EQUIP_TAG.ZHUZHUANGPLUS1},
	{pos = GameConst.ITEM_ZHUZHUANGPLUS2_POSITION,	etype = GameConst.EQUIP_TAG.ZHUZHUANGPLUS2},
	
	{pos = GameConst.ITEM_FUZHUANGPLUS1_POSITION,	etype = GameConst.EQUIP_TAG.FUZHUANGPLUS1},
	{pos = GameConst.ITEM_FUZHUANGPLUS2_POSITION,	etype = GameConst.EQUIP_TAG.FUZHUANGPLUS2},
	{pos = GameConst.ITEM_FUZHUANGPLUS3_POSITION,	etype = GameConst.EQUIP_TAG.FUZHUANGPLUS3},
	
	{pos = GameConst.ITEM_SRSX1_POSITION,	etype = GameConst.EQUIP_TAG.SRSX1},
	{pos = GameConst.ITEM_SRSX2_POSITION,	etype = GameConst.EQUIP_TAG.SRSX2},
	{pos = GameConst.ITEM_SRSX3_POSITION,	etype = GameConst.EQUIP_TAG.SRSX3},
	{pos = GameConst.ITEM_SRSX4_POSITION,	etype = GameConst.EQUIP_TAG.SRSX4},
	{pos = GameConst.ITEM_SRSX5_POSITION,	etype = GameConst.EQUIP_TAG.SRSX5},
	{pos = GameConst.ITEM_SRSX6_POSITION,	etype = GameConst.EQUIP_TAG.SRSX6},
	{pos = GameConst.ITEM_SRSX7_POSITION,	etype = GameConst.EQUIP_TAG.SRSX7},
	{pos = GameConst.ITEM_SRSX8_POSITION,	etype = GameConst.EQUIP_TAG.SRSX8},
	{pos = GameConst.ITEM_SRSX9_POSITION,	etype = GameConst.EQUIP_TAG.SRSX9},
	{pos = GameConst.ITEM_SRSX10_POSITION,	etype = GameConst.EQUIP_TAG.SRSX10},
	{pos = GameConst.ITEM_SRSX11_POSITION,	etype = GameConst.EQUIP_TAG.SRSX11},
	{pos = GameConst.ITEM_SRSX12_POSITION,	etype = GameConst.EQUIP_TAG.SRSX12},
	
	
	{pos = GameConst.ITEM_ACHIEVE_MEDAL_POSITION,			},
}


function ContainerXuanHun.initView(extend)
	var = {
		xmlPanel,
		
	}

	--刷新装备
	local function updateEquips()
		for i = 1, #equip_info do
			local equip_block = var.xmlPanel:getWidgetByName("equip_"..i)
			if equip_block then
				-- ccui.Widget:create():setContentSize(equip_block:getContentSize()):setName("guideWidget"):align(display.LEFT_BOTTOM, 0, 0):addTo(equip_block)
				equip_block.etype = equip_info[i].etype
				local param = {
					parent			= equip_block,
					pos				= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
					tipsPos			= cc.p(display.cx-var.xmlPanel:getContentSize().width/2+(i<=5 and 290 or 0), display.cy-var.xmlPanel:getContentSize().height/2),
					tipsAnchor		= cc.p(0,0),
					mShowEquipFlag  = true,
					tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
					showInnerLook = true,   --格子里显示内观
				}
				GUIItem.getItem(param)
			end
		end
	end
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerXuanHun.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "bg", "ui/image/v4_hunjia_bg.png")
		updateEquips()
		return var.xmlPanel
	end
end


function ContainerXuanHun.onPanelOpen(extend)
	
end

function ContainerXuanHun.onPanelClose()

end

return ContainerXuanHun