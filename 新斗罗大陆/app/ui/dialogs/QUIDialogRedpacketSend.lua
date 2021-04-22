--
-- Author: Kumo.Wang
-- 宗门红包发包界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRedpacketSend = class("QUIDialogRedpacketSend", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetRedpacketSendCell = import("..widgets.QUIWidgetRedpacketSendCell")
local QQuickWay = import("...utils.QQuickWay")
local QMaskWords = import("...utils.QMaskWords")
local QRichText = import("...utils.QRichText")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogRedpacketSend:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_send.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerSend", callback = handler(self, self._onTriggerSend)},
        -- {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
        -- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogRedpacketSend.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = false --是否动画显示

	self._redpacketType = options.redpacketType
    self._superOptions = options.superOptions

    self:_init()
end

function QUIDialogRedpacketSend:viewDidAppear()
	QUIDialogRedpacketSend.super.viewDidAppear(self)
end

function QUIDialogRedpacketSend:viewWillDisappear()
	QUIDialogRedpacketSend.super.viewWillDisappear(self)
end

function QUIDialogRedpacketSend:_resetAll()
	self._ccbOwner.node_redpacketIcon:removeAllChildren()
    self._ccbOwner.node_title:removeAllChildren()
	self._ccbOwner.tf_explain:setVisible(false)
	self._ccbOwner.tf_timesValue:setVisible(false)
    self._ccbOwner.tf_timesTitle:setVisible(false)
            
    self._ccbOwner.tf_timesTitle:setPositionX(134)
    self._ccbOwner.tf_timesValue:setPositionX(141)
end

function QUIDialogRedpacketSend:_init()
	self:_resetAll()
	if not self._redpacketType then return end

	self:_setRedpacketImg()
	self:_setAwardInfo()
    self:_addInputBox()
    self:_setInfo()
end

function QUIDialogRedpacketSend:_addInputBox()
    if not self._inputMsg then
        -- add input box
        self._inputWidth = self._ccbOwner.inputArea:getContentSize().width
        self._inputHeight = self._ccbOwner.inputArea:getContentSize().height
        self._inputMsg = ui.newEditBox({image = "ui/none.png", listener = handler(self, self._onEdit), size = CCSize(self._inputWidth, self._inputHeight)})
        self._inputMsg:setFont(global.font_default, 20)
        self._inputMsg:setMaxLength(36)
        self._inputMsg:setPlaceHolder(remote.redpacket.DEFAULT_SEND_MESSAGE)
        self._inputMsg:setPlaceholderFontColor(ccc3(200, 200, 200)) 
        self._inputMsg:setPlaceholderFontSize(20)
        self._inputMsg:setFontName(global.font_name)
        self._ccbOwner.input:addChild(self._inputMsg)
    end
end

function QUIDialogRedpacketSend:_onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then
        if device.platform == "android" or device.platform == "windows" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    elseif event == "ended" then
        if device.platform == "android" or device.platform == "windows" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    elseif event == "return" then
        -- 从输入框返回
    elseif event == "returnDone" then
        if device.platform == "ios" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    end
end
function QUIDialogRedpacketSend:_setRedpacketImg()
    local path = remote.redpacket:getSendRedPacketPathByType(self._redpacketType)
    if path then
    	local sprite = CCSprite:create(path)
    	if sprite then
    		self._ccbOwner.node_redpacketIcon:addChild(sprite)
    	end
	end
end

function QUIDialogRedpacketSend:_setAwardInfo()
	if self._redpacketType == remote.redpacket.TOKEN_REDPACKET then
        self:_updateTokenData()
    elseif self._redpacketType == remote.redpacket.ITEM_REDPACKET then
        self:_updateItemData()
    elseif self._redpacketType == remote.redpacket.CONSORTIA_WAR_REDPACKET then
        self:_updateConsortiaWarData()
    end
end

function QUIDialogRedpacketSend:_updateTokenData()
    local configList = remote.redpacket:getRedpacketConfigListByType(self._redpacketType)
    table.sort(configList, function(a, b)
            return a.award_num < b.award_num
        end)
    self._useItemData = configList
    self:_initListView()
end

function QUIDialogRedpacketSend:_updateItemData()
	local configList = remote.redpacket:getRedpacketConfigListByType(self._redpacketType)
	table.sort(configList, function(a, b)
			return a.award_num < b.award_num
		end)
	self._useItemData = configList
	self:_initListView()
end

function QUIDialogRedpacketSend:_updateConsortiaWarData()
    local configList = remote.redpacket:getRedpacketConfigListByType(self._redpacketType)
    table.sort(configList, function(a, b)
            return a.award_num < b.award_num
        end)
    self._useItemData = configList
    self:_initListView()
end

function QUIDialogRedpacketSend:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._useItemData[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetRedpacketSendCell.new()
                    item:setScale(1)
                    isCacheNode = false
                end
                item:setInfo({itemData = itemData, redpacketType = self._redpacketType})
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_select", handler(self, self._clickCellHandler))

                return isCacheNode
            end,
            curOriginOffset = 0,
            curOffset = 0,
            contentOffsetX = 0, 
            contentOffsetY = 0,
            spaceX = 10,
            spaceY = 0,
            isVertical = false,
            multiItems = 1,
            enableShadow = false,
            curOffset = 0,
            ignoreCanDrag = false,
            autoCenter = true,
            totalNumber = #self._useItemData,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._useItemData})
    end
end

function QUIDialogRedpacketSend:_clickCellHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local index = 1
    while true do
        local node = listView:getItemByIndex(index)
        if node then
            if index == touchIndex then
                node:setSelectedState(true)
            else
                node:setSelectedState(false)
            end
            index = index + 1
        else
            break
        end
    end

    local touchIndex = listView:getCurTouchIndex()
    local itemData = self._useItemData[touchIndex]

    self:_setInfo(itemData)
end


function QUIDialogRedpacketSend:_setInfo( config )
    self._selectedConfig = config
	self._ccbOwner.tf_explain:setString(config and config.explain or "")
    self._ccbOwner.tf_explain:setVisible(true)
    
    if self._redpacketType == remote.redpacket.TOKEN_REDPACKET then
        local maxCount = remote.redpacket:getMaxSendCount()
        local curCount = maxCount - remote.redpacket:getCurSendCount()
        self._ccbOwner.tf_timesTitle:setString("剩余次数：")
        local freeCount = remote.user.userConsortia.free_red_packet_count or 0
        if freeCount > 0 then
            self._ccbOwner.tf_timesValue:setString(curCount.." (免费福袋不消耗发放次数)")
            self._ccbOwner.tf_timesTitle:setPositionX(104)
            self._ccbOwner.tf_timesValue:setPositionX(111)
        else
            self._ccbOwner.tf_timesValue:setString(curCount)
        end
    elseif self._redpacketType == remote.redpacket.ITEM_REDPACKET then
        self._ccbOwner.tf_timesValue:setString(config and config.use_num or 1)
        self._ccbOwner.tf_timesTitle:setString("消耗数量：")
    elseif self._redpacketType == remote.redpacket.CONSORTIA_WAR_REDPACKET then
        self._ccbOwner.tf_timesTitle:setString("剩余次数：")
        local freeCount = remote.user.userConsortia.free_red_packet4_count or 0
        if freeCount > 0 then
            self._ccbOwner.tf_timesValue:setString(freeCount.." (免费福袋不消耗发放次数)")
            self._ccbOwner.tf_timesTitle:setPositionX(104)
            self._ccbOwner.tf_timesValue:setPositionX(111)
        else
            self._ccbOwner.tf_timesValue:setString(freeCount)
        end
    end
    self._ccbOwner.tf_timesValue:setVisible(true)
    self._ccbOwner.tf_timesTitle:setVisible(true)

    self._ccbOwner.node_title:removeAllChildren()
    local str = "##j钻石档位："
    if self._redpacketType == remote.redpacket.TOKEN_REDPACKET then
        str = "##j钻石档位："
    elseif self._redpacketType == remote.redpacket.ITEM_REDPACKET then
        if self._selectedConfig and self._selectedConfig.award_num then
            str = "##j钻石档位##w"..self._selectedConfig.award_num.."##j消耗道具："
        else
            str = "##j消耗道具："
        end
    end
    local richText = QRichText.new(str, 500, {autoCenter = false, stringType = 1, defaultSize = 22})
    richText:setAnchorPoint(ccp(0.0, 0.5))
    self._ccbOwner.node_title:addChild(richText)
end

function QUIDialogRedpacketSend:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogRedpacketSend:_onTriggerSend(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_send) == false then return end
	app.sound:playSound("common_small")
    if not self._selectedConfig then
        app.tip:floatTip("尚未选择")
        return 
    end
    if self._selectedConfig.unlock_level then
        if remote.user.level < self._selectedConfig.unlock_level then
            app.tip:floatTip("发放该福袋需要"..self._selectedConfig.unlock_level.."级")
            return 
        end
    end

    if self._selectedConfig.unlock_vip then
        if QVIPUtil:VIPLevel() < self._selectedConfig.unlock_vip then
            app.tip:floatTip("发放该福袋需要VIP达到"..self._selectedConfig.unlock_vip.."级")
            return 
        end
    end

    local isFree = false
    local haveFreeToken = false
    if self._redpacketType == remote.redpacket.TOKEN_REDPACKET then
        local maxCount = remote.redpacket:getMaxSendCount()
        local curCount = maxCount - remote.redpacket:getCurSendCount()
        if tonumber(self._selectedConfig.id) == remote.redpacket.FREE_TOKEN_REDPACKET_ID_1 then
            if remote.user.userConsortia.free_red_packet_count and remote.user.userConsortia.free_red_packet_count > 0 then
                haveFreeToken = true
            end
        elseif tonumber(self._selectedConfig.id) == remote.redpacket.FREE_TOKEN_REDPACKET_ID_2 then 
            if remote.user.userConsortia.free_red_packet2_count and remote.user.userConsortia.free_red_packet2_count > 0 then
                haveFreeToken = true
            end
        end
        if tonumber(self._selectedConfig.id) == remote.redpacket.FREE_TOKEN_REDPACKET_ID_3 then
            if remote.user.userConsortia.free_red_packet3_count and remote.user.userConsortia.free_red_packet3_count > 0 then
                haveFreeToken = true
            end
        end
        if not haveFreeToken and curCount <= 0 then 
            app.tip:floatTip("今日次数已用完")
            return 
        end
    elseif self._redpacketType == remote.redpacket.ITEM_REDPACKET then
    elseif self._redpacketType == remote.redpacket.CONSORTIA_WAR_REDPACKET then
        isFree = true
        local freeCount = remote.user.userConsortia.free_red_packet4_count or 0
        if freeCount <= 0 then
            app.tip:floatTip("没有免费的宗门战福袋")
            return
        end
    end

    local id = tonumber(self._selectedConfig.use_type)
    local haveNum = 0
    if haveFreeToken == false then
        if id then
            haveNum = remote.items:getItemsNumByID(id)
            if haveNum < self._selectedConfig.use_num then 
                QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, id)
                -- app.tip:floatTip("道具数量不足")
                return 
            end
        else
            haveNum = remote.items:getNumByIDAndType(nil, self._selectedConfig.use_type)
            local useNum = self._selectedConfig.use_num
            if isFree then
                useNum = 0
            end
            if haveNum < useNum then 
                QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
                return 
            end
        end
    end

    local msg = self._inputMsg:getText()
    print(msg, string.len(msg))

    if msg == nil or msg == "" then
        msg = remote.redpacket.DEFAULT_SEND_MESSAGE
    end
    if string.len(msg) > 36 then
        app.tip:floatTip("发送祝福语内容过长")
        return
    end
    if QMaskWords:isFind(msg) then
        app.tip:floatTip("发送祝福中包含敏感字符")
        return
    end
    local serverChatData = app:getServerChatData() -- app:getXMPPData() 
    if not serverChatData:messageValid(msg, CHANNEL_TYPE.GLOBAL_CHANNEL) then
        app.tip:floatTip("发送祝福中包含非法字符")
        return
    end
    
    local redpacketType = self._redpacketType
    remote.redpacket:unionRedpacketSendRequest(self._selectedConfig.id, msg, self:safeHandler(function()
            if not isFree then
                remote.activity:updateLocalDataByType(703, self._selectedConfig.award_num)
            end

            if redpacketType == remote.redpacket.TOKEN_REDPACKET then
                app.taskEvent:updateTaskEventProgress(app.taskEvent.TOKEN_REDPACKET_EVENT, 1, false, false)
            elseif redpacketType == remote.redpacket.ITEM_REDPACKET then
                app.taskEvent:updateTaskEventProgress(app.taskEvent.ITEM_REDPACKET_EVENT, 1, false, false)
            end
            self._superOptions.selectedTab = remote.redpacket.GAIN
            if self._selectedConfig.consortia_money or self._selectedConfig.consortia_exp then
                self._superOptions.lastSendConfig = self._selectedConfig
            end
            self:_onTriggerClose()
        end))
end

function QUIDialogRedpacketSend:_onTriggerSelect(event, target)
    app.sound:playSound("common_small")
    local index = 1
    while true do
        local node = self._ccbOwner["btn_select_"..index]
        local spOn = self._ccbOwner["sp_on_"..index]
        local spOff = self._ccbOwner["sp_off_"..index]
        if node then
            if target == node then
                if spOn then spOn:setVisible(true) end
                if spOff then spOff:setVisible(false) end
                local config = self._useItemData[index]
                if config then
                    self:_setInfo(config)
                end
            else
                if spOn then spOn:setVisible(false) end
                if spOff then spOff:setVisible(true) end
            end
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogRedpacketSend:_onTriggerClose(e)
    if e then
    	app.sound:playSound("common_small")
    end
	self:playEffectOut()
end

function QUIDialogRedpacketSend:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogRedpacketSend