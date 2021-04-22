
-- @Author: liaoxianbo
-- @Date:   2020-02-27 14:59:02
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-04 18:38:31
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritFireProperty = class("QUIDialogSoulSpiritFireProperty", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSoulSpiritFirePropety = import("..widgets.QUIWidgetSoulSpiritFirePropety")
local QListView = import("...views.QListView")

function QUIDialogSoulSpiritFireProperty:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulSpiritFireProperty.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._treeType = options.treeType or 1
    self._bigPoint = options.bigPoint or 1
    self._childPoint = options.childPoint or 0

    self._allChildSoulFires = {}
    self._ccbOwner.frame_tf_title:setString("魂火属性")

    self._allChildSoulFires = db:getAllChildSoulFireInfo(self._treeType,self._bigPoint)

	table.sort(self._allChildSoulFires, function(a, b)
			if a.cell_id and b.cell_id then
				return a.cell_id < b.cell_id
			end
		end)

	self:initListView()

end

function QUIDialogSoulSpiritFireProperty:viewDidAppear()
	QUIDialogSoulSpiritFireProperty.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogSoulSpiritFireProperty:viewWillDisappear()
  	QUIDialogSoulSpiritFireProperty.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogSoulSpiritFireProperty:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._allChildSoulFires,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogSoulSpiritFireProperty:renderFunHandler(list, index, info)
    local isCacheNode = true
    local masterConfig = self._allChildSoulFires[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulSpiritFirePropety.new()
        isCacheNode = false
    end
    info.item = item
	item:setSoulFireInfo(self._childPoint, masterConfig)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulSpiritFireProperty:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulSpiritFireProperty:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulSpiritFireProperty:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulSpiritFireProperty

