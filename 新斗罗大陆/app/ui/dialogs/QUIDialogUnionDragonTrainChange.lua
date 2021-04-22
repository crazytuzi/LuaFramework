-- 
-- 宗门武魂选择
-- zxs
-- 
local QUIDialog = import(".QUIDialog")
local QUIDialogUnionDragonTrainChange = class("QUIDialogUnionDragonTrainChange", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetUnionDragonTrainChange = import("..widgets.dragon.QUIWidgetUnionDragonTrainChange")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QListView = import("...views.QListView")

QUIDialogUnionDragonTrainChange.TAB_WEAPON = "TAB_WEAPON"
QUIDialogUnionDragonTrainChange.TAB_WARRIOR = "TAB_WARRIOR"

function QUIDialogUnionDragonTrainChange:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_illusion.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerWeapon", callback = handler(self, self._onTriggerWeapon)},
		{ccbCallbackName = "onTriggerWarrior", callback = handler(self, self._onTriggerWarrior)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogUnionDragonTrainChange.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true
	self._ccbOwner.tf_title:setString("武魂幻化")
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	ui.tabButton(self._ccbOwner.btn_weapon, "器武魂", nil, ccp(0.6, 0.5))
    ui.tabButton(self._ccbOwner.btn_warrior, "兽武魂", nil, ccp(0.6, 0.5))
    local tabs = {}
    table.insert(tabs, self._ccbOwner.btn_weapon)
    table.insert(tabs, self._ccbOwner.btn_warrior)
    self._tabManager = ui.tabManager(tabs)

	self._selectDragonId = 0
	local dragonInfo = remote.dragon:getDragonInfo()
	self._dragonId = dragonInfo.dragonId or 0
	self._dragonType = 0

	if self._dragonId ~= 0 then
		local dragonConfig = db:getUnionDragonConfigById(self._dragonId)
		self._dragonType = dragonConfig.type
	end

    if remote.union:checkUnionRight() then
        self._ccbOwner.node_buy:setVisible(true)
        self._ccbOwner.tf_tips:setVisible(false)
    else
        self._ccbOwner.node_buy:setVisible(false)
        self._ccbOwner.tf_tips:setVisible(true)
    end
	self._ccbOwner.tf_buy:setString("幻 化")

    self._tab = QUIDialogUnionDragonTrainChange.TAB_WEAPON
	self:selectTab()
end

function QUIDialogUnionDragonTrainChange:viewDidAppear()
	QUIDialogUnionDragonTrainChange.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogUnionDragonTrainChange:viewWillDisappear()
	QUIDialogUnionDragonTrainChange.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogUnionDragonTrainChange:initListView()
	self:updateTips()

	table.sort(self._infos, function(a, b)
			if a.isLock ~= b.isLock then
				return a.isLock == false
			end
			return a.dragon.dragon_id < b.dragon.dragon_id
		end)	

	local headIndex = 1
	for i, info in pairs(self._infos) do
		if info.isUse then
			headIndex = i
		end
		info.isSelect = self._selectDragonId == info.dragon.dragon_id
	end

	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        isVertical = false,
	        spaceX = 0,
	        spaceY = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._infos,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
		if headIndex > 3 then
    		self._listView:startScrollToIndex(headIndex, nil, 1000, nil, 170)
    	end
	else
		self._listView:refreshData()
	end
end

function QUIDialogUnionDragonTrainChange:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._infos[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetUnionDragonTrainChange.new()
		item:addEventListener(QUIWidgetUnionDragonTrainChange.EVENT_CLICK_CARD, handler(self, self._clickCard))
		item:addEventListener(QUIWidgetUnionDragonTrainChange.EVENT_CLICK_INFO, handler(self, self._clickInfo))
    	isCacheNode = false
    end
    item:setInfo(itemData, self._dragonType)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_visit", "_onTriggerVisit", nil, true)
    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
   
    return isCacheNode
end

function QUIDialogUnionDragonTrainChange:_clickCard(event)
	if not event.dragonId then
		return
	end

	self._selectDragonId = event.dragonId
	self:initListView()
end

function QUIDialogUnionDragonTrainChange:_clickInfo(event)
	if not event.dragonId then
		return
	end
	local skillInfo = db:getUnionDragonSkillByIdAndLevel(event.dragonId, 1)
	local skillIds = string.split(tostring(skillInfo.dragon_skill), ";")
	local skillId = skillIds[1]
	if skillId then
		app.tip:skillTip(skillId, 1, true)
	else
		app.tip:floatTip("该武魂没有专属技能~")
	end
end

function QUIDialogUnionDragonTrainChange:isDragonActivate(dragonId)
	if dragonId == 0 then
		return true
	end

	if remote.dragon:isDragonActivate(dragonId) then
		return true
	end
	
	local dragonConfig = db:getUnionDragonConfigById(dragonId)
	if dragonConfig.token_cost <= 0 then
		return true
	end

	return false
end

function QUIDialogUnionDragonTrainChange:setDragonList()
	self._infos = {}
	local dragons = db:getUnionDragonListDragonByType(self._dragonType)
	for i, dragon in pairs(dragons) do
		local info = {}
		info.dragon = dragon
		info.isUse = self._dragonId == dragon.dragon_id
		info.isLock = not self:isDragonActivate(dragon.dragon_id)
		table.insert(self._infos, info )
	end
	local info = {}
	info.dragon = {dragon_id = 10000}
	table.insert(self._infos, info)

	self:initListView()
end

function QUIDialogUnionDragonTrainChange:updateTips()
	if self:isDragonActivate(self._selectDragonId) then
		self._ccbOwner.tf_buy:setString("幻 化")
		if not remote.union:checkUnionRight() then
	        self._ccbOwner.tf_tips:setVisible(true)
	        self._ccbOwner.node_buy:setVisible(false)
	    end
	else
		self._ccbOwner.tf_buy:setString("解 锁")
	    self._ccbOwner.node_buy:setVisible(true)
	    self._ccbOwner.tf_tips:setVisible(false)
	end
end

function QUIDialogUnionDragonTrainChange:selectTab()
	self._selectDragonId = 0
	if self._tab == QUIDialogUnionDragonTrainChange.TAB_WEAPON then
    	self._dragonType = remote.dragon.TYPE_WEAPON
		-- self._ccbOwner.btn_weapon:setEnabled(false)
		-- self._ccbOwner.btn_weapon:setHighlighted(true)
		-- self._ccbOwner.btn_warrior:setEnabled(true)
		-- self._ccbOwner.btn_warrior:setHighlighted(false)
		self._tabManager:selected(self._ccbOwner.btn_weapon)
	elseif self._tab == QUIDialogUnionDragonTrainChange.TAB_WARRIOR then
    	self._dragonType = remote.dragon.TYPE_WARRIOR
		-- self._ccbOwner.btn_weapon:setEnabled(true)
		-- self._ccbOwner.btn_weapon:setHighlighted(false)
		-- self._ccbOwner.btn_warrior:setEnabled(false)
		-- self._ccbOwner.btn_warrior:setHighlighted(true)
		self._tabManager:selected(self._ccbOwner.btn_warrior)
	end

	self:setDragonList()
end

function QUIDialogUnionDragonTrainChange:_onTriggerWeapon(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_weapon) == false then return end
    if self._tab == QUIDialogUnionDragonTrainChange.TAB_WEAPON then
        return
    end
	app.sound:playSound("common_menu")
    self._tab = QUIDialogUnionDragonTrainChange.TAB_WEAPON

	self:selectTab()
end

function QUIDialogUnionDragonTrainChange:_onTriggerWarrior(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_warrior) == false then return end
    if self._tab == QUIDialogUnionDragonTrainChange.TAB_WARRIOR then
        return
    end
	app.sound:playSound("common_menu")
    self._tab = QUIDialogUnionDragonTrainChange.TAB_WARRIOR

	self:selectTab()
end

function QUIDialogUnionDragonTrainChange:_onTriggerBuy(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_buy) == false then return end
	local dragonId = self._selectDragonId
	if dragonId == 0 then
		app.tip:floatTip("宗主大人， 您还没有选择武魂哦~")
		return
	elseif dragonId == self._dragonId then
		app.tip:floatTip("宗主大人， 您正在使用该武魂~")
		return
	end

	if self:isDragonActivate(dragonId) then
		-- 未选择过形象
		if self._dragonId == 0 then
		    self:changeUnionAragon(dragonId)
		else
			local dragonInfo = remote.dragon:getDragonInfo()
			local useDragon = db:getUnionDragonConfigById(self._dragonId)
			local curType = useDragon.type
			-- 同类型
			if curType == self._dragonType then
				if q.isSameDayTime(dragonInfo.dragonUpdateAt/1000, 5) then
					local errorCode = db:getErrorCode("CONSORTIA_DRAGON_ID_IN_CD")
        			app.tip:floatTip(errorCode.desc)
        			return
				end
				self:changeUnionAragon(dragonId)
			else
				if q.isSameWeekTime(dragonInfo.typeUpdateAt/1000, 5) then
					local errorCode = db:getErrorCode("CONSORTIA_DRAGON_TYPE_IN_CD")
        			app.tip:floatTip(errorCode.desc)
        			return
				end				

				if q.isSameDayTime(dragonInfo.dragonUpdateAt/1000, 5) then
					local errorCode = db:getErrorCode("CONSORTIA_DRAGON_ID_IN_CD")
        			app.tip:floatTip(errorCode.desc)
        			return
				end

				local token = db:getConfigurationValue("sociaty_dragon_change_type_cost") or 0
			    local content = string.format("##n宗主大人，切换兽武魂或器武魂需要消耗##l%d##n钻石，且##l下周一凌晨5点##n才能再次切换，是否确认？", token ) 
			    app:alert({content = content, title = "系统提示", callback = function(callType)
			            if callType == ALERT_TYPE.CONFIRM then
			            	self:changeUnionAragon(dragonId)
			            end
			        end, isAnimation = true, colorful = true}, true, true)
			end
		end
	else
		local dragonConfig = db:getUnionDragonConfigById(dragonId)
		local token = dragonConfig.token_cost or 0
		if token > 0 then
		    local content = string.format("##n是否消耗##l%d钻石##n，解锁武魂##l%s##n？", token, dragonConfig.dragon_name ) 
		    app:alert({content = content, title = "系统提示", callback = function(callType)
		            if callType == ALERT_TYPE.CONFIRM then
		            	self:activateAragons(dragonId)
		            end
		        end, isAnimation = true, colorful = true}, true, true)
		else
			self:activateAragons(dragonId)
		end
	end
end

function QUIDialogUnionDragonTrainChange:changeUnionAragon(dragonId)
	remote.dragon:consortiaDragonChangeDragonIdRequest(dragonId, function(data)
			app.tip:floatTip("幻化成功！")
			if self:safeCheck() then
            	self:playEffectOut()
            end
        end)
end

function QUIDialogUnionDragonTrainChange:activateAragons(dragonId)
	remote.dragon:consortiaBuyDragonRequest(dragonId, function(data)
			app.tip:floatTip("解锁成功！宗门武魂可以幻化成新的样子了~")
            if self:safeCheck() then
            	self:setDragonList()
            end
        end)
end

-- function QUIDialogUnionDragonTrainChange:_backClickHandler()
--     self:playEffectOut()
-- end

function QUIDialogUnionDragonTrainChange:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_close) == false then return end
    if e then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

return QUIDialogUnionDragonTrainChange