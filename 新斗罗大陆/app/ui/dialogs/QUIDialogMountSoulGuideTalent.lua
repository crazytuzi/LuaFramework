-- @Author: zhouxiaoshu
-- @Date:   2019-11-02 11:23:15
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-02 11:30:18

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountSoulGuideTalent = class("QUIDialogMountSoulGuideTalent", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetMountSkillAndTalent = import("..widgets.mount.QUIWidgetMountSkillAndTalent")

function QUIDialogMountSoulGuideTalent:ctor(options)
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMountSoulGuideTalent.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("科技天赋")
	self._soulGuideLevel = remote.user:getPropForKey("soulGuideLevel") or 0

	self._talents = {}
	local configs = db:getStaticByName("soul_arms_science_tianfu")
	for i, v in pairs(configs) do
		if v.condition > 0 then
			table.insert(self._talents, v)
		end
	end
    table.sort(self._talents, function(a, b)
        return a.condition < b.condition
    end)
	self:initListView()
end

function QUIDialogMountSoulGuideTalent:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._talents,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._talents})
	end
end

function QUIDialogMountSoulGuideTalent:renderFunHandler(list, index, info)
    local isCacheNode = true
    local talent = self._talents[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMountSkillAndTalent.new()
        isCacheNode = false
    end

    info.item = item
	item:setSoulGuideTalentInfo(talent, talent.condition <= self._soulGuideLevel)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogMountSoulGuideTalent:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMountSoulGuideTalent:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogMountSoulGuideTalent