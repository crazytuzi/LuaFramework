-- @Author: liaoxianbo
-- @Date:   2020-08-06 15:37:37
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-14 17:00:44
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreRecord = class("QUIDialogMazeExploreRecord", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMazeExploreRecordCell = import("..widgets.QUIWidgetMazeExploreRecordCell")
local QListView = import("...views.QListView")

function QUIDialogMazeExploreRecord:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMazeExploreRecord.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("探索记录")

	self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()

	self._ccbOwner.style_s9s_bg:setVisible(false)

	self._mazeExploreRecord = self._mazeExploreDataHandle:getExploredTextGrids() or {}
	table.sort(self._mazeExploreRecord, function(a,b)
		return tonumber(a) < tonumber(b)
	end)
	QPrintTable(self._mazeExploreRecord)
	self:initListView()
end

function QUIDialogMazeExploreRecord:viewDidAppear()
	QUIDialogMazeExploreRecord.super.viewDidAppear(self)
end

function QUIDialogMazeExploreRecord:viewWillDisappear()
  	QUIDialogMazeExploreRecord.super.viewWillDisappear(self)

end

function QUIDialogMazeExploreRecord:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._mazeExploreRecord,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogMazeExploreRecord:renderFunHandler(list, index, info)
    local isCacheNode = true
    local recordID = self._mazeExploreRecord[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMazeExploreRecordCell.new()
        isCacheNode = false
    end
    local recordConfig = self._mazeExploreDataHandle:getMazeExploreRecordConfigById(recordID)
    info.item = item
	item:setMazeExploreRecordInfo(recordConfig)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogMazeExploreRecord:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMazeExploreRecord:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreRecord:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMazeExploreRecord
