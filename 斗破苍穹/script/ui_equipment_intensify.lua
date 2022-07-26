UIEquipmentIntensify = {}

local ui_equipQualityBg = nil
local ui_equipIcon = nil
local ui_equipName = nil
local ui_equipQuality = nil
local ui_curLevel = nil
local ui_newLevel = nil
local ui_curGasAttack = nil
local ui_newGasAttack = nil
local ui_curSoulAttack = nil
local ui_newSoulAttack = nil
local ui_gasAdd = nil
local ui_soulAdd = nil
local ui_intensifyCost = nil

local _equipInstId = nil

local function netCallbackFunc(data)
	if data then
		AudioEngine.playEffect("sound/strengthen.mp3")
		local animation = ActionManager.getUIAnimation(15, function()
			if tonumber(data.header) == StaticMsgRule.quickStrengthen then
				UIGuidePeople.isGuide(nil,UIEquipmentIntensify)
			elseif tonumber(data.header) == StaticMsgRule.strengthen then
			end
			UIManager.flushWidget(UIEquipmentIntensify)
			UIManager.flushWidget(UIEquipmentInfo)
            UIManager.flushWidget(UIEquipmentNew)
			UIManager.flushWidget(UILineup)
			UIManager.flushWidget(UIBagEquipment)
		end)
		if tonumber(data.header) == StaticMsgRule.quickStrengthen then
				animation:getAnimation():playWithIndex(1)
			elseif tonumber(data.header) == StaticMsgRule.strengthen then
				animation:getAnimation():playWithIndex(0)
			end
		animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
		UIManager.uiLayer:addChild(animation, UIEquipmentIntensify.Widget:getLocalZOrder() + 1)
	end
end

function UIEquipmentIntensify.init()
	ui_equipQualityBg = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "image_di_equipment")
	ui_equipIcon = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "image_equipment")
	ui_equipName = ccui.Helper:seekNodeByName(ui_equipQualityBg, "text_name")
	ui_equipQuality = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "text_number_quality")
	
	local ui_image_intensify_info = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "image_info_l")
	local image_info1 = ccui.Helper:seekNodeByName(ui_image_intensify_info, "image_info1")
	ui_curLevel = image_info1:getChildByName("text_l")
	ui_newLevel = image_info1:getChildByName("text_r")
	local image_info2 = ccui.Helper:seekNodeByName(ui_image_intensify_info, "image_info2")
	ui_curGasAttack = image_info2:getChildByName("text_l")
	ui_newGasAttack = image_info2:getChildByName("text_r")
	local image_info3 = ccui.Helper:seekNodeByName(ui_image_intensify_info, "image_info3")
	ui_curSoulAttack = image_info3:getChildByName("text_l")
	ui_newSoulAttack = image_info3:getChildByName("text_r")
	ui_gasAdd = ccui.Helper:seekNodeByName(ui_image_intensify_info, "text_property1")
	ui_soulAdd = ccui.Helper:seekNodeByName(ui_image_intensify_info, "text_property2")
	ui_intensifyCost = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "image_money"):getChildByName("text_hint") --强化消耗

	local btn_close = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "btn_close")
	local btn_onekey = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "btn_onekey") --一键强化按钮
	local btn_intensify = ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "btn_lineup") --强化按钮

	btn_close:setPressedActionEnabled(true)
	btn_onekey:setPressedActionEnabled(true)
	btn_intensify:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close then
				UIManager.popScene()
				UIGuidePeople.isGuide(nil,UIEquipmentIntensify)
			elseif sender == btn_onekey then
				local sendData = {
					header = StaticMsgRule.quickStrengthen,
					msgdata = {
						int = {
							instPlayerEquipId = _equipInstId
						}
					}
				}
                local function errorStopGuide(pack)
                    if UIGuidePeople.guideStep == guideInfo["18B6"].step then
                        UIGuidePeople.guideStep = nil
		                UIGuidePeople.levelStep = nil
                        UIGuidePeople.free()
                        UIGuidePeople.setUIEnabled(true)
                    end
                end
				UIManager.showLoading()
				netSendPackage(sendData, netCallbackFunc,errorStopGuide)
			elseif sender == btn_intensify then
				local sendData = {
					header = StaticMsgRule.strengthen,
					msgdata = {
						int = {
							instPlayerEquipId = _equipInstId
						}
					}
				}
				UIManager.showLoading()
				netSendPackage(sendData, netCallbackFunc)
			end
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_onekey:addTouchEventListener(btnTouchEvent)
	btn_intensify:addTouchEventListener(btnTouchEvent)
end

function UIEquipmentIntensify.setup()
	if net.InstPlayerEquip and _equipInstId then
		
		local instEquipData = net.InstPlayerEquip[tostring(_equipInstId)]
		local equipTypeId = instEquipData.int["3"] --装备类型ID
		local dictEquipId = instEquipData.int["4"] --装备字典ID
		local equipLv = instEquipData.int["5"] --装备等级
		local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表
		local dictEquipData = DictEquipment[tostring(dictEquipId)] --装备字典表
		ui_equipName:setString(dictEquipData.name)
		ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData and dictEquipAdvanceData.equipQualityId or dictEquipData.equipQualityId, dp.QualityImageType.middle, true))
		ui_equipIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedbigUiId or dictEquipData.bigUiId)].fileName)
		ui_curLevel:setString("LV." .. equipLv)
		ui_newLevel:setString("LV." .. equipLv + 1)
		ui_equipQuality:setString(tostring(dictEquipData.qualityLevel))
		
		local equipPropData = {}
		local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
		for key, obj in pairs(propData) do
			equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
		end
		if #equipPropData > 1 then
			ui_curSoulAttack:setVisible(true)
			ui_newSoulAttack:setVisible(true)
			ui_curSoulAttack:getParent():setVisible(true)
			ui_soulAdd:setVisible(true)
		else
			ui_curSoulAttack:setVisible(false)
			ui_newSoulAttack:setVisible(false)
			ui_curSoulAttack:getParent():setVisible(false)
			ui_soulAdd:setVisible(false)
		end
		local attAddValue = 0
		for key, obj in pairs(DictEquipAdvance) do
			if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId and equipAdvanceId >= obj.id then
				attAddValue = attAddValue + obj.propAndAdd
			end
		end
        if equipAdvanceId >= 1000 then
            for key, obj in pairs(DictEquipAdvancered) do
                if dictEquipId == obj.equipId and dictEquipAdvanceData.starLevel >= obj.starLevel then
                    attAddValue = attAddValue + obj.propAndAdd
                end
            end
        end
		for key, obj in pairs(equipPropData) do
			local curEquipProp, newEquipProp, propAdd
			if key == 1 then
				curEquipProp = ui_curGasAttack
				newEquipProp = ui_newGasAttack
				propAdd = ui_gasAdd
			else
				curEquipProp = ui_curSoulAttack
				newEquipProp = ui_newSoulAttack
				propAdd = ui_soulAdd
			end
			local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3]) + attAddValue
			local curValue = formula.getEquipAttribute(equipLv, initValue, addValue)
			local newValue = formula.getEquipAttribute(equipLv + 1, initValue, addValue)
			curEquipProp:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. curValue)
			newEquipProp:setString(tostring(newValue))
			propAdd:setString(DictFightProp[tostring(fightPropId)].name .. "  +" .. (newValue - curValue))
		end
		local dictEquipStrengthen = DictEquipStrengthen[tostring(equipLv + 1)]
		if dictEquipStrengthen then
			local price = 0
			if dictEquipData.equipQualityId == StaticEquip_Quality.white then
				price = dictEquipStrengthen.whiteCopper
			elseif dictEquipData.equipQualityId == StaticEquip_Quality.green then
				price = dictEquipStrengthen.greenCopper
			elseif dictEquipData.equipQualityId == StaticEquip_Quality.blue then
				price = dictEquipStrengthen.blueCopper
			elseif dictEquipData.equipQualityId == StaticEquip_Quality.purple then
				price = dictEquipStrengthen.purpleCopper
			elseif dictEquipData.equipQualityId == StaticEquip_Quality.golden then
				price = dictEquipStrengthen.goldenCopper
			end
			ui_intensifyCost:setString("：" .. price)
		end
	end
end

function UIEquipmentIntensify.setEquipInstId(equipInstId)
	_equipInstId = equipInstId
end