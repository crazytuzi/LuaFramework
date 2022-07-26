require"Lang"
UIAllianceSkillInfo = {}

--最大使用数量
local MAX_COUNT = 999

local UnionPracticeData = nil

local ui_scrollView = nil
local ui_svItem = nil

local practiceRollCount = 0

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
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

local function setScrollViewItem(_item, _data, _flag)
    _item:loadTexture("ui/lm_kuang.png")
    local ui_frame = _item:getChildByName("image_frame_skill")
    local ui_icon = ui_frame:getChildByName("image_skill")
    local ui_name = ui_frame:getChildByName("text_name")
    local ui_level = ui_frame:getChildByName("text_lv")
    local ui_expBar = ccui.Helper:seekNodeByName(ui_frame, "bar_good")
    local ui_exp = ccui.Helper:seekNodeByName(ui_frame, "text_number")
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
    ui_level:setString(practiceData.level .. Lang.ui_alliance_skill_info1)
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
        ui_desc:setString(string.format(Lang.ui_alliance_skill_info2, _data.practiceValueActivity))
    end
    _item:setTag(_data.id)
    _item:setTouchEnabled(true)
    _item:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if UIAllianceSkill.getPracticeValue() < _data.practiceValueActivity then
                return UIManager.showToast(Lang.ui_alliance_skill_info3)
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

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.unionPraciceRoll then
        UIManager.showToast(Lang.ui_alliance_skill_info4)
        practiceRollCount = utils.getThingCount(StaticThing.unionPracticeRoll)
        local practiceValueCount = UIAllianceSkill.getPracticeValue()
        local image_basemap = UIAllianceSkillInfo.Widget:getChildByName("image_basemap")
        local ui_practiceRoll = image_basemap:getChildByName("text_title")
        ui_practiceRoll:setString(Lang.ui_alliance_skill_info5 .. practiceRollCount)
        local ui_practiceValue = image_basemap:getChildByName("text_zhi")
        ui_practiceValue:setString(Lang.ui_alliance_skill_info6 .. practiceValueCount)
        local ui_selectedCount = image_basemap:getChildByName("image_base_number"):getChildByName("text_number")
        ui_selectedCount:setString("1")
        local childs = ui_scrollView:getChildren()
        for key, obj in pairs(childs) do
            if string.find(obj:getName(), "id_") then
                setScrollViewItem(obj, DictUnionPractice[tostring(obj:getTag())], true)
            else
                setScrollViewItem(obj, DictUnionPractice[tostring(obj:getTag())])
            end
        end
        UIManager.flushWidget(UIBag)
    end
end

function UIAllianceSkillInfo.init()
    local image_basemap = UIAllianceSkillInfo.Widget:getChildByName("image_basemap")
    local ui_selectedCount = image_basemap:getChildByName("image_base_number"):getChildByName("text_number")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    local btn_donate = image_basemap:getChildByName("btn_donate")
    btn_closed:setPressedActionEnabled(true)
    btn_donate:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_donate then
                UIManager.showToast(Lang.ui_alliance_skill_info7)
                local _selectedCount = tonumber(ui_selectedCount:getString())
                if _selectedCount <= 0 then
                    return UIManager.showToast(Lang.ui_alliance_skill_info8)
                end
                if _selectedCount > utils.getThingCount(StaticThing.unionPracticeRoll) then
                    return UIManager.showToast(Lang.ui_alliance_skill_info9)
                end
                local _dictUnionPracticeId = 0
                local childs = ui_scrollView:getChildren()
                for key, obj in pairs(childs) do
                    if string.find(obj:getName(), "id_") then
                        _dictUnionPracticeId = obj:getTag()
                        break
                    end
                end
                if _dictUnionPracticeId <= 0 then
                    return UIManager.showToast(Lang.ui_alliance_skill_info10)
                end
                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.unionPraciceRoll,
                    msgdata = { int = { unionPracticeId = _dictUnionPracticeId, thingId = StaticThing.unionPracticeRoll, num = _selectedCount } }
                } , netCallbackFunc)
            end
        end
    end
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_donate:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_skill")
    ui_svItem = ui_scrollView:getChildByName("image_skill"):clone()

    UnionPracticeData = {}
    for key, obj in pairs(DictUnionPractice) do
        UnionPracticeData[#UnionPracticeData + 1] = obj
    end
    utils.quickSort(UnionPracticeData, function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
end

function UIAllianceSkillInfo.setup()
    layoutScrollView(UnionPracticeData, setScrollViewItem)
    local childs = ui_scrollView:getChildren()
    if childs and childs[1] then
        childs[1]:releaseUpEvent()
    end

    practiceRollCount = utils.getThingCount(StaticThing.unionPracticeRoll)
    local practiceValueCount = UIAllianceSkill.getPracticeValue()
    local image_basemap = UIAllianceSkillInfo.Widget:getChildByName("image_basemap")
    local ui_practiceRoll = image_basemap:getChildByName("text_title")
    ui_practiceRoll:setString(Lang.ui_alliance_skill_info11 .. practiceRollCount)
    local ui_practiceValue = image_basemap:getChildByName("text_zhi")
    ui_practiceValue:setString(Lang.ui_alliance_skill_info12 .. practiceValueCount)
    local ui_selectedCount = image_basemap:getChildByName("image_base_number"):getChildByName("text_number")
    ui_selectedCount:setString("1")
    local ui_minBtn = image_basemap:getChildByName("btn_cut_ten")
    local ui_cutBtn = image_basemap:getChildByName("btn_cut")
    local ui_maxBtn = image_basemap:getChildByName("btn_add_ten")
    local ui_addBtn = image_basemap:getChildByName("btn_add")
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
        local _curSelectedCount = tonumber(ui_selectedCount:getString())
        if sender == ui_addBtn then
            _curSelectedCount = _curSelectedCount + 1
            if _curSelectedCount > MAX_COUNT or _curSelectedCount > practiceRollCount then
                _curSelectedCount = _curSelectedCount - 1
                stopScheduler()
                if _curSelectedCount >= MAX_COUNT then
                    UIManager.showToast(Lang.ui_alliance_skill_info13)
                else
                    UIManager.showToast(Lang.ui_alliance_skill_info14)
                end
            end
        elseif sender == ui_cutBtn then
            _curSelectedCount = _curSelectedCount - 1
            if _curSelectedCount <= 0 then
                _curSelectedCount = 0
                stopScheduler()
            end
        end
        ui_selectedCount:setString(tostring(_curSelectedCount))
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
                if sender == ui_minBtn then --最小值
                    ui_selectedCount:setString(tostring(1))
                elseif sender == ui_maxBtn then --最大值
                    ui_selectedCount:setString(tostring(practiceRollCount > MAX_COUNT and MAX_COUNT or practiceRollCount))
                end
            end
        end
    end
    ui_minBtn:addTouchEventListener(onBtnEvent)
    ui_cutBtn:addTouchEventListener(onBtnEvent)
    ui_maxBtn:addTouchEventListener(onBtnEvent)
    ui_addBtn:addTouchEventListener(onBtnEvent)
end

function UIAllianceSkillInfo.free()
    cleanScrollView(true)
    UnionPracticeData = nil
    practiceRollCount = 0
end

function UIAllianceSkillInfo.show()
    UIManager.pushScene("ui_alliance_skill_info")
end
