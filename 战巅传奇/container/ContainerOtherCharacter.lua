local ContainerOtherCharacter = {}

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

	{pos = GameConst.ITEM_JADE_PENDANT_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_SHIELD_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_MIRROR_ARMOUR_POSITION,	},
	{pos = GameConst.ITEM_FACE_CLOTH_POSITION,		},
	{pos = GameConst.ITEM_DRAGON_HEART_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_WOLFANG_POSITION,			noTipsBtn = true},
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
	
	{pos = GameConst.ITEM_ACHIEVE_MEDAL_POSITION,			},  --44
	--时装
	{pos = GameConst.ITEM_FASHION_WEAPON_POSITION,	etype = 31},
	{pos = GameConst.ITEM_FASHION_CLOTH_POSITION,	etype = 32},
	{pos = GameConst.ITEM_FASHION_WING_POSITION,	etype = 33},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI1,	etype = 34},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI2,	etype = 35},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI3,	etype = 36},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI4,	etype = 37},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI5,	etype = 38},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI6,	etype = 39},
}


local equipFlagRes = {

	[GameConst.ITEM_WEAPON_POSITION] 	=	"equip_flag_weapon",
	[GameConst.ITEM_CLOTH_POSITION] 	=	"equip_flag_cloth",
	[GameConst.ITEM_GLOVE1_POSITION] 	=	"equip_flag_glove",
	[GameConst.ITEM_RING1_POSITION] 	=	"equip_flag_ring",
	[GameConst.ITEM_BOOT_POSITION] 		=	"equip_flag_boot",
	[GameConst.ITEM_HAT_POSITION] 		=	"equip_flag_hat",	
	[GameConst.ITEM_NICKLACE_POSITION] 	=	"equip_flag_necklace",
	[GameConst.ITEM_GLOVE2_POSITION] 	=	"equip_flag_glove",
	[GameConst.ITEM_RING2_POSITION] 	=	"equip_flag_ring",
	[GameConst.ITEM_BELT_POSITION] 		=	"equip_flag_belt",

	--玉佩
	[GameConst.ITEM_JADE_PENDANT_POSITION] = "equip_flag_jade_pendant",
	--护盾
	[GameConst.ITEM_SHIELD_POSITION] = "equip_flag_shield",
	--护心镜
	[GameConst.ITEM_MIRROR_ARMOUR_POSITION] = "equip_flag_mirror_armour",
	--面巾
	[GameConst.ITEM_FACE_CLOTH_POSITION] = "equip_flag_face_cloth",
	--龙心
	[GameConst.ITEM_DRAGON_HEART_POSITION] = "equip_flag_dragon_heart",
	--狼牙
	[GameConst.ITEM_WOLFANG_POSITION] = "equip_flag_wolfang",
	--龙骨
	[GameConst.ITEM_DRAGON_BONE_POSITION] = "equip_flag_dragon_bone",
	--虎符
	[GameConst.ITEM_CATILLA_POSITION] = "equip_flag_catilla",
	
	[GameConst.ITEM_XUEFU_POSITION] = "equip_flag_xuefu",
	[GameConst.ITEM_FABAO_POSITION] = "equip_flag_fabao",
	[GameConst.ITEM_LINGFU_POSITION] = "equip_flag_lingfu",
	[GameConst.ITEM_YINGHUN_POSITION] = "equip_flag_yinghun",
	[GameConst.ITEM_BAODING_POSITION] = "equip_flag_baoding",
	[GameConst.ITEM_ZHANQI_POSITION] = "equip_flag_zhanqi",
	[GameConst.ITEM_SHOUHU_POSITION] = "equip_flag_shouhu",
	[GameConst.ITEM_ZHANDUN_POSITION] = "equip_flag_zhandun",
}



function ContainerOtherCharacter.initView(event)
	var = {
		xmlOtherCharacterPanel,
		mShowMainEquips = true,
		mShowSXEquips  = false,
		playerName,
		curWeaponId=nil,
		curClothId=nil,
		curwingId=nil,
	}

	var.xmlOtherCharacterPanel = GUIAnalysis.load("ui/layout/ContainerOtherCharacter.uif")
	if var.xmlOtherCharacterPanel then
		GameUtilSenior.asyncload(var.xmlOtherCharacterPanel, "bg", "ui/image/img_check_equip.jpg")

		var.xmlOtherCharacterPanel:getWidgetByName("box_role"):setLocalZOrder(5)

		ContainerOtherCharacter.refreshPanel()
		cc.EventProxy.new(GameSocket,var.xmlOtherCharacterPanel)
			:addEventListener(GameMessageCode.EVENT_PLAYEREQUIP_INFO, ContainerOtherCharacter.refreshPanel)
			:addEventListener(GameMessageCode.EVENT_PLAYER_INFO, ContainerOtherCharacter.updateInnerLooks)

		if event then
			var.playerName = event.pName
			-- if var.playerName then
			-- 	GameSocket:CheckPlayerEquip(event.pName)
			-- end
		end
		local btnSwitch = var.xmlOtherCharacterPanel:getWidgetByName("btn_switch_equips")
		btnSwitch:addClickEventListener( function (sender)
			var.mShowMainEquips = not var.mShowMainEquips
			ContainerOtherCharacter.updateBoxEquips()
		end)
		
		local btnSXSwitch = var.xmlOtherCharacterPanel:getWidgetByName("btn_sx_switch"):setPressedActionEnabled(true)
		btnSXSwitch:addClickEventListener( function (sender)
			var.mShowSXEquips = not var.mShowSXEquips
			ContainerOtherCharacter.updateBoxEquipsSX()
		end)
		
		local btn_shenqi = var.xmlOtherCharacterPanel:getWidgetByName("btn_shenqi"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_shenqi:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerShenQi", showOtherCharacter=true})
		end)
		
		local btn_shenyi = var.xmlOtherCharacterPanel:getWidgetByName("btn_shenyi"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_shenyi:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerShenYi", showOtherCharacter=true})
		end)
		
		local btn_tujian = var.xmlOtherCharacterPanel:getWidgetByName("btn_tujian"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_tujian:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerTuJian", showOtherCharacter=true})
		end)
		
		local btn_zhongshen = var.xmlOtherCharacterPanel:getWidgetByName("btn_zhongshen"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_zhongshen:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerZhongShen", showOtherCharacter=true})
		end)
		
		
		local btn_xz = var.xmlOtherCharacterPanel:getWidgetByName("btn_xz"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_xz:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_constellation", showOtherCharacter=true})
		end)
		
		local btn_jq = var.xmlOtherCharacterPanel:getWidgetByName("btn_jq"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_jq:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_jianqiao", showOtherCharacter=true})
		end)
		
		local btn_fj = var.xmlOtherCharacterPanel:getWidgetByName("btn_fj"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_fj:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_fojing", showOtherCharacter=true})
		end)
		
		local btn_xh = var.xmlOtherCharacterPanel:getWidgetByName("btn_xh"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_xh:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_xuanhun", showOtherCharacter=true})
		end)
		
					
		ContainerOtherCharacter.updateGameMoney()
		ContainerOtherCharacter.updateInnerLooks(event)
		var.xmlOtherCharacterPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerOtherCharacter.pushTabButtons)
		var.xmlOtherCharacterPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		
		
		return var.xmlOtherCharacterPanel
	end
end


function ContainerOtherCharacter.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag == 1 then
		var.xmlOtherCharacterPanel:getWidgetByName("box_fashion_equips"):hide()
		var.xmlOtherCharacterPanel:getWidgetByName("box_main_equips"):show()
	end
	if tag == 2 then
		var.xmlOtherCharacterPanel:getWidgetByName("box_fashion_equips"):show()
		var.xmlOtherCharacterPanel:getWidgetByName("box_main_equips"):hide()
	end
end

--金币刷新函数
function ContainerOtherCharacter:updateGameMoney()
	local panel = var.xmlOtherCharacterPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end


function ContainerOtherCharacter.onPanelOpen()

end

function ContainerOtherCharacter.onPanelClose()
	
end


function ContainerOtherCharacter.refreshPanel(event)
	local result = GameSocket.mOthersItems
	for i = 1, #equip_info do
		local equip_block = var.xmlOtherCharacterPanel:getWidgetByName("equip_"..i)
		local equipInfo = GameSocket.mOthersItems[equip_info[i].pos]
		local param
		if equipInfo then
			param = {
				parent = equip_block,
				-- pos	= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
				typeId = equipInfo.mTypeID,
				mLevel = equipInfo.mLevel,
				mZLevel= equipInfo.mZLevel,
				mShowEquipFlag  = true,
				tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
				compare = false
			}
			--var.xmlOtherCharacterPanel:getWidgetByName("equip_gray"..i):setVisible(false)
		else
			param = {
				parent = equip_block,
				-- pos	= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
				-- typeId = ,
				mShowEquipFlag  = true,
				tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
			}
			--var.xmlOtherCharacterPanel:getWidgetByName("equip_gray"..i):setVisible(true):loadTexture(equipFlagRes[equip_info[i].pos], ccui.TextureResType.plistType)
		end
		GUIItem.getItem(param)
	end
	--var.mShowMainEquips = true
	ContainerOtherCharacter.updateBoxEquips()
end

function ContainerOtherCharacter.updateInnerLooks(event)
	if var.xmlOtherCharacterPanel==nil then
		return
	end
	if var.xmlOtherCharacterPanel==nil then
		return
	end
	if var.xmlOtherCharacterPanel==nil then
		return
	end
	local img_role = var.xmlOtherCharacterPanel:getChildByName("img_role")
	local img_wing = var.xmlOtherCharacterPanel:getChildByName("img_wing")
	local img_weapon = var.xmlOtherCharacterPanel:getChildByName("img_weapon")

	--设置翅膀内观
	if not img_wing then
		img_wing = cc.Sprite:create()
		img_wing:addTo(var.xmlOtherCharacterPanel):align(display.CENTER, 524, 330):setName("img_wing")
	end
	local wing = GameSocket.m_PlayerEquip[var.playerName].wingLv+1000
	if wing then
		if wing~=var.curwingId then
		
			img_wing:removeChildByName("spriteEffect")
			GameUtilSenior.addEffect(img_wing,"spriteEffect",GROUP_TYPE.WING_REVIEW,wing,{x=0,y=-100},false,true)
				
			var.curwingId=wing
			
		end
	else
		img_wing:setTexture(nil)
		img_wing:setVisible(false)
		var.curwingId=nil
	end

	--设置衣服内观
	if not img_role then
		img_role = cc.Sprite:create()
		img_role:addTo(var.xmlOtherCharacterPanel):align(display.CENTER, 413, 260):setName("img_role")
	end

	local clothDef,clothId
	local isFashion = false
	local fashion = GameSocket.mOthersItems[GameConst.ITEM_FASHION_CLOTH_POSITION]
	local cloth = GameSocket.mOthersItems[GameConst.ITEM_CLOTH_POSITION]
	local gender = GameSocket.m_PlayerEquip[var.playerName].gender
	-- print("=======",fashion)
	if fashion then
		clothDef = GameSocket:getItemDefByID(fashion.mTypeID)
		if clothDef then
			clothId = gender == 200 and clothDef.mResMale or clothDef.mResFeMale
			isFashion = true
		end
	elseif cloth then
		clothDef = GameSocket:getItemDefByID(cloth.mTypeID)
		if clothDef then
			clothId = clothDef.mResMale
		else 
			clothId = cloth
		end
	end
	if not clothId then
		local luoti = gender == 200 and 20000 or 20000
		clothId = luoti
	end
	if clothId~=var.curClothId then
					
			img_role:removeChildByName("spriteEffect")
			if isFashion then
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.FDRESS_REVIEW,clothId,{x=-122,y=330},false,true)
			else
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.CLOTH_REVIEW,clothId,{x=-122,y=330},false,true)
			end			
			
			var.curClothId = clothId
	end

    --设置武器内观
	if not img_weapon then
		img_weapon = cc.Sprite:create()
		img_weapon:addTo(var.xmlOtherCharacterPanel):align(display.CENTER, 445, 270):setName("img_weapon")
	end
	local weapon = GameSocket.mOthersItems[GameConst.ITEM_WEAPON_POSITION]
	if weapon then
		--if weapon.mTypeID~=var.curWeaponId then
			local weaponDef = GameSocket:getItemDefByID(weapon.mTypeID)
					print("weapon.mResMale",weaponDef.mResMale)
			img_weapon:removeChildByName("spriteEffect")
			GameUtilSenior.addEffect(img_weapon,"spriteEffect",GROUP_TYPE.WEAPON_REVIEW,weaponDef.mResMale,{x=-159,y=327},false,true)
			
			var.curWeaponId=weapon.mTypeID
		--end
	else
		img_weapon:setTexture(nil)
		img_weapon:setVisible(false)
		var.curWeaponId=nil
	end
	if isFashion then
		img_weapon:setVisible(false)
	end
	local playerInfo = GameSocket.m_PlayerEquip[var.playerName]
	if var.playerName then
		var.xmlOtherCharacterPanel:getWidgetByName("lbl_role_name"):setString(var.playerName)
	end
	if playerInfo and playerInfo.guild~="" then
		var.xmlOtherCharacterPanel:getWidgetByName("lbl_guild_name"):setString(playerInfo.guild)
	else
		var.xmlOtherCharacterPanel:getWidgetByName("lbl_guild_name"):setString("暂无帮会")
	end

	local job = playerInfo.job or 100
	local imgJob = var.xmlOtherCharacterPanel:getWidgetByName("img_Job")
	local jobres = {"img_role_zhan","img_role_fa","img_role_dao"}
	---imgJob:loadTexture(jobres[job-99], ccui.TextureResType.plistType)
end

function ContainerOtherCharacter.updateBoxEquips()
	var.xmlOtherCharacterPanel:getWidgetByName("img_equips_type"):loadTexture(var.mShowMainEquips and "word_vice_equips" or "word_main_equips", ccui.TextureResType.plistType)
	local boxMainEquips = var.xmlOtherCharacterPanel:getWidgetByName("box_main_equips")
	local boxViceEquips = var.xmlOtherCharacterPanel:getWidgetByName("box_vice_equips")
	local boxSXEquips = var.xmlOtherCharacterPanel:getWidgetByName("box_sx_equips")
	if var.mShowMainEquips then
		boxSXEquips:hide()
		boxMainEquips:show()
		boxViceEquips:hide()
	else
		boxSXEquips:hide()
		boxMainEquips:hide()
		boxViceEquips:show()
	end
end


function ContainerOtherCharacter.updateBoxEquipsSX()
	--var.xmlOtherCharacterPanel:getWidgetByName("img_equips_type"):loadTexture(var.mShowMainEquips and "word_vice_equips" or "word_main_equips", ccui.TextureResType.plistType)
	local boxMainEquips = var.xmlOtherCharacterPanel:getWidgetByName("box_main_equips")
	local boxViceEquips = var.xmlOtherCharacterPanel:getWidgetByName("box_vice_equips")
	local boxSXEquips = var.xmlOtherCharacterPanel:getWidgetByName("box_sx_equips")
	if var.mShowSXEquips then
		boxSXEquips:show()
		boxMainEquips:hide()
		boxViceEquips:hide()
	else
		boxSXEquips:hide()
		boxMainEquips:show()
		boxViceEquips:hide()
	end
end


local btnArrs = {"btn_switch_equips"}
function ContainerOtherCharacter.initBtn()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btn_switch_equips" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "addGongXun"}))
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlOtherCharacterPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end




return ContainerOtherCharacter