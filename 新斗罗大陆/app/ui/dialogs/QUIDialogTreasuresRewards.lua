--
-- Kumo.Wang
-- 资源夺宝全部获得的奖励
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTreasuresRewards = class("QUIDialogTreasuresRewards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogTreasuresRewards:ctor(options)
	local ccbFile = "ccb/Dialog_Treasures_Rewards.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogTreasuresRewards.super.ctor(self, ccbFile, callBack, options)

	self._ccbOwner.frame_tf_title:setString("已获得奖励")

	self.isAnimation = true --是否动画显示

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)

    self:_init()
end

function QUIDialogTreasuresRewards:viewDidAppear()
	QUIDialogTreasuresRewards.super.viewDidAppear(self)
end

function QUIDialogTreasuresRewards:viewWillDisappear()
	QUIDialogTreasuresRewards.super.viewWillDisappear(self)
end

function QUIDialogTreasuresRewards:_init()
	self._awards = {}
   	if self._resourceTreasuresModule then
   		for key, count in pairs(self._resourceTreasuresModule.allRewards) do
   			local id = tonumber(key)
   			print(key, id)
   			if id then
   				table.insert(self._awards, {id = id, type = ITEM_TYPE.ITEM, count = tonumber(count)})
			else
				table.insert(self._awards, {id = nil, type = key, count = tonumber(count)})
   			end
   		end
   	end

	self:_initListView()
end

function QUIDialogTreasuresRewards:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.reandFunHandler),
	        isVertical = true,
	        multiItems = 4, 
	        spaceX = 35,
	        enableShadow = false,
	        totalNumber = #self._awards,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._awards})
	end
end

function QUIDialogTreasuresRewards:reandFunHandler( list, index, info )
    local isCacheNode = true
    local data = self._awards[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    self:setItemInfo(item, data, index)	
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    
    list:registerItemBoxPrompt(index, 1, item._itemBox)

    return isCacheNode
end

function QUIDialogTreasuresRewards:setItemInfo( item, data, index )
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setPosition(ccp(46, 70))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(94, 140))
		item:setClickBtnSize(CCSizeMake(86, 140))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
	item._itemBox:showItemName()
	item._itemBox:setGoodsNameScale(0.8)
end

function QUIDialogTreasuresRewards:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTreasuresRewards:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	self:playEffectOut()
end

function QUIDialogTreasuresRewards:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogTreasuresRewards