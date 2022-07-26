require"Lang"
UILineupQixia = {}

local EQUIP_TYPE_WQ = 1 --武器
local EQUIP_TYPE_YF = 2 --衣服
local EQUIP_TYPE_TK = 3 --头盔
local EQUIP_TYPE_SP = 4 --饰品

local userData = nil

local DictQixia = nil

local ui_titleTabs = nil
local ui_pageView = nil
local ui_pageViewItem = nil
local pageViewEvent = nil

local _curPageViewIndex = -1

local function cleanPageView(_isRelease)
    if _isRelease then
        if ui_pageViewItem and ui_pageViewItem:getReferenceCount() >= 1 then
            ui_pageViewItem:release()
            ui_pageViewItem = nil
        end
    else
        if ui_pageViewItem:getReferenceCount() == 1 then
            ui_pageViewItem:retain()
        end
    end
    if ui_pageView then
        ui_pageView:removeAllPages()
    end
    if ui_pageView then
        ui_pageView:removeAllChildren()
    end
    _curPageViewIndex = -1
end

local function layoutScrollView(ui_scrollView, _listData, _initItemFunc, _noJumpToTop)
    local SCROLLVIEW_ITEM_SPACE = 5
    local _isCloneItem = false
    local childs = ui_scrollView:getChildren()
    if #childs == 0 then
	    ui_scrollView:removeAllChildren()
        _isCloneItem = true
    elseif ui_scrollView:getChildByName("ui_logicPanel") then
        ui_scrollView:getChildByName("ui_logicPanel"):removeFromParent()
    end
    if not _noJumpToTop then
	    ui_scrollView:jumpToTop()
    end
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
        local scrollViewItem = childs[key]
        if _isCloneItem then
		    scrollViewItem = ccui.Helper:seekNodeByName(ui_pageViewItem, "image_info"):clone()
		    ui_scrollView:addChild(scrollViewItem)
        end
        _initItemFunc(scrollViewItem, obj, key)
		_innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
end

local function getLineupData()
    local cardData = { }
    local formation1, formation2 = { }, { }
    for key, obj in pairs(net.InstPlayerFormation) do
        if UILineup.friendState == 1 then
            if obj.int["4"] == 3 and obj.int["10"] > 0 then
                formation1[#formation1 + 1] = obj
            end
        else
            if obj.int["4"] == 1 then
                -- 主力
                formation1[#formation1 + 1] = obj
            elseif obj.int["4"] == 2 then
                -- 替补
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
    if UILineup.friendState == 1 then
        utils.quickSort(formation1, function (obj1, obj2)
            if obj1.int["10"] > obj2.int["10"] then
                return true
            end
            return false
        end)
    else
        utils.quickSort(formation1, compareFunc)
    end
    utils.quickSort(formation2, compareFunc)
    for i = 1,(#formation1 + #formation2) do
        local obj = nil
        if formation1[i] then
            obj = formation1[i]
        elseif formation2[i - #formation1] then
            obj = formation2[i - #formation1]
        end
        if obj then
            if cardData[i] == nil then
                cardData[i] = { }
            end
            cardData[i].dictId = obj.int["6"]
            cardData[i].instId = obj.int["3"]
            cardData[i].instFormationId = obj.int["1"]
        end
    end
    return cardData
end

local function getCurSelectedEquipType()
    local _equipType = 0
    for key, obj in pairs(ui_titleTabs) do
        if obj.ui:getTag() > 0 then
            _equipType = obj.ui:getTag()
            break
        end
    end
    return _equipType
end

local function refreshUITitleInfo()
    local image_basemap = UILineupQixia.Widget:getChildByName("image_basemap")
    local image_bian = image_basemap:getChildByName("image_bian")
    local _zhufushui = ccui.Helper:seekNodeByName(image_bian, "text_shui_number")
    _zhufushui:setString(tostring(utils.getThingCount(StaticThing.wishWater)))
    local _huonengshi = ccui.Helper:seekNodeByName(image_bian, "text_stone_number")
    _huonengshi:setString(tostring(net.InstPlayer.int["21"]))
    local _wanmeifu = ccui.Helper:seekNodeByName(image_bian, "text_fu_number")
    _wanmeifu:setString(tostring(utils.getThingCount(StaticThing.thing174)))
    local _zhandouli = ccui.Helper:seekNodeByName(image_bian, "label_fight")
    _zhandouli:setString(tostring(utils.getFightValue()))
end

-- _curState : -1未解封 0可精炼 1普通 2优良 3完美
local function scrollViewItemLogic(_uiPanel, _data, _instFormationId, _curState, _index, _instItemDatas)
    local formation = net.InstPlayerFormation[tostring(_instFormationId)]
    local btn_refine = _uiPanel:getChildByName("btn_refine")
    local ui_thingIcon = ccui.Helper:seekNodeByName(_uiPanel, "image_good")
    local ui_thingName = ccui.Helper:seekNodeByName(_uiPanel, "text_name")
    local ui_thingChoose = ccui.Helper:seekNodeByName(_uiPanel, "box_choose")
    local ui_fireStoneNum = ccui.Helper:seekNodeByName(_uiPanel, "text_number")
    ui_fireStoneNum:setString("×" .. _data.useStone)
    if _curState == -1 then
        ui_thingIcon:loadTexture("image/" .. DictUI[tostring(DictThing[tostring(StaticThing.wishWater)].smallUiId)].fileName)
        ui_thingName:setString(DictThing[tostring(StaticThing.wishWater)].name .. "×" .. _data.openNum)
        ui_thingChoose:setVisible(false)
        btn_refine:setTitleText(Lang.ui_lineup_qixia1)
        ui_fireStoneNum:getParent():setVisible(false)
    else
        ui_thingIcon:loadTexture("image/" .. DictUI[tostring(DictThing[tostring(StaticThing.thing174)].smallUiId)].fileName)
        ui_thingName:setString(DictThing[tostring(StaticThing.thing174)].name .. "×" .. _data.perfectNum)
        ui_thingChoose:setVisible(true)
        ui_thingChoose:setSelected(false)
        btn_refine:setTitleText(Lang.ui_lineup_qixia2)
        ui_fireStoneNum:getParent():setVisible(true)
    end
    local refreshItemData = function()
        _curPageViewIndex = -1
        refreshUITitleInfo()
        pageViewEvent(ui_pageView, ccui.PageViewEventType.turning, _index)
    end
    btn_refine:setPressedActionEnabled(true)
    btn_refine:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _curState == -1 then
                if _index == 1 or (_instItemDatas and _instItemDatas[_index - 1]) then
                    if utils.getThingCount(StaticThing.wishWater) < _data.openNum then
                        UIManager.showToast(DictThing[tostring(StaticThing.wishWater)].name .. Lang.ui_lineup_qixia3)
                    else
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.deblockEquipBoxData,
                            msgdata = { int = {
                                formationId = _instFormationId,
                                level = _data.id,
                                type = getCurSelectedEquipType()
                            } }
                        } , function(_msgData)
                            UIManager.showToast(Lang.ui_lineup_qixia4)
                            refreshItemData()
                        end)
                    end
                else
                    UIManager.showToast(Lang.ui_lineup_qixia5)
                end
            else
                if net.InstPlayer.int["21"] < _data.useStone then
                    UIManager.showToast(Lang.ui_lineup_qixia6)
                elseif ui_thingChoose:isSelected() and utils.getThingCount(StaticThing.thing174) < _data.perfectNum then
                    UIManager.showToast(DictThing[tostring(StaticThing.thing174)].name .. Lang.ui_lineup_qixia7)
                else
                    UIManager.showLoading()

                    local _oldData = {}
                    if _instItemDatas and #_instItemDatas > 0 then
                        local _perfectLvStr = ""
                        for _iii, _ooo in pairs(_instItemDatas) do
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
                                        _oldData[#_oldData + 1] = _lvId
                                    end
                                end
                            end
                        end
                    end
                    
                    netSendPackage( {
                        header = StaticMsgRule.refineEquipBox,
                        msgdata = { int = {
                            formationId = _instFormationId,
                            level = _data.id,
                            type = getCurSelectedEquipType(),
                            perfect = ui_thingChoose:isSelected() and 1 or 0 --0不使用完美符  1使用完美符
                        } }
                    } , function(_msgData)
                        
                        local _animImages = {}
                        if net.InstPlayerEquipBox then
                            local _curEquipType = getCurSelectedEquipType()
                            for _ipebKey, _ipebObj in pairs(net.InstPlayerEquipBox) do
                                if _instFormationId == _ipebObj.int["3"] then
                                    local _ipebInstData = nil
                                    if _curEquipType == EQUIP_TYPE_WQ then
                                        _ipebInstData = utils.stringSplit(_ipebObj.string["4"], ";")
                                    elseif _curEquipType == EQUIP_TYPE_YF then
                                        _ipebInstData = utils.stringSplit(_ipebObj.string["5"], ";")
                                    elseif _curEquipType == EQUIP_TYPE_TK then
                                        _ipebInstData = utils.stringSplit(_ipebObj.string["6"], ";")
                                    elseif _curEquipType == EQUIP_TYPE_SP then
                                        _ipebInstData = utils.stringSplit(_ipebObj.string["7"], ";")
                                    end
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
                                                        local _flag = true
                                                        for _kkk, _ddd in pairs(_oldData) do
                                                            if _ddd == _lvId then
                                                                _flag = false
                                                                break
                                                            end
                                                        end
                                                        if _flag then
                                                            if _lvId == 5 then
                                                                _animImages[#_animImages + 1] = "ui/qx_green.png"
                                                            elseif _lvId == 10 then
                                                                _animImages[#_animImages + 1] = "ui/qx_blue.png"
                                                            elseif _lvId == 15 then
                                                                _animImages[#_animImages + 1] = "ui/qx_purple.png"
                                                            elseif _lvId == 20 then
                                                                _animImages[#_animImages + 1] = "ui/qx_red.png"
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end

                        if #_animImages > 0 then
                            local _equipIcon = "ui/frame_tianjia.png"
                            local _equipQualityImage = "ui/low_small_white.png"
                            if net.InstPlayerLineup then
                                local _curEquipType = getCurSelectedEquipType()
                                if _curEquipType == EQUIP_TYPE_WQ then
                                    _curEquipType = StaticEquip_Type.equip
                                elseif _curEquipType == EQUIP_TYPE_YF then
                                    _curEquipType = StaticEquip_Type.outerwear
                                elseif _curEquipType == EQUIP_TYPE_TK then
                                    _curEquipType = StaticEquip_Type.pants
                                elseif _curEquipType == EQUIP_TYPE_SP then
                                    _curEquipType = StaticEquip_Type.necklace
                                end
                                for _iplKey, _iplObj in pairs(net.InstPlayerLineup) do
                                    if _instFormationId == _iplObj.int["3"] and _curEquipType == _iplObj.int["4"] then
                                        local instEquipData = net.InstPlayerEquip[tostring(_iplObj.int["5"])]
                                        local dictData = DictEquipment[tostring(instEquipData.int["4"])]
                                        _equipIcon = "image/" .. DictUI[tostring(dictData.smallUiId)].fileName
                                        local _equipQualityId = dictData.equipQualityId
                                        if instEquipData.int["8"] >= 1000 then
                                            _equipQualityId = DictEquipAdvancered[tostring(instEquipData.int["8"])].equipQualityId
                                            _equipIcon = "image/" .. DictUI[tostring(dictData.RedsmallUiId)].fileName
                                        end
                                        _equipQualityImage = utils.getQualityImage(dp.Quality.equip, _equipQualityId, dp.QualityImageType.small)
                                        break
                                    end
                                end
                            end
                            local playerAnimation = nil
                            local _animIndex = 1
                            local dialog = ccui.Layout:create()
                            dialog:setContentSize(UIManager.screenSize)
                            dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
                            dialog:setBackGroundColor(cc.c3b(0, 0, 0))
                            dialog:setBackGroundColorOpacity(130)
                            dialog:setTouchEnabled(true)
                            dialog:retain()
                            playerAnimation = function()
                                local uiAnimId = 78
                                local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
                                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
                                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
                                local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
                                animation:getAnimation():playWithIndex(0)
                                animation:getAnimation():setMovementEventCallFunc(function(armature, movementType, movementID)
                                    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                                        armature:removeFromParent()
                                        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
                                        ccs.ArmatureDataManager:getInstance():removeArmatureData(movementID)
                                        if _animImages[_animIndex] then
                                            playerAnimation()
                                        else
                                            UIManager.uiLayer:removeChild(dialog, true)
                                            cc.release(dialog)
                                            refreshItemData()
                                        end
                                    end
                                end)
                                animation:getBone("jingliankuang"):addDisplay(ccs.Skin:create(_animImages[_animIndex]), 0)
                                animation:getBone("zhuangbei"):addDisplay(ccs.Skin:create(_equipIcon), 0)
                                animation:getBone("di"):addDisplay(ccs.Skin:create(_equipQualityImage), 0)
                                animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
	                            dialog:addChild(animation)
                                _animIndex = _animIndex + 1
                            end
                            UIManager.uiLayer:addChild(dialog, 1000)
                            playerAnimation()
                        else
                            UIManager.showToast(Lang.ui_lineup_qixia8)
                            refreshItemData()
                        end

                    end)
                end
            end
        end
    end)
end

pageViewEvent = function(sender, eventType, _refreshItemIndex)
    if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
        _curPageViewIndex = sender:getCurPageIndex()
        local pageViewItem = sender:getPage(_curPageViewIndex)
        local ui_scrollView = pageViewItem:getChildByName("view_info")
        local _instFormationId = ui_scrollView:getTag()
        local _instDatas, _instItemDatas = nil, nil
        if net.InstPlayerEquipBox then
            local _curEquipType = getCurSelectedEquipType()
            for key, obj in pairs(net.InstPlayerEquipBox) do
                if obj.int["3"] == _instFormationId then
                    if _curEquipType == EQUIP_TYPE_WQ then
                        _instDatas = obj.string["4"]
                    elseif _curEquipType == EQUIP_TYPE_YF then
                        _instDatas = obj.string["5"]
                    elseif _curEquipType == EQUIP_TYPE_TK then
                        _instDatas = obj.string["6"]
                    elseif _curEquipType == EQUIP_TYPE_SP then
                        _instDatas = obj.string["7"]
                    end
                    break
                end
            end
        end
        if _instDatas then
            _instItemDatas = utils.stringSplit(_instDatas, ";")
        end
        local setScrollViewItemData = function(_item, _data, _index)
            local _curState = -1 -- -1未解封 0可精炼 1普通 2优良 3完美
            if _instItemDatas and _instItemDatas[_index] then
                _curState = tonumber(utils.stringSplit(_instItemDatas[_index], "_")[2])
            end
            local ui_lv = _item:getChildByName("text_lv")
            local ui_range = _item:getChildByName("text_range")
            local ui_addProp = _item:getChildByName("text_add")
            local ui_state = _item:getChildByName("text_prefect")
            local ui_closed = _item:getChildByName("text_closed")
            ui_lv:setString(Lang.ui_lineup_qixia9 .. _data.id)
            ui_range:setString(string.format("%d - %d %%", _data.goodAdd, _data.bestAdd))

            --default
            _item:loadTexture((_index % 2 == 0) and "ui/lm_s.png" or "ui/lm_q.png")
            ui_closed:setString(Lang.ui_lineup_qixia10)
            ui_range:setVisible(false)
            ui_addProp:setVisible(false)
            ui_state:setVisible(false)
            ui_closed:setVisible(true)
            _item:setTouchEnabled(true)

            if _curState >= 0 then
                ui_range:setVisible(true)
                if _curState == 0 then
                    ui_closed:setString(Lang.ui_lineup_qixia11)
                else
                    ui_closed:setVisible(false)
                    ui_addProp:setVisible(true)
                    ui_state:setVisible(true)
                    if _curState == 1 then
                        ui_addProp:setString(string.format("+%d %%", _data.goodAdd))
                        ui_state:setString(Lang.ui_lineup_qixia12)
                        ui_state:setTextColor(cc.c3b(255, 255, 255))
                    elseif _curState == 2 then
                        ui_addProp:setString(string.format("+%d %%", _data.betterAdd))
                        ui_state:setString(Lang.ui_lineup_qixia13)
                        ui_state:setTextColor(cc.c3b(0, 218, 255))
                    elseif _curState == 3 then
                        ui_addProp:setString(string.format("+%d %%", _data.bestAdd))
                        ui_state:setString(Lang.ui_lineup_qixia14)
                        ui_state:setTextColor(cc.c3b(255, 165, 0))
                        _item:loadTexture("ui/qx_prefect.png")
                    end
                end
            end
            
            _item:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if _curState == 3 then
                        UIManager.showToast(Lang.ui_lineup_qixia15)
                        return
                    end
                    local _innerHeight = ui_scrollView:getInnerContainerSize().height
                    local ui_logicPanel = ui_scrollView:getChildByName("ui_logicPanel")
                    local _isShowLogicPanel = true
                    local SCROLLVIEW_ITEM_SPACE = 5
                    local childs = ui_scrollView:getChildren()
                    if ui_logicPanel then
                        if ui_logicPanel:getTopBoundary() == sender:getBottomBoundary() then
                            _innerHeight = _innerHeight - ui_logicPanel:getContentSize().height
                            ui_logicPanel:removeFromParent()
                            _isShowLogicPanel = false
                            childs = ui_scrollView:getChildren()
                        else
                            for _key, _obj in pairs(childs) do
                                if _obj == ui_logicPanel then
                                    table.remove(childs, _key)
                                    break
                                end
                            end
                            scrollViewItemLogic(ui_logicPanel, _data, _instFormationId, _curState, _index, _instItemDatas)
                        end
                    else
                        ui_logicPanel = ccui.Helper:seekNodeByName(ui_pageViewItem, "image_di_good"):clone()
                        _innerHeight = _innerHeight + ui_logicPanel:getContentSize().height
                        ui_logicPanel:setName("ui_logicPanel")
                        ui_scrollView:addChild(ui_logicPanel)
                        scrollViewItemLogic(ui_logicPanel, _data, _instFormationId, _curState, _index, _instItemDatas)
                    end
                    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
                    local prevChildBottomPos = nil
	                for _key, _obj in pairs(childs) do
		                if prevChildBottomPos == nil then
			                _obj:setPositionY(_innerHeight - _obj:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		                else
			                _obj:setPositionY(prevChildBottomPos - _obj:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		                end
                        if _isShowLogicPanel and _key == _data.id then
                            local y = _obj:getBottomBoundary() - ui_logicPanel:getContentSize().height / 2
                            ui_logicPanel:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, y))
                            prevChildBottomPos = ui_logicPanel:getBottomBoundary()
                        else
		                    prevChildBottomPos = _obj:getBottomBoundary()
                        end
	                end
                end
            end)
        end
        if _refreshItemIndex then
            local _curState = -1 -- -1未解封 0可精炼 1普通 2优良 3完美
            if _instItemDatas and _instItemDatas[_refreshItemIndex] then
                _curState = tonumber(utils.stringSplit(_instItemDatas[_refreshItemIndex], "_")[2])
            end
            if _curState == 3 then
                layoutScrollView(ui_scrollView, DictQixia, setScrollViewItemData, true)
            else
                local childs = ui_scrollView:getChildren()
                local ui_logicPanel = ui_scrollView:getChildByName("ui_logicPanel")
                if ui_logicPanel then
                    scrollViewItemLogic(ui_logicPanel, DictQixia[_refreshItemIndex], _instFormationId, _curState, _refreshItemIndex, _instItemDatas)
                end
                for _key, _obj in pairs(childs) do
                    if _obj ~= ui_logicPanel then
                        setScrollViewItemData(_obj, DictQixia[_key], _key)
                    end
                end
            end
        else
            layoutScrollView(ui_scrollView, DictQixia, setScrollViewItemData)
        end
        if net.InstPlayerEquipBox == nil then
            ui_scrollView:getChildren()[1]:releaseUpEvent()
        end
    end
end

function UILineupQixia.init()
    local image_basemap = UILineupQixia.Widget:getChildByName("image_basemap")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_r = image_basemap:getChildByName("btn_r")
    local btn_l = image_basemap:getChildByName("btn_l")
    btn_help:setPressedActionEnabled(true)
    btn_r:setPressedActionEnabled(true)
    btn_l:setPressedActionEnabled(true)
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_help then
                UIAllianceHelp.show( { type = 31 , titleName = Lang.ui_lineup_qixia16 } )
            elseif sender == btn_r then
                local index = ui_pageView:getCurPageIndex() + 1
                if index > #ui_pageView:getPages() then
                    index = #ui_pageView:getPages()
                end
                ui_pageView:scrollToPage(index)
            elseif sender == btn_l then
                local index = ui_pageView:getCurPageIndex() -1
                if index < 0 then
                    index = 0
                end
                ui_pageView:scrollToPage(index)
            end
        end
    end
    btn_help:addTouchEventListener(onBtnEvent)
    btn_r:addTouchEventListener(onBtnEvent)
    btn_l:addTouchEventListener(onBtnEvent)
    ui_pageView = image_basemap:getChildByName("page_info")
    ui_pageViewItem = ui_pageView:getChildByName("panel"):clone()

    ui_titleTabs = {
        {
            tag = EQUIP_TYPE_WQ,
            ui = image_basemap:getChildByName("image_equipment"), --武器
            focusImage = "ui/qx_wq_l.png",
            unFocusImage = "ui/qx_wq.png"
        },
        {
            tag = EQUIP_TYPE_YF,
            ui = image_basemap:getChildByName("image_clother"), --衣服
            focusImage = "ui/qx_yf_l.png",
            unFocusImage = "ui/qx_yf.png"
        },
        {
            tag = EQUIP_TYPE_TK,
            ui = image_basemap:getChildByName("image_head"), --头盔
            focusImage = "ui/qx_tk_l.png",
            unFocusImage = "ui/qx_tk.png"
        },
        {
            tag = EQUIP_TYPE_SP,
            ui = image_basemap:getChildByName("image_ring"), --饰品
            focusImage = "ui/qx_sp_l.png",
            unFocusImage = "ui/qx_sp.png"
        }
    }
    for key, obj in pairs(ui_titleTabs) do
        obj.ui:ignoreContentAdaptWithSize(true)
        obj.ui:setTouchEnabled(true)
        obj.ui:addTouchEventListener(function(sender, eventType)
            if sender:getTag() == obj.tag then
                return
            end
            for _k, _o in pairs(ui_titleTabs) do
                _o.ui:setTag(0)
                _o.ui:loadTexture(_o.unFocusImage)
            end
            sender:loadTexture(obj.focusImage)
            sender:setTag(obj.tag)
            _curPageViewIndex = -1
            pageViewEvent(ui_pageView, ccui.PageViewEventType.turning)
        end)
    end
    ui_titleTabs[1].ui:releaseUpEvent()
end

function UILineupQixia.setup()
    cleanPageView()
    DictQixia = {}
    for key, obj in pairs(DictEquipBox) do
        DictQixia[obj.id] = obj
    end
    refreshUITitleInfo()
    local _pageIndex = 0

    local lineupData = getLineupData()
    for key, obj in pairs(lineupData) do
        local pageViewItem = ui_pageViewItem:clone()
        pageViewItem:setTag(obj.dictId)
        if key == userData.curShowCardIndex then
            _pageIndex = key - 1
        end
        local dictCardData = DictCard[tostring(obj.dictId)]
        local instCardData = net.InstPlayerCard[tostring(obj.instId)]
        local isAwake = instCardData.int["18"]      
        if dictCardData then
            local ui_cardBg = pageViewItem:getChildByName("image_card")
            ui_cardBg:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)       
        end
        local ui_scrollView = pageViewItem:getChildByName("view_info")
        ui_scrollView:removeAllChildren()
        ui_scrollView:setTag(obj.instFormationId)
        ui_pageView:addPage(pageViewItem)
    end
    ui_pageView:addEventListener(pageViewEvent)
    ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        ui_pageView:scrollToPage(_pageIndex)
    end )))
end

function UILineupQixia.free()
    cleanPageView()
    DictQixia = nil
    userData = nil
end

function UILineupQixia.show(_tableParams)
    userData = _tableParams
    UIManager.showWidget("ui_notice", "ui_lineup_qixia", "ui_menu")
end
