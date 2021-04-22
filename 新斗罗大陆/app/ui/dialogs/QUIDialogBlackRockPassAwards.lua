local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockPassAwards = class("QUIDialogBlackRockPassAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText") 
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")


function QUIDialogBlackRockPassAwards:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_tongguan.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
        {ccbCallbackName = "onTriggerDoubleGet", callback = handler(self, self._onTriggerDoubleGet)},
        {ccbCallbackName = "onTriggerNotGet",callback = handler(self,self._onTriggerNotGet)},
	}
	QUIDialogBlackRockPassAwards.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._award = options.award
	self._callBack = options.callback
    self._endScore = self._award.awardScore or 0

	local rt = QRichText.new(nil, 380)
    rt:setAnchorPoint(ccp(0,1))
	rt:setPosition(self._ccbOwner.tf_text:getPosition())
    local time = q.date("*t", self._award.happenAt/1000)
    local timeStr = string.format("%.2d-%.2d %.2d:%.2d", time.month, time.day, time.hour, time.min)
    local starStr = q.numToWord(self._award.starNum).."星"
    local tfTbl = {}
    local chapterName = remote.blackrock:getChapterById(self._award.chapterId)[1].name
    table.insert(tfTbl, {oType = "font", content = "魂师大人，您在", size = 24, color = COLORS.a})
    table.insert(tfTbl, {oType = "font", content = timeStr..chapterName, size = 24, color = COLORS.M})
    table.insert(tfTbl, {oType = "font", content = "的组队战中获得", size = 24, color = COLORS.a})
    table.insert(tfTbl, {oType = "font", content = starStr, size = 24, color = COLORS.M})
    if self._award.giveAward == false then
        table.insert(tfTbl, {oType = "font", content = "（奖励次数已用完）", size = 24, color = COLORS.a})
    else
        table.insert(tfTbl, {oType = "font", content = "，以下为您的奖励~", size = 24, color = COLORS.a})
    end
    rt:setString(tfTbl)
    local parentNode = self._ccbOwner.tf_text:getParent()
    parentNode:addChild(rt)
    if self._award.giveAward == true then
        local _awards = remote.items:analysisServerItem(self._award.awards)
        for index,value in ipairs(_awards) do
            local box = QUIWidgetItemsBox.new()
            box:setPromptIsOpen(true)
            box:setGoodsInfo(value.id or value.typeName, value.typeName, value.count, true)
            box:setPositionX(100 * (index - 1))
            self._ccbOwner.node_item_1:addChild(box)
        end
        if self._endScore > 0 then
            local box = QUIWidgetItemsBox.new()
            box:setPromptIsOpen(true)
            box:setGoodsInfo(nil, ITEM_TYPE.BLACKROCK_INTEGRAL, self._endScore)
            box:setColor("orange")
            box:setPositionX(100 * (#_awards))
            self._ccbOwner.node_item_1:addChild(box)
        end
        if self._award.isPlayComeBack then
            local sp = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
            local node = self._ccbOwner.node_item_1:getParent()
            sp:setAnchorPoint(ccp(0.5, 0.5))
            sp:setPositionX(100 * (#_awards))
            sp:setPositionY(self._ccbOwner.node_item_1:getPositionY())
            node:addChild(sp)
        end
    else
        rt:setPositionY(rt:getPositionY()-20)
    end
    self._costToken = QStaticDatabase:sharedDatabase():getConfigurationValue("blackrock_buy_double_rewards") or "免费"
    self._ccbOwner.tf_token:setString(self._costToken)
end

function QUIDialogBlackRockPassAwards:viewDidAppear()
    QUIDialogBlackRockPassAwards.super.viewDidAppear(self)
    self:addBackEvent(false)
end

function QUIDialogBlackRockPassAwards:viewWillDisappear()
    QUIDialogBlackRockPassAwards.super.viewWillDisappear(self)
    self:removeBackEvent()
end

function QUIDialogBlackRockPassAwards:_onTriggerGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
    if self._award.getAward == false then
        --像后端请求
        local awards = {}
        local _awards = remote.items:analysisServerItem(self._award.awards)
        for index,value in ipairs(_awards) do
            table.insert(awards, {id = value.id or value.typeName, typeName = value.typeName, count = value.count})
        end
        if self._endScore > 0 then
            table.insert(awards, {id = nil, typeName = ITEM_TYPE.BLACKROCK_INTEGRAL, count = self._endScore})
        end

        remote.blackrock:blackRockGetTeamAwardRequest(self._award.awardId,false,false,function(sucessData)
            if self:safeCheck() then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                options = {awards = awards,callBack = function()
                    self:_onTriggerClose()
                end}},{isPopCurrentDialog = false} )
                dialog:setTitle("恭喜你获得通关奖励")
            end
        end,function(failData)
            -- body
        end)
    end
    -- self:_onTriggerClose()
end

function QUIDialogBlackRockPassAwards:_onTriggerDoubleGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_doubleget) == false then return end
    if self._award.getAward == false then
        if remote.user.token < tonumber(self._costToken) then
            app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
            return
        end
        local awards = {}
        local _awards = remote.items:analysisServerItem(self._award.awards)
        for index,value in ipairs(_awards) do
            table.insert(awards, {id = value.id or value.typeName, typeName = value.typeName, count = value.count*2})
        end
        if self._endScore > 0 then
            table.insert(awards, {id = nil, typeName = ITEM_TYPE.BLACKROCK_INTEGRAL, count = self._endScore*2})
        end
        --像后端请求
        remote.blackrock:blackRockGetTeamAwardRequest(self._award.awardId,true,false,function(sucessData)
            if self:safeCheck() then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                options = {awards = awards,callBack = function()
                    self:_onTriggerClose()
                end}},{isPopCurrentDialog = false} )
                dialog:setTitle("恭喜你获得通关奖励")
            end
        end)
    end
end

function QUIDialogBlackRockPassAwards:_onTriggerNotGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_notget) == false then return end
    remote.blackrock:blackRockGetTeamAwardRequest(self._award.awardId,false,true,function(sucessData)
        if self:safeCheck() then
            self:_onTriggerClose()
        end
    end)
end

-- function QUIDialogBlackRockPassAwards:_backClickHandler()
-- 	self:_onTriggerClose()
-- end

function QUIDialogBlackRockPassAwards:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogBlackRockPassAwards:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogBlackRockPassAwards