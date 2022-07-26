require"Lang"
UIEquipmentAdvance = {}

local RED_QUIPMENT_FLAG_ID = 1000
local MAX_STAR_LEVEL = 5
local STAR_ANIM_TAG = -11111

local userData = nil

local function playAnimaction(_equipIconPath, _callbackFunc)
    local image_basemap = UIEquipmentAdvance.Widget:getChildByName("image_basemap")
    local ui_equipIcon = ccui.Helper:seekNodeByName(image_basemap:getChildByName("image_di_l"), "image_equipment")
    if ui_equipIcon:getParent():getChildByName("_equipIcon_animation") then
        if _equipIconPath then
            local animation = ui_equipIcon:getParent():getChildByName("_equipIcon_animation")
            animation:getBone("002"):addDisplay(ccs.Skin:create(_equipIconPath), 0)
        end
--        local animation = ui_equipIcon:getParent():getChildByName("_equipIcon_animation")
--        animation:getAnimation():playWithIndex(0)
--        animation:getAnimation():setMovementEventCallFunc(function(armature, movementType, movementID)
--            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
--                if _callbackFunc then
--                    _callbackFunc()
--                end
--            end
--        end)
    else
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
        ui_equipIcon:getParent():addChild(animation)
    end
end

local function huashenAnimation(_equipIconPath, _newEquipIconPath, _callbackFunc)
    local image_basemap = UIEquipmentAdvance.Widget:getChildByName("image_basemap")
    local ui_equipIcon = ccui.Helper:seekNodeByName(image_basemap:getChildByName("image_di_l"), "image_equipment")
    local equipIconAnimation = ui_equipIcon:getParent():getChildByName("_equipIcon_animation")
    if equipIconAnimation then
        equipIconAnimation:setVisible(false)
    end
    local animation = ActionManager.getUIAnimation(77, function()
        if equipIconAnimation then
            equipIconAnimation:getBone("002"):addDisplay(ccs.Skin:create(_newEquipIconPath), 0)
            equipIconAnimation:setVisible(true)
        end
        if _callbackFunc then
            _callbackFunc()
        end
    end)
    animation:getBone("001"):addDisplay(ccs.Skin:create(_equipIconPath), 0)
    animation:getBone("002"):addDisplay(ccs.Skin:create(_newEquipIconPath), 0)
    animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2 + 179))
	UIManager.uiLayer:addChild(animation, 1000)
end

local function advanceAnimation(_equipIconPath, _curEquipStarLevel, animCallbackFunc)
    local animation = ActionManager.getUIAnimation(41)
    animation:getBone("Layer1"):addDisplay(ccs.Skin:create(_equipIconPath), 0)
    animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2 + 60))
	UIManager.uiLayer:addChild(animation, 1000)
    local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "starAnim" then
            local _curStarPosition = nil
            local image_basemap = UIEquipmentAdvance.Widget:getChildByName("image_basemap")
            local infoPanel = image_basemap:getChildByName("image_di_l")
            local ui_equipQualityBg = ccui.Helper:seekNodeByName(infoPanel, "image_di_name")
            for i = 1, MAX_STAR_LEVEL do
                if _curEquipStarLevel + 1 == i then
		            local ui_starImg = ui_equipQualityBg:getChildByName("image_star" .. i)
                    local point = ui_starImg:getParent():convertToWorldSpace(cc.p(ui_starImg:getPositionX(), ui_starImg:getPositionY()))
                    _curStarPosition = cc.p(point.x, point.y)
                    break
                end
            end
            local animStar = ccui.ImageView:create("ui/star01.png")
            animStar:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height * 0.75))
            animStar:setScale(8)
            UIEquipmentAdvance.Widget:addChild(animStar, 1000, STAR_ANIM_TAG)
            animStar:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.15, 1), cc.MoveTo:create(0.15, _curStarPosition)), cc.CallFunc:create(animCallbackFunc)))
        end
    end
    animation:getAnimation():setFrameEventCallFunc(onFrameEvent)
end

function UIEquipmentAdvance.init()
    local image_basemap = UIEquipmentAdvance.Widget:getChildByName("image_basemap")
    local btn_preview = ccui.Helper:seekNodeByName(image_basemap:getChildByName("image_di_l"), "btn_preview")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_preview:setPressedActionEnabled(true)
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_preview then
                local instEquipData = net.InstPlayerEquip[tostring(userData.InstPlayerEquip_id)]
                require("EquipmentInfo").show({DictEquip_id = instEquipData.int["4"], isRedEquip = true})
            end
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_preview:addTouchEventListener(onBtnEvent)
end

function UIEquipmentAdvance.setup()
    local instEquipData = net.InstPlayerEquip[tostring(userData.InstPlayerEquip_id)]
    local equipTypeId = instEquipData.int["3"] --装备类型ID
	local dictEquipId = instEquipData.int["4"] --装备字典ID
	local equipLv = instEquipData.int["5"] --装备等级
    local dictEquipData = DictEquipment[tostring(dictEquipId)]
	local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID

    --装备进阶字典表
	local dictEquipAdvanceData = (equipAdvanceId >= RED_QUIPMENT_FLAG_ID) and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]

    local image_basemap = UIEquipmentAdvance.Widget:getChildByName("image_basemap")
    local infoPanel = image_basemap:getChildByName("image_di_l")
    local ui_equipIcon = ccui.Helper:seekNodeByName(infoPanel, "image_equipment")
    local ui_equipQualityBg = ccui.Helper:seekNodeByName(infoPanel, "image_di_name")
    local ui_equipName = ccui.Helper:seekNodeByName(infoPanel, "text_name")
    local image_arrow1 = ccui.Helper:seekNodeByName(infoPanel, "image_arrow1")
    local image_arrow2 = ccui.Helper:seekNodeByName(infoPanel, "image_arrow2")
    local image_di_advance = image_basemap:getChildByName("image_di_advance")
    local image_di_god = image_basemap:getChildByName("image_di_god")

    local nextEquipAdvanceData = nil
    local _propAndAdd = 0
    if equipAdvanceId < RED_QUIPMENT_FLAG_ID then
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
        
	    for key, obj in pairs(equipAdvanceData) do
		    if dictEquipAdvanceData.id == obj.id then
			    nextEquipAdvanceData = (equipAdvanceId == 0) and obj or equipAdvanceData[key + 1]
		    end
		    if equipAdvanceId >= obj.id then
			    _propAndAdd = _propAndAdd + obj.propAndAdd
		    else
			    break
		    end
	    end
        if nextEquipAdvanceData == nil then
            for key, obj in pairs(DictEquipAdvancered) do
                if dictEquipId == obj.equipId and obj.starLevel == 0 then
                    nextEquipAdvanceData = obj
                    break
                end
            end
        end
    else
	    for key, obj in pairs(DictEquipAdvance) do
		    if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
			    _propAndAdd = _propAndAdd + obj.propAndAdd
		    end
	    end

        for key, obj in pairs(DictEquipAdvancered) do
            if dictEquipId == obj.equipId and dictEquipAdvanceData.starLevel >= obj.starLevel then
                _propAndAdd = _propAndAdd + obj.propAndAdd
            end
            if dictEquipId == obj.equipId and obj.starLevel == dictEquipAdvanceData.starLevel + 1 then
                nextEquipAdvanceData = obj
            end
        end
    end

    local _curEquipStarLevel = 0
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
    for key, obj in pairs(equipPropData) do
		local _item = ccui.Helper:seekNodeByName(infoPanel, "image_arrow" .. key)
		local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
		_item:getChildByName("text_title"):setString(DictFightProp[tostring(fightPropId)].name .. "：")
		_item:getChildByName("text_blood_before"):setString(addValue + _propAndAdd)
		if nextEquipAdvanceData then
			_item:getChildByName("text_blood_after"):setString(addValue + _propAndAdd + nextEquipAdvanceData.propAndAdd)
		else
			_item:getChildByName("text_blood_after"):setString(Lang.ui_equipment_advance1)
		end
	end

    ui_equipName:setString(dictEquipData.name)
    local _curEquipIconPath = nil
    if dictEquipAdvanceData.equipQualityId == StaticEquip_Quality.golden then
        _curEquipIconPath = "image/" .. DictUI[tostring(dictEquipData.RedbigUiId)].fileName
    else
        _curEquipIconPath = "image/" .. DictUI[tostring(dictEquipData.bigUiId)].fileName
    end
    ui_equipIcon:loadTexture(_curEquipIconPath)
    playAnimaction(_curEquipIconPath)
    ui_equipQualityBg:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.middle, true))

    if dictEquipAdvanceData.starLevel == MAX_STAR_LEVEL and equipAdvanceId < RED_QUIPMENT_FLAG_ID then
        image_di_advance:setVisible(false)
        image_di_god:setVisible(true)
    else
        image_di_god:setVisible(false)
        image_di_advance:setVisible(true)
    end

    ccui.Helper:seekNodeByName(infoPanel, "btn_preview"):setVisible(image_di_god:isVisible())

    local _tempNextEquipAdvanceData = nextEquipAdvanceData
    if nextEquipAdvanceData == nil then
        _tempNextEquipAdvanceData = dictEquipAdvanceData
    end
    local itemPanel = image_di_god:isVisible() and image_di_god or image_di_advance
    if _tempNextEquipAdvanceData.contions1 then
        for i = 1, 3 do
            local _itemProp = utils.getItemProp(_tempNextEquipAdvanceData["contions"..i])
            if _itemProp.tableTypeId == StaticTableType.DictEquipment then
                local ui_frame = itemPanel:getChildByName("image_frame_stone")
                ui_frame:loadTexture(_itemProp.frameIcon)
                ui_frame:getChildByName("image_stone"):loadTexture(_itemProp.smallIcon)
                ui_frame:getChildByName("text_name"):setString(_itemProp.name)
                local _count = 0
	            for key, obj in pairs(net.InstPlayerEquip) do
		            if obj.int["1"] ~= userData.InstPlayerEquip_id and obj.int["6"] == 0 and obj.int["7"] == 0 and obj.int["4"] == dictEquipId and obj.int["8"] <= 0 then
			            _count = _count + 1
		            end
	            end
                ui_frame:getChildByName("text_numbr"):setString(_count .. "/" .. _itemProp.count)
            elseif _itemProp.tableTypeId == StaticTableType.DictThing then
                local ui_frame = itemPanel:getChildByName("image_frame_red")
                ui_frame:loadTexture(_itemProp.frameIcon)
                ui_frame:getChildByName("image_red"):loadTexture(_itemProp.smallIcon)
                ui_frame:getChildByName("text_name"):setString(_itemProp.name)
                ui_frame:getChildByName("text_numbr"):setString(utils.getThingCount(_itemProp.tableFieldId) .. "/" .. _itemProp.count)
            elseif _itemProp.tableTypeId == StaticTableType.DictPlayerBaseProp then
                itemPanel:getChildByName("image_yin"):getChildByName("text_number"):setString(tostring(_itemProp.count))
            end
        end
    end

    local _stoneNums = utils.getThingCount(StaticThing.luckStore)
    local stonePanel = image_di_advance:getChildByName("image_frame_prop")
    local ui_stoneIcon = stonePanel:getChildByName("image_prop")
    ui_stoneIcon:loadTexture("image/" .. DictUI[tostring(DictThing[tostring(StaticThing.luckStore)].smallUiId)].fileName)
    stonePanel:getChildByName("text_name"):setString(DictThing[tostring(StaticThing.luckStore)].name)
    stonePanel:getChildByName("text_have"):setString(Lang.ui_equipment_advance2 .. _stoneNums)
    utils.showThingsInfo(ui_stoneIcon, StaticTableType.DictThing, StaticThing.luckStore)
    local image_number = stonePanel:getChildByName("image_number")
    local ui_stoneNums = image_number:getChildByName("text_number")
    ui_stoneNums:setString(tostring(0))
    
    local _successPercent = 0
    if equipAdvanceId >= RED_QUIPMENT_FLAG_ID and dictEquipAdvanceData and nextEquipAdvanceData then
        _successPercent = nextEquipAdvanceData.pr * 100
    end
    if nextEquipAdvanceData then
        image_di_advance:getChildByName("text_hint"):setString(string.format(Lang.ui_equipment_advance3, _successPercent))
    else
        image_di_advance:getChildByName("text_hint"):setString(Lang.ui_equipment_advance4)
    end

    local btn_add = image_number:getChildByName("btn_add")
    local btn_minus = image_number:getChildByName("btn_minus")
    btn_add:setPressedActionEnabled(true)
    btn_minus:setPressedActionEnabled(true)
    local function btnNumEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local _nums, _percent = 0, _successPercent
            if sender == btn_add then
                if _stoneNums <= 0 then
                    UIManager.showToast(Lang.ui_equipment_advance5)
                    return
                end
                if _percent + tonumber(ui_stoneNums:getString()) * DictThing[tostring(StaticThing.luckStore)].value >= 100 then
                    UIManager.showToast(Lang.ui_equipment_advance6)
                    return
                end
                _nums = tonumber(ui_stoneNums:getString()) + 1
                if utils.getThingCount(StaticThing.luckStore) < _nums then
                    UIManager.showToast(Lang.ui_equipment_advance7)
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
                image_di_advance:getChildByName("text_hint"):setString(string.format(Lang.ui_equipment_advance8, _percent))
            end
        end
    end
    btn_add:addTouchEventListener(btnNumEvent)
    btn_minus:addTouchEventListener(btnNumEvent)

    local btn_clean = itemPanel:getChildByName("btn_clean")
    btn_clean:setPressedActionEnabled(true)
    if nextEquipAdvanceData == nil then
        btn_clean:setBright(false)
    end
    btn_clean:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not btn_clean:isBright() then
                return UIManager.showToast(Lang.ui_equipment_advance9)
            end
            local _num1 = itemPanel:getChildByName("image_frame_stone"):getChildByName("text_numbr"):getString()
            local _num2= itemPanel:getChildByName("image_frame_red"):getChildByName("text_numbr"):getString()
            local _num3 = itemPanel:getChildByName("image_yin"):getChildByName("text_number"):getString()
            local _tempNum1 = utils.stringSplit(_num1, "/")
            local _tempNum2 = utils.stringSplit(_num2, "/")
            if tonumber(_tempNum1[2]) > tonumber(_tempNum1[1]) then
                return UIManager.showToast(Lang.ui_equipment_advance10)
            elseif tonumber(_tempNum2[2]) > tonumber(_tempNum2[1]) then
                return UIManager.showToast(Lang.ui_equipment_advance11)
            elseif tonumber(net.InstPlayer.string["6"]) < tonumber(_num3) then
                return UIManager.showToast(Lang.ui_equipment_advance12)
            end
            --~~~~~~~~~~~~~~~~~~~ net connect logic : start ~~~~~~~~~~~~~~~~~~~~~~~~
            local sendNetData = function()
                local sendData = {
				    header = StaticMsgRule.equipAdvance,
				    msgdata = {
					    int = {
						    instPlayerEquipId = userData.InstPlayerEquip_id,
                            wishWaterNum = 0,
                            luckStoreNum = tonumber(ui_stoneNums:getString())
					    }
				    }
			    }
			    UIManager.showLoading()
			    netSendPackage(sendData, function(_msgData)
                    local refreshUI = function()
                        if UIEquipmentAdvance.Widget:getChildByTag(STAR_ANIM_TAG) then
                            UIEquipmentAdvance.Widget:getChildByTag(STAR_ANIM_TAG):removeFromParent()
                        end
                        UIEquipmentAdvance.setup()
                        UIManager.flushWidget(UIEquipmentInfo)
                        UIManager.flushWidget(UIEquipmentNew)
	                    UIManager.flushWidget(UILineup)
	                    UIManager.flushWidget(UIBagEquipment)
                    end
                    local _state = _msgData.msgdata.int["1"] --1-成功  2-失败变回0星  3-失败不变
                    if _state == 1 then
                        if image_di_god:isVisible() then
--                            UIManager.showToast("恭喜您，化神成功！")
                            local _newEquipIconPath = "image/" .. DictUI[tostring(dictEquipData.RedbigUiId)].fileName
                            huashenAnimation(_curEquipIconPath, _newEquipIconPath, function()
                                refreshUI()
                            end)
                        else
--                            UIManager.showToast("恭喜您，进阶成功！")
                            advanceAnimation(_curEquipIconPath, _curEquipStarLevel, refreshUI)
                        end
                    else
                        if image_di_god:isVisible() then
                            UIManager.showToast(Lang.ui_equipment_advance13)
                        else
                            UIManager.showToast(Lang.ui_equipment_advance14)
                        end
                        refreshUI()
                    end
                end)
            end
            --~~~~~~~~~~~~~~~~~~~ net connect logic : end ~~~~~~~~~~~~~~~~~~~~~~~~
            local _percent = utils.stringSplit(image_di_advance:getChildByName("text_hint"):getString(), "：")[2]
            if image_di_advance:isVisible() and _percent ~= "100%" then
                utils.showDialog(Lang.ui_equipment_advance15, sendNetData)
            else
                sendNetData()
            end
        end
    end)
end

function UIEquipmentAdvance.free()
    userData = nil
    if UIEquipmentAdvance.Widget:getChildByTag(STAR_ANIM_TAG) then
        UIEquipmentAdvance.Widget:getChildByTag(STAR_ANIM_TAG):removeFromParent()
    end
end

function UIEquipmentAdvance.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_equipment_advance")
end
