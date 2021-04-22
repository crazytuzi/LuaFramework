-- @Author: liaoxianbo
-- @Date:   2019-04-30 17:55:09
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-08-05 14:52:47
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolySeting = class("QUIDialogMonopolySeting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMonopolySeting = import("..widgets.QUIWidgetMonopolySeting")
local QListView = import("...views.QListView")

function QUIDialogMonopolySeting:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMonopolySeting.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._ccbOwner.frame_tf_title:setString("快捷设置")

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    self:initMonopolySetConfig()
end

function QUIDialogMonopolySeting:viewDidAppear()
	QUIDialogMonopolySeting.super.viewDidAppear(self)

	self._monopolyEventProxy = cc.EventProxy.new(remote.monopoly)
    self._monopolyEventProxy:addEventListener(remote.monopoly.MONOPOLY_SET_UPDATE, handler(self, self._settingUpdate))     

end

function QUIDialogMonopolySeting:_settingUpdate()
	self:initMonopolySetConfig()
end

function QUIDialogMonopolySeting:viewWillDisappear()
  	QUIDialogMonopolySeting.super.viewWillDisappear(self)
  	self._monopolyEventProxy:removeAllEventListeners()
end

function QUIDialogMonopolySeting:initMonopolySetConfig()
	local setConfigs = remote.monopoly.setTableConfigList
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = setConfigs[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetMonopolySeting.new()
            		item:addEventListener(QUIWidgetMonopolySeting.EVENT_SELECT_CLICK, handler(self, self.itemClickHandler))
            		item:addEventListener(QUIWidgetMonopolySeting.EVENT_SETTING_CLICK, handler(self, self.itemClickHandler))
	                isCacheNode = false
	            end
	            info.item = item
	            info.size = item:getContentSize()

				list:registerBtnHandler(index, "btn_select", "_onTriggerSelect")
            	list:registerBtnHandler(index, "btn_set", "_onTriggerSet")

	            item:setInfo(itemData)

	            return isCacheNode
	        end,
	        curOriginOffset = 12,
	        enableShadow = true,
	        totalNumber = #setConfigs,
	    }  
    	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:refreshData()	
    end
end

function QUIDialogMonopolySeting:itemClickHandler(event)
	if not event or not event.id then
		return
	end
	if event.name == QUIWidgetMonopolySeting.EVENT_SELECT_CLICK then
		self:monoplySelect(event.id)
	elseif event.name == QUIWidgetMonopolySeting.EVENT_SETTING_CLICK then
		self:monoplySetting(event.id)
	end
end

function QUIDialogMonopolySeting:monoplySelect(id)
	local curSetting = remote.monopoly:getSelectByMonopolyId(id) 
	local isOpen = curSetting.isOpen or false
	local setting = {}
	setting.isOpen = not isOpen
	remote.monopoly:updateMonoplySetting(id, setting)

	local setConfig = remote.monopoly:getSettingByMonoplyId(id)
	local oneSetting = {}
	if id == remote.monopoly.ZIDONG_OPEN then
		if setting.isOpen then
			oneSetting.openNum = curSetting.openNum
		else
			oneSetting.openNum = 1
		end
		remote.monopoly:updateMonoplyOneSetting(setConfig.oneSetId,oneSetting)
	elseif id == remote.monopoly.ZIDONG_CAIQUAN then
		if setting.isOpen then
			oneSetting.caiQuanNum = curSetting.caiQuanNum
		else
			oneSetting.caiQuanNum = 1
		end
		remote.monopoly:updateMonoplyOneSetting(setConfig.oneSetId,oneSetting)
	end
end

function QUIDialogMonopolySeting:monoplySetting(id)
	-- local setConfig = remote.monopoly:getSettingConfigById(id)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonopolySubSet", 
				options = {setId = id}},{isPopCurrentDialog = false})
end

function QUIDialogMonopolySeting:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogMonopolySeting:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMonopolySeting:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMonopolySeting
