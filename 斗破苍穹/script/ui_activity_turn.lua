require"Lang"
UIActivityTurn = {}

local TURN_TYPE_OUTER = 1 --豪华转(外圈)
local TURN_TYPE_INNER = 2 --至尊转(内圈)

local DictActivity = nil

local ui_arrow = nil
local ui_scrollView = nil
local ui_itemArrays = nil
local ui_focus = nil

local _itemThingsData = nil
local _scrollViewIsAction = false

function UIActivityTurn.onActivity(_params)
    DictActivity = _params
end

local function cleanScrollView()
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
	local SCROLLVIEW_ITEM_SPACE = 0
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if _listData == nil then
        _listData = {}
    end
	for key, obj in pairs(_listData) do
        local ui_richText = ccui.RichText:create()
	    ui_richText:ignoreContentAdaptWithSize(false)
	    ui_richText:setContentSize(cc.size(ui_scrollView:getContentSize().width, 30))
		_initItemFunc(ui_richText, obj)
		ui_scrollView:addChild(ui_richText)
		_innerHeight = _innerHeight + ui_richText:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		local apX, apY = childs[i]:getAnchorPoint().x, childs[i]:getAnchorPoint().y
		if i == 1 then
			if apX == 0.5 and apY == 0.5 then
				childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
			elseif apX == 0 and apY == 0 then
				childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
			end
		else
			if apX == 0.5 and apY == 0.5 then
				childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
			elseif apX == 0 and apY == 0 then
				childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
			end
		end
		prevChild = childs[i]
	end
