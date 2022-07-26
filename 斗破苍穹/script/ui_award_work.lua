require"Lang"
UIAwardWork = {}

local ui_scrollView = nil
local ui_svItem = nil

local DictActivity = nil

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
    local SCROLLVIEW_ITEM_SPACE = 10
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
		_initItemFunc(scrollViewItem, obj, key)
		ui_scrollView:addChild(scrollViewItem)
		_innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

function UIAwardWork.init()
    local image_basemap = UIAwardWork.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)
    ui_scrollView = image_basemap:getChildByName("view_award")
    ui_svItem = ui_scrollView:getChildByName("image_base_gift"):clone()
end

function UIAwardWork.setup()
    local image_basemap = UIAwardWork.Widget:getChildByName("image_basemap")
    local ui_timeLabel = image_basemap:getChildByName("text_time")
    ccui.Helper:seekNodeByName( UIAwardWork.Widget ,  "text_title" ):setString(Lang.ui_award_work1)
    if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "RepeatLogin" then
                DictActivity = obj
                break
            end
        end
    end
    if DictActivity then
        local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
	    local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
        ui_timeLabel:setString(string.format(Lang.ui_award_work2, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
    end
end

function UIAwardWork.show()
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.openSevenDayLoginPanel, msgdata={}}, function(_msgData)
        local _loginDayCount = _msgData.msgdata.int.allCount --总登陆天数
        local _allInfo = _msgData.msgdata.string.allInfo --天数|奖励|状态(0可以领取 1是领取过)#天数|奖励|状态(0可以领取 1是领取过)
        UIManager.pushScene("ui_award_work")
        layoutScrollView(utils.stringSplit(_allInfo, "#"), function(_item, _data, _index)
            local _tempData = utils.stringSplit(_data, "|")--天数|奖励|状态(0可以领取 1是领取过)
            local _day = tonumber(_tempData[1])
            local _things = utils.stringSplit(_tempData[2], ";")
            local _state = tonumber(_tempData[3]) --0可以领取 1是领取过
            local ui_day = ccui.Helper:seekNodeByName(_item:getChildByName("image_base_hint"), "text_begin_number")
            local btn_prize = _item:getChildByName("btn_prize")

            ui_day:setString(tostring(_index))
            for i = 1, 4 do
                local ui_frame = ccui.Helper:seekNodeByName(_item, "image_frame_good" .. i)
                if _things[i] then
                    local itemProps = utils.getItemProp(_things[i])
                    if itemProps then
                        local ui_icon = ui_frame:getChildByName("image_good")
                        local ui_name = ui_frame:getChildByName("text_name")
                        local ui_count = ccui.Helper:seekNodeByName(ui_frame, "text_number")
                        if itemProps.frameIcon then
                            ui_frame:loadTexture(itemProps.frameIcon)
                        end
                        if itemProps.smallIcon then
                            ui_icon:loadTexture(itemProps.smallIcon)
                            utils.showThingsInfo(ui_icon, itemProps.tableTypeId, itemProps.tableFieldId)
                        end
                        if itemProps.name then
                            ui_name:setString(itemProps.name)
                        end
                        if itemProps.count then
                            ui_count:setString(tostring(itemProps.count))
                        end
                        if itemProps.qualityColor then
                            ui_name:setTextColor(itemProps.qualityColor)
                        end
                        if itemProps.flagIcon then
                            local ui_flagIcon = ccui.ImageView:create(itemProps.flagIcon)
                            ui_flagIcon:setAnchorPoint(cc.p(0.2, 0.8))
                            ui_flagIcon:setPosition(cc.p(0, ui_frame:getContentSize().height))
                            ui_frame:addChild(ui_flagIcon)
                        end
                    end
                else
                    ui_frame:setVisible(false)
                end
            end
            if _index > _loginDayCount then
                btn_prize:setTouchEnabled(false)
                btn_prize:setBright(false)
            else
                if _state == 1 then
                    btn_prize:setTitleText(Lang.ui_award_work3)
                    btn_prize:setTouchEnabled(false)
                    btn_prize:setBright(false)
                end
            end
            btn_prize:setPressedActionEnabled(true)
            btn_prize:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    UIManager.showLoading()
	                netSendPackage({header=StaticMsgRule.drawSevenLoginReward, msgdata={int={dayId=_index}}}, function(_messsagData)
                        
                        UIAwardGet.setOperateType(UIAwardGet.operateType.award, _things)
                        UIManager.pushScene("ui_award_get")
                        sender:setTitleText(Lang.ui_award_work4)
                        sender:setTouchEnabled(false)
                        sender:setBright(false)
                        local _isVisiblePoint = false
                        local childs = ui_scrollView:getChildren()
	                    for i = 1, #childs do
                            if childs[i]:getChildByName("btn_prize"):isTouchEnabled() then
                                _isVisiblePoint = true
                                break
                            end
                        end
                        UIHomePage.setBtnWorkPoint(_isVisiblePoint)
                    end)
                end
            end)
        end)
    end)
end

function UIAwardWork.free()
    cleanScrollView(true)
    DictActivity = nil
end