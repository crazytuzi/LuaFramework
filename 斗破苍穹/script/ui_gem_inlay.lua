require"Lang"
UIGemInlay = {}

local ui_equipQualityBg = nil
local ui_equipIcon = nil
local ui_equipName = nil
local ui_equipLevel = nil
local ui_equipProp1 = nil
local ui_equipProp2 = nil
local ui_inlayItems = {}
local ui_punchAmount= nil

local _exitCallbackFunc = nil
local _equipInstId = nil
local _holeCount = 0 --先有打孔器数量

local function netCallbackFunc(data)
	local code = data.header
	if code == StaticMsgRule.equipInlay then
		UIManager.popScene()
		UIManager.showToast(Lang.ui_gem_inlay1)
	else
	
	end 
	UIGemInlay.setup()
	UIManager.flushWidget(UIEquipmentInfo)
    UIManager.flushWidget(UIEquipmentNew)
    UIManager.flushWidget(UIBagEquipment)
	UIManager.flushWidget(UILineup)
end

function UIGemInlay.init()
	local btn_exit = ccui.Helper:seekNodeByName(UIGemInlay.Widget, "btn_close") --退出按钮
	local btn_gem_lineup = ccui.Helper:seekNodeByName(UIGemInlay.Widget, "btn_gem_lineup") --魔核升级按钮标签
	local btn_gem_switch = ccui.Helper:seekNodeByName(UIGemInlay.Widget, "btn_gem_switch") --魔核转换按钮标签
	btn_exit:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_exit then
				UIManager.popScene()
			elseif sender == btn_gem_lineup then
			  UIGemUpGrade.setData(nil,UIGemInlay,_exitCallbackFunc)
			  UIManager.replaceScene("ui_gem_upgrade")
			elseif sender == btn_gem_switch then
			  UIGemSwitch.setData(nil,UIGemInlay,_exitCallbackFunc)
				UIManager.replaceScene("ui_gem_switch")
			end
		end
	end
	btn_exit:addTouchEventListener(btnTouchEvent)
	btn_gem_lineup:addTouchEventListener(btnTouchEvent)
	btn_gem_switch:addTouchEventListener(btnTouchEvent)
	
	local image_basecolour = ccui.Helper:seekNodeByName(UIGemInlay.Widget, "image_basecolour")
	ui_equipQualityBg = ccui.Helper:seekNodeByName(image_basecolour, "image_base_name")
	ui_equipIcon = ccui.Helper:seekNodeByName(image_basecolour, "image_gem")
	ui_equipName = ui_equipQualityBg:getChildByName("text_name_equipment")
	ui_equipLevel = ccui.Helper:seekNodeByName(image_basecolour, "text_lv")
	ui_equipProp1 = ccui.Helper:seekNodeByName(image_basecolour, "text_attack")
	ui_equipProp2 = ccui.Helper:seekNodeByName(image_basecolour, "text_reduce")
	
	for i = 1, 4 do
		ui_inlayItems[i] = ccui.Helper:seekNodeByName(image_basecolour, "image_inlay_gem" .. i)
	end

	ui_punchAmount = ccui.Helper:seekNodeByName(image_basecolour, "text_number")
end

function UIGemInlay.setup()
	_holeCount = utils.getThingCount(StaticThing.openHole)
	ui_punchAmount:setString("x" .. _holeCount)

	if net.InstPlayerEquip and _equipInstId then
		local instEquipData = net.InstPlayerEquip[tostring(_equipInstId)]
		local dictEquipId = instEquipData.int["4"] --装备字典ID
		local equipLv = instEquipData.int["5"] --装备等级
        local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
		local dictEquipData = DictEquipment[tostring(dictEquipId)] --装备字典表
        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表
		ui_equipName:setString(dictEquipData.name)
		ui_equipLevel:setString(Lang.ui_gem_inlay2 .. equipLv)
		ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData and dictEquipAdvanceData.equipQualityId or dictEquipData.equipQualityId, dp.QualityImageType.middle, true))
		ui_equipIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedbigUiId or dictEquipData.bigUiId)].fileName)
		local equipPropData = {}
		local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
		for key, obj in pairs(propData) do
			equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
		end
		if #equipPropData > 1 then
			ui_equipProp2:setVisible(true)
		else
			ui_equipProp2:setVisible(false)
		end
		for key, obj in pairs(equipPropData) do
			local equipProp
			if key == 1 then
				equipProp = ui_equipProp1
			else
				equipProp = ui_equipProp2
			end
			local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
			local curValue = formula.getEquipAttribute(equipLv, initValue, addValue)
			if fightPropId == StaticFightProp.blood then
				equipProp:setString(Lang.ui_gem_inlay3 .. curValue)
			elseif fightPropId == StaticFightProp.wAttack then
				equipProp:setString(Lang.ui_gem_inlay4 .. curValue)
			elseif fightPropId == StaticFightProp.fAttack then
				equipProp:setString(Lang.ui_gem_inlay5 .. curValue)
			elseif fightPropId == StaticFightProp.wDefense then
				equipProp:setString(Lang.ui_gem_inlay6 .. curValue)
			elseif fightPropId == StaticFightProp.fDefense then
				equipProp:setString(Lang.ui_gem_inlay7 .. curValue)
			end
		end
		local holeNums = {}
		for key, obj in pairs(DictHoleConsume) do
			if obj.qualityId == dictEquipData.equipQualityId then
				holeNums[obj.times + 1] = obj.num
			end
		end
		local inlayThingId = {}
		if net.InstEquipGem then
			for key, obj in pairs(net.InstEquipGem) do
				if _equipInstId == obj.int["3"] then
					inlayThingId[obj.int["5"]] = {obj.int["1"], obj.int["4"]} --[1]:装备宝石实例ID [2]:物品Id 0表示未镶嵌宝石
				end
			end
		end
		local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)] --装备品质字典表
		local holeNum = dictEquipQualityData.holeNum --拥有宝石孔数
		local _tempBtnItem = nil
		for key, uiItem in pairs(ui_inlayItems) do
			local btnItem = uiItem:getChildByName("btn_punch")
			btnItem:setPressedActionEnabled(true)
			if key <= holeNum then
				uiItem:setVisible(true)
				local _frame = ccui.Helper:seekNodeByName(uiItem, "image_frame_gem")
				_frame:loadTexture("ui/low_small_white.png")
				local _icon = _frame:getChildByName("image_gem1")
				local _gemLv = ccui.Helper:seekNodeByName(uiItem, "text_lv_gem")
				local _gemProp = ccui.Helper:seekNodeByName(uiItem, "text_property_gem")
				local _gemHint = ccui.Helper:seekNodeByName(uiItem, "text_hint_gem")
				local _thingId = nil
				if inlayThingId[key] then
					_thingId = inlayThingId[key][2]
				end
				btnItem:setTouchEnabled(true)
				if _thingId then
					if _thingId == 0 then
						--已打孔了
						_gemHint:setVisible(true)
						_gemLv:setVisible(false)
						_gemProp:setVisible(false)
						btnItem:setTitleText(Lang.ui_gem_inlay8)
						_gemHint:setString(Lang.ui_gem_inlay9)
						_icon:loadTexture("ui/frame_tianjia.png")
					else
						--镶嵌了物品
						_gemHint:setVisible(false)
						_gemLv:setVisible(true)
						_gemProp:setVisible(true)
						btnItem:setTitleText(Lang.ui_gem_inlay10)
						local dictThingData = DictThing[tostring(_thingId)]
						_gemLv:setString(dictThingData.name)
						_frame:loadTexture(utils.getThingQualityImg(dictThingData.bkGround))
						_icon:loadTexture("image/" .. DictUI[tostring(dictThingData.smallUiId)].fileName)
						_gemProp:setString("+" .. dictThingData.fightPropValue .. DictFightProp[tostring(dictThingData.fightPropId)].name)
					end
				else
					--未打孔
					_gemHint:setVisible(true)
					_gemLv:setVisible(false)
					_gemProp:setVisible(false)
					btnItem:setTitleText(Lang.ui_gem_inlay11)
					_gemHint:setString(Lang.ui_gem_inlay12 .. holeNums[key] .. Lang.ui_gem_inlay13)
					_icon:loadTexture("ui/mg_suo.png")
					if _tempBtnItem == nil then
						_tempBtnItem = btnItem
					end
				end
				local function btnItemEvent(sender, eventType)
					if eventType == ccui.TouchEventType.ended then
						if _thingId then
							if _thingId == 0 then
								--已打孔了
								local function gemInlay(instThingId)
									local sendData = {
										header = StaticMsgRule.equipInlay,
										msgdata = {
											int = {
												position = key,
												instPlayerThingId = instThingId,--物品实例Id,魔核
												instPlayerEquipId = _equipInstId
											}
										}
									}
--                                    local sendData = nil
--                                    if UIGuidePeople.levelStep == "16_5" then
--                                        sendData = {
--										    header = StaticMsgRule.equipInlay,
--										    msgdata = {
--											    int = {
--												    position = key,
--												    instPlayerThingId = instThingId,--物品实例Id,魔核
--												    instPlayerEquipId = _equipInstId
--											    },
--                                                string = {
--                                                    step = "16_6"
--                                                }
--										    }
--									    }
--                                    else
--                                        sendData = {
--										    header = StaticMsgRule.equipInlay,
--										    msgdata = {
--											    int = {
--												    position = key,
--												    instPlayerThingId = instThingId,--物品实例Id,魔核
--												    instPlayerEquipId = _equipInstId
--											    }
--										    }
--									    }
--                                    end
									UIManager.showLoading()
									netSendPackage(sendData, netCallbackFunc)
								end
								cclog("----------->>  镶嵌")
								UIGemList.setData(UIGemList.OperateType.GemInlay, gemInlay, inlayThingId)
								UIManager.pushScene("ui_gem_list")
							else
								--镶嵌了物品
								cclog("----------->>  拆除 .. instId = " .. inlayThingId[key][1])
								local sendData = {
									header = StaticMsgRule.takeOffGem,
									msgdata = {
										int = {
											instEquipGemId = inlayThingId[key][1] --装备宝石实例Id
										}
									}
								}
								UIManager.showLoading()
								netSendPackage(sendData, netCallbackFunc)
							end
						else
							--未打孔
							if _tempBtnItem ~= btnItem then
								UIManager.showToast(Lang.ui_gem_inlay14)
								return
							end
							if _holeCount >= holeNums[key] then
								cclog("----------->>  打孔")
                                local sendData = nil
                                if UIGuidePeople.levelStep == "16_3" then
                                    sendData = {
									    header = StaticMsgRule.openHole,
									    msgdata = {
										    int = {
											    instPlayerEquipId = _equipInstId
										    },
                                            string = {
                                                step = "16_4"
                                            }
									    }
								    }
                                else
                                    sendData = {
									    header = StaticMsgRule.openHole,
									    msgdata = {
										    int = {
											    instPlayerEquipId = _equipInstId
										    }
									    }
								    }
                                end
								UIManager.showLoading()
								netSendPackage(sendData, netCallbackFunc)
							else
								UIManager.showToast(Lang.ui_gem_inlay15)
							end
						end
					end
				end
				btnItem:addTouchEventListener(btnItemEvent)
			else
				uiItem:setVisible(false)
				btnItem:setTouchEnabled(false)
			end
		end
	end
	UIGuidePeople.isGuide(nil,UIGemInlay)
end

function UIGemInlay.setEquipInstId(equipInstId)
	_equipInstId = equipInstId
end

function UIGemInlay.setExitCallback(exitCallbackFunc)
	_exitCallbackFunc = exitCallbackFunc
end
