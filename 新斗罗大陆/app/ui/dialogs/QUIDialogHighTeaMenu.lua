local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHighTeaMenu = class("QUIDialogHighTeaMenu", QUIDialog)


local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHighTeaMenu = import("..widgets.QUIWidgetHighTeaMenu")
local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")


function QUIDialogHighTeaMenu:ctor(options)
    local ccbFile = "ccb/Dialog_HighTea_Menu.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }

    QUIDialogHighTeaMenu.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
    -- self:_initListView() 
   	self._highTeaHandler = remote.activityRounds:getHighTea()
	if options.callBack ~= nil then 
		self._callback = options.callBack
	end

end

function QUIDialogHighTeaMenu:viewDidAppear()
    QUIDialogHighTeaMenu.super.viewDidAppear(self)
	self:handleData()
	self:sortData()
	self:_initListView()
	self:setInfo()
end


function QUIDialogHighTeaMenu:_updateInfo()
	self:sortData()
	self:_initListView()
	self:setInfo()
end


function QUIDialogHighTeaMenu:viewWillDisappear()
    QUIDialogHighTeaMenu.super.viewWillDisappear(self)
end

function QUIDialogHighTeaMenu:setInfo()
	self._ccbOwner.frame_tf_title:setString("美食制作")
end

function QUIDialogHighTeaMenu:handleData()
	self._items = {}
	local foodConfigs = remote.activity:getHighTeaFoodConfig()
	self._mood = self._highTeaHandler:getHighTeaMood()
	print("mood  	"..self._mood)
	for k,v in pairs(foodConfigs or {}) do
		-- QPrintTable(v)
		local itemId = v.item_id
		local id = v.id
		local awardsTbl  = string.split(v.source_item, ";")
		local isLike = self._mood == v.kind
		self._items[id] = {id = id , itemId = itemId , awardsTbl = awardsTbl , canCook = 0 , isLike = isLike }
	end
	-- QPrintTable(self._items)
end

function QUIDialogHighTeaMenu:sortData()
	if q.isEmpty(self._items) then return end
	for k,v in pairs(self._items) do
		local canCook = 1
		local itemNeedTable = {}
		for i,itemId in ipairs(v.awardsTbl) do
			if itemNeedTable[itemId] then
				itemNeedTable[itemId] = itemNeedTable[itemId] + 1
			else
				itemNeedTable[itemId] = 1
			end
		
		end

		for k,v in pairs(itemNeedTable or {}) do
			local num = remote.items:getItemsNumByID(k) or 0
			if num < v then
				canCook = 0
				break
			end			
		end
		v.canCook = canCook
	end

	table.sort(self._items, function (target1, target2)
	
		if target1.canCook == target2.canCook then
			return target1.id > target2.id
		else
			return target1.canCook > target2.canCook
		end

	end)	

end


function QUIDialogHighTeaMenu:_initListView()

	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
	        curOriginOffset = 7,
	        contentOffsetX = -2,
	        contentOffsetY = 10,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 10,
	      	isVertical = true ,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		-- self._listViewLayout:reload({totalNumber = #self._items})
		self._listViewLayout:refreshData() 
	end
end

function QUIDialogHighTeaMenu:_renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self._items[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetHighTeaMenu.new()
        item:addEventListener(QUIWidgetHighTeaMenu.EVENT_FOOD_MADE, handler(self,self._onClickCookHandler))
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_ok", "_onTriggerOK", nil, "true")

    return isCacheNode
end

function QUIDialogHighTeaMenu:_onClickCookHandler(event)
	local info = event.info
	if not info then
		return
	end
	local itemId = info.itemId
	local count = 1
	local itemType = ITEM_TYPE.ITEM
	if tonumber(itemId) == nil then
	    itemType = remote.items:getItemType(itemId)
	end
	app.sound:playSound("common_small")
	if info.canCook <= 0 then
		app.tip:floatTip("食材不足，无法制作")
		return
	end

	local awards = {}
	table.insert(awards, {id = itemId, typeName = itemType , count = count})

	self._highTeaHandler:weeklyGameHighTeaCraftFoodRequest(itemId, count, function (data)
		if data.items then remote.items:setItems(data.items) end
  		-- local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    -- 		options = {awards = awards, callBack = function ()
    -- 		end}},{isPopCurrentDialog = false} )
    -- 	dialog:setTitle("食物加工成功")

    	app.tip:awardsTip(awards, "食物加工成功",nil,true)

		if self:safeCheck() then
			self:_updateInfo()
		end
	end)

end

function QUIDialogHighTeaMenu:_backClickHandler()
	if self._callback then
		self._callback()
	end		
    self:_onTriggerClose()
end

function QUIDialogHighTeaMenu:_onTriggerClose()
  	app.sound:playSound("common_close")
	if self._callback then
		self._callback()
	end	  	
	self:playEffectOut()
end

function QUIDialogHighTeaMenu:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end


return QUIDialogHighTeaMenu