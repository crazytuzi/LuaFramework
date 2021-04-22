-- @Author: xurui
-- @Date:   2016-08-27 16:20:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-25 10:38:34
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPersonalSetting = class("QUIDialogPersonalSetting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetChooseShowHero = import("..widgets.QUIWidgetChooseShowHero")
local QUIWidgetShowAvatarInfo = import("..widgets.QUIWidgetShowAvatarInfo")
local QUIWidgetShowFrameInfo = import("..widgets.QUIWidgetShowFrameInfo")
local QUIWidgetShowTitleInfo = import("..widgets.QUIWidgetShowTitleInfo")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")
local QListView = import("...views.QListView")

QUIDialogPersonalSetting.TAB_SHOW_HERO = "TAB_SHOW_HERO"
QUIDialogPersonalSetting.TAB_HEAD_PIC = "TAB_HEAD_PIC"
QUIDialogPersonalSetting.TAB_FRAME = "TAB_FRAME"
QUIDialogPersonalSetting.TAB_TITLE = "TAB_TITLE"
 
function QUIDialogPersonalSetting:ctor(options)
	local ccbFile = "ccb/Dialog_Rongyao.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerUse", callback = handler(self, self._onTriggerUse)},
	}
	QUIDialogPersonalSetting.super.ctor(self, ccbFile, callBacks, options)

	local btnList = {
		{id = 1, btnName = "展示魂师", btnType = QUIDialogPersonalSetting.TAB_SHOW_HERO, isOpen = true},
		{id = 2, btnName = "头  像", btnType = QUIDialogPersonalSetting.TAB_HEAD_PIC, isOpen = true},
		{id = 3, btnName = "头像框", btnType = QUIDialogPersonalSetting.TAB_FRAME, isOpen = true},
		{id = 4, btnName = "称  号", btnType = QUIDialogPersonalSetting.TAB_TITLE, isOpen = true},
	}
	self._btnList = {}
	for i, btn in pairs(btnList) do
		if btn.isOpen then
			table.insert(self._btnList, btn)
		end
	end

	self._ccbOwner.frame_tf_title:setString("个性设置")

	self._selectTab = options.tab or QUIDialogPersonalSetting.TAB_HEAD_PIC
	self._selectId = options.selectId or 0
	self._lastTab = self._selectTab
	self._showHeroActorId = remote.user.defaultActorId
	self._showHeroSkinId = remote.user.defaultSkinId

	self._avatarId, self._useFrameId = remote.headProp:getAvatarFrameId(remote.user.avatar)

	if self._avatarId == nil or self._avatarId == -1 then
		self._avatarId = db:getDefaultAvatar().id
	end
	if self._useFrameId == nil or self._useFrameId == 0 then
		self._useFrameId = db:getDefaultFrame().id
	end

	self._ccbOwner.tf_use_tips:setVisible(false)
	self._ccbOwner.node_btn_use:setVisible(false)
	self._ccbOwner.tf_lock_tips:setVisible(false)

	self._useTitle = remote.user.title
	self:initBtnListView()
end

function QUIDialogPersonalSetting:viewDidAppear()
	QUIDialogPersonalSetting.super.viewDidAppear(self)
  	self:addBackEvent(true)
	
   	self._headPropProxy = cc.EventProxy.new(remote.headProp)
	self._headPropProxy:addEventListener(remote.headProp.AVATAR_CHANGE, handler(self, self._avatarChange))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.SHOW_HERO_CHANGE_SUCCESS, handler(self, self._showHeroChange))

	self:initScrollView()

	local callback = function()
		self:setDefaultTitle()
		self:selectTabs()
	end
	remote.headProp:requestHeadList(callback)
end

function QUIDialogPersonalSetting:viewWillDisappear()
	QUIDialogPersonalSetting.super.viewWillDisappear(self)
	if self._headPropProxy then
		self._headPropProxy:removeAllEventListeners()
	end
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.SHOW_HERO_CHANGE_SUCCESS, handler(self, self._showHeroChange))
	self:removeBackEvent()
end

function QUIDialogPersonalSetting:initBtnListView()
	for i, v in pairs(self._btnList) do
		v.isSelected = self._selectTab == v.btnType
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

function QUIDialogPersonalSetting:initScrollView()
	local sheetSize = self._ccbOwner.sheet_layout:getContentSize()
	local clientSize = self._ccbOwner.client_layout:getContentSize()
	self._clientWidth = clientSize.width
	
	self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 2, sensitiveDistance = 10, nodeAR = ccp(0.5, 0.5)})
	self._scrollView:setVerticalBounce(true)
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))

    self._scrollView1 = QScrollView.new(self._ccbOwner.node_client, clientSize, {bufferMode = 1, sensitiveDistance = 10, endGradient = ccc4(41, 23, 8, 100)})
	self._scrollView1:setVerticalBounce(true)
end

function QUIDialogPersonalSetting:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogPersonalSetting:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogPersonalSetting:setDefaultTitle()
	if self._useTitle ~= 0 then
		return
	end
	local titles = remote.headProp:getTitleInfo()
	for i = 1, #titles do
		-- 已解锁的魂力试炼称号id,只有一个当前的
		if titles[i].function_type == remote.headProp.TITLE_TRIAL_TYPE then
			local idTble = string.split(titles[i].condition, ",")
			local min = tonumber(idTble[1])
			local max = tonumber(idTble[2])
			if min <= remote.user.soulTrial and remote.user.soulTrial <= max then
		    	self._useTitle = titles[i].id
		    	break
		    end
		end
	end
end

function QUIDialogPersonalSetting:selectTabs()
	self:getOptions().tab = self._selectTab 
	self._selectPosition = self:getOptions().selectPosition or 1

	self._scrollView:clear()
	if self._selectTab == QUIDialogPersonalSetting.TAB_SHOW_HERO then
		self._showHeroBox = {}
		self:setShowHeroInfo()
	elseif self._selectTab == QUIDialogPersonalSetting.TAB_FRAME then
		self._frameBox = {}
		self:setFrameInfo()
	elseif self._selectTab == QUIDialogPersonalSetting.TAB_HEAD_PIC then
		self._headPicBox = {}
		self:setHeadPicInfo()
	elseif self._selectTab == QUIDialogPersonalSetting.TAB_TITLE then
		self._titleBox = {}
		self:setTitleInfo()
	end
	self:initBtnListView()
end 

function QUIDialogPersonalSetting:getShowHeroSkinByActorId(actorId)
	local skinDataList = remote.heroSkin:getHeroSkinConfigListById(actorId,true)
	-- QPrintTable(skinDataList)
	table.sort( skinDataList, function(a, b) 
			if a.is_nature ~= b.is_nature then
				return a.is_nature == 0
			else
				return a.skins_id > b.skins_id 
			end
		end )
	return skinDataList
end

function QUIDialogPersonalSetting:getHerosId()
	local heros = {}
	local transformHeros = {}
	local heroIds = remote.herosUtil:getShowHerosKey()
	table.sort(heroIds, function(a, b)
			local characterA = db:getCharacterByID(a)
			local characterB = db:getCharacterByID(b)

			local haveA = remote.herosUtil:checkHeroHavePast(a)
			local haveB = remote.herosUtil:checkHeroHavePast(b)
			if characterA.aptitude ~= characterB.aptitude then
				return characterA.aptitude > characterB.aptitude
			else
				if haveA ~= haveB then
					return haveA
				else
					return a < b
				end
			end
		end)	
	for key,heroId in pairs(heroIds) do
		local characterConfig = db:getCharacterByID(heroId)
		table.insert(heros,{actorId = heroId,isTransform = false})
		if characterConfig and characterConfig.transform_skins then
			local skins = string.split(characterConfig.transform_skins, ";") or {}
			for _,v in pairs(skins) do
				local tbl = string.split(v, "^")
				local actorId = tonumber(tbl[1])
				local skinId = tonumber(tbl[2])
				if skinId == 0 and remote.herosUtil:checkHeroHavePast(heroId) then --0表示默认变身皮肤，必须拥有当前魂师才显示
					transformHeros[heroId] = {actorId = actorId,isTransform = true,lockHeroId = heroId,lockskinId = 0}
					-- table.insert(transformHeros,{actorId = actorId,isTransform = true,lockHeroId = heroId,lockskinId = 0})
				elseif remote.heroSkin:checkSkinIsActivation(heroId,skinId) then
					transformHeros[skinId] = {actorId = actorId,isTransform = true,lockHeroId = 0,lockskinId = skinId}
					-- table.insert(transformHeros,{actorId = actorId,isTransform = true,lockHeroId = 0,lockskinId = skinId})
				end
			end
		end
	end

	return heros,transformHeros
end

function QUIDialogPersonalSetting:setShowHeroInfo()
	local selectId = self._showHeroActorId
	local selectSkinId = self._showHeroSkinId

	if self._selectId ~= 0 then
		selectId = self._selectId
		self._selectId = 0
	end
	-- local heros = remote.herosUtil:getShowHerosKey()
	local heros,transformHeros = self:getHerosId()
	local row = 0
	local line = 0
	local rowDistance = 30
	local lineDistance = -45
	local offsetX = 20
	local offsetY = -20
	local maxRowNum = 3
	local selectPositionY = 0
	local titleHeight = 0
	local selectHeroIdPos = 0
	local curIsTransform = false

	local itemContentSize, buffer = self._scrollView:setCacheNumber(18, "widgets.QUIWidgetSettingHeroHead")
	for k, v in ipairs(buffer) do
		table.insert(self._showHeroBox, v)
		v:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickEvent))
	end

	local aptitude = 0
	local count = 1
	local addScrollViewBox = function(currentAptitude,actorId,skinInfo,isTransform)
		local addTitle = false
		local isSkin = true
		if aptitude ~= currentAptitude then
			aptitude = currentAptitude
			addTitle = true
			titleHeight = titleHeight + 50
			if row ~= 0 then
				row = 0
				line = line == 0 and 1 or line + 1
			end
		end
		local skinId = 0
		if skinInfo then
			skinId = skinInfo.skins_id
			if skinInfo.is_nature == 0 then
				isSkin = false
			end
		else
			isSkin = false
		end

		local positionX = itemContentSize.width/2 + (itemContentSize.width + rowDistance) * row + offsetX
		local positionY = itemContentSize.height/2 + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
		self._scrollView:addItemBox(positionX, -positionY, {actorId = actorId, skinId = skinId, isSkin = isSkin,isTransform = isTransform, index = count, addTitle = addTitle})

		if selectId == actorId and selectSkinId == skinId then
			self._selectPosition = count
			curIsTransform = isTransform
			if count > 2*maxRowNum then
				selectPositionY = positionY - itemContentSize.height * 3/2
			end
		end

		row = row + 1
		if row >= maxRowNum then
			row = 0
			line = line + 1
		end
		count = count + 1
	end

	for i,heroInfo in pairs(heros) do 
		local skins = self:getShowHeroSkinByActorId(heroInfo.actorId)
		local characterConfig = db:getCharacterByID(heroInfo.actorId)
		local currentAptitude = characterConfig.aptitude
		if q.isEmpty(skins) then
			addScrollViewBox(currentAptitude,heroInfo.actorId,nil,false)
		else
			for _,skinInfo in pairs(skins) do
				addScrollViewBox(currentAptitude,heroInfo.actorId,skinInfo)
				if skinInfo.is_nature == 0 and transformHeros[heroInfo.actorId] then
					addScrollViewBox(currentAptitude,transformHeros[heroInfo.actorId].actorId,nil,transformHeros[heroInfo.actorId].isTransform)
				elseif transformHeros[skinInfo.skins_id] then
					addScrollViewBox(currentAptitude,transformHeros[skinInfo.skins_id].actorId,nil,transformHeros[skinInfo.skins_id].isTransform)
				end
			end
		end
	end

	local totalWidth = (itemContentSize.width + rowDistance) * maxRowNum
	local totalHeight = itemContentSize.height + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
	self._scrollView:setRect(0, -(totalHeight), 0, totalWidth)

	print("当前的魂师ID---",selectId,self._selectPosition,selectSkinId,curIsTransform)
	self:setSelectBoxInfo(selectId, self._selectPosition,nil,selectSkinId,curIsTransform)
	self._scrollView:moveTo(0, selectPositionY, false)
end 

function QUIDialogPersonalSetting:setFrameInfo()
	local selectId = self._useFrameId
	if self._selectId ~= 0 then
		selectId = self._selectId
		self._selectId = 0
	end
	local frames = remote.headProp:getFrameInfo()

	local row = 0
	local line = 0
	local rowDistance = 0
	local lineDistance = 0
	local offsetX = 5
	local offsetY = 0
	local maxRowNum = 3
	local selectPositionY = 0
	local titleHeight = 0

	local itemContentSize, buffer = self._scrollView:setCacheNumber(15, "widgets.QUIWidgetChooseFramsAvatar")
	for k, v in ipairs(buffer) do
		table.insert(self._frameBox, v)
		v:addEventListener(QUIWidgetAvatar.CLICK, handler(self, self._clickEvent))
	end

	local frameType = 0
	for i = 1, #frames do 
		local addTitle = false
		local currentType = frames[i].function_type
		if frameType ~= currentType then
			frameType = currentType
			addTitle = true
			titleHeight = titleHeight + 50
			if row ~= 0 then
				row = 0
				line = line == 0 and line or line + 1
			end
		end
		local positionX = itemContentSize.width/2 + (itemContentSize.width + rowDistance) * row + offsetX
		local positionY = itemContentSize.height/2 + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
		self._scrollView:addItemBox(positionX, -positionY, {avatarConfig = frames[i], index = i, addTitle = addTitle})

		if selectId == frames[i].id then
			self._selectPosition = i
			if line >= 2 then
				selectPositionY = positionY - itemContentSize.height * 3/2
			end
		end
		row = row + 1
		if row >= maxRowNum then
			row = 0
			line = line + 1
		end
	end

	local totalWidth = (itemContentSize.width + rowDistance) * maxRowNum
	local totalHeight = itemContentSize.height + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
	self._scrollView:setRect(0, -(totalHeight), 0, totalWidth)

	if frames[self._selectPosition] then
		self:setSelectBoxInfo(frames[self._selectPosition].id, self._selectPosition)
		self._scrollView:moveTo(0, selectPositionY, false)
	end
end

function QUIDialogPersonalSetting:setHeadPicInfo()
	local selectId = self._avatarId
	if self._selectId ~= 0 then
		selectId = self._selectId
		self._selectId = 0
	end
	local avaterList = remote.headProp:getAvatarInfo()

	local row = 0
	local line = 0
	local rowDistance = 0
	local lineDistance = 0
	local offsetX = 6
	local offsetY = 30
	local maxRowNum = 3
	local selectPositionY = 0
	local titleHeight = -20

	local itemContentSize, buffer = self._scrollView:setCacheNumber(20, "widgets.QUIWidgetChooseHeadAvatar")
	for k, v in ipairs(buffer) do
		table.insert(self._headPicBox, v)
		v:addEventListener(QUIWidgetAvatar.CLICK, handler(self, self._clickEvent))
	end

	local avatarType = 0
	for i = 1, #avaterList do 
		local addTitle = false
		local currentType = avaterList[i].function_type
		if avatarType ~= currentType then
			avatarType = currentType
			addTitle = true
			titleHeight = titleHeight + 50
			if row ~= 0 then
				row = 0
				line = line == 0 and line or line + 1
			end
		end

		local positionX = itemContentSize.width/2 + (itemContentSize.width + rowDistance) * row + offsetX
		local positionY = itemContentSize.height/2 + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
		self._scrollView:addItemBox(positionX, -positionY, {avatarConfig = avaterList[i], index = i, addTitle = addTitle})

		if selectId == avaterList[i].id then
			self._selectPosition = i
			if line >= 2 then
				selectPositionY = positionY - itemContentSize.height * 3/2
			end
		end
		row = row + 1
		if row >= maxRowNum then
			row = 0
			line = line + 1
		end
	end

	local totalWidth = (itemContentSize.width + rowDistance) * maxRowNum
	local totalHeight = itemContentSize.height + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
	self._scrollView:setRect(0, -(totalHeight), 0, totalWidth)

	if avaterList[self._selectPosition] then
		self:setSelectBoxInfo(avaterList[self._selectPosition].id, self._selectPosition)
		self._scrollView:moveTo(0, selectPositionY, false)
	end
end

function QUIDialogPersonalSetting:setTitleInfo()
	local selectId = self._useTitle
	if self._selectId ~= 0 then
		selectId = self._selectId
		self._selectId = 0
	end
	local titles = remote.headProp:getTitleInfo()

	local row = 0
	local line = 0
	local rowDistance = -10
	local lineDistance = 10
	local offsetX = -3
	local offsetY = 20
	local maxRowNum = 1
	local selectPositionY = 0
	local titleHeight = 0

	local itemContentSize, buffer = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetHeroTitleBox")
	for k, v in ipairs(buffer) do
		table.insert(self._titleBox, v)
		v:setTouchEnabled()
		v:addEventListener(QUIWidgetHeroTitleBox.CLICK_TITLE_EVENT, handler(self, self._clickEvent))
	end

	local titleType = 0
	for i = 1, #titles do 
		local addTitle = false
		local currentType = titles[i].function_type
		-- 活动福袋和砖石福袋合并
		if currentType == remote.headProp.TITLE_LUCKYBAG_P_TYPE then
    		currentType = remote.headProp.TITLE_LUCKYBAG_A_TYPE
    	end
		if titleType ~= currentType then
			titleType = currentType
			addTitle = true
			titleHeight = titleHeight + 50
			if row ~= 0 then
				row = 0
				line = line == 0 and line or line + 1
			end
		end
		local positionX = itemContentSize.width/2 + offsetX
		local positionY = itemContentSize.height/2 + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
		self._scrollView:addItemBox(positionX, -positionY, {titleInfo = titles[i], index = i, addTitle = addTitle})

		if selectId == titles[i].id then
			self._selectPosition = i
			if line >= 2 then
				selectPositionY = positionY - itemContentSize.height * 3/2
			end
		end

		row = row + 1
		if row >= maxRowNum then
			row = 0
			line = line + 1
		end
	end
	
	local totalWidth = (itemContentSize.width + rowDistance) * maxRowNum
	local totalHeight = (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)

	if titles[self._selectPosition] then
		self:setSelectBoxInfo(titles[self._selectPosition].id, self._selectPosition, titles[self._selectPosition].lock)
		self._scrollView:moveTo(0, selectPositionY, false)
	end
end

------------------------ click event ----------------------------

function QUIDialogPersonalSetting:_clickEvent(event) 
	if self._isMove then return end
	app.sound:playSound("common_small")

	if event.name == QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK then
		local itemBox = event.target
		self:setSelectBoxInfo(itemBox:getHeroActorID(), itemBox:getIndex(),nil,itemBox:getHeroSkinId(),itemBox:getIsTransform())
	elseif event.name == QUIWidgetAvatar.CLICK then
		local avatarId, frameId = remote.headProp:getAvatarFrameId(event.avatar)
		if self._selectTab == QUIDialogPersonalSetting.TAB_HEAD_PIC then
			self:setSelectBoxInfo(avatarId, event.index, event.locked)
		elseif self._selectTab == QUIDialogPersonalSetting.TAB_FRAME then
			self:setSelectBoxInfo(frameId, event.index, event.locked)
		end
	elseif event.name == QUIWidgetHeroTitleBox.CLICK_TITLE_EVENT then
		self:setSelectBoxInfo(event.titleId, event.index, event.locked)
	end
end

function QUIDialogPersonalSetting:_avatarChange(event)
	if not self:safeCheck() then
		return
	end
	if self._selectTab == QUIDialogPersonalSetting.TAB_TITLE then
		self._useTitle = event.title
		self:setDefaultTitle()

		if self._selectItemId == self._useTitle then
			self:setSelectBoxInfo(self._useTitle, self._selectPosition, false)
		else
			self:selectTabs()
		end
	else
		local avatarId, frameId = remote.headProp:getAvatarFrameId(event.avatar)
		self._avatarId = avatarId
		self._useFrameId = frameId
		if self._selectItemId == self._avatarId then
			self:setSelectBoxInfo(avatarId, self._selectPosition, false)
		elseif self._selectItemId == self._useFrameId then
			self:setSelectBoxInfo(frameId, self._selectPosition, false)
		else
			self:selectTabs()
		end
	end
end

