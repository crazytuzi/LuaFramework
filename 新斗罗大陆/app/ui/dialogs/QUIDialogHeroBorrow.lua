--
-- Author: qinsiyang
-- Date: 2020-03-16 
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroBorrow = class("QUIDialogHeroBorrow", QUIDialog)

local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTavernOverViewHeroHead = import("..widgets.QUIWidgetTavernOverViewHeroHead")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")

local LINEDISTANCE = 30
local ROWDISTANCE = 33

function QUIDialogHeroBorrow:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBorrow.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBorrow", callback = handler(self, self._onTriggerBorrow)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogHeroBorrow.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local btnList = {
		{id = 1, btnName = "防 御", tabType = "1"},
		{id = 2, btnName = "辅 助", tabType = "2"},
		{id = 3, btnName = "物 攻", tabType = "3"},
		{id = 4, btnName = "法 攻", tabType = "4"},
	}
	self._btnList = btnList
	self._ccbOwner.frame_tf_title:setString("魂师借用")
	self._genreType = tostring(remote.offerreward:getMyBorrowGenreType())
    q.setButtonEnableShadow(self._ccbOwner.btn_borrow)

	self._index = 1
	self._isMoving = false
    self:_getContentInfo()
	self:_setHeroInfo()
	self:_updateRedTips()
end

function QUIDialogHeroBorrow:_updateRedTips()
	local count = remote.offerreward:getBorrowInfosCountNum()
	self._ccbOwner.sp_borrow_tips:setVisible(count > 0)
end

function QUIDialogHeroBorrow:viewDidAppear()
	QUIDialogHeroBorrow.super.viewDidAppear(self)
	-- self:addBackEvent()
end

function QUIDialogHeroBorrow:viewWillDisappear()
	QUIDialogHeroBorrow.super.viewWillDisappear(self)
	-- self:removeBackEvent()
end

function QUIDialogHeroBorrow:viewAnimationInHandler()
	--代码
	self:initBtnListView()
	self:initListView()
end

function QUIDialogHeroBorrow:initBtnListView()
	for i, v in pairs(self._btnList) do
		v.isSelected = self._genreType == v.tabType
	end

	if self._btnlistViewLayout then
		self._btnlistViewLayout:setContentSize(self._ccbOwner.sheet_menu:getContentSize())
		self._btnlistViewLayout:resetTouchRect()
	end

	-- body
	if not self._btnlistViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._btnList[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetSelectBtn.new()
            		item:addEventListener(QUIWidgetSelectBtn.EVENT_CLICK, handler(self, self.btnItemClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	            return isCacheNode
	        end,
	        curOriginOffset = 5,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 5,
	        totalNumber = #self._btnList,
		}
		self._btnlistViewLayout = QListView.new(self._ccbOwner.sheet_menu,cfg)
	else
		self._btnlistViewLayout:reload({totalNumber = #self._btnList})
	end
end

function QUIDialogHeroBorrow:btnItemClickHandler(event)
	local info = event.info or {}
	local tabType = "1"
	for i, v in pairs(self._btnList) do
		if v.id == info.id then
			tabType = v.tabType
			break
		end
	end
	self._genreType = tabType
	self:_setHeroInfo()
end

function QUIDialogHeroBorrow:setGenreType( int )
	self._genreType = tostring(int)
	self:_setHeroInfo()
end

function QUIDialogHeroBorrow:_getContentInfo()
	self._genreInfo = QStaticDatabase:sharedDatabase():getGenreInfo()
	local noSuper = self:getOptions().noSuperAndAPlusHero
	self._genreHeroIds = {}
	for _, value in pairs(self._genreInfo) do
		local tbl = string.split(value.ID, ";")
		local filteredtbl = {}
		for _, id in ipairs(tbl) do
			-- 过滤掉S级魂师，以及暂未开启的魂师
			-- 是否屏蔽道具（主要是碎片）
			local isHide = db:checkHeroShields(id)
			local character = db:getCharacterByID(id)
			if isHide 
				-- or character.aptitude > 20 or noSuper and (character.aptitude == 20) 
				then
			else
				filteredtbl[#filteredtbl + 1] = id
			end
		end
		tbl = filteredtbl
		table.sort(tbl, function(a, b)
				local characherA = db:getCharacterByID(a)
				local characherB = db:getCharacterByID(b)
				if tonumber(characherA.aptitude) ~= tonumber(characherB.aptitude)  then
					return tonumber(characherA.aptitude) > tonumber(characherB.aptitude) 
				else
					return tonumber(a) < tonumber(b) 
				end
			end)
		self._genreHeroIds[tostring(value.INDEX)] = tbl
	end
end 

function QUIDialogHeroBorrow:_setHeroInfo() 
	self:initBtnListView()
	self:initListView()
	self._ccbOwner.tf_genre_text:setString(self._genreInfo[self._genreType].GENRE_DESCRIBE)
end

function QUIDialogHeroBorrow:initListView()

	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_content:getContentSize())
		self._listViewLayout:resetTouchRect()
	end

	self._ids = self._genreHeroIds[self._genreType]
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._ids[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetTavernOverViewHeroHead.new()
            		item:addEventListener(QUIWidgetTavernOverViewHeroHead.OVERVIEW_HEROHEAD_CLICK, handler(self, self._clickHerohead))
	            	isCacheNode = false
	            end
	            item:setHeroHeadNotMine(itemData)
	            item:initGLLayer()
	            
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "_onTriggerClick")

	            return isCacheNode
	        end,
	        multiItems = 5,
	        contentOffsetX = 4,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceX = 20,
	      	spaceY = 10,
	        totalNumber = #self._ids,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._ids})
	end
end

function QUIDialogHeroBorrow:_clickHerohead(data)
	app.sound:playSound("common_common")
	if self._isMoving == false then 
		remote.offerreward:offerRewardGetTargetHeroRankingRequest(data.actorId,function(  )
			remote.offerreward:setMyBorrowGenreType(tonumber(self._genreType))
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroBorrowSituation" ,
				options = {actorId = data.actorId }, {isPopCurrentDialog = true}})
		end,function(  )
			-- body
		end)
	end
end

function QUIDialogHeroBorrow:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogHeroBorrow:_onTriggerClose()
	remote.offerreward:setMyBorrowGenreType(1)
	self:playEffectOut()
end

function QUIDialogHeroBorrow:_onTriggerBorrow(event)
	app.sound:playSound("common_small")
	remote.offerreward:setMyBorrowGenreType(1)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroBorrowOperation"
		, {isPopCurrentDialog = true}})
end

return QUIDialogHeroBorrow