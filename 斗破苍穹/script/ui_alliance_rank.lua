require"Lang"
UIAllianceRank = { }

local BUTTON_TEXT_APPLY = Lang.ui_alliance_rank1
local BUTTON_TEXT_CANCEL_APPLY = Lang.ui_alliance_rank2
local BUTTON_TEXT_FULL = Lang.ui_alliance_rank3
local MAX_APPLY_COUNT = 3 -- 最大申请个数
local PAGE_ITEM_SIZE = 10 -- 每页显示的个数
local MAX_ITEM_SIZE = 5000000 -- 最大显示条数
local SCROLLVIEW_ITEM_SPACE = 0

local ui_scrollView = nil
local ui_svItem = nil

local ui_applyButton = nil

local _isJoinAlliance = false -- 是否加入联盟
local _applyCount = 0
local _allianceData = nil

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

local function layoutScrollView(_innerHeight)
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
end

local function layoutApplyList(_listData, _initItemFunc)
    local _scrollView = ui_scrollView:getParent():getChildByName("scrollView_clone")
    if not _scrollView then
        _scrollView = ui_scrollView:clone()
        _scrollView:setVisible(true)
        _scrollView:setName("scrollView_clone")
        ui_scrollView:getParent():addChild(_scrollView)
    end
    _scrollView:removeAllChildren()
    _scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = ui_svItem:clone()
        _initItemFunc(scrollViewItem, obj)
        _scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < _scrollView:getContentSize().height then
        _innerHeight = _scrollView:getContentSize().height
    end
    _scrollView:setInnerContainerSize(cc.size(_scrollView:getContentSize().width, _innerHeight))
    local childs = _scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(_scrollView:getContentSize().width / 2, _scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(_scrollView)
end

local function removeApplyList()
    local _scrollView = ui_scrollView:getParent():getChildByName("scrollView_clone")
    if _scrollView then
        _scrollView:removeAllChildren()
        _scrollView:removeFromParent()
        _scrollView = nil
    end
end

local function getAllianceData(_page)
    UIManager.showLoading()
    local _instUnionMemberId = 0
    if net.InstUnionMember then
        _instUnionMemberId = net.InstUnionMember.int["1"]
    end
    netSendPackage( { header = StaticMsgRule.unionRank, msgdata = { int = { pageNum = _page, instUnionMemberId = _instUnionMemberId } } }, netCallbackFunc)
end

local function getInstApplyId(instUnionId)
    if net.InstUnionApply then
        for key, obj in pairs(net.InstUnionApply) do
            if instUnionId == obj.int["3"] then
                return obj.int["1"]
            end
        end
    end
    return 0
end

local function setScrollViewItem(_item, _data)
	if _data then
--		local ui_rankImg = _item:getChildByName("image_rank")
--		local ui_rankLabel = ui_rankImg:getChildByName("text_rank")
        local ui_allianceIcon = _item:getChildByName("image_title")
		local ui_allianceName = _item:getChildByName("text_alliance_name")
		local ui_allianceLevel = _item:getChildByName("text_alliance_lv")
		local ui_allianceMainName = ccui.Helper:seekNodeByName(_item, "text_name")
		local ui_allianceMemberNum = ccui.Helper:seekNodeByName(_item, "text_member")
--        local ui_allianceBuild = ccui.Helper:seekNodeByName(_item, "text_build")
		local ui_allianceOffer = ccui.Helper:seekNodeByName(_item, "text_notice")
		ui_allianceName:setString(_data.string["2"])
		ui_allianceLevel:setString("LV ".._data.int["4"])
		ui_allianceMainName:setString(Lang.ui_alliance_rank4.._data.string["15"])
		ui_allianceMemberNum:setString(string.format(Lang.ui_alliance_rank5, _data.int["7"], _data.int["6"]))
--        ui_allianceBuild:setString("建设度：" .. _data.int["3"])
		ui_allianceOffer:setString(_data.string["11"])
        if _data.int["17"] <= 0 then
            ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag["1"].bigUiId)].fileName)
        else
            ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(_data.int["17"])].bigUiId)].fileName)
        end
		local _isShowRank = true
		local image_basemap = UIAllianceRank.Widget:getChildByName("image_basemap")
		local search_panel = image_basemap:getChildByName("search_panel")
		if not _isJoinAlliance and not search_panel:isVisible() then
			_isShowRank = false
		end
