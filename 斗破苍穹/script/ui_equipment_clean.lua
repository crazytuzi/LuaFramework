require"Lang"
UIEquipmentClean = {}

local MAX_STAR_LEVEL = 5 --最大星级
local STAR_ANIM_TAG = -11111

local userData = nil
local _equipIconPath = nil
local _curEquipStarLevel = 0

local function playAnimaction(_callbackFunc)
    local image_basemap = UIEquipmentClean.Widget:getChildByName("image_basemap")
	local panel = ccui.Helper:seekNodeByName(image_basemap, "image_di_r")
    if panel:getChildByName("_equipIcon_animation") then
        if _equipIconPath then
            local animation = panel:getChildByName("_equipIcon_animation")
            animation:getBone("002"):addDisplay(ccs.Skin:create(_equipIconPath), 0)
        end
--        animation:getAnimation():playWithIndex(0)
--        animation:getAnimation():setMovementEventCallFunc(function(armature, movementType, movementID)
--            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
--                if _callbackFunc then
--                    _callbackFunc()
--                end
--            end
--        end)
    else
	    local ui_equipIcon = panel:getChildByName("image_equipment")
        ui_equipIcon:setVisible(false)
        local uiAnimId = 77
        local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
        local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
        animation:getBone("002"):addDisplay(ccs.Skin:create(_equipIconPath), 0)
        animation:getAnimation():playWithIndex(1)
        animation:setPosition(cc.p(ui_equipIcon:getPositionX(), ui_equipIcon:getPositionY()))
        animation:setName("_equipIcon_animation")
        panel:addChild(animation)
    end
end

local function netCallbackFunc(msgData)
    local animCallbackFunc = function()
        if UIEquipmentClean.Widget:getChildByTag(STAR_ANIM_TAG) then
            UIEquipmentClean.Widget:getChildByTag(STAR_ANIM_TAG):removeFromParent()
        end
        UIEquipmentClean.setup()
	    UIManager.flushWidget(UIEquipmentInfo)
        UIManager.flushWidget(UIEquipmentNew)
	    UIManager.flushWidget(UILineup)
	    UIManager.flushWidget(UIBagEquipment)
    end
    local _animId = nil
    local _state = msgData.msgdata.int["1"] --1-成功  2-失败变回0星  3-失败不变
    if _state == 1 then
        _animId = 41
--	    UIManager.showToast("进阶成功！")
    else
        UIManager.showToast(Lang.ui_equipment_clean1)
        animCallbackFunc()
    end
	if _animId then
        local animation = ActionManager.getUIAnimation(_animId)
        animation:getBone("Layer1"):addDisplay(ccs.Skin:create(_equipIconPath), 0)
        animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
	    UIManager.uiLayer:addChild(animation, 1000)
        local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
		    if evt == "starAnim" then
                local _curStarPosition = nil
                local image_basemap = UIEquipmentClean.Widget:getChildByName("image_basemap")
	            local panel = ccui.Helper:seekNodeByName(image_basemap, "image_di_r")
	            local ui_equipQualityBg = panel:getChildByName("image_di_name")
                for i = 1, MAX_STAR_LEVEL do
                    if _curEquipStarLevel + 1 == i then
		                local ui_starImg = ui_equipQualityBg:getChildByName("image_star" .. i)
                        local point = ui_starImg:getParent():convertToWorldSpace(cc.p(ui_starImg:getPositionX(), ui_starImg:getPositionY()))
                        _curStarPosition = cc.p(point.x, point.y)
                        break
                    end
                end
                _curEquipStarLevel = 0
                local animStar = ccui.ImageView:create("ui/star01.png")
                animStar:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height * 0.75))
                animStar:setScale(8)
                UIEquipmentClean.Widget:addChild(animStar, 1000, STAR_ANIM_TAG)
                animStar:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.15, 1), cc.MoveTo:create(0.15, _curStarPosition)), cc.CallFunc:create(animCallbackFunc)))
            end
        end
        animation:getAnimation():setFrameEventCallFunc(onFrameEvent)
    end
end

function UIEquipmentClean.init()
	local image_basemap = UIEquipmentClean.Widget:getChildByName("image_basemap")
	local btn_close = image_basemap:getChildByName("btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIManager.popScene()
		end
	end)
end

function UIEquipmentClean.setup()
	local image_basemap = UIEquipmentClean.Widget:getChildByName("image_basemap")
	local panel = ccui.Helper:seekNodeByName(image_basemap, "image_di_r")

	local ui_equipIcon = panel:getChildByName("image_equipment")
	local ui_equipQualityBg = panel:getChildByName("image_di_name")
	local ui_equipName = ui_equipQualityBg:getChildByName("text_name")

	local image_arrow1 = panel:getChildByName("image_arrow1")
	local image_arrow2 = panel:getChildByName("image_arrow2")

	local instEquipData = net.InstPlayerEquip[tostring(userData.InstPlayerEquip_id)]
	local equipTypeId = instEquipData.int["3"] --装备类型ID
	local dictEquipId = instEquipData.int["4"] --装备字典ID
	local equipLv = instEquipData.int["5"] --装备等级
	local _equipCardInstId = instEquipData.int["6"] --装备上卡牌ID
	local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
	local dictEquipData = DictEquipment[tostring(dictEquipId)] --装备字典表
	local dictEquipAdvanceData = DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表

	local equipAdvanceData = {}
	for key, obj in pairs(DictEquipAdvance) do
		if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
			equipAdvanceData[#equipAdvanceData + 1] = obj
		end
	end
	utils.quickSort(equipAdvanceData,function(obj1, obj2) if obj1.id > obj2.id then return true end end)
	if equipAdvanceId == 0 and (not dictEquipAdvanceData) then
		dictEquipAdvanceData = equipAdvanceData[1]
	end
    _equipIconPath = "image/" .. DictUI[tostring(dictEquipData.bigUiId)].fileName
	ui_equipIcon:loadTexture(_equipIconPath)
    playAnimaction()
	ui_equipName:setString(dictEquipData.name)
	ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.middle, true))

    _curEquipStarLevel = 0
	for i = 1, MAX_STAR_LEVEL do
		local ui_starImg = ui_equipQualityBg:getChildByName("image_star" .. i)
		if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
			ui_starImg:loadTexture("ui/star01.png")
            _curEquipStarLevel = _curEquipStarLevel + 1
		else
			ui_starImg:loadTexture("ui/star02.png")
		end
		if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
			ui_starImg:setVisible(false)
		else
			ui_starImg:setVisible(true)
		end
	end

	local nextEquipAdvanceData = nil
	local attAddValue = 0
	for key, obj in pairs(equipAdvanceData) do
		if dictEquipAdvanceData.id == obj.id then
			nextEquipAdvanceData = (equipAdvanceId == 0) and obj or equipAdvanceData[key + 1]
		end
		if equipAdvanceId >= obj.id then
			attAddValue = attAddValue + obj.propAndAdd
		else
			break
		end
	end

	local equipPropData = {}
	local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
	for key, obj in pairs(propData) do
		equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
	end
	if #equipPropData > 1 then
		image_arrow2:setVisible(true)
	else
		image_arrow2:setVisible(false)
	end
    local _nextRedEquipAdvanceData = nil
    if nextEquipAdvanceData == nil and dictEquipAdvanceData.starLevel == MAX_STAR_LEVEL and dictEquipData.equipQualityId == StaticEquip_Quality.purple then
        for key, obj in pairs(DictEquipAdvancered) do
            if dictEquipId == obj.equipId and obj.starLevel == 0 then
                _nextRedEquipAdvanceData = obj
                break
            end
        end
    end
	for key, obj in pairs(equipPropData) do
		local _item = panel:getChildByName("image_arrow" .. key)
		local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
		_item:getChildByName("text_title"):setString(DictFightProp[tostring(fightPropId)].name .. "：")
		_item:getChildByName("text_blood_before"):setString(addValue + attAddValue)
		if nextEquipAdvanceData then
			_item:getChildByName("text_blood_after"):setString(addValue + attAddValue + nextEquipAdvanceData.propAndAdd)
		else
            if _nextRedEquipAdvanceData then
                _item:getChildByName("text_blood_after"):setString(addValue + attAddValue + _nextRedEquipAdvanceData.propAndAdd)
            else
			    _item:getChildByName("text_blood_after"):setString(Lang.ui_equipment_clean2)
            end
		end
	end

	local image_di = panel:getChildByName("image_di")
	local _equipFrame = image_di:getChildByName("image_frame_stone")
	local _equipIcon = _equipFrame:getChildByName("image_stone")
	local _equipName = _equipFrame:getChildByName("text_name")
	local _equipNum = _equipFrame:getChildByName("text_numbr")
	local price = ccui.Helper:seekNodeByName(image_di, "text_number")

	_equipName:setString(dictEquipData.name)
	_equipIcon:loadTexture("image/" .. DictUI[tostring(dictEquipData.smallUiId)].fileName)
	_equipFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small))
	local contions = {"0","0"} --[1]:装备数量, [2]:需要的银币
	if nextEquipAdvanceData then
		contions = utils.stringSplit(nextEquipAdvanceData.contions, "_") --[1]:装备数量, [2]:需要的银币
	end
	local _count = 0
	for key, obj in pairs(net.InstPlayerEquip) do
		if obj.int["1"] ~= userData.InstPlayerEquip_id and obj.int["6"] == 0 and obj.int["7"] == 0 and obj.int["4"] == dictEquipId and obj.int["8"] <= 0 then
			_count = _count + 1
		end
	end
	_equipNum:setString(_count .. "/" .. contions[1])
	price:setString(contions[2])
	if tonumber(contions[2]) == 0 then
		price:getParent():setVisible(false)
	else
		price:getParent():setVisible(true)
	end

    local ui_textProtect = image_di:getChildByName("text_protect")
    ui_textProtect:setString(Lang.ui_equipment_clean3)
    ui_textProtect:setTextColor(cc.c3b(191,191,191))
    local image_di_water = panel:getChildByName("image_di_water")
    local image_di_stone = panel:getChildByName("image_di_stone")
    local _waterNums = utils.getThingCount(StaticThing.wishWater)
    local _stoneNums = utils.getThingCount(StaticThing.luckStore)
    ccui.Helper:seekNodeByName(image_di_water, "text_name"):setString(DictThing[tostring(StaticThing.wishWater)].name)
    image_di_water:getChildByName("text_have"):setString(Lang.ui_equipment_clean4 .. _waterNums)
    utils.showThingsInfo(ccui.Helper:seekNodeByName(image_di_water, "image_water"), StaticTableType.DictThing, StaticThing.wishWater)
    local image_frame_stone = image_di_stone:getChildByName("image_frame_stone")
    image_frame_stone:getChildByName("text_name"):setString(DictThing[tostring(StaticThing.luckStore)].name)
    image_di_stone:getChildByName("text_have"):setString(Lang.ui_equipment_clean5 .. _stoneNums)
    utils.showThingsInfo(image_frame_stone:getChildByName("image_stone"), StaticTableType.DictThing, StaticThing.luckStore)

    local btn_protect = image_di_water:getChildByName("btn_protect")
    btn_protect:setTitleText(Lang.ui_equipment_clean6)
    btn_protect:setBright(true)
    btn_protect:setPressedActionEnabled(true)
    btn_protect:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _waterNums <= 0 then
                UIManager.showToast(Lang.ui_equipment_clean7)
                return
            end
            btn_protect:setBright(not btn_protect:isBright())
            btn_protect:setTitleText(btn_protect:isBright() and Lang.ui_equipment_clean8 or Lang.ui_equipment_clean9)
            ui_textProtect:setString(btn_protect:isBright() and Lang.ui_equipment_clean10 or Lang.ui_equipment_clean11)
            ui_textProtect:setTextColor(btn_protect:isBright() and cc.c3b(191,191,191) or cc.c3b(0,194,255))
        end
    end)
    local _successPercent = DictSysConfig[tostring(StaticSysConfig.equipAdwance0To1)].value
    if equipAdvanceId ~= 0 and dictEquipAdvanceData and nextEquipAdvanceData then
        _successPercent = DictSysConfig[tostring(StaticSysConfig[string.format("equipAdwance%dTo%d", dictEquipAdvanceData.starLevel, dictEquipAdvanceData.starLevel+1)])].value
    end
    if nextEquipAdvanceData then
        image_di:getChildByName("text_success"):setString(string.format(Lang.ui_equipment_clean12, _successPercent))
    else
        if dictEquipAdvanceData.starLevel == MAX_STAR_LEVEL and dictEquipData.equipQualityId == StaticEquip_Quality.purple then
            image_di:getChildByName("text_success"):setString(Lang.ui_equipment_clean13)
        else
            image_di:getChildByName("text_success"):setString(Lang.ui_equipment_clean14)
        end
    end
    image_di_stone:getChildByName("text_success"):setString(string.format(Lang.ui_equipment_clean15, 0))
    local image_number = image_di_stone:getChildByName("image_number")
    local ui_stoneNums = image_number:getChildByName("text_number")
    ui_stoneNums:setString(tostring(0))
    local btn_add = image_number:getChildByName("btn_add")
    local btn_minus = image_number:getChildByName("btn_minus")
    btn_add:setPressedActionEnabled(true)
    btn_minus:setPressedActionEnabled(true)
    local function btnNumEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local _nums, _percent = 0, _successPercent
            if sender == btn_add then
                if _stoneNums <= 0 then
                    UIManager.showToast(Lang.ui_equipment_clean16)
                    return
                end
                if _percent + tonumber(ui_stoneNums:getString()) * DictThing[tostring(StaticThing.luckStore)].value >= 100 then
                    UIManager.showToast(Lang.ui_equipment_clean17)
                    return
                end
                _nums = tonumber(ui_stoneNums:getString()) + 1
                if utils.getThingCount(StaticThing.luckStore) < _nums then
                    UIManager.showToast(Lang.ui_equipment_clean18)
                    return
                end
                _percent = _percent + _nums * DictThing[tostring(StaticThing.luckStore)].value
                if _percent > 100 then
                    _percent = 100
                end
            elseif sender == btn_minus then
                if _stoneNums <= 0 then
                    return
                end
                _nums = tonumber(ui_stoneNums:getString()) - 1
                if _nums < 0 then
                    _nums = 0
                end
                _percent = _percent + _nums * DictThing[tostring(StaticThing.luckStore)].value
                if _percent < _successPercent then
                    _percent = _successPercent
                end
            end
            ui_stoneNums:setString(tostring(_nums))
            if nextEquipAdvanceData then
                image_di:getChildByName("text_success"):setString(string.format(Lang.ui_equipment_clean19, _percent))
            end
            image_di_stone:getChildByName("text_success"):setString(string.format(Lang.ui_equipment_clean20, _nums * DictThing[tostring(StaticThing.luckStore)].value))
        end
    end
    btn_add:addTouchEventListener(btnNumEvent)
    btn_minus:addTouchEventListener(btnNumEvent)

    local btn_clean = image_di:getChildByName("btn_clean")
	btn_clean:setPressedActionEnabled(true)
	if dictEquipAdvanceData.starLevel == MAX_STAR_LEVEL or (dictEquipAdvanceData.starLevel == 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue) then
		btn_clean:setBright(false)
	else
		btn_clean:setBright(true)
	end
    if dictEquipAdvanceData.starLevel == MAX_STAR_LEVEL and dictEquipData.equipQualityId == StaticEquip_Quality.purple then
        btn_clean:setBright(true)
        btn_clean:setTitleText(Lang.ui_equipment_clean21)
    end

	btn_clean:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if btn_clean:isBright() then
                if btn_clean:getTitleText() == Lang.ui_equipment_clean22 then
                    UIManager.popScene()
                    UIEquipmentAdvance.show({InstPlayerEquip_id = userData.InstPlayerEquip_id})
                    return
                end
				if _count >= tonumber(contions[1]) then
					if tonumber(net.InstPlayer.string["6"]) >= tonumber(contions[2]) then
                        local sendNetData = function()
                            local sendData = {
							    header = StaticMsgRule.equipAdvance,
							    msgdata = {
								    int = {
									    instPlayerEquipId = userData.InstPlayerEquip_id,
                                        wishWaterNum = btn_protect:isBright() and 0 or 1,
                                        luckStoreNum = tonumber(ui_stoneNums:getString())
								    }
							    }
						    }
						    UIManager.showLoading()
						    netSendPackage(sendData, netCallbackFunc)
                        end
                        local _percent = utils.stringSplit(image_di:getChildByName("text_success"):getString(), "：")[2]
                        if equipAdvanceId == 0 and _percent ~= "100%" then
                            utils.showDialog(Lang.ui_equipment_clean23, sendNetData)
                        else
                            if btn_protect:isBright() and _percent ~= "100%" then
                                utils.showDialog(Lang.ui_equipment_clean24, sendNetData)
                            elseif btn_protect:isBright() then
                                 utils.showDialog(Lang.ui_equipment_clean25, sendNetData)
                            elseif _percent ~= "100%" then
                                utils.showDialog(Lang.ui_equipment_clean26, sendNetData)
                            else
                                sendNetData()
                            end
                        end
					else
						UIManager.showToast(Lang.ui_equipment_clean27)
					end
				else
					UIManager.showToast(Lang.ui_equipment_clean28)
				end
			else
				UIManager.showToast(Lang.ui_equipment_clean29)
			end
		end
	end)
end

function UIEquipmentClean.free()
	userData = nil
    _equipIconPath = nil
    _curEquipStarLevel = 0
    if UIEquipmentClean.Widget:getChildByTag(STAR_ANIM_TAG) then
        UIEquipmentClean.Widget:getChildByTag(STAR_ANIM_TAG):removeFromParent()
    end
end

function UIEquipmentClean.show(_tableParams)
	userData = _tableParams
	if userData and userData.InstPlayerEquip_id then
        UIManager.pushScene("ui_equipment_clean")
	else
		UIManager.showToast(Lang.ui_equipment_clean30)
	end
end
