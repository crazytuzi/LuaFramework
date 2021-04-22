


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalAbyssRewardPerview = class("QUIDialogMetalAbyssRewardPerview", QUIDialog)

local QScrollView = import("...views.QScrollView") 
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogMetalAbyssRewardPerview:ctor(options)
	local ccbFile = "ccb/Dialog_fumo_yulan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMetalAbyssRewardPerview.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
	self._itemBox = {}
	self._currentTitle = nil
	self._ccbOwner.high_overview:setVisible(false)
	self._ccbOwner.low_overview:setVisible(false)
	self._ccbOwner.frame_tf_title:setString("宝箱奖励预览")

	self:initScrollView()
end

function QUIDialogMetalAbyssRewardPerview:viewDidAppear()
	QUIDialogMetalAbyssRewardPerview.super.viewDidAppear(self)

	self:getPreviewData()
	self:setPreviewInfo()
end

function QUIDialogMetalAbyssRewardPerview:viewWillDisappear()
	QUIDialogMetalAbyssRewardPerview.super.viewWillDisappear(self)
end

function QUIDialogMetalAbyssRewardPerview:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10, nodeAR = ccp(0.5, 0.5)})
	self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)
	
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogMetalAbyssRewardPerview:getPreviewData()

	self._items = {}

	for i=1,15 do
		local dataConfig = remote.metalAbyss:getMetalAbyssFinalRewardById(i)
		if dataConfig then
			local title = "获得"
			if i < 5 then
				title = title.."5星奖励"
			elseif i < 10 then
				title = title.."10星奖励"
			elseif i < 15 then
				title = title.."15星奖励"
			end

			local index = 0
		    while true do
		    	index = index + 1
		    	local itemId = dataConfig["id_"..index]
		        if itemId == nil then
		            break
		        else
		        	local info = {}
		        	info.id = itemId
		        	info.itemType = dataConfig["type_"..index]
		        	info.title = title
		        	info.count = dataConfig["num_"..index] or 0 
		        	info.probability = dataConfig["probability_"..index]
		        	table.insert(self._items,info)
		        end
		    end
		end
	end
end

function QUIDialogMetalAbyssRewardPerview:setPreviewInfo()

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

			titleHeight = titleHeight + 85
			if row ~= 0 then
				row = 0
				line = line + 1
				totalHeight = totalHeight + itemContentSize.height + lineDistance
			end
		end

		local positionX = itemContentSize.width/2 + (itemContentSize.width + rowDistance) * row + offsetX
		local positionY = itemContentSize.height/2 + (itemContentSize.height + lineDistance) * line + offsetY + titleHeight 
		self._scrollView:addItemBox(positionX, -positionY , {itemInfo = self._items[i], addTitle = addTitle, titleWord = self._items[i].title})

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


function QUIDialogMetalAbyssRewardPerview:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogMetalAbyssRewardPerview:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogMetalAbyssRewardPerview:_backClickHandler()
	self:playEffectOut()
end 

function QUIDialogMetalAbyssRewardPerview:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_cloose) == false then return end
	self:playEffectOut()
end

function QUIDialogMetalAbyssRewardPerview:viewAnimationOutHandler()
	self:popSelf()
end 

return QUIDialogMetalAbyssRewardPerview