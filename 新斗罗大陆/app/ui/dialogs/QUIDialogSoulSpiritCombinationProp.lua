-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 14:44:00
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-21 11:19:51

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritCombinationProp = class("QUIDialogSoulSpiritCombinationProp", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetSoulSpiritCombinationProp = import("..widgets.QUIWidgetSoulSpiritCombinationProp")

function QUIDialogSoulSpiritCombinationProp:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSoulSpiritCombinationProp.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("图鉴属性")
	
	local combinationInfos = db:getStaticByName("soul_tujian")
	self._combinationInfo = combinationInfos[tostring(options.combinationId)]
	self._grade = options.grade or 0
	self:initListView()
end

function QUIDialogSoulSpiritCombinationProp:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._combinationInfo,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._combinationInfo})
	end
end

function QUIDialogSoulSpiritCombinationProp:renderFunHandler(list, index, info)
    local isCacheNode = true
    local combinationInfo = self._combinationInfo[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulSpiritCombinationProp.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(combinationInfo, self._grade)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulSpiritCombinationProp:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulSpiritCombinationProp:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogSoulSpiritCombinationProp
