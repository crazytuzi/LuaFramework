--
-- Author: xurui
-- Date: 2015-06-02 19:39:10
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPreview = class("QUIDialogPreview", QUIDialog)

local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTavernOverViewHeroHead = import("..widgets.QUIWidgetTavernOverViewHeroHead")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")

local LINEDISTANCE = 30
local ROWDISTANCE = 33

function QUIDialogPreview:ctor(options)
	local ccbFile = "ccb/Dialog_school.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerHandBook", callback = handler(self, self._onTriggerHandBook)},
	}
	QUIDialogPreview.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:showWithMainPage()

	local btnList = {
		{id = 1, btnName = "防 御", tabType = "1"},
		{id = 2, btnName = "辅 助", tabType = "2"},
		{id = 3, btnName = "物 攻", tabType = "3"},
		{id = 4, btnName = "法 攻", tabType = "4"},
	}
	self._btnList = btnList
	self._ccbOwner.frame_tf_title:setString("武魂殿预览")
	self._genreType = tostring(options.genreType or 1)

	self._index = 1
	self._isMoving = false
    self:_getContentInfo()
	self:_setHeroInfo()
end

function QUIDialogPreview:viewDidAppear()
	QUIDialogPreview.super.viewDidAppear(self)
	self:addBackEvent()
end

function QUIDialogPreview:viewWillDisappear()
	QUIDialogPreview.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogPreview:initBtnListView()
	for i, v in pairs(self._btnList) do
		v.isSelected = self._genreType == v.tabType
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

function QUIDialogPreview:btnItemClickHandler(event)
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

function QUIDialogPreview:setGenreType( int )
	self._genreType = tostring(int)
	self:_setHeroInfo()
end

function QUIDialogPreview:_getContentInfo()
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
			if isHide or character.aptitude > 20 or noSuper and (character.aptitude == 20) then
			else
				filteredtbl[#filteredtbl + 1] = id
			end
		end
		tbl = filteredtbl
		table.sort(tbl, function(a, b)
				return tonumber(a) < tonumber(b) 
			end)
		table.sort(tbl, function(a, b)
				local characherA = db:getCharacterByID(a)
				local characherB = db:getCharacterByID(b)
				return tonumber(characherA.aptitude) > tonumber(characherB.aptitude) 
			end)
		self._genreHeroIds[tostring(value.INDEX)] = tbl
	end
end 

function QUIDialogPreview:_setHeroInfo() 
	self:initBtnListView()
	self:initListView()
	self._ccbOwner.tf_genre_text:setString(self._genreInfo[self._genreType].GENRE_DESCRIBE)
end

function QUIDialogPreview:initListView()
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
	            item:setHeroHead(itemData)
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

function QUIDialogPreview:_clickHerohead(data)
	app.sound:playSound("common_common")
	if self._isMoving == false then 
		app.tip:itemTip(ITEM_TYPE.HERO, data.actorId, true)
	end
end

function QUIDialogPreview:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogPreview:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogPreview:_onTriggerHandBook(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_handBook) == false then return end
	app.sound:playSound("common_small")
	remote.handBook:openDialog()
end

return QUIDialogPreview