--		if _isShowRank then
--			local _rank = _data.int["16"]
--			local _image = _rank <= 3 and string.format("ui/lm%d.png", _rank) or "ui/lm_number.png"
--			ui_rankImg:loadTexture(_image)
--			if _rank <= 3 then
--				ui_rankLabel:setVisible(false)
--			else
--				ui_rankLabel:setVisible(true)
--			end
--			ui_rankLabel:setString(tostring(_rank))
--		else
--			ui_rankImg:setVisible(false)
--			ui_rankLabel:setVisible(false)
--		end
		local btn_applyfor = _item:getChildByName("btn_applyfor")
		if btn_applyfor:isVisible() then
			local _instApplyId = getInstApplyId(_data.int["1"])
			if _instApplyId and _instApplyId ~= 0 then
				btn_applyfor:setTitleText(BUTTON_TEXT_CANCEL_APPLY)
				btn_applyfor:loadTextures("ui/tk_btn_purple.png", "ui/tk_btn_purple.png")
			else
				btn_applyfor:setTitleText(BUTTON_TEXT_APPLY)
				btn_applyfor:loadTextures("ui/tk_btn01.png", "ui/tk_btn01.png")
			end
			if _data.int["7"] >= _data.int["6"] then
				btn_applyfor:setTitleText(BUTTON_TEXT_FULL)
				btn_applyfor:setTouchEnabled(false)
				btn_applyfor:setBright(false)
			else
				btn_applyfor:setTouchEnabled(true)
				btn_applyfor:setBright(true)
			end
			btn_applyfor:setPressedActionEnabled(true)
			btn_applyfor:addTouchEventListener(function(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					if sender:getTitleText() == BUTTON_TEXT_APPLY then
                        local openLv = DictSysConfig[tostring(StaticSysConfig.unionApplayPlayerLevel)].value
                        if net.InstPlayer.int["4"] < openLv then
                            return UIManager.showToast(string.format(Lang.ui_alliance_rank6, openLv))
                        end
						if _applyCount >= MAX_APPLY_COUNT then
							UIManager.showToast(Lang.ui_alliance_rank7)
						else
							UIManager.showLoading()
							ui_applyButton = btn_applyfor
							netSendPackage({header = StaticMsgRule.applyAddUnion, msgdata = {int={instUnionId=_data.int["1"]}}}, netCallbackFunc)
						end
					else
						UIManager.showLoading()
						if _isShowRank then
							ui_applyButton = btn_applyfor
						else
							ui_applyButton = _data.int["1"]
						end
						netSendPackage({header = StaticMsgRule.refuseApply, msgdata = {int={instUnionApplyId=getInstApplyId(_data.int["1"])}}}, netCallbackFunc)
					end
				end
			end)
		end
    else
        _item:setTouchEnabled(true)
        _item:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                getAllianceData(math.floor(#_allianceData / PAGE_ITEM_SIZE) + 1)
            end
        end )
    end
end

local function addMoreItemToScrollView()
    local scrollViewItem = ccui.ImageView:create("ui/btn_l.png")
    --    scrollViewItem:setContentSize(ui_svItem:getContentSize())
    local moreLabel = ccui.Text:create()
    moreLabel:setString(Lang.ui_alliance_rank8)
    moreLabel:setFontName(dp.FONT)
    moreLabel:setFontSize(25)
    moreLabel:setPosition(cc.p(scrollViewItem:getContentSize().width / 2, scrollViewItem:getContentSize().height / 2))
    scrollViewItem:addChild(moreLabel)
    scrollViewItem:setTag(-100)
    setScrollViewItem(scrollViewItem)
    ui_scrollView:addChild(scrollViewItem)
    return scrollViewItem:getContentSize().height
end

netCallbackFunc = function(msgData)
    local code = tonumber(msgData.header)
    if code == StaticMsgRule.createUnion then
        UIManager.popScene()
        UIAlliance.show()
    elseif code == StaticMsgRule.unionRank then
--        if msgData.msgdata.message.myRank and msgData.msgdata.message.myRank.int then
--            local ui_myRank = UIAllianceRank.Widget:getChildByName("image_basemap"):getChildByName("image_di"):getChildByName("text_rank")
--            ui_myRank:setString("我的排名：" .. msgData.msgdata.message.myRank.int["1"])
--        end
        local unionRank = msgData.msgdata.message.unionRank

        ---------========================================================================
        if unionRank and unionRank.message then
            local _moreItemHeight = 0
            local childs = ui_scrollView:getChildren()
            if childs and #childs > 0 and childs[#childs]:getTag() < 0 then
                _moreItemHeight = childs[#childs]:getContentSize().height
                childs[#childs]:removeFromParent()
                childs[#childs] = nil
            end
            local _isResetInnerHieght = false
            local _index = math.floor(#_allianceData / PAGE_ITEM_SIZE) * 10 + 1

            local innerHieght = ui_scrollView:getInnerContainerSize().height
            if innerHieght == ui_scrollView:getContentSize().height then
                innerHieght = SCROLLVIEW_ITEM_SPACE
                _isResetInnerHieght = true
            end
            local _tempLists = { }
            if unionRank and unionRank.message then
                for key, obj in pairs(unionRank.message) do
                    _tempLists[#_tempLists + 1] = obj
                end

                -- @前八名无序排列
                local _randomSize = (#_tempLists > 8) and 8 or #_tempLists
                local _randoms = utils.randoms(1, _randomSize, _randomSize)
                for key, obj in pairs(_tempLists) do
                    if _tempLists[key].int["16"] < 8 and _randoms[key] then
                        _tempLists[key].int["16"] = _randoms[key]
                    end
                end
                _randoms = nil

                utils.quickSort(_tempLists, function(obj1, obj2) if obj1.int["16"] > obj2.int["16"] then return true end end)
            end
            for key, obj in pairs(_tempLists) do
                if _allianceData[_index] then
                    local childs = ui_scrollView:getChildren()
                    if childs and childs[_index] then
                        setScrollViewItem(childs[_index], obj)
                        if _isResetInnerHieght then
                            innerHieght = innerHieght + childs[_index]:getContentSize().height + SCROLLVIEW_ITEM_SPACE
                        end
                    end
                    _allianceData[_index] = nil
                else
                    local scrollViewItem = ui_svItem:clone()
                    setScrollViewItem(scrollViewItem, obj)
                    ui_scrollView:addChild(scrollViewItem)
                    innerHieght = innerHieght + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
                end
                _allianceData[_index] = obj
                _index = _index + 1
            end
            _tempLists = nil
            
            if #_allianceData >= MAX_ITEM_SIZE then
                innerHieght = innerHieght - _moreItemHeight - SCROLLVIEW_ITEM_SPACE
            else
                if _isResetInnerHieght then
                    innerHieght = innerHieght + addMoreItemToScrollView() + SCROLLVIEW_ITEM_SPACE
                else
                    addMoreItemToScrollView()
                end
            end
            
            if _allianceData then
                utils.quickSort(_allianceData, function(obj1, obj2) if obj1.int["16"] > obj2.int["16"] then return true end end)
            end
            layoutScrollView(innerHieght)
        else
            UIManager.showToast(Lang.ui_alliance_rank9)
        end
        ---------========================================================================

        -- local _allianceLists = {}
        -- if unionRank and unionRank.message then
        -- 	for key, obj in pairs(unionRank.message) do
        -- 		_allianceLists[#_allianceLists + 1] = obj
        -- 	end
        -- 	utils.quickSort(_allianceLists, function(obj1, obj2) if obj1.int["16"] > obj2.int["16"] then return true end end)
        -- end
        -- layoutScrollView(_allianceLists, setScrollViewItem)
    elseif code == StaticMsgRule.applyAddUnion then
        -- //有这个参数表示审核关闭，直接进入联盟, 没有这个值表示走审核
        if msgData.msgdata.int["1"] then
            UIManager.popScene()
            UIAlliance.show()
        else
            _applyCount = _applyCount + 1
            UIManager.showToast(Lang.ui_alliance_rank10)
            if ui_applyButton then
                ui_applyButton:setTitleText(BUTTON_TEXT_CANCEL_APPLY)
                ui_applyButton:loadTextures("ui/tk_btn_purple.png", "ui/tk_btn_purple.png")
                ui_applyButton = nil
            end
        end
    elseif code == StaticMsgRule.refuseApply then
        _applyCount = _applyCount - 1
        UIManager.showToast(Lang.ui_alliance_rank11)
        if type(ui_applyButton) == "number" then
            local image_basemap = UIAllianceRank.Widget:getChildByName("image_basemap")
            local tab_button_apply = image_basemap:getChildByName("tab_button_apply")
            tab_button_apply:releaseUpEvent()
            local childs = ui_scrollView:getChildren()
            for key, obj in pairs(childs) do
                if _allianceData[key].int["1"] == ui_applyButton and obj:getChildByName("btn_applyfor"):getTitleText() == BUTTON_TEXT_CANCEL_APPLY then
                    obj:getChildByName("btn_applyfor"):setTitleText(BUTTON_TEXT_APPLY)
                    obj:getChildByName("btn_applyfor"):loadTextures("ui/tk_btn01.png", "ui/tk_btn01.png")
                    break
                end
            end
        else
            ui_applyButton:setTitleText(BUTTON_TEXT_APPLY)
            ui_applyButton:loadTextures("ui/tk_btn01.png", "ui/tk_btn01.png")
        end
        ui_applyButton = nil
    elseif code == StaticMsgRule.applyUnion then
        local applyUnion = msgData.msgdata.message.applyUnion
        local _applyLists = { }
        if applyUnion and applyUnion.message then
            for key, obj in pairs(applyUnion.message) do
                _applyLists[#_applyLists + 1] = obj
            end
        end
        layoutApplyList(_applyLists, setScrollViewItem)
    end
end

function UIAllianceRank.init()
    if net.InstUnionMember and net.InstUnionMember.int["2"] ~= 0 then
        _isJoinAlliance = true
    end
    local image_basemap = UIAllianceRank.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    local tab_button_rank = image_basemap:getChildByName("tab_button_rank")
    local tab_button_apply = image_basemap:getChildByName("tab_button_apply")
    local tab_button_create = image_basemap:getChildByName("tab_button_create")
    local image_create_panel = image_basemap:getChildByName("image_create_panel")
    local ui_NameEditBox, ui_OfferEditBox = nil, nil
    if not _isJoinAlliance then
        image_create_panel:getChildByName("text_lv_number"):setString(tostring(DictSysConfig[tostring(StaticSysConfig.unionPlayerLevel)].value))
        local image_input_name = image_create_panel:getChildByName("image_input_name")
        ui_NameEditBox = cc.EditBox:create(image_input_name:getContentSize(), cc.Scale9Sprite:create())
        ui_NameEditBox:setAnchorPoint(image_input_name:getAnchorPoint())
        ui_NameEditBox:setPosition(image_input_name:getPosition())
        ui_NameEditBox:setFont(dp.FONT, 23)
        ui_NameEditBox:setFontColor(cc.c3b(255, 255, 255))
        ui_NameEditBox:setPlaceholderFontName(dp.FONT)
        ui_NameEditBox:setPlaceHolder(Lang.ui_alliance_rank12)
        ui_NameEditBox:setMaxLength(8)
        image_input_name:getParent():addChild(ui_NameEditBox)
        local image_alliance_manifesto = image_create_panel:getChildByName("image_alliance_manifesto")
        ui_OfferEditBox = cc.EditBox:create(image_alliance_manifesto:getContentSize(), cc.Scale9Sprite:create())
        ui_OfferEditBox:setAnchorPoint(image_alliance_manifesto:getAnchorPoint())
        ui_OfferEditBox:setPosition(image_alliance_manifesto:getPosition())
        ui_OfferEditBox:setFont(dp.FONT, 23)
        ui_OfferEditBox:setFontColor(cc.c3b(255, 255, 255))
        ui_OfferEditBox:setPlaceholderFontName(dp.FONT)
        ui_OfferEditBox:setPlaceHolder(Lang.ui_alliance_rank13)
        ui_OfferEditBox:setMaxLength(20)
        image_alliance_manifesto:getParent():addChild(ui_OfferEditBox)
    end

    local image_build = image_basemap:getChildByName("image_build")
    local top_line_img = image_basemap:getChildByName("top_line_img")
--    local image_di = image_basemap:getChildByName("image_di")
    local search_panel = image_basemap:getChildByName("search_panel")
    local btn_search = search_panel:getChildByName("btn_search")
    if IOS_PREVIEW then
        btn_search:hide()
    end
    ui_scrollView = image_basemap:getChildByName("view_info")
    ui_svItem = ui_scrollView:getChildByName("image_di_alliance"):clone()
    ui_svItem:getChildByName("btn_applyfor"):setVisible(not _isJoinAlliance)
    if _isJoinAlliance then
        local _offset = 45
        local image_rank = ui_svItem:getChildByName("image_rank")
        image_rank:setPositionX(image_rank:getPositionX() + _offset - 10)
        local image_di_info = ui_svItem:getChildByName("image_di_info")
        image_di_info:setPositionX(image_di_info:getPositionX() + _offset)
        local text_alliance_name = ui_svItem:getChildByName("text_alliance_name")
        text_alliance_name:setPositionX(text_alliance_name:getPositionX() + _offset)
        local text_alliance_lv = ui_svItem:getChildByName("text_alliance_lv")
        text_alliance_lv:setPositionX(text_alliance_lv:getPositionX() + _offset)
        image_create_panel:getChildByName("text_gold_number"):setString(tostring(DictSysConfig[tostring(StaticSysConfig.unionPlayerLevel)].value))
        image_create_panel:getChildByName("text_lv_number"):setString(tostring(DictSysConfig[tostring(StaticSysConfig.unionGold)].value))
    else
--        ui_scrollView:setContentSize(cc.size(ui_scrollView:getContentSize().width, ui_scrollView:getContentSize().height - image_build:getContentSize().height))
    end

    btn_close:setPressedActionEnabled(true)
    btn_closed:setPressedActionEnabled(true)
    btn_search:setPressedActionEnabled(true)

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_closed then
                if _isJoinAlliance then
                    UIManager.popScene()
                else
                    local openLv = DictSysConfig[tostring(StaticSysConfig.unionPlayerLevel)].value
                    if net.InstPlayer.int["4"] >= openLv then
                        if net.InstPlayer.int["5"] >= DictSysConfig[tostring(StaticSysConfig.unionGold)].value then
                            if ui_NameEditBox:getText() == "" then
                                UIManager.showToast(Lang.ui_alliance_rank14)
                            elseif ui_NameEditBox:getText():find("|") then
                                UIManager.showToast(Lang.ui_alliance_rank15)
                            else
                                UIManager.showLoading()
                                netSendPackage( {
                                    header = StaticMsgRule.createUnion,
                                    msgdata = { string = { unionName = ui_NameEditBox:getText(), unionManifesto = ui_OfferEditBox:getText() } }
                                } , netCallbackFunc)
                            end
                        else
                            UIManager.showToast(Lang.ui_alliance_rank16)
                        end
                    else
                        UIManager.showToast(Lang.ui_alliance_rank17 .. openLv .. Lang.ui_alliance_rank18)
                    end
                end
            elseif sender == tab_button_rank then
                tab_button_rank:loadTextures("ui/tk_j_btn01.png", "ui/tk_j_btn02.png")
                tab_button_rank:getChildByName("text_rank"):setTextColor(cc.c3b(0, 0, 0))
                tab_button_apply:loadTextures("ui/tk_j_btn02.png", "ui/tk_j_btn02.png")
                tab_button_apply:getChildByName("text_rank"):setTextColor(cc.c3b(255, 255, 255))
                tab_button_create:loadTextures("ui/tk_j_btn02.png", "ui/tk_j_btn02.png")
                image_create_panel:setVisible(false)
                removeApplyList()
                ui_scrollView:setVisible(true)
                btn_closed:setVisible(false)
                search_panel:setVisible(true)
            elseif sender == tab_button_apply then
                tab_button_apply:loadTextures("ui/tk_j_btn01.png", "ui/tk_j_btn02.png")
                tab_button_apply:getChildByName("text_rank"):setTextColor(cc.c3b(0, 0, 0))
                tab_button_rank:loadTextures("ui/tk_j_btn02.png", "ui/tk_j_btn02.png")
                tab_button_rank:getChildByName("text_rank"):setTextColor(cc.c3b(255, 255, 255))
                tab_button_create:loadTextures("ui/tk_j_btn02.png", "ui/tk_j_btn02.png")
                image_create_panel:setVisible(false)
                ui_scrollView:setVisible(false)
                btn_closed:setVisible(false)
                search_panel:setVisible(false)
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.applyUnion, msgdata = { } }, netCallbackFunc)
            elseif sender == tab_button_create then
                tab_button_create:loadTextures("ui/tk_j_btn01.png", "ui/tk_j_btn02.png")
                tab_button_rank:loadTextures("ui/tk_j_btn02.png", "ui/tk_j_btn02.png")
                tab_button_rank:getChildByName("text_rank"):setTextColor(cc.c3b(255, 255, 255))
                tab_button_apply:loadTextures("ui/tk_j_btn02.png", "ui/tk_j_btn02.png")
                tab_button_apply:getChildByName("text_rank"):setTextColor(cc.c3b(255, 255, 255))
                removeApplyList()
                ui_scrollView:setVisible(false)
                image_create_panel:setVisible(true)
                btn_closed:setVisible(true)
                search_panel:setVisible(false)
            elseif sender == btn_search then
                UIManager.showToast(Lang.ui_alliance_rank19)
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_search:addTouchEventListener(onButtonEvent)
    tab_button_rank:addTouchEventListener(onButtonEvent)
    tab_button_apply:addTouchEventListener(onButtonEvent)
    tab_button_create:addTouchEventListener(onButtonEvent)

    btn_closed:setTitleText(_isJoinAlliance and Lang.ui_alliance_rank20 or Lang.ui_alliance_rank21)
    btn_closed:setVisible(_isJoinAlliance)
    tab_button_rank:setVisible(not _isJoinAlliance)
    tab_button_apply:setVisible(not _isJoinAlliance)
    tab_button_create:setVisible(not _isJoinAlliance)
    top_line_img:setVisible(not _isJoinAlliance)
--    image_di:setVisible(_isJoinAlliance)
    image_build:setVisible(not _isJoinAlliance)
    search_panel:setVisible(not _isJoinAlliance)

    -- ui_scrollView:addEventListener(function(sender, eventType)
    -- 	if eventType == ccui.ScrollviewEventType.scrollToTop then
    -- 	elseif eventType == ccui.ScrollviewEventType.scrollToBottom then
    -- 		if _allianceData and ui_scrollView:isVisible() then
    -- 			getAllianceData(math.floor(#_allianceData / PAGE_ITEM_SIZE) + 1)
    -- 		end
    -- 	elseif eventType == ccui.ScrollviewEventType.scrolling then
    -- 	else
    -- 	end
    -- end)
end

function UIAllianceRank.setup()
    if not _isJoinAlliance then
        local image_basemap = UIAllianceRank.Widget:getChildByName("image_basemap")
        local tab_button_rank = image_basemap:getChildByName("tab_button_rank")
        tab_button_rank:releaseUpEvent()
    end
    _allianceData = { }
    cleanScrollView()
    getAllianceData(1)
    local innerHieght = 0
    if _allianceData then
        for key, obj in pairs(_allianceData) do
            local scrollViewItem = ui_svItem:clone()
            setScrollViewItem(scrollViewItem, obj)
            ui_scrollView:addChild(scrollViewItem)
            innerHieght = innerHieght + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
        end
        innerHieght = innerHieght + addMoreItemToScrollView() + SCROLLVIEW_ITEM_SPACE
    end
    innerHieght = innerHieght + SCROLLVIEW_ITEM_SPACE
    layoutScrollView(innerHieght)
    ActionManager.ScrollView_SplashAction(ui_scrollView)
end

function UIAllianceRank.free()
    _isJoinAlliance = false
    cleanScrollView(true)
    ui_applyButton = nil
    _applyCount = 0
    _allianceData = nil
end
