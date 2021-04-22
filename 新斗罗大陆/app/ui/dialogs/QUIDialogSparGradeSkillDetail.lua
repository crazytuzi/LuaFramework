-- @Author: xurui
-- @Date:   2017-04-08 11:35:24
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-29 10:56:21
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSparGradeSkillDetail = class("QUIDialogSparGradeSkillDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetSparSuitSkillCell = import("..widgets.spar.QUIWidgetSparSuitSkillCell")

function QUIDialogSparGradeSkillDetail:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_jinhua.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSparGradeSkillDetail.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._suitInfo = options.suitInfo
		self._minGrade = options.minGrade
	end

	self._skills = {}

end

function QUIDialogSparGradeSkillDetail:viewDidAppear()
	QUIDialogSparGradeSkillDetail.super.viewDidAppear(self)

	self:setTitleInfo()

	self:setSkillInfo()
end

function QUIDialogSparGradeSkillDetail:viewWillDisappear()
	QUIDialogSparGradeSkillDetail.super.viewWillDisappear(self)
end

function QUIDialogSparGradeSkillDetail:viewAnimationInHandler()
	if self._contentListView then
		self._contentListView:resetTouchRect()
	end
end

function QUIDialogSparGradeSkillDetail:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._skills,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._skills})
	end
end

function QUIDialogSparGradeSkillDetail:renderFunHandler(list, index, info)
    local isCacheNode = true
    local skill = self._skills[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSparSuitSkillCell.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(skill, self._minGrade)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSparGradeSkillDetail:setTitleInfo()
	local title = self._suitInfo.suit_name or ""
	self._ccbOwner.frame_tf_title:setString(title)
end

function QUIDialogSparGradeSkillDetail:setSkillInfo()
	local info = QStaticDatabase:sharedDatabase():getSparSuitInfosBySuitId(self._suitInfo.id)

	local data = {}
	local activeSuitId = nil
	for _, value in pairs(info) do
		data[#data+1] = value
		if value.isActive then
			activeSuitId = value.id
		end
	end
	table.sort(data, function(a, b)
			return a.star_min < b.star_min
		end)

	for i = 1, #data do
		local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(i)
		local title = "两块外附魂骨均达到"..level..gardeName.."可激活"
		local unlock = data[i].star_min <= self._minGrade and data[i].id == activeSuitId
		data[i].title = title
		data[i].unlock = unlock
		self._skills[#self._skills+1] = data[i]
	end

	self:initListView()
end

function QUIDialogSparGradeSkillDetail:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSparGradeSkillDetail:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSparGradeSkillDetail:viewAnimationOutHandler()
	self:popSelf()
end

return QUIDialogSparGradeSkillDetail