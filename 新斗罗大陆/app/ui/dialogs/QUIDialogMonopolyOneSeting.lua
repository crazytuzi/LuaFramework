-- @Author: liaoxianbo
-- @Date:   2019-07-22 10:50:09
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-25 11:14:38
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyOneSeting = class("QUIDialogMonopolyOneSeting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMonopolyOneSeting = import("..widgets.QUIWidgetMonopolyOneSeting")
local QListView = import("...views.QListView")

function QUIDialogMonopolyOneSeting:ctor(options)
	local ccbFile = "ccb/Dialog_Monopoly_Secretary.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSet", callback = handler(self, self._onTriggerSet)},
		{ccbCallbackName = "onTriggerBegin", callback = handler(self, self._onTriggerBegin)},		
    }
    QUIDialogMonopolyOneSeting.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._ccbOwner.frame_tf_title:setString("一键投掷")

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    self:initMonopolyOneSetConfig()
end

function QUIDialogMonopolyOneSeting:viewDidAppear()
	QUIDialogMonopolyOneSeting.super.viewDidAppear(self)

	self._monopolyOneEventProxy = cc.EventProxy.new(remote.monopoly)
    self._monopolyOneEventProxy:addEventListener(remote.monopoly.MONOPOLY_ONESET_UPDATE, handler(self, self._settingUpdate))  

    q.autoLayerNode({self._ccbOwner.tf_des1,self._ccbOwner.tf_chaojishai},"x",5)
    q.autoLayerNode({self._ccbOwner.tf_des2,self._ccbOwner.tf_bsyl},"x",5)
    self:refreshView()	
end

function QUIDialogMonopolyOneSeting:viewWillDisappear()
  	QUIDialogMonopolyOneSeting.super.viewWillDisappear(self)

  	self._monopolyOneEventProxy:removeAllEventListeners()
end

function QUIDialogMonopolyOneSeting:_settingUpdate()
	self:initMonopolyOneSetConfig()
end

function QUIDialogMonopolyOneSeting:refreshView()
	local superNum = remote.items:getItemsNumByID(13200000)
	self._ccbOwner.tf_chaojishai:setString(superNum or 0)
	local costItemNum = remote.items:getItemsNumByID(13300005)
	self._ccbOwner.tf_bsyl:setString(costItemNum or 0)
end

function QUIDialogMonopolyOneSeting:initMonopolyOneSetConfig( )
	local setConfigs = remote.monopoly:getMonoplyOneSetTableConfigList()
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = setConfigs[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetMonopolyOneSeting.new()
            		item:addEventListener(QUIWidgetMonopolyOneSeting.EVENT_ONE_SELECT_CLICK, handler(self, self.itemClickHandler))
            		item:addEventListener(QUIWidgetMonopolyOneSeting.EVENT_ONE_SETTING_CLICK, handler(self, self.itemClickHandler))
	                isCacheNode = false
	            end
	            info.item = item
	            info.size = item:getContentSize()

				list:registerBtnHandler(index, "btn_select", "_onTriggerSelect")
            	list:registerBtnHandler(index, "btn_set", "_onTriggerSet")

	            item:setInfo(itemData)

	            return isCacheNode
	        end,
	        enableShadow = true,
	        totalNumber = #setConfigs,
	    }  
    	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:refreshData()	
		-- self._listView:reload({totalNumber = #setConfigs}) 
    end
end

function QUIDialogMonopolyOneSeting:itemClickHandler(event)
	if not event or not event.id then
		return
	end
	QPrintTable(event)
	if event.name == QUIWidgetMonopolyOneSeting.EVENT_ONE_SELECT_CLICK then
		self:monoplySelect(event.id)
	elseif event.name == QUIWidgetMonopolyOneSeting.EVENT_ONE_SETTING_CLICK then
		self:monoplySetting(event.setType)
	end
end

function QUIDialogMonopolyOneSeting:monoplySelect(id)
	local curSetting = remote.monopoly:getOneSetMonopolyId(id)
	local isOpen = curSetting.isOpen or false
	local setting = curSetting
	setting.isOpen = not isOpen
	remote.monopoly:updateMonoplyOneSetting(id, setting)
end

function QUIDialogMonopolyOneSeting:monoplySetting(setType)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonopolySubSet", 
				options = {setId = setType}},{isPopCurrentDialog = false})
end

function QUIDialogMonopolyOneSeting:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMonopolyOneSeting:_onTriggerSet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_set) == false then return end
    app.sound:playSound("common_small")  
    if not app.unlock:checkLock("UNLOCK_BINHUO_YIJIAN", true) then
       return false
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolySeting"})        
    end
end

function QUIDialogMonopolyOneSeting:_onTriggerBegin(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	--  一键投掷中将会自动为您使用遥控骰前往目标（优先使用大小骰）
	local setconfig = remote.monopoly:getOneSetMonopolyId(1)
	if next(setconfig) == nil then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonopolySubSet", 
			options = {setId = remote.monopoly.MONOPOLY_GETAWARS}},{isPopCurrentDialog = false})	
		app.tip:floatTip("您还没有设置解毒大奖呢!")
		return	
	end

	if not app:getUserOperateRecord():checkNewDayCompareWithRecordeTime(DAILY_TIME_TYPE.MONOPOLY_YJZSZ_BUYNUM, 5) then
		if remote.monopoly:getCurDiceCount() == 0 then
			if remote.monopoly:getLastBuyDiceNum() > 0 then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", 
            		options = {cls = "QBuyCountMonopoly"}}, {isPopCurrentDialog = false})
			else
				app.tip:floatTip("您当前没有剩余骰子次数，并且可购买次数也用完了哦")
			end

			return
		end
	end

	app.tip:floatTip("一键投掷中将会自动为您使用遥控骰前往目标（优先使用大小骰）!")
	remote.monopoly:beginOneTriggerGo()
	self:_onTriggerClose()
end

function QUIDialogMonopolyOneSeting:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMonopolyOneSeting
