-- @Author: liaoxianbo
-- @Date:   2019-11-21 15:58:48
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-11 11:57:23
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainChapterChoose = class("QUIDialogCollegeTrainChapterChoose", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetCollegeTrainChooseButton = import("..widgets.QUIWidgetCollegeTrainChooseButton")
local QUIWidgetCollegeTrainChapterInfo = import("..widgets.QUIWidgetCollegeTrainChapterInfo")
local QListView = import("...views.QListView")

function QUIDialogCollegeTrainChapterChoose:ctor(options)
	local ccbFile = "ccb/Dialog_CollegeTrain_Choose.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerCollegeRank", callback = handler(self, self._onTriggerCollegeRank)},
		{ccbCallbackName = "onTriggerFamousPerson", callback = handler(self, self._onTriggerFamousPerson)},
    }
    QUIDialogCollegeTrainChapterChoose.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(true)
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._chapterType = options.chapterType
    self._curSelectBtnIndex = 1
    self._mapInfo = {}

    q.setButtonEnableShadow(self._ccbOwner.btn_famousPerson)
    q.setButtonEnableShadow(self._ccbOwner.btn_rank)

    self:initBtnInfoData()

    self:initBtnListView()

    self:refreshContent()
    if self._chapterType ~= 3 then
    	self._ccbOwner.node_rank:setVisible(false)
    	self._ccbOwner.node_famousPerson:setVisible(false)
    else
    	self._ccbOwner.node_rank:setVisible(true)
    	self._ccbOwner.node_famousPerson:setVisible(true)
    end
end


function QUIDialogCollegeTrainChapterChoose:viewDidAppear()
	QUIDialogCollegeTrainChapterChoose.super.viewDidAppear(self)
	self:addBackEvent(false)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
end

function QUIDialogCollegeTrainChapterChoose:viewWillDisappear()
  	QUIDialogCollegeTrainChapterChoose.super.viewWillDisappear(self)
	self:removeBackEvent()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
end

function QUIDialogCollegeTrainChapterChoose:initBtnInfoData( )
    self._curSelectBtnIndex = remote.collegetrain:getMinChooseChapterBtnIndex(self._chapterType) 
    print("战斗前选择的章节=",self._curSelectBtnIndex,math.floor(4.9))
    self._allChapterInfo = remote.collegetrain:getChapterInfoByType(self._chapterType) or {}
    self._mapInfo = {}
    for _,v in pairs(self._allChapterInfo) do
    	local mapInfo = {}
    	local btnMapInfo = db:getDungeonConfigByIntID(v.dungeon_config)
    	if btnMapInfo then
	    	mapInfo.id = v.id
	    	mapInfo.type = v.type
	    	mapInfo.animationScale = v.animationScale
	    	mapInfo.condition = v.condition
	    	mapInfo.reward = v.reward
	    	mapInfo.btnMapInfo = btnMapInfo
	    	mapInfo.finsh = v.finsh or false
            mapInfo.firstUserNickname = v.firstUserNickname
            mapInfo.firstUserPassTime = v.firstUserPassTime
            mapInfo.myPassTime = v.myPassTime	
            mapInfo.isAllEnv = v.isAllEnv    	
	    	table.insert(self._mapInfo,mapInfo)
	    end
    end
end

function QUIDialogCollegeTrainChapterChoose:exitFromBattleHandler(event)
	print("战斗结束------")
	self:initBtnInfoData()
    self:initBtnListView()
    self:refreshContent()	
end


function QUIDialogCollegeTrainChapterChoose:initBtnListView( )
    local clickBtnItemHandler = handler(self, self.onClickBtnItem)

    if not self._btnListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._mapInfo[index]
	            if not item then
	                item = QUIWidgetCollegeTrainChooseButton.new()
	                isCacheNode = false
	            end
	            item:setBtnInfo(data)
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerBtnHandler(index, "btn_click", clickBtnItemHandler)
	            
	            if self._curSelectBtnIndex == index then
	                item:setSelect(true)
	            else
	                item:setSelect(false)
	            end
	            return isCacheNode
	        end,
	        headIndex = self._curSelectBtnIndex,
	        enableShadow = false,
	        ignoreCanDrag = true,
	        totalNumber = #self._mapInfo,
	        spaceY = 6,

	    }  
	    self._btnListView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	    self._btnListView:startScrollToIndex(self._curSelectBtnIndex, true, 20)
	 else
	 	self._btnListView:reload({totalNumber = #self._mapInfo,headIndex = self._curSelectBtnIndex})
	 end
end

function QUIDialogCollegeTrainChapterChoose:onClickBtnItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()

    if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectBtnIndex)
        if oldItem then
            oldItem:setSelect(false)
        end
    end

    local item = listView:getItemByIndex(touchIndex)
    if item then
        item:setSelect(true)
    end

    if self._curSelectBtnIndex ~= touchIndex then
        self._curSelectBtnIndex = touchIndex
        self:refreshContent()
    end
end

function QUIDialogCollegeTrainChapterChoose:refreshContent( )
    local selectItemInfo = self._btnListView:getItemByIndex(self._curSelectBtnIndex)
    if selectItemInfo == nil then return end
    if self._chapterInfoWidget ~= nil then
    	self._ccbOwner.clientNode:removeAllChildren()
    	self._chapterInfoWidget = nil
    end

	
	self._chapterInfoWidget = QUIWidgetCollegeTrainChapterInfo.new()
	self._ccbOwner.clientNode:addChild(self._chapterInfoWidget)

    local chapterInfo = selectItemInfo:getChapterInfo()
	self._chapterInfoWidget:updateInfo(chapterInfo)
	
	remote.collegetrain:initChapterHeroInfo(chapterInfo.id)
	remote.collegetrain:setSelectBtnIndex(self._curSelectBtnIndex)

	self._initRank = "collegeTrainGroupRealTime"..chapterInfo.id
	self._selectChapterId = chapterInfo.id
end

function QUIDialogCollegeTrainChapterChoose:_onTriggerCollegeRank( )
	-- local initRank = "collegeTrain"
	-- if self._btnListView and  self._curSelectBtnIndex > 0 then
	-- 	local curSelectItem = self._btnListView:getItemByIndex(self._curSelectBtnIndex)
	-- 	if curSelectItem then
	-- 		local chapterInfo = curSelectItem:getChapterInfo()
	-- 		initRank = "collegeTrainGroupRealTime"..chapterInfo.id
	-- 	end
	-- end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = self._initRank}})
end

function QUIDialogCollegeTrainChapterChoose:_onTriggerFamousPerson( )
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCollegeTrainFamousPerson",
    	options = {chapterId = self._selectChapterId}})	
end

function QUIDialogCollegeTrainChapterChoose:onTriggerBackHandler()
    self:_onTriggerClose()
end

function QUIDialogCollegeTrainChapterChoose:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainChapterChoose:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainChapterChoose
