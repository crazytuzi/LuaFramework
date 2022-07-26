require"Lang"
UIArenaCheck = {
    playerId = nil
}

local ui_scrollView = nil
local ui_iconItem = nil
local ui_sectorView = nil

local ui_propPanel = nil

local ui_cardTouchPanel = nil
local ui_cardInfoItem = nil

local _curShowCardIndex = 1
local _activateLuckNum = 0 --激活缘分数
local _cardAnimations = nil

local function setScrollViewFocus(isJumpTo)
	local childs = ui_scrollView:getChildren()
	for key, obj in pairs(childs) do
		local ui_focus = obj:getChildByName("image_choose")
		if _curShowCardIndex == key then
			ui_focus:setVisible(true)
			
			local contaniner = ui_scrollView:getInnerContainer()
			local w = (contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
			local dt
			if w == 0 then
				dt = 0
			else
				dt = (obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
				if dt < 0 then
					dt = 0
				end
			end
			if isJumpTo then
				ui_scrollView:jumpToPercentHorizontal(dt * 100)
			else
				ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
			end
			
		else
			ui_focus:setVisible(false)
		end
	end
end

local function setCardEquipInfo(touchEnabled, _instFormationId, instCardId)
	local ui_btnWeapon = ui_propPanel:getChildByName("image_weapon") --武器
	local ui_btnCorselet = ui_propPanel:getChildByName("image_corselet") --护甲
	local ui_btnHelm = ui_propPanel:getChildByName("image_helm") --头盔
	local ui_btnNecklace = ui_propPanel:getChildByName("image_necklace") --饰品
	local ui_treasurePanel = ui_propPanel:getChildByName("image_di_treasure")
	local ui_btnTreasure = ui_treasurePanel:getChildByName("image_frame_treasure") --法宝
	local ui_gongfaPanel = ui_propPanel:getChildByName("image_di_gongfa")
	local ui_btnGongfa = ui_gongfaPanel:getChildByName("image_frame_gongfa") --功法
	
	ui_btnWeapon:setTag(0)
	ui_btnWeapon:loadTexture("ui/quality_small_white.png")
	local ui_weaponIcon = ui_btnWeapon:getChildByName("image_weapon") --武器图标
	ui_weaponIcon:getChildByName("image_lv"):setVisible(false)
	ui_weaponIcon:loadTexture("ui/frame_tianjia.png")
	local ui_weaponName = ccui.Helper:seekNodeByName(ui_btnWeapon, "text_name_weapon")
	ui_weaponName:setString(Lang.ui_arena_check1)
	
	ui_btnCorselet:setTag(0)
	ui_btnCorselet:loadTexture("ui/quality_small_white.png")
	local ui_corseletIcon = ui_btnCorselet:getChildByName("image_corselet") --护甲图标
	ui_corseletIcon:getChildByName("image_lv"):setVisible(false)
	ui_corseletIcon:loadTexture("ui/frame_tianjia.png")
	local ui_corseletName = ccui.Helper:seekNodeByName(ui_btnCorselet, "text_name_corselet")
	ui_corseletName:setString(Lang.ui_arena_check2)
	
	ui_btnHelm:setTag(0)
	ui_btnHelm:loadTexture("ui/quality_small_white.png")
	local ui_helmIcon = ui_btnHelm:getChildByName("image_helm") --头盔图标
	ui_helmIcon:getChildByName("image_lv"):setVisible(false)
	ui_helmIcon:loadTexture("ui/frame_tianjia.png")
	local ui_helmName = ccui.Helper:seekNodeByName(ui_btnHelm, "text_name_helm")
	ui_helmName:setString(Lang.ui_arena_check3)
	
	ui_btnNecklace:setTag(0)
	ui_btnNecklace:loadTexture("ui/quality_small_white.png")
	local ui_necklaceIcon = ui_btnNecklace:getChildByName("image_necklace") --饰品图标
	ui_necklaceIcon:getChildByName("image_lv"):setVisible(false)
	ui_necklaceIcon:loadTexture("ui/frame_tianjia.png")
	local ui_necklaceName = ccui.Helper:seekNodeByName(ui_btnNecklace, "text_name_necklace")
	ui_necklaceName:setString(Lang.ui_arena_check4)
	
	ui_btnTreasure:setTag(0)
	ui_btnTreasure:loadTexture("ui/gold_d.png")
	local ui_treasureIcon = ui_treasurePanel:getChildByName("image_treasure") --法宝图标
	ui_treasurePanel:getChildByName("image_lv"):setVisible(false)
	ui_treasureIcon:loadTexture("ui/frame_tianjia.png")
	local ui_treasureName = ccui.Helper:seekNodeByName(ui_treasurePanel, "text_name_treasure")
	ui_treasureName:setString(Lang.ui_arena_check5)
	
	ui_btnGongfa:setTag(0)
	ui_btnGongfa:loadTexture("ui/gold_d.png")
	local ui_gongfaIcon = ui_gongfaPanel:getChildByName("image_gongfa") --功法图标
	ui_gongfaPanel:getChildByName("image_lv"):setVisible(false)
	ui_gongfaIcon:loadTexture("ui/frame_tianjia.png")
	local ui_gongfaName = ccui.Helper:seekNodeByName(ui_gongfaPanel, "text_name_gongfa")
	ui_gongfaName:setString(Lang.ui_arena_check6)
	
    ui_btnCorselet:getChildByName("image_star"):setVisible(false)
    ui_btnHelm:getChildByName("image_star"):setVisible(false)
    ui_btnNecklace:getChildByName("image_star"):setVisible(false)
    ui_btnWeapon:getChildByName("image_star"):setVisible(false)

    ui_btnCorselet:getChildByName("image_jinglian"):setVisible(false)
    ui_btnHelm:getChildByName("image_jinglian"):setVisible(false)
    ui_btnNecklace:getChildByName("image_jinglian"):setVisible(false)
    ui_btnWeapon:getChildByName("image_jinglian"):setVisible(false)

    utils.addFrameParticle( ui_corseletIcon , false ) 
    utils.addFrameParticle( ui_helmIcon , false ) 
    utils.addFrameParticle( ui_necklaceIcon , false ) 
    utils.addFrameParticle( ui_weaponIcon , false )   

    if pvp.InstPlayerEquipBox then
        for _ipebKey, _ipebObj in pairs(pvp.InstPlayerEquipBox) do
            if _instFormationId == _ipebObj.int["3"] then
                local getJLQualityImage = function(_ipebInstData)
                    local _jlQualityImage = nil
                    if _ipebInstData and #_ipebInstData > 0 then
                        local _perfectLvStr = ""
                        for _iii, _ooo in pairs(_ipebInstData) do
                            local _tempOOO = utils.stringSplit(_ooo, "_")
                            local _lvId = tonumber(_tempOOO[1])
                            local _state = tonumber(_tempOOO[2]) --0可精炼 1普通 2优良 3完美
                            if _state == 3 then
                                _perfectLvStr = _perfectLvStr .. _lvId
                                if _lvId % 5 == 0 then
                                    local _tempStr = ""
                                    for _i = 1, _lvId do
                                        _tempStr = _tempStr .. _i
                                    end
                                    if _perfectLvStr == _tempStr then
                                        if _lvId == 5 then
                                            _jlQualityImage = "ui/qx_green.png"
                                        elseif _lvId == 10 then
                                            _jlQualityImage = "ui/qx_blue.png"
                                        elseif _lvId == 15 then
                                            _jlQualityImage = "ui/qx_purple.png"
                                        elseif _lvId == 20 then
                                            _jlQualityImage = "ui/qx_red.png"
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return _jlQualityImage
                end

                --武器
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["4"], ";"))
                if _jlImage then
                    ui_btnWeapon:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnWeapon:getChildByName("image_jinglian"):setVisible(true)
                end
                --护甲
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["5"], ";"))
                if _jlImage then
                    ui_btnCorselet:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnCorselet:getChildByName("image_jinglian"):setVisible(true)
                end
                --头盔
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["6"], ";"))
                if _jlImage then
                    ui_btnHelm:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnHelm:getChildByName("image_jinglian"):setVisible(true)
                end
                --饰品
                local _jlImage = getJLQualityImage(utils.stringSplit(_ipebObj.string["7"], ";"))
                if _jlImage then
                    ui_btnNecklace:getChildByName("image_jinglian"):loadTexture(_jlImage)
                    ui_btnNecklace:getChildByName("image_jinglian"):setVisible(true)
                end
                break
            end
        end
    end

	if _instFormationId and pvp.InstPlayerLineup then
		for key, obj in pairs(pvp.InstPlayerLineup) do
			if _instFormationId == obj.int["3"] then
				local equipTypeId = obj.int["4"] --装备类型Id
				local instEquipId = obj.int["5"] --装备实例Id
				local instEquipData = pvp.InstPlayerEquip[tostring(instEquipId)] --装备实例数据
				local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])] --装备字典数据
				local equipLevel = instEquipData.int["5"] --装备等级

                local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
                if equipAdvanceId == nil then
                    equipAdvanceId = 0
                end
		        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表

				local qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small)
				local qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipData.equipQualityId)
                if dictEquipAdvanceData then
                    qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small)
                    qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipAdvanceData.equipQualityId)
                end
				if equipTypeId == StaticEquip_Type.outerwear then --护甲
					ui_btnCorselet:setTag(instEquipId)
                    ui_btnCorselet:loadTexture(qualityImage)
                    ui_corseletIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)
					ui_corseletIcon:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
                    ui_corseletIcon:getChildByName("image_lv"):setVisible(true)
					ccui.Helper:seekNodeByName(ui_corseletIcon, "text_lv"):setString(tostring(equipLevel))
                    if dictEquipAdvanceData then
                        ui_btnCorselet:getChildByName("image_star"):setVisible(true)
                        ui_btnCorselet:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                    end
                     local suitEquipData = utils.getEquipSuit(tostring( instEquipData.int["4"] ) )
                    --if suitEquipData then
                        utils.addFrameParticle( ui_corseletIcon , suitEquipData )                    
                    --end
					ui_corseletName:setString(dictEquipData.name)
				elseif equipTypeId == StaticEquip_Type.pants then --头盔
					ui_btnHelm:setTag(instEquipId)
					ui_btnHelm:loadTexture(qualityImage)
					ui_helmIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)
					ui_helmIcon:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
					ui_helmIcon:getChildByName("image_lv"):setVisible(true)
					ccui.Helper:seekNodeByName(ui_helmIcon, "text_lv"):setString(tostring(equipLevel))
                    if dictEquipAdvanceData then
                        ui_btnHelm:getChildByName("image_star"):setVisible(true)
                        ui_btnHelm:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                    end
                    local suitEquipData = utils.getEquipSuit(tostring( instEquipData.int["4"] ) )
                    --if suitEquipData then
                        utils.addFrameParticle( ui_helmIcon , suitEquipData )                   
                   -- end
					ui_helmName:setString(dictEquipData.name)
				elseif equipTypeId == StaticEquip_Type.necklace then --饰品
					ui_btnNecklace:setTag(instEquipId)
					ui_btnNecklace:loadTexture(qualityImage)
					ui_necklaceIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)
					ui_necklaceIcon:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
					ui_necklaceIcon:getChildByName("image_lv"):setVisible(true)
					ccui.Helper:seekNodeByName(ui_necklaceIcon, "text_lv"):setString(tostring(equipLevel))
                    if dictEquipAdvanceData then
                        ui_btnNecklace:getChildByName("image_star"):setVisible(true)
                        ui_btnNecklace:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                    end
                    local suitEquipData = utils.getEquipSuit(tostring( instEquipData.int["4"] ) )
                   -- if suitEquipData then
                        utils.addFrameParticle( ui_necklaceIcon , suitEquipData )                     
                    --end
					ui_necklaceName:setString(dictEquipData.name)
				elseif equipTypeId == StaticEquip_Type.ring then --戒指
				--[[
					ui_btnRing:setTag(instEquipId)
					ui_btnRing:loadTextures(qualityImage, qualityImage)
					ui_ringIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
					ui_ringIcon:getChildByName("image_lv"):setVisible(true)
					ccui.Helper:seekNodeByName(ui_ringIcon, "label_lv"):setString(tostring(equipLevel))
					]]
				elseif equipTypeId == StaticEquip_Type.equip then --武器
					ui_btnWeapon:setTag(instEquipId)
					ui_btnWeapon:loadTexture(qualityImage)
					ui_weaponIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)
					ui_weaponIcon:getChildByName("image_lv"):loadTexture(qualitySuperscriptImg)
					ui_weaponIcon:getChildByName("image_lv"):setVisible(true)
					ccui.Helper:seekNodeByName(ui_weaponIcon, "text_lv"):setString(tostring(equipLevel))
                    if dictEquipAdvanceData then
                        ui_btnWeapon:getChildByName("image_star"):setVisible(true)
                        ui_btnWeapon:getChildByName("image_star"):getChildByName("label_star"):setString(tostring(dictEquipAdvanceData.starLevel))
                    end
                    local suitEquipData = utils.getEquipSuit(tostring( instEquipData.int["4"] ) )
                   -- if suitEquipData then
                        utils.addFrameParticle( ui_weaponIcon , suitEquipData )                      
                   -- end
					ui_weaponName:setString(dictEquipData.name)
				elseif equipTypeId == StaticEquip_Type.cloak then --法宝
				--[[
					ui_btnTreasure:setTag(instEquipId)
					ui_btnTreasure:loadTextures(qualityImage, qualityImage)
					ui_treasureIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
					ui_treasureIcon:getChildByName("image_lv"):setVisible(true)
					ccui.Helper:seekNodeByName(ui_treasureIcon, "label_lv"):setString(tostring(equipLevel))
					]]
				end
			end
		end
	end
	if pvp.InstPlayerMagic then
		local _magicCount = 0
		for key, obj in pairs(pvp.InstPlayerMagic) do
			if instCardId == obj.int["8"] then
				_magicCount = _magicCount + 1
				local instMagicId = obj.int["1"]
				local dictMagicId = obj.int["3"]
				local magicType = obj.int["4"]
				local magicQualityId = obj.int["5"]
				local magicLv = DictMagicLevel[tostring(obj.int["6"])].level
				local dictMagicData = DictMagic[tostring(dictMagicId)]
				local frameImg = nil
				if magicQualityId == StaticMagicQuality.HJ then
					frameImg = "ui/gold_d.png"
				elseif magicQualityId == StaticMagicQuality.XJ then
					frameImg = "ui/gold_c.png"
				elseif magicQualityId == StaticMagicQuality.DJ then
					frameImg = "ui/gold_b.png"
				elseif magicQualityId == StaticMagicQuality.TJ then
					frameImg = "ui/gold_a.png"
				end
				if magicType == dp.MagicType.treasure then
					ui_btnTreasure:setTag(instMagicId)
					ui_btnTreasure:loadTexture(frameImg)
					ui_treasureIcon:loadTexture("image/" .. DictUI[tostring(dictMagicData.smallUiId)].fileName)
					ui_treasurePanel:getChildByName("image_lv"):setVisible(true)
					ui_treasurePanel:getChildByName("image_lv"):getChildByName("text_lv"):setString(tostring(magicLv))
					ui_treasureName:setString(dictMagicData.name)
				elseif magicType == dp.MagicType.gongfa then
					ui_btnGongfa:setTag(instMagicId)
					ui_btnGongfa:loadTexture(frameImg)
					ui_gongfaIcon:loadTexture("image/" .. DictUI[tostring(dictMagicData.smallUiId)].fileName)
					ui_gongfaPanel:getChildByName("image_lv"):setVisible(true)
					ui_gongfaPanel:getChildByName("image_lv"):getChildByName("text_lv"):setString(tostring(magicLv))
					ui_gongfaName:setString(dictMagicData.name)
				end
				if _magicCount >= 2 then
					break
				end
			end
		end
	end
	if touchEnabled then
		local function eventLogic(_instEquipId, _equipTypeId, isMagic)
			if _instEquipId > 0 then
				if isMagic then
					if _equipTypeId == dp.MagicType.treasure then
						cclog("-------------->>> PVP 查看法宝")
					elseif _equipTypeId == dp.MagicType.gongfa then
						cclog("-------------->>> PVP 查看功法")
					end
					 UIGongfaInfo.setInstMagicId(_instEquipId,false,true)
					 UIManager.pushScene("ui_gongfa_info")
				else
					 UIEquipmentInfo.setEquipInstId(_instEquipId,true)
					 UIManager.pushScene("ui_equipment_info")
					cclog("-------------->>> PVP 查看装备")
				end
			end
		end
		local function btnEquipEvent(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				if sender == ui_btnWeapon then --武器
					eventLogic(ui_btnWeapon:getTag(), StaticEquip_Type.equip)
				elseif sender == ui_btnCorselet then --护甲
					eventLogic(ui_btnCorselet:getTag(), StaticEquip_Type.outerwear)
				elseif sender == ui_btnHelm then --头盔
					eventLogic(ui_btnHelm:getTag(), StaticEquip_Type.pants)
				elseif sender == ui_btnNecklace then --饰品
					eventLogic(ui_btnNecklace:getTag(), StaticEquip_Type.necklace)
				elseif sender == ui_btnTreasure then --法宝
					eventLogic(ui_btnTreasure:getTag(), dp.MagicType.treasure, true)
				elseif sender == ui_btnGongfa then --功法
					eventLogic(ui_btnGongfa:getTag(), dp.MagicType.gongfa, true)
				end
			end
		end
		ui_btnWeapon:addTouchEventListener(btnEquipEvent)
		ui_btnCorselet:addTouchEventListener(btnEquipEvent)
		ui_btnHelm:addTouchEventListener(btnEquipEvent)
		ui_btnNecklace:addTouchEventListener(btnEquipEvent)
		ui_btnTreasure:addTouchEventListener(btnEquipEvent)
		ui_btnGongfa:addTouchEventListener(btnEquipEvent)
	end
	ui_btnWeapon:setTouchEnabled(touchEnabled)
	ui_btnCorselet:setTouchEnabled(touchEnabled)
	ui_btnHelm:setTouchEnabled(touchEnabled)
	ui_btnNecklace:setTouchEnabled(touchEnabled)
	ui_btnTreasure:setTouchEnabled(touchEnabled)
	ui_btnGongfa:setTouchEnabled(touchEnabled)
end

local function setCardProp(_instFormationId)
	local ui_cardName = ui_propPanel:getChildByName("image_di_name"):getChildByName("text_name") --卡牌名称
	local ui_bench = ui_propPanel:getChildByName("image_di_name"):getChildByName("image_bu") --‘补’
	---///-----> 卡牌属性栏
	local ui_cardLevel = ui_propPanel:getChildByName("text_lv") --卡牌等级
	local ui_cardBlood = ui_propPanel:getChildByName("text_blood") --卡牌血量
	local ui_gasAttack = ui_propPanel:getChildByName("text_attack_gas") --物攻
	local ui_gasDefense = ui_propPanel:getChildByName("text_defense_gas") --物防
	local ui_soulAttack = ui_propPanel:getChildByName("text_defense_soul") --法攻
	local ui_soulDefense = ui_propPanel:getChildByName("text_life") --法防
	---///-----> 卡牌阵营栏
	-- local ui_campLabel = ui_propPanel:getChildByName("image_camp") --阵营标签
	---//------> 卡牌称号
	local ui_cardTitle = ui_propPanel:getChildByName("text_title") --卡牌称号
	---///-----> 卡牌标签栏
	local ui_cardLabel1 = ui_propPanel:getChildByName("text_label2") --职业标签
	local ui_cardLabel2 = ui_propPanel:getChildByName("text_label1") --类型标签
	-- local ui_cardLabel3 = ui_propPanel:getChildByName("image_label3") --描述标签
    --///------> 异火栏
    local ui_firePanel = ui_propPanel:getChildByName("image_di_fire")
	---///-----> 缘分栏
	local ui_lucks = {} --缘分
	for i = 1, 6 do
		ui_lucks[i] = ui_propPanel:getChildByName("text_luck" .. i)
		ui_lucks[i]:setTextColor(cc.c4b(51, 25, 4, 255))
		ui_lucks[i]:setString("")
	end
	---///-----> 技能栏
	-- local ui_skillNames = {} --技能名称
	-- for i = 1, 3 do
	-- 	ui_skillNames[i] = ui_propPanel:getChildByName("text_skill" .. i)
	-- 	ui_skillNames[i]:setTextColor(cc.c4b(51, 25, 4, 255))
	-- 	ui_skillNames[i]:setString("")
	-- end
	---///-----> 小伙伴
	local ui_friend = ui_propPanel:getChildByName("image_friend") --小伙伴
	
	if _instFormationId and _instFormationId > 0 then
		ui_friend:setVisible(false)
		ui_cardName:setVisible(true)
		ui_bench:setVisible(true)
		-- ui_campLabel:setVisible(true)
		ui_cardTitle:setVisible(true)
		ui_cardLabel1:setVisible(true)
		ui_cardLabel2:setVisible(true)
		-- ui_cardLabel3:setVisible(true)
        ui_firePanel:setVisible(true)
		local obj = pvp.InstPlayerFormation[tostring(_instFormationId)]
		local instCardId = obj.int["3"] --卡牌实例ID
		local type = obj.int["4"] --阵型类型 1:主力,2:替补
		local dictCardId = obj.int["6"] --卡牌字典ID
		local instCardData = pvp.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
		local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
		local qualityId = instCardData.int["4"] --品阶ID
		local starLevelId = instCardData.int["5"] --星级ID
		local titleDetailId = instCardData.int["6"] --具体称号ID
		local level = instCardData.int["9"] --等级
        local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
		
		ui_cardName:setString((isAwake == 1 and Lang.ui_arena_check7 or "") .. dictCardData.name)
		ui_cardName:setTextColor(utils.getQualityColor(qualityId))
		if type == 2 then
			ui_bench:setVisible(true)
		else
			ui_bench:setVisible(false)
		end
		ui_cardLevel:setString(Lang.ui_arena_check8 .. level)
		local attributes = pvp.getCardAttribute(instCardId)
		ui_cardBlood:setString(DictFightProp[tostring(StaticFightProp.blood)].name .. "：" .. math.floor(attributes[StaticFightProp.blood]))
		ui_gasAttack:setString(DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：" .. math.floor(attributes[StaticFightProp.wAttack]))
		ui_gasDefense:setString(DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：" .. math.floor(attributes[StaticFightProp.wDefense]))
		ui_soulAttack:setString(DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：" .. math.floor(attributes[StaticFightProp.fAttack]))
		ui_soulDefense:setString(DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：" .. math.floor(attributes[StaticFightProp.fDefense]))
		-- ui_campLabel:getChildByName("text_label1"):setString(dictCardData.camp)
		local dictTitleDetailData = DictTitleDetail[tostring(titleDetailId)]
		ui_cardTitle:setString(dictTitleDetailData.description)
		ui_cardLabel1:setString(DictCardType[tostring(dictCardData.cardTypeId)].name)
		ui_cardLabel2:setString(DictFightType[tostring(dictCardData.fightTypeId)].name)
		-- if string.len(dictCardData.nickname) > 0 then
		-- 	ui_cardLabel3:getChildByName("text_label3"):setString(dictCardData.nickname)
		-- 	ui_cardLabel3:setVisible(true)
		-- else
		-- 	ui_cardLabel3:setVisible(false)
		-- end

        local _equipFireInstData = pvp.getEquipFireInstData(instCardId)
        for _i, _obj in pairs(dp.FireEquipGrid) do
            local ui_fireIcon = ui_firePanel:getChildByName("image_fire".._i)
            local ui_fireState = ui_firePanel:getChildByName("image_kuang_fire".._i):getChildByName("image_state")
            ui_fireState:setVisible(false)
            ui_fireIcon:setTouchEnabled(false)
            local _gridState = 0 --0.上锁, 1.开启
            if qualityId >= _obj.qualityId then
                if qualityId == _obj.qualityId then
                    if starLevelId >= _obj.starLevelId then
                        _gridState = 1
                    end
                else
                    _gridState = 1
                end
            end
            if _gridState == 0 then
                ui_fireIcon:loadTexture("ui/mg_suo.png")
            elseif _gridState == 1 then
                ui_fireIcon:loadTexture("ui/frame_tianjia.png")
                ui_fireIcon:setTouchEnabled(true)
            end
            local InstPlayerYFire = _equipFireInstData[_i]
            if InstPlayerYFire then
                local _dictYFireData = DictYFire[tostring(InstPlayerYFire.int["3"])]
                ui_fireIcon:loadTexture("image/fireImage/" .. DictUI[tostring(_dictYFireData.smallUiId)].fileName)
                local _fireState = pvp.getEquipFireState(InstPlayerYFire.int["1"])
                if _fireState == 1 then
                    ui_fireState:loadTexture("ui/fire_wang.png")
                elseif _fireState == 2  then
                    ui_fireState:loadTexture("ui/fire_bao.png")
                end
                ui_fireState:setVisible(true)
                ui_fireIcon:setTouchEnabled(true)
            end
        end
		
		setCardEquipInfo(true, _instFormationId, instCardId)
		
		local cardLucks = {}
		for key, obj in pairs(DictCardLuck) do
			if obj.cardId == dictCardId then
				cardLucks[#cardLucks + 1] = obj
			end
		end
		utils.quickSort(cardLucks, function(obj1, obj2) if obj1.id > obj2.id then return end return false end)
		for key, obj in pairs(cardLucks) do
			ui_lucks[key]:setString(obj.name)
			if pvp.isCardLuck(obj, _instFormationId) then
				ui_lucks[key]:setTextColor(cc.c4b(0, 68, 255, 255))
			else
				ui_lucks[key]:setTextColor(cc.c4b(51, 25, 4, 255))
			end
		end
		if #cardLucks == 0 then
			for kye, obj in pairs(ui_lucks) do
				obj:setString(Lang.ui_arena_check9)
			end
		end
		--[[
		local skillData = {SkillManager[dictCardData.skillOne], SkillManager[dictCardData.skillTwo], SkillManager[dictCardData.skillThree]}
		local skillOpenLv = {tonumber(StaticQuality.white), tonumber(StaticQuality.blue), tonumber(StaticQuality.purple)}
		for key, obj in pairs(ui_skillNames) do
			if skillData[key] then
				obj:setString(skillData[key].name)
				if qualityId >= skillOpenLv[key] then
					obj:setTextColor(cc.c4b(0, 128, 0, 255))
				end
			end
		end
		--]]
        ccui.Helper:seekNodeByName(UIArenaCheck.Widget , "btn_soul" ):setVisible(true)
	else
        ccui.Helper:seekNodeByName(UIArenaCheck.Widget , "btn_soul" ):setVisible(false)
		setCardEquipInfo(false)
		ui_cardName:setVisible(false)
		ui_bench:setVisible(false)
		-- ui_campLabel:setVisible(false)
		ui_cardTitle:setVisible(false)
		ui_cardLabel1:setVisible(false)
		ui_cardLabel2:setVisible(false)
		-- ui_cardLabel3:setVisible(false)
        ui_firePanel:setVisible(false)
		ui_cardLevel:setString(Lang.ui_arena_check10)
		ui_cardBlood:setString(DictFightProp[tostring(StaticFightProp.blood)].name .. "：0")
		ui_gasAttack:setString(DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：0")
		ui_gasDefense:setString(DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：0")
		ui_soulAttack:setString(DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：0")
		ui_soulDefense:setString(DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：0")
		if _instFormationId == 0 then
			ui_friend:setScale(0.1)
			ui_friend:setVisible(true)
			ui_friend:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
			ui_friend:getChildByName("label_luck_number"):setString(tostring(_activateLuckNum))
			-- ui_friend:getChildByName("label_fight_add"):setString(tostring(0))
		else
			ui_friend:setVisible(false)
		end
	end
end

local function setItemData(obj, iconItem, cardInfoItem, index, isFriend)
	local ui_focus = iconItem:getChildByName("image_choose") --光标图片
	local ui_cardSmallIcon = iconItem:getChildByName("image_warrior") --小头像
	local ui_bench = ui_cardSmallIcon:getChildByName("image_bu") --‘补’
	local ui_cardBg = cardInfoItem:getChildByName("image_frame_card") --卡牌背景图
	local ui_cardIcon = ui_cardBg:getChildByName("image_warrior") --卡牌大图标
	local ui_cardAptitude = ui_cardBg:getChildByName("image_zz") --卡牌资质
	local ui_cardAptitudeLabel = ui_cardAptitude:getChildByName("label_zz") --卡牌资质标签
	-- local ui_cardLevel = ccui.Helper:seekNodeByName(ui_cardBg, "label_lv") --卡牌等级
	-- local ui_cardTitle = ccui.Helper:seekNodeByName(ui_cardBg, "text_title") --卡牌称号
	local ui_starImgs = {}
	for i = 1, 5 do
		ui_starImgs[i] = ui_cardBg:getChildByName("image_star" .. i)
		ui_starImgs[i]:setVisible(false)
		ui_starImgs[i]:loadTexture("ui/jj01.png")
	end

	if index == _curShowCardIndex then
		ui_focus:setVisible(true)
	else
		ui_focus:setVisible(false)
	end
	local function iconItemEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			_curShowCardIndex = index
			setScrollViewFocus()
			ui_sectorView:scrollToIndex(index)
		end
	end
	iconItem:addTouchEventListener(iconItemEvent)

	if obj then
		ui_cardBg:setTag(obj.int["1"])
		local instCardId = obj.int["3"] --卡牌实例ID
		local type = obj.int["4"] --阵型类型 1:主力,2:替补
		local dictCardId = obj.int["6"] --卡牌字典ID
		if pvp.InstPlayerWing then
            for key , value in pairs( pvp.InstPlayerWing ) do
                if value.int["6"] == instCardId then
                    local actionName = DictWing[tostring(value.int["3"])].actionName
                    if actionName and actionName ~= "" then
                        utils.addArmature( ui_cardBg , 54 + value.int["5"] , actionName , ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 2 + 28 * 2 , 0 )
                    else
                        utils.addArmature( ui_cardBg , 54 + value.int["5"] , "0"..value.int["5"]..DictWing[tostring(value.int["3"])].sname , ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 2 + 28 * 2 , 0 )
                    end
                    break
                end
            end
        end
		local instCardData = pvp.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
		local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
		local qualityId = instCardData.int["4"] --品阶ID
		local starLevelId = instCardData.int["5"] --星级ID
		-- local titleDetailId = instCardData.int["6"] --具体称号ID
		-- local level = instCardData.int["9"] --等级
        local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
		
		local qualityImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
		iconItem:loadTextures(qualityImage, qualityImage)
		ui_cardSmallIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)
		if type == 2 then
			ui_bench:setVisible(true)
		else
			ui_bench:setVisible(false)
		end

		ui_cardAptitude:setVisible(true)
		ui_cardAptitudeLabel:setString(tostring(dictCardData.nickname))
		
		ui_cardBg:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle))
        
        ui_cardIcon:setVisible(false)
		local cardAnim, cardAnimName
        if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
            cardAnim, cardAnimName = ActionManager.getCardAnimation(isAwake == 1 and dictCardData.awakeAnima or dictCardData.animationFiles, index == _curShowCardIndex and 1 or 2)
        else
            cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName, index == _curShowCardIndex and 1 or 2)
        end
		cardAnim:setPosition(cc.p(ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 2 + 28 * 2))
		ui_cardBg:addChild(cardAnim)
		_cardAnimations[obj.int["1"]] = {cardAnim, cardAnimName}

		local _startIndex, _endIndex, _curIndex = 1, 0, 0
		local maxStarLevel = DictQuality[tostring(qualityId)].maxStarLevel
		if maxStarLevel == 1 then
			_startIndex = 3
			_endIndex = 3
		elseif maxStarLevel == 2 then
			_startIndex = 3
			_endIndex = 4
		elseif maxStarLevel == 3 then
			_startIndex = 2
			_endIndex = 4
		elseif maxStarLevel == 4 then
			_startIndex = 2
			_endIndex = 5
		else
			_startIndex = 1
			_endIndex = 5
		end
		for i = _startIndex, _endIndex do
			_curIndex = _curIndex + 1
			if DictStarLevel[tostring(starLevelId)].level >= _curIndex then
				ui_starImgs[i]:loadTexture("ui/jj02.png")
			end
			ui_starImgs[i]:setVisible(true)
		end
		--[[
		for i = 1, 5 do
			local ui_starImg = ccui.Helper:seekNodeByName(ui_cardBg, "image_star" .. i)
			if DictStarLevel[tostring(starLevelId)].level >= i then
				ui_starImg:setVisible(true)
			else
				ui_starImg:setVisible(false)
			end
		end
		--]]
		
		local cardLucks = {}
		for key, objDcl in pairs(DictCardLuck) do
			if objDcl.cardId == dictCardId then
				cardLucks[#cardLucks + 1] = objDcl
			end
		end
		for key, dictLuck in pairs(cardLucks) do
			if pvp.isCardLuck(dictLuck, obj.int["1"]) then
				_activateLuckNum = _activateLuckNum + 1
			end
		end
		
	else
		ui_bench:setVisible(false)
		iconItem:loadTextures("ui/card_small_white.png", "ui/card_small_white.png")
		-- local ui_baseInfo = ui_cardBg:getChildByName("image_base_info")
		-- ui_baseInfo:setVisible(false)
		ui_cardAptitude:setVisible(false)
		if isFriend then
			ui_cardBg:setTag(0)
			ui_cardSmallIcon:loadTexture("ui/xhb.png")
			ui_cardBg:loadTexture("ui/pai_friend.png")
			ui_cardIcon:setVisible(false)
		else
			ui_cardBg:setTag(-1)
			ui_cardSmallIcon:loadTexture("ui/frame_tianjia.png")
			ui_cardBg:loadTexture("ui/pai_bei.png")
			ui_cardIcon:loadTexture("ui/pai_beizi.png")
			ui_cardIcon:setPosition(cc.p(ui_cardBg:getContentSize().width / 2, ui_cardBg:getContentSize().height / 4))
		end
	end
end

function UIArenaCheck.init()
	local btn_close = ccui.Helper:seekNodeByName(UIArenaCheck.Widget, "btn_close")
	local btn_soul = ccui.Helper:seekNodeByName(UIArenaCheck.Widget , "btn_soul" )
	local function onBtnCloseEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            if sender == btn_soul then
			    UISoulInstall.setType( UISoulInstall.type.PVP, 0 )
                UIManager.pushScene( "ui_soul_install" )
            else
                AudioEngine.playEffect("sound/button.mp3")
			    UIManager.popScene()
            end
		end
	end
	btn_close:setPressedActionEnabled(true)
	btn_close:addTouchEventListener(onBtnCloseEvent)
	btn_soul:setPressedActionEnabled( true )
    btn_soul:addTouchEventListener( onBtnCloseEvent )
	local base_cardchoose = ccui.Helper:seekNodeByName(UIArenaCheck.Widget, "base_cardchoose")
	ui_scrollView = ccui.Helper:seekNodeByName(base_cardchoose, "view_warrior")
	ui_iconItem = ui_scrollView:getChildByName("btn_base_warrior")
	ui_propPanel = ccui.Helper:seekNodeByName(UIArenaCheck.Widget, "basemap")
	ui_cardTouchPanel = ccui.Helper:seekNodeByName(UIArenaCheck.Widget, "panel_choose")
	ui_cardTouchPanel:setVisible(true)
	ui_cardTouchPanel:setTouchEnabled(false)
	ui_cardInfoItem = ui_cardTouchPanel:getChildByName("image_base_card"):clone()
end

local function setCardAnimation(sender, _animIndex)
	if sender and _animIndex and _cardAnimations and _cardAnimations[_animIndex] then
		local ui_cardAnim = _cardAnimations[_animIndex][1]
		if sender:getRotation() >= -5 and sender:getRotation() <= 5 then
			ui_cardAnim:getAnimation():play(_cardAnimations[_animIndex][2] .. "_1")
		else
			ui_cardAnim:getAnimation():play(_cardAnimations[_animIndex][2] .. "_2")
		end
	end
end

function UIArenaCheck.setup()
	ui_scrollView:removeAllChildren()
	ui_cardTouchPanel:removeAllChildren()
	_activateLuckNum = 0
	_curShowCardIndex = 1
	local innerWidth, space = 0, 5
	if pvp.InstPlayerFormation then
		local countItem = 0
		
		local formation1, formation2 = {}, {}
		for key, obj in pairs(pvp.InstPlayerFormation) do
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
			    countItem = countItem + 1
			    if obj.int["4"] == 1 then	--主力
				    formation1[#formation1 + 1] = obj
			    elseif obj.int["4"] == 2 then --替补
				    formation2[#formation2 + 1] = obj
			    end
            end
		end
		local function compareFunc(obj1, obj2)
			if obj1.int["1"] > obj2.int["1"] then
				return true
			end
			return false
		end
		utils.quickSort(formation1, compareFunc)
		utils.quickSort(formation2, compareFunc)
		_cardAnimations = {}
		ui_sectorView = cc.SectorView:create(ui_cardTouchPanel, _curShowCardIndex)
		for i = 1, countItem + 1 do
			local obj = nil
			if formation1[i] then
				obj = formation1[i]
			elseif formation2[i - #formation1] then
				obj = formation2[i - #formation1]
			end
			
			local iconItem = ui_iconItem:clone()
			ui_scrollView:addChild(iconItem)
			innerWidth = innerWidth + iconItem:getContentSize().width + space
			
			local cardInfoItem = ui_cardInfoItem:clone()
			ui_sectorView:addChild(cardInfoItem)
			if i > countItem then
				setItemData(obj, iconItem, cardInfoItem, i, true)
			else
				setItemData(obj, iconItem, cardInfoItem, i)
			end
		end
		setCardProp(ui_sectorView:getItem(_curShowCardIndex):getChildByName("image_frame_card"):getTag())
		local function sectorViewEvent(sender, eventType)
			local instFormationId = sender:getChildByName("image_frame_card"):getTag()
			_curShowCardIndex = ui_sectorView:getCurItemIndex()
			if eventType == ccui.SectorViewEventType.onTurning then
				setCardAnimation(sender, instFormationId)
				setScrollViewFocus()
			elseif eventType == ccui.SectorViewEventType.onUplift then
				setCardAnimation(sender, instFormationId)
				setCardProp(instFormationId)
			elseif eventType == ccui.SectorViewEventType.onClick then
				if UIArenaCheck.Widget:isEnabled() then
					if instFormationId > 0 then
						UICardInfo.setUIParam(UIArenaCheck, instFormationId)
						UIManager.pushScene("ui_card_info")
						cclog("-------------->>> PVP 查看卡牌")
					elseif instFormationId == 0 then
--						UIManager.pushScene("ui_friend")
						cclog("-------------->>> PVP 查看小伙伴")
					end
				end
			end
		end
		ui_sectorView:addEventListener(sectorViewEvent)
		
		innerWidth = innerWidth + space
	end
	
	if innerWidth < ui_scrollView:getContentSize().width then
		innerWidth = ui_scrollView:getContentSize().width
	end
	ui_scrollView:setInnerContainerSize(cc.size(innerWidth, ui_scrollView:getContentSize().height))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if prevChild then
			childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + space, ui_scrollView:getContentSize().height / 2))
		else
			childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + space, ui_scrollView:getContentSize().height / 2))
		end
		prevChild = childs[i]
	end
	
	setScrollViewFocus(true)
end

function UIArenaCheck.free()
	if _cardAnimations then
		for key, obj in pairs(_cardAnimations) do
			obj[1]:getAnimation():stop()
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/card_action/" .. obj[2] .. "/" .. obj[2] .. ".ExportJson")
			ccs.ArmatureDataManager:getInstance():removeArmatureData(obj[1]:getAnimation():getCurrentMovementID())
		end
	end
end
