-- @Author: liaoxianbo
-- @Date:   2019-12-28 15:35:02
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-07 16:55:28
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmMasterInfo = class("QUIDialogGodarmMasterInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGodarmMasterInfo = import("..widgets.QUIWidgetGodarmMasterInfo")
local QListView = import("...views.QListView")

function QUIDialogGodarmMasterInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGodarmMasterInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("神器天赋")

	if options then
		self._godarmId = options.godarmId
	end
	self._ccbOwner.style_s9s_bg:setVisible(false)
    local characterConfig = db:getCharacterByID(self._godarmId)
	if characterConfig then
		self._masterConfigs = {}
		local masterConfigs = db:getGodarmMasterByAptitude(characterConfig.aptitude)
		for _, config in ipairs(masterConfigs) do
			if config.condition > 0 then
				table.insert(self._masterConfigs, config)
			end
		end
		table.sort(self._masterConfigs, function(a, b)
				return a.condition < b.condition
			end)
		self:initListView()
	end
end

function QUIDialogGodarmMasterInfo:viewDidAppear()
	QUIDialogGodarmMasterInfo.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogGodarmMasterInfo:viewWillDisappear()
  	QUIDialogGodarmMasterInfo.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogGodarmMasterInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._masterConfigs,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogGodarmMasterInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local masterConfig = self._masterConfigs[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetGodarmMasterInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setMasterInfo(self._godarmId, masterConfig)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogGodarmMasterInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGodarmMasterInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodarmMasterInfo:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGodarmMasterInfo
