local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonTotemTalent = class("QUIDialogDragonTotemTalent", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetDragonTotemTalent = import("..widgets.totem.QUIWidgetDragonTotemTalent")
local QListView = import("...views.QListView")

function QUIDialogDragonTotemTalent:ctor(options)
	local ccbFile = "ccb/Dialog_Weever_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogDragonTotemTalent.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	self._ccbOwner.frame_tf_title:setString("武魂天赋")

	self._talents = remote.dragonTotem:getDragonTotemTalent()
	local totemInfo = remote.dragonTotem:getTotemInfo()
	self._gradeLevel = 1
	if totemInfo ~= nil then
		self._gradeLevel = totemInfo.grade or 1
	end
	self:initListView()
end

function QUIDialogDragonTotemTalent:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._talents,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._talents})
	end
end

function QUIDialogDragonTotemTalent:renderFunHandler(list, index, info)
    local isCacheNode = true
    local talent = self._talents[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetDragonTotemTalent.new()
        isCacheNode = false
    end

    info.item = item
	item:setInfo(talent, talent.condition <= self._gradeLevel)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogDragonTotemTalent:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogDragonTotemTalent:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogDragonTotemTalent