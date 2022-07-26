require"Lang"
UIAllianceApply = {}

local ui_scrollView = nil
local ui_svItem = nil

local userData = nil

local netCallbackFunc = nil

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
	local SCROLLVIEW_ITEM_SPACE = 0
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
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

local function setScrollViewItem(_item, _data)
	local _name = _data.string["1"]
	local _level = _data.int["2"]
	local _cardId = _data.int["3"]
	local _vipLevel = _data.int["5"]
    local _fightVale = _data.int["6"]
	local image_info = _item:getChildByName("image_di_info")
	local ui_frameImg = image_info:getChildByName("image_frame_title")
	local ui_icon = ui_frameImg:getChildByName("image_title")
	local ui_vipFlag = ui_frameImg:getChildByName("image_vip")
	local ui_name = image_info:getChildByName("text_name")
	local ui_level = image_info:getChildByName("text_lv")
	local ui_fight = image_info:getChildByName("text_fight")
	local btn_yes = _item:getChildByName("btn_yes")
	local btn_no = _item:getChildByName("btn_no")

	ui_name:setString(_name)
	ui_level:setString(Lang.ui_alliance_apply1.._level)
	ui_fight:setString(Lang.ui_alliance_apply2.._fightVale)
	local dictCard = DictCard[tostring(_cardId)]
	if dictCard then
		ui_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
	end
	if _vipLevel > 0 then
		ui_vipFlag:setVisible(true)
	else
		ui_vipFlag:setVisible(false)
	end
	btn_yes:setPressedActionEnabled(true)
	btn_no:setPressedActionEnabled(true)
	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_yes then
				if userData.currentCount >= userData.totalCount then
					UIManager.showToast(Lang.ui_alliance_apply3)
				else
					UIManager.showLoading()
					netSendPackage({header = StaticMsgRule.agreeApply, msgdata = {int={instUnionApplyId=_data.int["4"]}}}, netCallbackFunc)
				end
			elseif sender == btn_no then
				UIManager.showLoading()
				netSendPackage({header = StaticMsgRule.refuseApply, msgdata = {int={instUnionApplyId=_data.int["4"]}}}, netCallbackFunc)
			end
		end
	end
	btn_yes:addTouchEventListener(onButtonEvent)
	btn_no:addTouchEventListener(onButtonEvent)
end

netCallbackFunc = function(msgData)
	local code = tonumber(msgData.header)
	if code == StaticMsgRule.obtainApply then
        local applyLists = {}
		local unionApply = msgData.msgdata.message.unionApply
		if unionApply and unionApply.message then
			for key, obj in pairs(unionApply.message) do
				applyLists[#applyLists + 1] = obj
			end
		    layoutScrollView(applyLists, setScrollViewItem)
		end
        -- //审核状态 0-关闭  1-开启
        local _applyState = msgData.msgdata.int["1"]
        local image_basemap = UIAllianceApply.Widget:getChildByName("image_basemap")
        local btn_clean = image_basemap:getChildByName("btn_clean")
        btn_clean:setTitleText((_applyState == 0) and Lang.ui_alliance_apply4 or Lang.ui_alliance_apply5)
	elseif code == StaticMsgRule.agreeApply or code == StaticMsgRule.refuseApply then
		if code == StaticMsgRule.agreeApply then
			userData.currentCount = userData.currentCount + 1
		end
		UIAllianceApply.setup()
    elseif code == StaticMsgRule.clearUnionApplay then
        UIAllianceApply.setup()
	end
end

function UIAllianceApply.init()
	local image_basemap = UIAllianceApply.Widget:getChildByName("image_basemap")
	local btn_close = image_basemap:getChildByName("btn_close")

    --一键拒绝
	local btn_closed = image_basemap:getChildByName("btn_closed")

    --开启审核
    local btn_clean = image_basemap:getChildByName("btn_clean")

	ui_scrollView = image_basemap:getChildByName("view_info")
	ui_svItem = ui_scrollView:getChildByName("image_di_alliance"):clone()

	btn_close:setPressedActionEnabled(true)
	btn_closed:setPressedActionEnabled(true)
	btn_clean:setPressedActionEnabled(true)

	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_close then
				UIManager.popScene()
            elseif sender == btn_closed then
                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.clearUnionApplay,
                    msgdata = { int = { instUnionId = net.InstUnionMember.int["2"] } }
                } , netCallbackFunc)
            elseif sender == btn_clean then
                local _applyState = (btn_clean:getTitleText() == Lang.ui_alliance_apply6) and 1 or 0
                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.setUnionCheckState,
                    msgdata = { int = { state = _applyState, instUnionMemberId = net.InstUnionMember.int["1"] } }
                } , function(_msgData)
                    btn_clean:setTitleText((_applyState == 0) and Lang.ui_alliance_apply7 or Lang.ui_alliance_apply8)
                end)
			end
		end
	end

	btn_close:addTouchEventListener(onButtonEvent)
	btn_closed:addTouchEventListener(onButtonEvent)
	btn_clean:addTouchEventListener(onButtonEvent)
end

function UIAllianceApply.setup()
    layoutScrollView({}, setScrollViewItem)
	UIManager.showLoading()
	netSendPackage({header = StaticMsgRule.obtainApply, msgdata = {int={instUnionMemberId=net.InstUnionMember.int["1"]}}}, netCallbackFunc)
	local image_basemap = UIAllianceApply.Widget:getChildByName("image_basemap")
	local ui_memberLabel = ccui.Helper:seekNodeByName(image_basemap, "text_rank")
	ui_memberLabel:setString(string.format(Lang.ui_alliance_apply9, userData.currentCount, userData.totalCount))
end

function UIAllianceApply.free()
	cleanScrollView(true)
--	UIAllianceInfo.refreshMemberCount(userData)
	userData = nil
    UIAllianceManage.setup()
end

function UIAllianceApply.show(_tableParams)
	userData = _tableParams
	UIManager.pushScene("ui_alliance_apply")
end