function QUIDialogPersonalSetting:_showHeroChange(event)
	if not self:safeCheck() then
		return
	end
	self._showHeroActorId = event.actorId
	self._showHeroSkinId = event.skinId
	self:setSelectBoxInfo(event.actorId, self._selectPosition,nil,event.skinId,event.isTransform)
end

function QUIDialogPersonalSetting:resetSelect()
	-- 重置当前选择的id
	self._curShowHeroId = nil
	self._curSkinId = nil
	self._curAvatarId = nil
	self._curFrameId = nil
	self._curTitleId = nil
	self._isTransform = false

	-- 切换tab按钮 为避免太频繁清除重绘
	if self._lastTab ~= self._selectTab then
		self._scrollView1:clear()
		self._showHero = nil
		self._headInfo = nil
		self._frameInfo = nil
		self._titleInfo = nil
	end

	-- 记录上次tab
	self._lastTab = self._selectTab
	self._scrollView1:setTouchState(true)
end

function QUIDialogPersonalSetting:setSelectBoxInfo(itemId, index, locked,skinId,isTransform) 
	self._selectPosition = index
	self:getOptions().selectPosition = self._selectPosition
	self._selectItemId = itemId
	self:resetSelect()

	local locked, limitTime = remote.headProp:getIsLocked(itemId)

	if self._selectTab == QUIDialogPersonalSetting.TAB_SHOW_HERO then
		for i = 1, #self._showHeroBox do
			self._showHeroBox[i]:setSelectPosition(index)
			self._showHeroBox[i]:showSettingSelect(self._showHeroBox[i]:getIndex() == index)
			if self._showHeroSkinId == 0 then
				self._showHeroBox[i]:showSettingUse(self._showHeroActorId == self._showHeroBox[i]:getHeroActorID())
			else
				self._showHeroBox[i]:showSettingUse(self._showHeroSkinId == self._showHeroBox[i]:getHeroSkinId())
			end
		end

		self._curShowHeroId = itemId
		self._curSkinId = skinId

		local lock = remote.herosUtil:checkHeroHavePast(self._curShowHeroId)
		if isTransform then
			lock = true
		end
		self._isTransform = isTransform
		local skinInfo = remote.heroSkin:getHeroSkinBySkinId(self._curShowHeroId, skinId)

		if q.isEmpty(skinInfo) == false then
			if skinInfo.is_nature ~= 0 then
				local skinLock = remote.heroSkin:checkSkinIsActivation(self._curShowHeroId, skinId)
				self:setUserTip(self._curSkinId == self._showHeroSkinId, not skinLock)
			else
				self:setUserTip(self._curSkinId == self._showHeroSkinId, not lock)
			end
		else
			self:setUserTip(self._showHeroActorId == self._curShowHeroId, not lock)
		end

		if self._showHero == nil then
			self._showHero = QUIWidgetChooseShowHero.new()
			self._scrollView1:addItemBox(self._showHero)
		end
		self._showHero:setHeroInfo(itemId,skinId,isTransform)
		local contentSize = self._showHero:getContentSize()
    	self._scrollView1:setRect(0, -contentSize.height, 0, self._clientWidth)
    	self._scrollView1:setTouchState(false)

	elseif self._selectTab == QUIDialogPersonalSetting.TAB_HEAD_PIC then
		for i = 1, #self._headPicBox do
			self._headPicBox[i]:setSelectPosition(index)
			self._headPicBox[i]:showSettingSelect(self._headPicBox[i]:getIndex() == index)
			self._headPicBox[i]:showSettingUse(self._avatarId == self._headPicBox[i]:getAvatarId())
		end

		self._curAvatarId = itemId
		self:setUserTip(self._curAvatarId == self._avatarId, locked)

		if self._headInfo == nil then
			self._headInfo = QUIWidgetShowAvatarInfo.new()
			self._scrollView1:addItemBox(self._headInfo)
		end
		self._headInfo:setAvatarInfo(itemId, locked, limitTime)
		local contentSize = self._headInfo:getContentSize()
    	self._scrollView1:setRect(0, -contentSize.height, 0, self._clientWidth)

	elseif self._selectTab == QUIDialogPersonalSetting.TAB_FRAME then
		for i = 1, #self._frameBox do
			self._frameBox[i]:setSelectPosition(index)
			self._frameBox[i]:showSettingSelect(self._frameBox[i]:getIndex() == index)
			self._frameBox[i]:showSettingUse(self._useFrameId == self._frameBox[i]:getFrameId())
		end

		self._curFrameId = itemId
		self:setUserTip(self._curFrameId == self._useFrameId, locked)

		if self._frameInfo == nil then
			self._frameInfo = QUIWidgetShowFrameInfo.new()
			self._scrollView1:addItemBox(self._frameInfo)
		end
		self._frameInfo:setFrameInfo(itemId, locked, limitTime)
		local contentSize = self._frameInfo:getContentSize()
    	self._scrollView1:setRect(0, -contentSize.height, 0, self._clientWidth)

	elseif self._selectTab == QUIDialogPersonalSetting.TAB_TITLE then
		for i = 1, #self._titleBox do
			self._titleBox[i]:setSelectPosition(index)
			self._titleBox[i]:showSettingSelect(self._titleBox[i]:getIndex() == index)
			self._titleBox[i]:showSettingUse(self._useTitle == self._titleBox[i]:getTitleId())
		end

		locked = remote.headProp:getIsTitleLocked(itemId)
		self._curTitleId = itemId
		self:setUserTip(self._curTitleId == self._useTitle, locked)

		if self._titleInfo == nil then
			self._titleInfo = QUIWidgetShowTitleInfo.new()
			self._scrollView1:addItemBox(self._titleInfo)
		end
		self._titleInfo:setTitleInfo(itemId, locked, limitTime)
		local contentSize = self._titleInfo:getContentSize()
    	self._scrollView1:setRect(0, -contentSize.height, 0, self._clientWidth)
	end
end

function QUIDialogPersonalSetting:setUserTip(state, lock)
	if state then
		self._ccbOwner.tf_use_tips:setVisible(true)
		self._ccbOwner.node_btn_use:setVisible(false)
		self._ccbOwner.tf_lock_tips:setVisible(false)
	else
		if lock then
			self._ccbOwner.tf_use_tips:setVisible(false)
			self._ccbOwner.node_btn_use:setVisible(false)
			self._ccbOwner.tf_lock_tips:setVisible(true)
		else
			self._ccbOwner.tf_use_tips:setVisible(false)
			self._ccbOwner.node_btn_use:setVisible(true)
			self._ccbOwner.tf_lock_tips:setVisible(false)
		end
	end
end

function QUIDialogPersonalSetting:btnItemClickHandler(event)
	local info = event.info or {}
	self._selectTab = QUIDialogPersonalSetting.TAB_SHOW_HERO
	for i, btn in pairs(self._btnList) do
		if btn.id == info.id then
			self._selectTab = btn.btnType
			break
		end
	end

	self:selectTabs()
end

function QUIDialogPersonalSetting:_onTriggerUse(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_use) == false then return end
    app.sound:playSound("common_small")
    if self._curAvatarId then
		local newAvatar = remote.headProp:getAvatar(self._curAvatarId, nil)
		remote.headProp:changeAvatarRequest(newAvatar, nil, function()
				app.tip:floatTip("恭喜您, 成功修改头像")
			end)
    elseif self._curFrameId then
	    local newAvatar = remote.headProp:getAvatar(nil, self._curFrameId)
	    remote.headProp:changeAvatarRequest(newAvatar, nil, function()
	            app.tip:floatTip("恭喜您, 成功修改头像框")
	        end)
	elseif self._curSkinId and self._curShowHeroId then
		remote.headProp:changeShowHeroRequest(self._curShowHeroId,self._curSkinId,self._isTransform, function()
				app.tip:floatTip("恭喜您, 成功修改展示魂师")
			end)
	elseif self._curTitleId then
	    local curAvatar = remote.headProp:getAvatar()
	    local titleId = self._curTitleId
		local titleInfo = db:getHeadInfoById(titleId)
		-- 转换成0为默认魂力试炼
	    if titleInfo.function_type == remote.headProp.TITLE_TRIAL_TYPE then
	    	titleId = 0
	    end
		remote.headProp:changeAvatarRequest(curAvatar, titleId, function()
				app.tip:floatTip("恭喜您, 成功修改称号")
			end)
	end 
end

function QUIDialogPersonalSetting:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPersonalSetting:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogPersonalSetting