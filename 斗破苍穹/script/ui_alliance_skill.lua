require"Lang"
UIAllianceSkill = {}

--每次修炼增加的修炼值
local PRACTICE_SPACE = 0

--最大修炼次数
local MAX_COUNT = 999

local UnionPracticeData = nil

local ui_scrollView = nil
local ui_svItem = nil

local _countdownTime = 0

local netCallbackFunc = nil

local function cleanScrollView()
    if ui_svItem and ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local ITEM_ROW = 3
    local SCROLLVIEW_ITEM_SPACE = 0
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
		_initItemFunc(scrollViewItem, obj, key)
		ui_scrollView:addChild(scrollViewItem)
        if key % ITEM_ROW == 0 then
		    _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
        end
	end
    if #_listData % ITEM_ROW ~= 0 then
        _innerHeight = _innerHeight + ui_svItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
    local _index = 1
	for i = 1, #childs do
        local _x = _index * (ui_scrollView:getContentSize().width / ITEM_ROW) - (ui_scrollView:getContentSize().width / ITEM_ROW / 2)
        local _y = prevChild and (prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE) or (ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        _index = _index + 1
        if i % ITEM_ROW == 0 then
            _index = 1
            prevChild = childs[i]
        end
        childs[i]:setPosition(_x, _y)
	end
end

local function getTimer(curTime, hour, minute)
    local _date = os.date("*t", curTime)
    _date.hour = hour
    if minute then
        _date.min = minute
    else
        _date.min = 0
    end
    _date.sec = 0
    return os.time(_date)
end

local function getPracticeData(_practiceId)
    if net.InstUnionPractice then
        -- 修炼Id_当前等级_当前经验;
        local practice = utils.stringSplit(net.InstUnionPractice.string["3"], ";")
        for key, obj in pairs(practice) do
            local _tempObj = utils.stringSplit(obj, "_")
            local _id = tonumber(_tempObj[1])
            local _level = tonumber(_tempObj[2])
            local _exp = tonumber(_tempObj[3])
            if _practiceId == _id then
                return { level = _level, exp = _exp }
            end
        end
        practice = nil
    end
    return { level = 0, exp = 0 }
end

local function getCheckBoxItemData(_count)
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
    local ui_checkbox1 = image_wing_di:getChildByName("checkbox_practice1")
    local ui_checkbox2 = image_wing_di:getChildByName("checkbox_practice2")
    local _selectedType = 0 --消耗类型 1-消耗联盟贡献  2-消耗元宝
    if ui_checkbox1:isSelected() then
        _selectedType = 1
    elseif ui_checkbox2:isSelected() then
        _selectedType = 2
    end

    local consumLogic = nil
    local cValue1, cValue2 = 0, 0
    local _curPracticeValue = UIAllianceSkill.getPracticeValue()
    consumLogic = function(_pValue)
        for key, obj in pairs(DictUnionPracticeConsum) do
            if obj.type == _selectedType and _pValue >= obj.practiceValueStart and _pValue <= obj.practiceValueEnd then
                if _curPracticeValue >= obj.practiceValueStart then
                    cValue1 = cValue1 + (_pValue - _curPracticeValue) * obj.consumUnionValue
                    cValue2 = cValue2 + (_pValue - _curPracticeValue) * obj.consumUnionFund
                else
                    cValue1 = cValue1 + (_pValue - (obj.practiceValueStart - 1)) * obj.consumUnionValue
                    cValue2 = cValue2 + (_pValue - (obj.practiceValueStart - 1)) * obj.consumUnionFund
                    consumLogic(obj.practiceValueStart - 1)
                end
                break
            end
        end
    end
    consumLogic(_curPracticeValue + _count * PRACTICE_SPACE)

    return { type = _selectedType, consumValue1 = cValue1, consumValue2 = cValue2 }
end

local function runWaitAction(_callbackFunc)
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local btn_donate = image_di_dowm:getChildByName("btn_donate")
    local waitPanel = ccui.Layout:create()
    waitPanel:setContentSize(UIManager.screenSize)
--    waitPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    waitPanel:setBackGroundColor(cc.c3b(255, 255, 255))
--    waitPanel:setBackGroundColorOpacity(130)
    waitPanel:setTouchEnabled(true)
    waitPanel:setLocalZOrder(100000)
    UIAllianceSkill.Widget:addChild(waitPanel)
    local _speed = DictSysConfig[tostring(StaticSysConfig.unionPracticeCd)].value
    local loadingBarPanel = ccui.Layout:create()
    loadingBarPanel:setContentSize(cc.size(waitPanel:getContentSize().width * 0.9, 80))
    loadingBarPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    loadingBarPanel:setBackGroundColor(cc.c3b(0, 0, 0))
    loadingBarPanel:setBackGroundColorOpacity(130)
    loadingBarPanel:setPosition(cc.p((waitPanel:getContentSize().width - loadingBarPanel:getContentSize().width) / 2, waitPanel:getContentSize().height * 0.25))
    waitPanel:addChild(loadingBarPanel)
    local loadingBar = ccui.LoadingBar:create()
    loadingBar:loadTexture("ui/bb_loading_blue3.png")
    loadingBar:setPosition(cc.p(loadingBarPanel:getContentSize().width / 2, loadingBarPanel:getContentSize().height / 2))
--    loadingBar:setColor(cc.c3b(0, 0, 255))
    loadingBar:setPercent(0)
    loadingBarPanel:addChild(loadingBar)
    loadingBarPanel:scheduleUpdateWithPriorityLua(function(dt)
        loadingBar:setPercent(loadingBar:getPercent() + ((_speed <= 1) and 2 or 1))
        if loadingBar:getPercent() >= 100 then
            loadingBarPanel:unscheduleUpdate()
        end
    end,0)
    local button = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    button:setTitleText(Lang.ui_alliance_skill1)
    button:setScale(btn_donate:getScale())
    button:setTitleFontName(btn_donate:getTitleFontName())
    button:setTitleColor(btn_donate:getTitleColor())
    button:setTitleFontSize(btn_donate:getTitleFontSize())
    button:setPressedActionEnabled(true)
    button:setTouchEnabled(true)
    local _position = btn_donate:getParent():convertToWorldSpace(cc.p(btn_donate:getPositionX(), btn_donate:getPositionY()))
    button:setPosition(_position)
    waitPanel:addChild(button)
    UIAllianceSkill.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(_speed), cc.CallFunc:create(function()
        waitPanel:removeFromParent()
        if _callbackFunc then
            _callbackFunc()
        end
    end)))
    button:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIAllianceSkill.Widget:stopAllActions()
            waitPanel:removeFromParent()
            btn_donate:setTitleText(Lang.ui_alliance_skill2)
        end
    end)
    btn_donate:setTitleText(Lang.ui_alliance_skill3)
end

local function showWaitingState()
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
    local btn_donate = image_di_dowm:getChildByName("btn_donate")
    local ui_waitTime = image_wing_di:getChildByName("text_time")
    ui_waitTime:setVisible(true)
    local waitPanel = ccui.Layout:create()
    waitPanel:setName("ui_waitPanel")
    waitPanel:setContentSize(UIManager.screenSize)
    waitPanel:setBackGroundColor(cc.c3b(255, 255, 255))
    waitPanel:setTouchEnabled(true)
    waitPanel:setLocalZOrder(100000)
    UIAllianceSkill.Widget:addChild(waitPanel)
    local button = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    button:setName("waitButton")
    button:setTitleText(Lang.ui_alliance_skill4)
    button:setScale(btn_donate:getScale())
    button:setTitleFontName(btn_donate:getTitleFontName())
    button:setTitleColor(btn_donate:getTitleColor())
    button:setTitleFontSize(btn_donate:getTitleFontSize())
    button:setPressedActionEnabled(true)
    button:setTouchEnabled(true)
    local _position = btn_donate:getParent():convertToWorldSpace(cc.p(btn_donate:getPositionX(), btn_donate:getPositionY()))
    button:setPosition(_position)
    waitPanel:addChild(button)
    button:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            dp.removeTimerListener(practiceRefreshTime)
            ui_waitTime:setVisible(false)
            waitPanel:removeFromParent()
            btn_donate:setTitleText(Lang.ui_alliance_skill5)
        end
    end)
    local text_money = image_basemap:getChildByName("text_money")
    text_money:setString(Lang.ui_alliance_skill6 .. 0)
end

local function setScrollViewItem(_item, _data, _flag)
    _item:loadTexture("ui/lm_kuang.png")
    local ui_frame = _item:getChildByName("image_frame_skill")
    local ui_icon = ui_frame:getChildByName("image_skill")
    local ui_name = ui_frame:getChildByName("text_name")
    local ui_level = ui_frame:getChildByName("text_lv")
    local ui_expBar = ccui.Helper:seekNodeByName(ui_frame, "bar_good")
    local ui_exp = ui_expBar:getChildByName("text_number")
    local ui_desc = ui_frame:getChildByName("text_info")
    local practiceData = getPracticeData(_data.id)
    local totalExp = 0
    for key, obj in pairs(DictUnionPracticeUpgrade) do
        if obj.unionPracticeId == _data.id and obj.level == practiceData.level then
            totalExp = obj.exp
            break
        end
    end
    ui_icon:loadTexture("image/" .. DictUI[tostring(_data.smallUiId)].fileName)
    ui_name:setString(_data.name)
    ui_level:setString(practiceData.level .. Lang.ui_alliance_skill7)
    ui_exp:setString(practiceData.exp .. "/" .. totalExp)
    ui_expBar:setPercent(utils.getPercent(practiceData.exp, totalExp))
    if UIAllianceSkill.getPracticeValue() >= _data.practiceValueActivity then
        ui_icon:setTouchEnabled(false)
        ui_desc:setTextColor(cc.c3b(255, 255, 0))
        ui_desc:setString(string.format(_data.description, tostring(practiceData.level * _data.levelAdd)).."%")
    else
        ui_icon:setTouchEnabled(true)
        ui_icon:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIGoodInfo.show({ tableTypeId = dp.TableType.DictUnionPractice, tableFieldId = _data.id })
            end
        end)
        ui_desc:setTextColor(cc.c3b(255, 0, 0))
        ui_desc:setString(string.format(Lang.ui_alliance_skill8, _data.practiceValueActivity))
    end
    _item:setTag(_data.id)
    _item:setTouchEnabled(true)
    _item:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if UIAllianceSkill.getPracticeValue() < _data.practiceValueActivity then
                return UIManager.showToast(Lang.ui_alliance_skill9)
            end
            local childs = ui_scrollView:getChildren()
            for key, child in pairs(childs) do
                child:loadTexture("ui/lm_kuang.png")
                child:setName("item_".._data.id)
            end
            sender:loadTexture("ui/lm_kuang_l.png")
            sender:setName("id_".._data.id)
        end
    end)
    if type(_flag) == "boolean" and _flag then
        _item:releaseUpEvent()
    end
end

local function initCheckBoxSelectItem()
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
    local ui_checkbox1 = image_wing_di:getChildByName("checkbox_practice1")
    local ui_checkbox2 = image_wing_di:getChildByName("checkbox_practice2")
    local ui_needDevote1 = ui_checkbox1:getChildByName("text_need")
    local ui_needMoney1 = ui_checkbox1:getChildByName("text_money")
    local ui_needDevote2 = ui_checkbox2:getChildByName("text_need")
    local ui_needMoney2 = ui_checkbox2:getChildByName("text_money")
    local ui_selectedCount = image_wing_di:getChildByName("image_base_number"):getChildByName("text_number")
    ui_selectedCount:setString("1")
    local checkBoxItemData = getCheckBoxItemData(tonumber(ui_selectedCount:getString()))
    if checkBoxItemData.type == 1 then
        ui_needDevote1:setString(Lang.ui_alliance_skill10..checkBoxItemData.consumValue1)
        ui_needMoney1:setString(Lang.ui_alliance_skill11..checkBoxItemData.consumValue2)
        ui_needDevote2:setString(Lang.ui_alliance_skill12)
        ui_needMoney2:setString(Lang.ui_alliance_skill13)
    elseif checkBoxItemData.type == 2 then
        ui_needDevote2:setString(Lang.ui_alliance_skill14..checkBoxItemData.consumValue1)
        ui_needMoney2:setString(Lang.ui_alliance_skill15..checkBoxItemData.consumValue2)
        ui_needDevote1:setString(Lang.ui_alliance_skill16)
        ui_needMoney1:setString(Lang.ui_alliance_skill17)
    end
end

local function setUIData()
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local text_contribute = image_basemap:getChildByName("text_contribute")
    local text_practicing = image_basemap:getChildByName("text_practicing")
    local text_gold = image_basemap:getChildByName("text_gold")
    text_contribute:setString(Lang.ui_alliance_skill18 .. net.InstUnionMember.int["5"])
    text_practicing:setString(Lang.ui_alliance_skill19 .. UIAllianceSkill.getPracticeValue())
    text_gold:setString(Lang.ui_alliance_skill20 .. net.InstPlayer.int["5"])
end

local function practiceRefreshTime()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    if UIAlliance.Widget then
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
        local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
        local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
        local btn_donate = image_di_dowm:getChildByName("btn_donate")
        local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
        local ui_waitTime = image_wing_di:getChildByName("text_time")
        ui_waitTime:setString(string.format(Lang.ui_alliance_skill21, minute, second))
        if _countdownTime == 0 then
            dp.removeTimerListener(practiceRefreshTime)
            ui_waitTime:setVisible(false)
            local ui_waitPanel = UIAllianceSkill.Widget:getChildByName("ui_waitPanel")
            if ui_waitPanel then
                local waitButton = ui_waitPanel:getChildByName("waitButton")
                if waitButton then
                    waitButton:releaseUpEvent()
                end
            end
            UIManager.showLoading()
            netSendPackage( {
                header = StaticMsgRule.intoUnionPractice,
                msgdata = { }
            } , function(_messageData)
                -- 刷新联盟总资金
                local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
                local text_money = image_basemap:getChildByName("text_money")
                text_money:setString(Lang.ui_alliance_skill22 .. _messageData.msgdata.int["1"])
                btn_donate:releaseUpEvent()
            end)
        end
    end
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.intoUnionPractice then
        -- 刷新联盟总资金
        local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
        local text_money = image_basemap:getChildByName("text_money")
        text_money:setString(Lang.ui_alliance_skill23 .. _msgData.msgdata.int["1"])
    elseif code == StaticMsgRule.unionSkillPractice then
        _countdownTime = _msgData.msgdata.int.seconds
        if type(_countdownTime) == "number" then
            dp.addTimerListener(practiceRefreshTime)
            showWaitingState()
            return
        else
            _countdownTime = 0
        end
        local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
        local text_money = image_basemap:getChildByName("text_money")
        text_money:setString(Lang.ui_alliance_skill24 .. _msgData.msgdata.int["1"])
        setUIData()
        local _dictUnionPracticeId = 0
        local childs = ui_scrollView:getChildren()
        for key, obj in pairs(childs) do
            if string.find(obj:getName(), "id_") then
                _dictUnionPracticeId = obj:getTag()
                setScrollViewItem(obj, DictUnionPractice[tostring(_dictUnionPracticeId)], true)
            else
                setScrollViewItem(obj, DictUnionPractice[tostring(obj:getTag())])
            end
        end
        local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
        local btn_donate = image_di_dowm:getChildByName("btn_donate")
        local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
        local ui_checkbox1 = image_wing_di:getChildByName("checkbox_practice1")
        local ui_checkbox2 = image_wing_di:getChildByName("checkbox_practice2")
        local ui_needDevote1 = ui_checkbox1:getChildByName("text_need")
        local ui_needMoney1 = ui_checkbox1:getChildByName("text_money")
        local ui_needDevote2 = ui_checkbox2:getChildByName("text_need")
        local ui_needMoney2 = ui_checkbox2:getChildByName("text_money")
        local ui_selectedCount = image_wing_di:getChildByName("image_base_number"):getChildByName("text_number")
        local _selectedCount = tonumber(ui_selectedCount:getString())
        _selectedCount = _selectedCount - 1
        ui_selectedCount:setString(tostring(_selectedCount))
        local checkBoxItemData = getCheckBoxItemData(_selectedCount)
        if checkBoxItemData.type == 1 then
            ui_needDevote1:setString(Lang.ui_alliance_skill25..checkBoxItemData.consumValue1)
            ui_needMoney1:setString(Lang.ui_alliance_skill26..checkBoxItemData.consumValue2)
        elseif checkBoxItemData.type == 2 then
            ui_needDevote2:setString(Lang.ui_alliance_skill27..checkBoxItemData.consumValue1)
            ui_needMoney2:setString(Lang.ui_alliance_skill28..checkBoxItemData.consumValue2)
        end
        if _selectedCount > 0 then
            runWaitAction(function()
                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.unionSkillPractice,
                    msgdata = { int = { id = _dictUnionPracticeId, type = checkBoxItemData.type } }
                } , netCallbackFunc, function()
                    btn_donate:setTitleText(Lang.ui_alliance_skill29)
                end)
            end)
        else
            btn_donate:setTitleText(Lang.ui_alliance_skill30)
        end
    end
end

--是否进入等待
local function isWaiting()
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
    local ui_waitTime = image_wing_di:getChildByName("text_time")
    local _curTime = utils.getCurrentTime()
    -- 资金刷新时间： 20:30 (提前15分钟进入等待...)
    local _startTime = getTimer(_curTime, 20, 15)
    local _endTime = getTimer(_curTime, 20, 30)
    if _curTime >= _startTime and _curTime < _endTime then
        if not ui_waitTime:isVisible() then
            _countdownTime = _endTime - _curTime
            dp.addTimerListener(practiceRefreshTime)
        end
        return true
    end
end

function UIAllianceSkill.updateTimer(interval)
    if _countdownTime then
        _countdownTime = _countdownTime - interval
        if _countdownTime < 0 then
            _countdownTime = 0
        end
    end
end

function UIAllianceSkill.init()
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_get = image_basemap:getChildByName("btn_get")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local btn_donate = image_di_dowm:getChildByName("btn_donate")
    btn_help:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_get:setPressedActionEnabled(true)
    btn_donate:setPressedActionEnabled(true)

    local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
    local ui_checkbox1 = image_wing_di:getChildByName("checkbox_practice1")
    local ui_checkbox2 = image_wing_di:getChildByName("checkbox_practice2")
    local ui_needDevote1 = ui_checkbox1:getChildByName("text_need")
    local ui_needMoney1 = ui_checkbox1:getChildByName("text_money")
    local ui_needDevote2 = ui_checkbox2:getChildByName("text_need")
    local ui_needMoney2 = ui_checkbox2:getChildByName("text_money")
    local ui_selectedCount = image_wing_di:getChildByName("image_base_number"):getChildByName("text_number")
    local ui_waitTime = image_wing_di:getChildByName("text_time")

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 21 , titleName = Lang.ui_alliance_skill31 } )
            elseif sender == btn_get then
                local signInOpen = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["5"] == 3 and obj.int["3"] == 25 then
                            --- 第三章节最后一个关卡打完才开启
                            signInOpen = true
                            break
                        end
                    end
                end
                if net.InstPlayerDailyTask and signInOpen then
                    UIManager.pushScene("ui_task_day")
                else
                    UIManager.showToast(Lang.ui_alliance_skill32)
                end
            elseif sender == btn_donate then
                local _dictUnionPracticeId = 0
                local childs = ui_scrollView:getChildren()
                for key, obj in pairs(childs) do
                    if string.find(obj:getName(), "id_") then
                        _dictUnionPracticeId = obj:getTag()
                        break
                    end
                end
                if _dictUnionPracticeId <= 0 then
                    return UIManager.showToast(Lang.ui_alliance_skill33)
                end
                if tonumber(ui_selectedCount:getString()) <= 0 then
                    return UIManager.showToast(Lang.ui_alliance_skill34)
                end
                if (not ui_checkbox1:isSelected()) and (not ui_checkbox2:isSelected()) then
                    return UIManager.showToast(Lang.ui_alliance_skill35)
                end
                local checkBoxItemData = getCheckBoxItemData(tonumber(ui_selectedCount:getString()))
                if checkBoxItemData.type == 1 then
                    if net.InstUnionMember.int["5"] < checkBoxItemData.consumValue1 then
                        return UIManager.showToast(Lang.ui_alliance_skill36)
                    end
                elseif checkBoxItemData.type == 2 then
                    if net.InstPlayer.int["5"] < checkBoxItemData.consumValue1 then
                        return UIManager.showToast(Lang.ui_alliance_skill37)
                    end
                end
                --[[
                if isWaiting() then
                    showWaitingState()
                    return
                else
                    local text_money = image_basemap:getChildByName("text_money")
                    local allianceMoney = tonumber(utils.stringSplit(text_money:getString(), "：")[2])
                    if allianceMoney < checkBoxItemData.consumValue2 then
                        return UIManager.showToast(Lang.ui_alliance_skill38)
                    end
                end
                --]]
                
                runWaitAction(function()
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.unionSkillPractice,
                        msgdata = { int = { id = _dictUnionPracticeId, type = checkBoxItemData.type } }
                    } , netCallbackFunc, function()
                        btn_donate:setTitleText(Lang.ui_alliance_skill39)
                    end)
                end)
            end
        end
    end
    btn_help:addTouchEventListener(onButtonEvent)
    btn_back:addTouchEventListener(onButtonEvent)
    btn_get:addTouchEventListener(onButtonEvent)
    btn_donate:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_skill")
    ui_svItem = ui_scrollView:getChildByName("image_skill"):clone()

    local text_time = image_basemap:getChildByName("text_time")
    text_time:setString(Lang.ui_alliance_skill40)

    UnionPracticeData = {}
    for key, obj in pairs(DictUnionPractice) do
        UnionPracticeData[#UnionPracticeData + 1] = obj
    end
    utils.quickSort(UnionPracticeData, function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
    
    local function checkboxEvent(sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            ui_checkbox1:setSelected(false)
            ui_checkbox2:setSelected(false)
            sender:setSelected(true)
            initCheckBoxSelectItem()
        elseif eventType == ccui.CheckBoxEventType.unselected then
        end
    end
    ui_checkbox1:addEventListener(checkboxEvent)
    ui_checkbox2:addEventListener(checkboxEvent)
    
    local ui_minBtn = image_wing_di:getChildByName("btn_cut_ten")
    local ui_cutBtn = image_wing_di:getChildByName("btn_cut")
    local ui_maxBtn = image_wing_di:getChildByName("btn_add_ten")
    local ui_addBtn = image_wing_di:getChildByName("btn_add")
    ui_minBtn:setPressedActionEnabled(true)
    ui_cutBtn:setPressedActionEnabled(true)
    ui_maxBtn:setPressedActionEnabled(true)
    ui_addBtn:setPressedActionEnabled(true)
    
    local _schedulerId, _isLongPressed = nil, false
    local stopScheduler = function()
        if _schedulerId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
		end
        _schedulerId = nil
    end
    local onTouchEventEnd = function(sender)
        if (not ui_checkbox1:isSelected()) and (not ui_checkbox2:isSelected()) then
            return UIManager.showToast(Lang.ui_alliance_skill41)
        end
        local _isStop = false
        local checkBoxItemData = nil
        local _curSelectedCount = tonumber(ui_selectedCount:getString())
        if sender == ui_addBtn then
            _curSelectedCount = _curSelectedCount + 1
            checkBoxItemData = getCheckBoxItemData(_curSelectedCount)
            if checkBoxItemData.type == 1 then
                if net.InstUnionMember.int["5"] < checkBoxItemData.consumValue1 then
	                UIManager.showToast(Lang.ui_alliance_skill42)
                    _isStop = true
                end
            elseif checkBoxItemData.type == 2 then
                if net.InstPlayer.int["5"] < checkBoxItemData.consumValue1 then
	                UIManager.showToast(Lang.ui_alliance_skill43)
                    _isStop = true
                end
            end
            --[[
            if not isWaiting() then
                local text_money = image_basemap:getChildByName("text_money")
                local allianceMoney = tonumber(utils.stringSplit(text_money:getString(), "：")[2])
                if allianceMoney < checkBoxItemData.consumValue2 then
                    if not _isStop then
                        UIManager.showToast(Lang.ui_alliance_skill44)
                    end
                    _isStop = true
                end
            end
            --]]
            if _curSelectedCount > MAX_COUNT then
                UIManager.showToast(Lang.ui_alliance_skill45)
                _isStop = true
            end
            if _isStop then
                _curSelectedCount = _curSelectedCount - 1
                stopScheduler()
            end
        elseif sender == ui_cutBtn then
            _curSelectedCount = _curSelectedCount - 1
            if _curSelectedCount <= 0 then
                _curSelectedCount = 0
                stopScheduler()
            end
        end
        if not _isStop then
            ui_selectedCount:setString(tostring(_curSelectedCount))
            if checkBoxItemData == nil then
                checkBoxItemData = getCheckBoxItemData(_curSelectedCount)
            end
            if checkBoxItemData.type == 1 then
                ui_needDevote1:setString(Lang.ui_alliance_skill46..checkBoxItemData.consumValue1)
                ui_needMoney1:setString(Lang.ui_alliance_skill47..checkBoxItemData.consumValue2)
            elseif checkBoxItemData.type == 2 then
                ui_needDevote2:setString(Lang.ui_alliance_skill48..checkBoxItemData.consumValue1)
                ui_needMoney2:setString(Lang.ui_alliance_skill49..checkBoxItemData.consumValue2)
            end
        end
    end
    local function onBtnEvent(sender, eventType)
        if sender == ui_cutBtn or sender == ui_addBtn then
            if eventType == ccui.TouchEventType.began then
                stopScheduler()
                _isLongPressed = false
                local _curTimer = os.clock()
				_schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
                    if not _isLongPressed and os.clock() - _curTimer >= 0.5 then
                        _isLongPressed = true
                    end
                    if _isLongPressed then
                        onTouchEventEnd(sender)
                    end
                end, 0.1, false)
            elseif eventType == ccui.TouchEventType.canceled then
                stopScheduler()
            elseif eventType == ccui.TouchEventType.ended then
                stopScheduler()
                if _isLongPressed then
                    return
                end
                onTouchEventEnd(sender)
            end
        else
            if eventType == ccui.TouchEventType.ended then
                if (not ui_checkbox1:isSelected()) and (not ui_checkbox2:isSelected()) then
                    return UIManager.showToast(Lang.ui_alliance_skill50)
                end
                if sender == ui_minBtn then --最小值
                    initCheckBoxSelectItem()
                elseif sender == ui_maxBtn then --最大值
                    local maxLogic = nil
                    maxLogic = function(_count)
                        local checkBoxItemData = getCheckBoxItemData(_count)
                        if checkBoxItemData.type == 1 then
                            if net.InstUnionMember.int["5"] < checkBoxItemData.consumValue1 then
                                if _count == 1 then
                                    UIManager.showToast(Lang.ui_alliance_skill51)
                                end
	                            return _count - 1
                            end
                        elseif checkBoxItemData.type == 2 then
                            if net.InstPlayer.int["5"] < checkBoxItemData.consumValue1 then
                                if _count == 1 then
                                    UIManager.showToast(Lang.ui_alliance_skill52)
                                end
	                            return _count - 1
                            end
                        end
                        --[[
                        if not isWaiting() then
                            local text_money = image_basemap:getChildByName("text_money")
                            local allianceMoney = tonumber(utils.stringSplit(text_money:getString(), "：")[2])
                            if allianceMoney < checkBoxItemData.consumValue2 then
                                if _count == 1 then
                                    UIManager.showToast(Lang.ui_alliance_skill53)
                                end
                                return _count - 1
                            end
                        end
                        --]]
                        if _count >= MAX_COUNT then
                            return MAX_COUNT
                        end
                        return maxLogic(_count + 1)
                    end
                    local _curSelectedCount = maxLogic(1)
                    ui_selectedCount:setString(tostring(_curSelectedCount))
                    local checkBoxItemData = getCheckBoxItemData(_curSelectedCount)
                    if checkBoxItemData.type == 1 then
                        ui_needDevote1:setString(Lang.ui_alliance_skill54..checkBoxItemData.consumValue1)
                        ui_needMoney1:setString(Lang.ui_alliance_skill55..checkBoxItemData.consumValue2)
                    elseif checkBoxItemData.type == 2 then
                        ui_needDevote2:setString(Lang.ui_alliance_skill56..checkBoxItemData.consumValue1)
                        ui_needMoney2:setString(Lang.ui_alliance_skill57..checkBoxItemData.consumValue2)
                    end
                end
            end
        end
    end
    ui_minBtn:addTouchEventListener(onBtnEvent)
    ui_cutBtn:addTouchEventListener(onBtnEvent)
    ui_maxBtn:addTouchEventListener(onBtnEvent)
    ui_addBtn:addTouchEventListener(onBtnEvent)
end

function UIAllianceSkill.setup()
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.intoUnionPractice,
        msgdata = { }
    } , netCallbackFunc)
    setUIData()
    layoutScrollView(UnionPracticeData, setScrollViewItem)
    local childs = ui_scrollView:getChildren()
    if childs and childs[1] then
        childs[1]:releaseUpEvent()
    end

    PRACTICE_SPACE = DictVIP[tostring(net.InstPlayer.int["19"] + 1)].unionProacticePoint

    --default
    local image_basemap = UIAllianceSkill.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local btn_donate = image_di_dowm:getChildByName("btn_donate")
    btn_donate:setTitleText(Lang.ui_alliance_skill58)
    local image_wing_di = image_di_dowm:getChildByName("image_wing_di")
    local ui_waitTime = image_wing_di:getChildByName("text_time")
    ui_waitTime:setVisible(false)
    local ui_checkbox1 = image_wing_di:getChildByName("checkbox_practice1")
    local ui_checkbox2 = image_wing_di:getChildByName("checkbox_practice2")
    ui_checkbox1:setSelected(true)
    ui_checkbox2:setSelected(false)
    initCheckBoxSelectItem()
end

function UIAllianceSkill.show()
    UIManager.showWidget("ui_alliance_skill")
end

function UIAllianceSkill.free()
    cleanScrollView()
    dp.removeTimerListener(practiceRefreshTime)
    _countdownTime = 0
end

function UIAllianceSkill.getPracticeValue()
    local practiceValue = 0
    if net.InstUnionPractice then
        -- 修炼Id_当前等级_当前经验;
        local practice = utils.stringSplit(net.InstUnionPractice.string["3"], ";")
        for key, obj in pairs(practice) do
            local _tempObj = utils.stringSplit(obj, "_")
            local _id = tonumber(_tempObj[1])
            local _level = tonumber(_tempObj[2])
            local _exp = tonumber(_tempObj[3])
            for key, obj in pairs(DictUnionPracticeUpgrade) do
                if obj.unionPracticeId == _id and _level > obj.level then
                    practiceValue = practiceValue + obj.exp
                end
            end
            practiceValue = practiceValue + _exp
        end
        practice = nil
    end
    return practiceValue
end
