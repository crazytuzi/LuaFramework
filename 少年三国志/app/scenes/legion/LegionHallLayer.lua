--LegionHallLayer.lua


local LegionHallLayer = class("LegionHallLayer", UFCCSNormalLayer)

LegionHallLayer.HISTORY_LENGTH_STEP = 10

function LegionHallLayer.create( ... )
	return LegionHallLayer.new("ui_layout/legion_HallLayer.json", _, ...)
end

function LegionHallLayer:ctor( ... )
	self._hallMemberList = nil
    self._hallHistoryList = nil

    self._startHistroyIndex = 0
    self._isShowMore = false
	self.super.ctor(self, ...)
end

function LegionHallLayer:onLayerLoad( _, _, defaultIndex )
    self._defaultTabIndex = defaultIndex or 1

	self:addCheckBoxGroupItem(1, "CheckBox_info")
    self:addCheckBoxGroupItem(1, "CheckBox_member")
    self:addCheckBoxGroupItem(1, "CheckBox_dynamic")

	self:enableLabelStroke("Label_info_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_member_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_dynamic_check", Colors.strokeBrown, 2 )

	self:addCheckNodeWithStatus("CheckBox_info", "Label_info_check", true)
	self:addCheckNodeWithStatus("CheckBox_info", "Panel_info", true)
    self:addCheckNodeWithStatus("CheckBox_info", "Label_info_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_member", "Label_member_check", true)
    --self:addCheckNodeWithStatus("CheckBox_member", "Panel_member_list", true)
    self:addCheckNodeWithStatus("CheckBox_member", "Label_member_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_dynamic", "Label_dynamic_check", true)
    self:addCheckNodeWithStatus("CheckBox_dynamic", "Panel_back", true)
    self:addCheckNodeWithStatus("CheckBox_dynamic", "Label_dynamic_uncheck", false)

    self:registerCheckboxEvent("CheckBox_info", handler(self, self._onSwitchLegionInfo))
	self:registerCheckboxEvent("CheckBox_member", handler(self, self._onSwitchLegionMember))
	self:registerCheckboxEvent("CheckBox_dynamic", handler(self, self._onSwitchLegionDynamic))

    self:registerBtnClickEvent("Button_back", handler(self, self._onBackClick))
    self:registerBtnClickEvent("Button_check", handler(self, self._onCheckApply))
    self:registerBtnClickEvent("Button_check_1", handler(self, self._onCheckApply))
    self:registerBtnClickEvent("Button_disband", handler(self, self._onDisbandLegion))

    self:registerWidgetClickEvent("Image_legion", handler(self, self._onChangeIcon))
    self:registerWidgetClickEvent("Image_gonggao", handler(self, self._onChangeNotice))
    self:registerWidgetClickEvent("Image_xuanyan", handler(self, self._onChangeDesc))

    self:enableLabelStroke("Label_progress_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_legion_name", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_notice", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_desc", Colors.strokeBrown, 2 )

    self:_updateCorpDetail()

    G_HandlersManager.legionHandler:sendGetCorpMember()
    G_HandlersManager.legionHandler:sendGetCorpDetail()

    self:callAfterFrameCount(1, function ( ... )
        self:adapterWidgetHeight("Panel_content", "Panel_Top", "", 0, 0)
        self:adapterWidgetHeight("Panel_dynamic_content", "Panel_Top", "", 10, -35)
        self:adapterWidgetHeight("Panel_member_list", "Panel_Top", "", 10, -20)
        self:adapterWidgetHeight("Panel_back", "Panel_Top", "", 0, -45)

        if self._defaultTabIndex == 2 then 
            self:setCheckStatus(1, "CheckBox_member")
        elseif self._defaultTabIndex == 3 then
            self:setCheckStatus(1, "CheckBox_dynamic")
        else
            self:setCheckStatus(1, "CheckBox_info")
        end
    end)
end

function LegionHallLayer:onLayerEnter( ... )
    
	   
    

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, self._updateCorpDetail, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_MEMBERLIST, self._reloadCorpMember, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_JOIN_MEMBER, self._reloadCorpMember, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP_MEMBER, self._updateCorpMember, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_STAFF, self._onCorpStaff, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EXCHANGE_LEADER, self._onExchangeLeader, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_QUIT_CORP, self._onQuitCorp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CONFIRM_JOIN_CORP, self._onConfirmApply, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_HISTORY, self._onHistoryUpdate, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_APPLY, self._doUpdateLegionHall, self)

    local array = CCArray:create()
    array:addObject(CCRotateTo:create(100,180))
    array:addObject(CCRotateTo:create(100,360))
    self:getImageViewByName("Image_6"):runAction(CCRepeatForever:create(CCSequence:create(array)))

    self:_doUpdateLegionHall()
end

function LegionHallLayer:_onBackClick( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionHallLayer:_onCheckApply( ... )
    require("app.scenes.legion.CheckApplyLayer").show()
end

function LegionHallLayer:_onDisbandLegion( ... )
    require("app.cfg.corps_value_info")
    local minCount = corps_value_info.get(10).value or 1
    if G_Me.legionData:getCorpMemberLength() >= minCount then 
        return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DISMISS_CORP_TIP"))
    end

    MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_DISMISS_CORP_CONFIRM"), false, function ( ... )
        G_HandlersManager.legionHandler:sendDismissCorp()
    end)    
end

function LegionHallLayer:_doUpdateLegionHall( ... )
    self:showWidgetByName("Image_check_flag", G_Me.legionData:hasCorpApply())
    self:showWidgetByName("Image_check_flag_1", G_Me.legionData:hasCorpApply())
end

function LegionHallLayer:_onSwitchLegionInfo( ... )
end

function LegionHallLayer:_onSwitchLegionMember( ... )
    local firstLoad = false
	if not self._hallMemberList then
        firstLoad = true 
		local panel = self:getPanelByName("Panel_member_list")
		if panel == nil then
			return 
		end

		self._hallMemberList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self:addCheckNodeWithStatus("CheckBox_member", "Panel_member_list", true)
    	self._hallMemberList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.HallMemberCell").new(list, index)
    	end)
    	self._hallMemberList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(G_Me.legionData:getCorpMemberByIndex(index + 1))
    		end
    	end)
    	self._hallMemberList:setSelectCellHandler(function ( cell, index )
    	end)
    	self._hallMemberList:setSpaceBorder(0, 40)
	end
    __Log("firstLoad:%d", firstLoad and 1 or 0)
    self._hallMemberList:reloadWithLength(G_Me.legionData:getCorpMemberLength(), 0,  firstLoad and 0.2 or 0)
end

function LegionHallLayer:_onSwitchLegionDynamic( ... )
    if not G_Me.legionData:hasHistoryDataInit() then 
        local corpDetail = G_Me.legionData:getCorpDetail()
        if corpDetail and corpDetail.history_index > 0 then 
            local startIndex = corpDetail.history_index >= LegionHallLayer.HISTORY_LENGTH_STEP and 
            (corpDetail.history_index - LegionHallLayer.HISTORY_LENGTH_STEP + 1) or 1
            G_HandlersManager.legionHandler:sendGetCorpHistory(startIndex, corpDetail.history_index)
        end
    else
        if not self._hallHistoryList then 
            local panel = self:getPanelByName("Panel_dynamic_content")
            if panel == nil then
                return 
            end

            self._hallHistoryList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
            self:addCheckNodeWithStatus("CheckBox_dynamic", "Panel_dynamic_content", true)
            self._hallHistoryList:setCreateCellHandler(function ( list, index)
                return require("app.scenes.legion.LegionHistoryItem").new(list, index)
            end)
            self._hallHistoryList:setUpdateCellHandler(function ( list, index, cell)
                if cell then 
                    cell:updateItem(G_Me.legionData:getHistoryByIndex(index + self._startHistroyIndex))
                end
            end)
            self._hallHistoryList:setSelectCellHandler(function ( cell, index )
            end)
            self._hallHistoryList:setSpaceBorder(0, 40)
            self._hallHistoryList:setShowMoreHandler(function ( list, topLeft, bottomRight )
                if topLeft then 
                    local curMinHistoryIndex = G_Me.legionData:getMinHistoryIndex() - 1
                    if curMinHistoryIndex > 0 then 
                        local startIndex = curMinHistoryIndex >= LegionHallLayer.HISTORY_LENGTH_STEP and 
                        (curMinHistoryIndex - LegionHallLayer.HISTORY_LENGTH_STEP + 1) or 1
                        G_HandlersManager.legionHandler:sendGetCorpHistory(startIndex, curMinHistoryIndex)
                        self._isShowMore = true
                    end
                end
            end)
        end
        self._startHistroyIndex = G_Me.legionData:getMinHistoryIndex()
        self._hallHistoryList:reloadWithLength(G_Me.legionData:getHistoryCount())
        if not self._isShowMore then
            self._hallHistoryList:scrollToBottomRightCellIndex(G_Me.legionData:getHistoryCount(), 0, 0, function ( ... )
                -- body
            end)
        end
        self._isShowMore = false
    end
end

function LegionHallLayer:_onChangeIcon( ... )
	require("app.scenes.legion.ChangeLegionIconLayer").show()
end

function LegionHallLayer:_onChangeNotice( ... )
	require("app.scenes.legion.ChangeNoticeLayer").show(1)
end

function LegionHallLayer:_onChangeDesc( ... )
	require("app.scenes.legion.ChangeNoticeLayer").show(2)
end


function LegionHallLayer:_updateCorpDetail( ... )
    if not G_Me.legionData:hasCorp() then 
        return 
    end
    local detailCorp = G_Me.legionData:getCorpDetail() or {}

    self:showTextWithLabel("Label_level_value", G_lang:get("LANG_LEGION_CORP_LEVEL_FORMAT", {levelValue=detailCorp.level or 1}) )
    self:showTextWithLabel("Label_legion_name", detailCorp.name or "")
    self:showTextWithLabel("Label_chief_name", detailCorp.leader_name or "")
    self:showTextWithLabel("Label_notice_content", detailCorp.notification or "")
    self:showTextWithLabel("Label_desc_content", detailCorp.announcement or "")

    --self:enableWidgetByName("Image_legion", detailCorp.position > 0 )
    self:showWidgetByName("Label_change_notice", detailCorp.position > 0 )
    self:showWidgetByName("Label_change_desc", detailCorp.position > 0 )
    self:showWidgetByName("Button_check", detailCorp.position == 1)
    self:showWidgetByName("Button_check_1", detailCorp.position == 2)
    self:showWidgetByName("Button_disband", detailCorp.position == 1)

    self:enableWidgetByName("Image_gonggao", detailCorp.position > 0)
    self:enableWidgetByName("Image_xuanyan", detailCorp.position > 0)

    -- 军团进度
    local maxExp = 0
    local curExp = 0
    local corpsInfo = nil
    if detailCorp then 
        corpsInfo = corps_info.get(detailCorp.level)
        maxExp = corpsInfo and corpsInfo.exp or 0
        curExp = detailCorp.exp
    end
    self:showTextWithLabel("Label_progress_value", curExp.."/"..maxExp)
    curExp = curExp > maxExp and maxExp or curExp
    local progressBar = self:getLoadingBarByName("ProgressBar_progress")
    if progressBar then 
        progressBar:runToPercent(maxExp > 0 and (curExp*100)/maxExp or 0, 0.2)
    end

    self:showTextWithLabel("Label_member_count", (detailCorp.size or 0).."/"..(corpsInfo and corpsInfo.number or 0))

    -- 军团边框和ICON
    local img = self:getImageViewByName("Image_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconByIndex(detailCorp.icon_pic))
    end
    img = self:getImageViewByName("Image_legion")
    if img then 
        img:loadTexture(G_Path.getLegionIconBackByIndex(detailCorp.icon_frame))
    end

    if not self._addLabel and detailCorp.size < 3 and detailCorp.level == 1 then
        self._addLabel =  GlobalFunc.createGameLabel(G_lang:get("LANG_LEGION_DISMISS_AUTO"), 20, Colors.lightColors.TIPS_01, nil,CCSizeMake(140,80))
        self:getLabelByName("Label_member_count"):addChild(self._addLabel)
        self._addLabel:setPosition(ccp(200,-40))
    end
end

function LegionHallLayer:_updateCorpMember( ... )
    if self._hallMemberList then 
        local startIndex = self._hallMemberList:getShowStart()
        self._hallMemberList:reloadWithLength(G_Me.legionData:getCorpMemberLength(), startIndex)
    end
end

function LegionHallLayer:_reloadCorpMember( ... )
    if self._hallMemberList then 
        self._hallMemberList:reloadWithLength(G_Me.legionData:getCorpMemberLength())
    end
end

function LegionHallLayer:_onExchangeLeader( ... )
    G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CORP_STAFF_EXCHANGE"))
    if self._hallMemberList then 
        self._hallMemberList:refreshAllCell()
    end
end

function LegionHallLayer:_onCorpStaff( ret, id, position )
    local memIndex = G_Me.legionData:getMemberIndexById(id or 0) 
    if memIndex > 0 and self._hallMemberList then 
        local item = self._hallMemberList:getCellByIndex(memIndex - 1)
        if item then 
            item:showCorpStaffFlag()
        end
    end
    position = position or 1
    if position > 2 or position < 0 then 
        position = 0 
    end
    G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CORP_STAFF_"..position))
    if self._hallMemberList then 
        self._hallMemberList:refreshAllCell()
    end
end

function LegionHallLayer:_onQuitCorp( ... )
    G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_QUIT_CORP_SUCCESS"))
    uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
end

function LegionHallLayer:_onDismissCorp( ... )
    G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DISMISS_CORP_SUCCESS"))
    uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
end

function LegionHallLayer:_onConfirmApply( ret, confirm )
    if ret == 1 and confirm then 
        G_HandlersManager.legionHandler:sendGetCorpDetail()
        G_HandlersManager.legionHandler:sendGetCorpMember()
    end
end

function LegionHallLayer:_onHistoryUpdate( ... )
    local dynamicCheck = self:getCheckBoxByName("CheckBox_dynamic")
    if not dynamicCheck or not dynamicCheck:getSelectedState() then 
        return 
    end

    self:_onSwitchLegionDynamic()
end


return LegionHallLayer
