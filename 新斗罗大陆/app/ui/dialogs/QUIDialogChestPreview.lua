-- @Author: xurui
-- @Date:   2016-10-09 10:00:44
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-05 16:23:51
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogChestPreview = class("QUIDialogChestPreview", QUIDialog)

local QScrollView = import("...views.QScrollView") 
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

QUIDialogChestPreview.ENCHANT_TYPE = 24       	--觉醒宝箱奖励预览
QUIDialogChestPreview.MOUNT_TYPE = 26       	--暗器宝箱奖励预览
QUIDialogChestPreview.GEMSTONE_TYPE = 29       	--魂骨宝箱奖励预览

function QUIDialogChestPreview:ctor(options)
	local ccbFile = "ccb/Dialog_fumo_yulan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogChestPreview.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	if options then
		self._previewType = options.previewType or QUIDialogChestPreview.ENCHANT_TYPE
		self._titleWord = options.title or {}
	end
	self._itemBox = {}
	self._currentTitle = nil
	self._ccbOwner.high_overview:setVisible(false)
	self._ccbOwner.low_overview:setVisible(false)
	self._ccbOwner.frame_tf_title:setString("宝箱奖励预览")

	self:initScrollView()
end

function QUIDialogChestPreview:viewDidAppear()
	QUIDialogChestPreview.super.viewDidAppear(self)

	self:getPreviewData()
	self:setPreviewInfo()
end

function QUIDialogChestPreview:viewWillDisappear()
	QUIDialogChestPreview.super.viewWillDisappear(self)
end

function QUIDialogChestPreview:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10, nodeAR = ccp(0.5, 0.5)})
	self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)
	
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogChestPreview:getPreviewData()
	local previewInfo = db:getTavernOverViewInfoByTavernType(tostring(self._previewType))

	self._items = {}

	local insertFunc = function(data, title, itemType)
		for i = 1, #data do
			local index = #self._items+1
			self._items[index] = {}
			self._items[index].itemType = itemType
			self._items[index].title = title
			self._items[index].id = data[i]
		end
	end

	local itemNum = 1
	local heroType = ITEM_TYPE.HERO
	if previewInfo["hero_"..1] then
		local heros = string.split(previewInfo["hero_"..1], ";")
		local hero = QStaticDatabase:sharedDatabase():getCharacterByID(tonumber(heros[1]))
		if hero and hero.npc_type == 3 then
			heroType = ITEM_TYPE.ZUOQI
		end
		insertFunc( heros, self._titleWord[1], heroType)
		itemNum = itemNum + 1
	end

	local index = 1
	for i = itemNum, 3 do
		if previewInfo["item_"..index] then
			local items = string.split(previewInfo["item_"..index], ";")
			local newItems = {}
			for i, v in pairs(items) do
				if not db:checkItemShields(v) then
					newItems[#newItems+1] = v
				end
			end
			insertFunc( newItems, self._titleWord[i], ITEM_TYPE.ITEM)
			index = index + 1
		end
	end
end

function QUIDialogChestPreview:setPreviewInfo()

	local itemContentSize, buffer = self._scrollView:setCacheNumber(25, "widgets.QUIWidgetTavernOverViewItemBox")
	for k, v in ipairs(buffer) do
		table.insert(self._itemBox, v)
	end

	local row = 0
	local line = 0
	local rowDistance = 18
	local lineDistance = -55
	local offsetX = -44
	local offsetY = -110
	local maxRowNum = 5
	local totalWidth = 0
	local totalHeight = 0
	local titleHeight = 0
	local title = nil

	for i = 1, #self._items do
		local addTitle = false
		local currentTitle = self._items[i].title
		if title == nil or title ~= currentTitle then
			title = currentTitle
			addTitle = true

			titleHeight = titleHeight + 65
			if row ~= 0 then
				row = 0
				line = line + 1
				totalHeight = totalHeight + itemContentSize.height + lineDistance
			end
		end

		local positionX = itemContentSize.width/2 + (itemContentSize.width + rowDistance) * row + offsetX
		local positionY = itemContentSize.height/2 + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight
		self._scrollView:addItemBox(positionX, -positionY, {itemInfo = self._items[i], addTitle = addTitle, titleWord = self._items[i].title})

		totalWidth = (itemContentSize.width + rowDistance) * maxRowNum
		row = row + 1
		if row >= maxRowNum then
			row = 0
			line = line + 1
			totalHeight = totalHeight + itemContentSize.height + lineDistance
		end
	end

	if row > 0 then
		totalHeight = totalHeight + itemContentSize.height + lineDistance
	end
	self._scrollView:setRect(0, -(totalHeight+titleHeight), 0, totalWidth)
end 

function QUIDialogChestPreview:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogChestPreview:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogChestPreview:_backClickHandler()
	self:playEffectOut()
end 

function QUIDialogChestPreview:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_cloose) == false then return end
	self:playEffectOut()
end

function QUIDialogChestPreview:viewAnimationOutHandler()
	self:popSelf()
end 

return QUIDialogChestPreview