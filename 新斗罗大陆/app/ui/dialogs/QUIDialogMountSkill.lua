local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountSkill = class("QUIDialogMountSkill", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetMountSkillAndTalent = import("..widgets.mount.QUIWidgetMountSkillAndTalent")

function QUIDialogMountSkill:ctor(options)
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMountSkill.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._mountId = options.mountId
	self._grade = options.grade
	self._isDress = options.isDress
	self._dressGrade = options.dressGrade
	self._isMockBattle = options.isMockbattle or false

	local mountInfo = remote.mount:getMountById(self._mountId)
	if mountInfo == nil or next(mountInfo) == nil then
		mountInfo = {zuoqiId = self._mountId, grade = -1}
	end
	if self._isMockBattle then
		mountInfo = remote.mockbattle:getCardInfoByIndex(options.id or 0)
	end

	self._curGrade = mountInfo.grade
	if self._isDress then
		self._curGrade = self._dressGrade
    	self._ccbOwner.frame_tf_title:setString("配件技能")
	else
    	self._ccbOwner.frame_tf_title:setString("暗器效果")
    	if self._grade ~= nil then
			self._curGrade = self._grade
		end
	end
	local gradesConfig = db:getGradeByHeroId(self._mountId) or {}
	self._grades = {}
	if self._isDress then
		for _,v in pairs(gradesConfig) do
			if v.grade_level <= 4 then --目前只有S配件只有5星，只显示5星
				table.insert(self._grades,v)
			end
		end
	else
		self._grades = gradesConfig
	end
	self:initListView()
end

function QUIDialogMountSkill:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._grades,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._grades})
	end
end

function QUIDialogMountSkill:renderFunHandler(list, index, info)
    local isCacheNode = true
    local grade = self._grades[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMountSkillAndTalent.new()
        isCacheNode = false
    end
    info.item = item
	item:setGradeInfo(grade, grade.grade_level <= self._curGrade, self._isDress)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogMountSkill:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMountSkill:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogMountSkill