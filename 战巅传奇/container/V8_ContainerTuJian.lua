local V8_ContainerTuJian = {}
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


function V8_ContainerTuJian.initView(extend)
	var = {
		xmlTuJianPanel,
		showOtherCharacter,
	}
	var.showOtherCharacter = extend.showOtherCharacter
	
	cc.EventProxy.new(GameSocket, var.xmlPageFashion)
		:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, V8_ContainerTuJian.showAnimal)
		
	--刷新装备
	local function updateEquips()
		if var.showOtherCharacter==nil or var.showOtherCharacter=="" or var.showOtherCharacter==false then
			for i = 1, #equip_info do
				local equip_block = var.xmlTuJianPanel:getWidgetByName("equip_"..i)
				if equip_block then
					-- ccui.Widget:create():setContentSize(equip_block:getContentSize()):setName("guideWidget"):align(display.LEFT_BOTTOM, 0, 0):addTo(equip_block)
					equip_block.etype = equip_info[i].etype
					local param = {
						parent			= equip_block,
						pos				= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
						tipsPos			= cc.p(display.cx-var.xmlTuJianPanel:getContentSize().width/2+(i<=5 and 290 or 0), display.cy-var.xmlTuJianPanel:getContentSize().height/2),
						tipsAnchor		= cc.p(0,0),
						mShowEquipFlag  = true,
						tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
						showInnerLook = true,   --格子里显示内观
					}
					GUIItem.getItem(param)
				end
			end
		else
			--别人的
			for i = 1, #equip_info do
				local equip_block = var.xmlTuJianPanel:getWidgetByName("equip_"..i)
				local equipInfo = GameSocket.mOthersItems[equip_info[i].pos]
				local param
				if i==32 then
					--GameUtilSenior.print_table( equipInfo )
				end
				if equipInfo then  
					param = {
						parent = equip_block,
						-- pos	= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
						typeId = equipInfo.mTypeID,
						mLevel = equipInfo.mLevel,
						mZLevel= equipInfo.mZLevel,
						mShowEquipFlag  = true,
						tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
						showInnerLook = true,   --格子里显示内观
					}
					--var.xmlTuJianPanel:getWidgetByName("equip_gray"..i):setVisible(false)
				else
					param = {
						parent = equip_block,
						-- pos	= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
						-- typeId = ,
						mShowEquipFlag  = true,
						tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
					}
					--var.xmlTuJianPanel:getWidgetByName("equip_gray"..i):setVisible(true):loadTexture(equipFlagRes[equip_info[i].pos], ccui.TextureResType.plistType)
				end
				GUIItem.getItem(param)
			end
		end
	end
	
	var.xmlTuJianPanel = GUIAnalysis.load("ui/layout/V8_ContainerTuJian.uif")
	if var.xmlTuJianPanel then
		--GameUtilSenior.asyncload(var.xmlTuJianPanel, "bg", "ui/image/v4_hunjia_bg.png")
		updateEquips()
		V8_ContainerTuJian.showAnimal()
		return var.xmlTuJianPanel
	end
end



function V8_ContainerTuJian.showAnimal()
	for i=11,16,1 do
		if var.xmlTuJianPanel~=nil and var.xmlTuJianPanel:getWidgetByName("equip_"..i.."_animal")~=nil then
			var.xmlTuJianPanel:getWidgetByName("equip_"..i.."_animal"):setVisible(false)
		end
	end
	for i = 1, #equip_info do
		if var.xmlTuJianPanel~=nil and var.xmlTuJianPanel:getWidgetByName("equip_"..i.."_animal")~=nil then
			local equipInfo = {}
			if var.showOtherCharacter==nil or var.showOtherCharacter=="" or var.showOtherCharacter==false then
				equipInfo = GameSocket:getNetItem(equip_info[i].pos)
			else
				equipInfo = GameSocket.mOthersItems[equip_info[i].pos]
			end
			if equipInfo then
				local title_animal = var.xmlTuJianPanel:getWidgetByName("equip_"..i.."_animal")
				title_animal:setVisible(true)
				title_animal:setLocalZOrder(100)
				local startNum = 7
				local function startShowTitleBg()
				
					local filepath = string.format("V8_ContainerTuJian_%d.png",startNum)
					title_animal:loadTexture(filepath,ccui.TextureResType.plistType)
					
					startNum= startNum+1
					if startNum ==20 then
						startNum =7
					end
				end
				title_animal:stopAllActions()
				title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(18)))
			end
		end
	end
end

function V8_ContainerTuJian.onPanelOpen(extend)
	
end

function V8_ContainerTuJian.onPanelClose()

end

return V8_ContainerTuJian