--	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local function playAnimaction(_callbackFunc)
    local uiAnimId = 73
    local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    animation:getAnimation():playWithIndex(0)
    animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    animation:getAnimation():setMovementEventCallFunc(function(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            armature:getAnimation():stop()
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
            ccs.ArmatureDataManager:getInstance():removeArmatureData(movementID)
            if _callbackFunc then
                _callbackFunc()
            end
            armature:removeFromParent()
        end
    end)
    UIActivityTurn.Widget:addChild(animation, 1000)
end

local function turnLogic(_type, _callbackFunc)
    UIManager.showLoading()
    netSendPackage({header=StaticMsgRule.runMiracleTurnStart, msgdata={int={type=_type}}}, function(_msgData)
    

    local uiLayout = ccui.Layout:create()
    uiLayout:setContentSize(UIManager.screenSize)
    uiLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    uiLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    uiLayout:setBackGroundColorOpacity(0)
    uiLayout:setTouchEnabled(true)
    UIManager.uiLayer:addChild(uiLayout, 9999)

    ui_focus:setVisible(true)
    local _curIndex = ui_focus:getTag()
    local _startIndex = 1
    local _endIndex = 12
    if _type == TURN_TYPE_INNER then
        _startIndex = 13
        _endIndex = #ui_itemArrays
        if _curIndex < _startIndex then
            ui_focus:setTag(_startIndex)
            _curIndex = _startIndex
        end
    else
        if _curIndex > _endIndex then
            ui_focus:setTag(_startIndex)
            _curIndex = _startIndex
        end
    end
    local _selectIndex = 0
    for key, item in pairs(ui_itemArrays) do
        if item:getTag() == _msgData.msgdata.int.rewardId then
            _selectIndex = key
            break
        end
    end
--    local _selectIndex = utils.random(_startIndex, #ui_itemArrays) --TEST
--    cclog("-------->>> _selectIndex = " .. _selectIndex)
    if _selectIndex <= 0 then
        UIManager.showToast(Lang.ui_activity_turn1)
        uiLayout:removeFromParent()
        uiLayout = nil
        return
    end
    local _isPlayAnim = false
    if _type == TURN_TYPE_OUTER and _selectIndex > _endIndex then
        _isPlayAnim = true
    end

    local _ranActionCount = 0
    local logicAction
    local _turnCount = 0
    logicAction = function()
        local _moveTime = _type == TURN_TYPE_OUTER and 0.004 or 0.008
        local _delayTime = _type == TURN_TYPE_OUTER and 0.04 or 0.08
        if _turnCount == 1 then
            _moveTime = _type == TURN_TYPE_OUTER and 0.008 or 0.016
            _delayTime = _type == TURN_TYPE_OUTER and 0.08 or 0.16
        elseif _turnCount == 2 then
            _moveTime = _type == TURN_TYPE_OUTER and 0.01 or 0.02
            _delayTime = _type == TURN_TYPE_OUTER and 0.1 or 0.2
        elseif _turnCount >= 3 then
            _moveTime = _moveTime + (_type == TURN_TYPE_OUTER and 0.01 or 0.02)
            _delayTime = _delayTime + (_type == TURN_TYPE_OUTER and 0.1 or 0.2)
        end
        local pos = cc.p(ui_itemArrays[ui_focus:getTag()]:getPositionX(), ui_itemArrays[ui_focus:getTag()]:getPositionY())
        ui_focus:runAction(cc.Sequence:create(cc.MoveTo:create(_moveTime, pos), cc.DelayTime:create(_delayTime), cc.CallFunc:create(function()
            local _focusTag = ui_focus:getTag()
            if _ranActionCount > 0 and _focusTag == _curIndex then
                _turnCount = _turnCount + 1
            end
            local _index = _focusTag + 1
            if _index > _endIndex then
                _index = _startIndex
            end
            ui_focus:setTag(_index)

            if _turnCount >= 3 and _focusTag == _selectIndex then
                if _itemThingsData then
                    utils.showGetThings(_itemThingsData[_selectIndex])
                end
                if _callbackFunc then
                    _callbackFunc()
                end
		UIActivityTime.refreshMoney()
                UIActivityTurn.setup()
                uiLayout:removeFromParent()
                uiLayout = nil
                _ranActionCount = 0
            elseif _isPlayAnim and _turnCount == 2 then
                playAnimaction(function()
                    _startIndex = 13
                    _endIndex = #ui_itemArrays
                    ui_focus:setTag(_startIndex)
                    _curIndex = _startIndex
                    _turnCount = 0
                    _ranActionCount = 0
                    _isPlayAnim = false
                    logicAction()
                end)
            else
                logicAction()
            end

            _ranActionCount = _ranActionCount + 1
        end)))
    end
    logicAction()


    end)
end

function UIActivityTurn.init()
    local image_basemap = UIActivityTurn.Widget:getChildByName("image_basemap")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_good = image_basemap:getChildByName("btn_good")
    local btn_super = image_basemap:getChildByName("btn_super")
    btn_help:setPressedActionEnabled(true)
    btn_good:setPressedActionEnabled(true)
    btn_super:setPressedActionEnabled(true)

    ui_arrow = image_basemap:getChildByName("image_di_info"):getChildByName("image_arrow")
    ui_scrollView = ccui.Helper:seekNodeByName(image_basemap:getChildByName("image_di_info"), "view_info")

    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if ui_scrollView:isTouchEnabled() then
                image_basemap:releaseUpEvent()
                return
            end
            if sender == btn_help then
                UIAllianceHelp.show( { type = 28 , titleName = Lang.ui_activity_turn2 } )
            elseif sender == btn_good then
                local numbers = utils.stringSplit(btn_good:getChildByName("text_number"):getString(), "×")
                if tonumber(numbers[2]) <= 0 then
                    UIManager.showToast(Lang.ui_activity_turn3)
                    return
                end
                turnLogic(TURN_TYPE_OUTER)
            elseif sender == btn_super then
                if utils.getThingCount(StaticThing.thing97) <= 0 then
                    UIManager.showToast(DictThing[tostring(StaticThing.thing97)].name .. Lang.ui_activity_turn4)
                    return
                end
                turnLogic(TURN_TYPE_INNER)
            end
        end
    end
    btn_help:addTouchEventListener(onButtonEvent)
    btn_good:addTouchEventListener(onButtonEvent)
    btn_super:addTouchEventListener(onButtonEvent)
    
    local arrowAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(ui_arrow:getPositionX(), ui_arrow:getPositionY() + 10)), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		ui_arrow:setPositionY(ui_arrow:getPositionY() - 10)
		ui_arrow:setOpacity(255)
	end)))
    ui_arrow:runAction(arrowAction)
    
    ui_scrollView:setTouchEnabled(false)
    ui_scrollView:getParent():addTouchEventListener(function(sender, eventType)
        if not _scrollViewIsAction and eventType == ccui.TouchEventType.ended and not ui_scrollView:isTouchEnabled() then
            _scrollViewIsAction = true
            ui_scrollView:getParent():runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 150)), cc.CallFunc:create(function()
                ui_scrollView:setTouchEnabled(true)
                ui_arrow:setVisible(false)
                _scrollViewIsAction = false
            end)))
        end
    end)

    image_basemap:setTouchEnabled(true)
    image_basemap:addTouchEventListener(function(sender, eventType)
        if not _scrollViewIsAction and eventType == ccui.TouchEventType.ended and ui_scrollView:isTouchEnabled() then
            _scrollViewIsAction = true
            ui_scrollView:getParent():runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, -150)), cc.CallFunc:create(function()
                ui_scrollView:jumpToTop()
                ui_scrollView:setTouchEnabled(false)
                ui_arrow:setVisible(true)
                _scrollViewIsAction = false
            end)))
        end
    end)

    ui_itemArrays = {}
    for i = 1, 16 do
        ui_itemArrays[i] = image_basemap:getChildByName("image_frame_good"..i)
    end
    ui_focus = image_basemap:getChildByName("image_choose")
    ui_focus:setVisible(false)
    ui_focus:setTag(1)
end

function UIActivityTurn.setup()
    local image_basemap = UIActivityTurn.Widget:getChildByName("image_basemap")
    local ui_leftCount = image_basemap:getChildByName("btn_good"):getChildByName("text_number")
    local ui_rightCount = image_basemap:getChildByName("btn_super"):getChildByName("text_number")
--    ui_leftCount:setString("×0")
    ui_rightCount:setString("×" .. utils.getThingCount(StaticThing.thing97))

    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.openMiracleTurnPanel, msgdata={}}, function(_msgData)
        ui_leftCount:setString("×" .. _msgData.msgdata.int.count)
        local _prevSelectedId = _msgData.msgdata.int.upId
        if _prevSelectedId <= 0 then
            ui_focus:setVisible(false)
            ui_focus:setTag(1)
        end
        local type1Datas = utils.stringSplit(_msgData.msgdata.string.type1, ";")
        local type2Datas = utils.stringSplit(_msgData.msgdata.string.type2, ";")
        _itemThingsData = nil
        for key, item in pairs(ui_itemArrays) do
            local ui_flagIcon = item:getChildByName("image_good_flag")
            if ui_flagIcon == nil then
                ui_flagIcon = ccui.ImageView:create("ui/suipian.png")
                ui_flagIcon:setName("image_good_flag")
                ui_flagIcon:setAnchorPoint(cc.p(0.2, 0.8))
                ui_flagIcon:setPosition(cc.p(0, item:getContentSize().height))
                item:addChild(ui_flagIcon)
            end
            ui_flagIcon:setVisible(false)
            local itemData = type1Datas[key]
            if key > #type1Datas then
                itemData = type2Datas[key - #type1Datas]
            end
            local tempData = utils.stringSplit(itemData, "|")
            local _id = tonumber(tempData[1])
            local _things = tempData[2]
            if _itemThingsData == nil then
                _itemThingsData = {}
            end
            _itemThingsData[key] = _things
            item:setTag(_id)
            if _id == _prevSelectedId then
                ui_focus:setTag(key)
                ui_focus:setPosition(cc.p(item:getPositionX(), item:getPositionY()))
                ui_focus:setVisible(true)
            end
            local itemProps = utils.getItemProp(_things)
            if itemProps then
                if itemProps.smallIcon then
                    item:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                    utils.showThingsInfo(item:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                end
                if itemProps.flagIcon then
                    ui_flagIcon:loadTexture(itemProps.flagIcon)
                    ui_flagIcon:setVisible(true)
                end
                item:getChildByName("text_number"):setString("×" .. itemProps.count)
            end
        end
        local _descData = nil
        if _msgData.msgdata.string.desc then
            _descData = utils.stringSplit(_msgData.msgdata.string.desc, "/")
        end
        layoutScrollView(_descData, function(_item, _data)
            local _stringDesc = ""
            local _tempData = utils.stringSplit(_data, "|") --type(1:豪华,2:至尊,3:意外)|玩家名称|道具名称
            local _itemProp = utils.getItemProp(_tempData[3])
            local _strColor = "255,217,0";
            if _itemProp.qualityColor then
                _strColor = _itemProp.qualityColor.r .. "," .. _itemProp.qualityColor.g .. "," .. _itemProp.qualityColor.b
            end
            if tonumber(_tempData[1]) == 1 then
                _stringDesc = "<color=255,217,0>".._tempData[2]..Lang.ui_activity_turn5.._strColor..">".._itemProp.name..Lang.ui_activity_turn6
            elseif tonumber(_tempData[1]) == 2 then
                _stringDesc = "<color=255,217,0>".._tempData[2]..Lang.ui_activity_turn7.._strColor..">".._itemProp.name..Lang.ui_activity_turn8
            elseif tonumber(_tempData[1]) == 3 then
                _stringDesc = "<color=255,217,0>".._tempData[2]..Lang.ui_activity_turn9.._strColor..">".._itemProp.name.."</color><color=0,255,0>。</color>"
            end
            _tempData = nil
            local richText = utils.richTextFormat(_stringDesc)
	        for key, obj in pairs(richText) do
		        _item:pushBackElement(ccui.RichElementText:create(key, obj.color, 255, obj.text, dp.FONT, 18))
	        end
        end)
    end)

    local ui_timeLabel = image_basemap:getChildByName("image_title"):getChildByName("text_countdown")
    if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
        local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
        ui_timeLabel:setString(string.format(Lang.ui_activity_turn10, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
    else
        ui_timeLabel:setString("")
    end
end

function UIActivityTurn.free()
    DictActivity = nil
    cleanScrollView()
    if ui_scrollView then
        ui_scrollView:setTouchEnabled(false)
        ui_arrow:setVisible(true)
        ui_scrollView:getParent():stopAllActions()
        ui_scrollView:getParent():setPositionY(0)
    end
    _scrollViewIsAction = false
    _itemThingsData = nil
end
