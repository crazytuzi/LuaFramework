-- @Author: liaoxianbo
-- @Date:   2019-11-20 20:32:59
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-18 17:55:04
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCollegeTrainLevel = class("QUIWidgetCollegeTrainLevel", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

QUIWidgetCollegeTrainLevel.EVENT_CLICK_CHAPTER = "EVENT_CLICK_CHAPTER"

function QUIWidgetCollegeTrainLevel:ctor(options)
	local ccbFile = "ccb/Widget_CollegeTrain_level.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClickChapter", callback = handler(self, self._onTriggerClickChapter)},
    }
    QUIWidgetCollegeTrainLevel.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isLock = false
	self._chapterType = options.chapterType or 1

	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
	self._progressWidth = self._ccbOwner.sp_progress:getContentSize().width
	self._progressStencil = progress:getStencil()

	self._allChapterInfo = remote.collegetrain:getChapterInfoByType(self._chapterType) or {}

	self._myCollegeInfo = remote.collegetrain:getCollegeMyInfo()

	self:setChapterInfo()
end

function QUIWidgetCollegeTrainLevel:onEnter()
end

function QUIWidgetCollegeTrainLevel:onExit()
end

function QUIWidgetCollegeTrainLevel:setChapterInfo()

	local floorRes = QResPath("college_train_png")[self._chapterType]
	QSetDisplayFrameByPath(self._ccbOwner.sp_bg, floorRes)

    local passNum = 0
    local allNum = #self._allChapterInfo
    local getAwardsIds = {}
    if self._myCollegeInfo then
    	getAwardsIds = self._myCollegeInfo.gotAwardId or {}
    end

    for _,chapter in pairs(self._allChapterInfo) do
    	for _, award in pairs(getAwardsIds) do
    		if chapter.id == award then
    			passNum = passNum + 1
    		end
    	end
    end

   	local value = passNum/allNum
   	if value > 1 then
   		value = 1
   	end
    local progressStr = string.format("%d/%d", passNum,allNum)
    self._canGrade = value>=1
    self._progressStencil:setPositionX(value*self._progressWidth - self._progressWidth)
    self._ccbOwner.tf_progress:setString(progressStr)	

    self._unlockKey = nil
    local unlockResPath = QResPath("collegeTrain_unlock_png")[1]
    if self._chapterType == 2 then
    	self._unlockKey = "UNLOCK_COLLEGE_TRAIN_2"
    	unlockResPath = QResPath("collegeTrain_unlock_png")[1]
    elseif self._chapterType == 3 then
    	self._unlockKey = "UNLOCK_COLLEGE_TRAIN_3"
    	unlockResPath = QResPath("collegeTrain_unlock_png")[2]
    end

    if self._unlockKey then
		self._isUnLock = app.unlock:checkLock(self._unlockKey)
		if self._isUnLock == false then
			makeNodeFromNormalToGray(self._ccbOwner.node_box)
			self._ccbOwner.node_spar:setVisible(false)
			QSetDisplaySpriteByPath(self._ccbOwner.shop_is_lock,unlockResPath)
			self._ccbOwner.shop_is_lock:setVisible(true)
		end
	end
end

function QUIWidgetCollegeTrainLevel:_onTriggerClickChapter(event)
	if app.unlock:checkLock(self._unlockKey, true) == false then
		return
	end

	if tonumber(event) == CCControlEventTouchDown then
		self:getView():setScale(1.05)
	elseif tonumber(event) == CCControlEventTouchUpInside then
		self:getView():setScale(1)
		self._scheduler = scheduler.performWithDelayGlobal(function()
				if self.class ~= nil then
					self:dispatchEvent({name = QUIWidgetCollegeTrainLevel.EVENT_CLICK_CHAPTER, chapterType = self._chapterType})
				end
			end, 0)
	else
		self:getView():setScale(1)
	end
end

function QUIWidgetCollegeTrainLevel:getContentSize()

end


return QUIWidgetCollegeTrainLevel
