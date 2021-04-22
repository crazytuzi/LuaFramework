-- @Author: liaoxianbo
-- @Date:   2020-08-17 15:16:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-18 13:29:53
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreEndPointInfo = class("QUIDialogMazeExploreEndPointInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIDialogMazeExploreEndPointInfo:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_EndPoints.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogMazeExploreEndPointInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._callBack = options.callBack
    self._allAwardsTbl = options.awrds or {}
    self._progress = options.progress or 0

    self:sortSameAwrads()
    self:updateExploreProgres()
    self:initListView()
end

function QUIDialogMazeExploreEndPointInfo:viewDidAppear()
	QUIDialogMazeExploreEndPointInfo.super.viewDidAppear(self)

	-- self:addBackEvent(true)
end

function QUIDialogMazeExploreEndPointInfo:viewWillDisappear()
  	QUIDialogMazeExploreEndPointInfo.super.viewWillDisappear(self)

	-- self:removeBackEvent()
end

function QUIDialogMazeExploreEndPointInfo:sortSameAwrads()
    --合并相同的道具
    local tempAwards = {}

    for _,v in pairs(self._allAwardsTbl) do
    	local key = v.id
    	if not key then
    		key = v.typeName
	    end
	    if key then
	    	if tempAwards[key] then
	    		tempAwards[key].count = tempAwards[key].count + v.count
	    	else
	    		tempAwards[key] = {id = v.id,count = v.count,typeName = v.typeName}
	    	end
	    end
    end
    self._allAwardsTbl = {}
    for _,v in pairs(tempAwards) do
    	table.insert(self._allAwardsTbl, v)
    end
end


function QUIDialogMazeExploreEndPointInfo:updateExploreProgres( )
    local scale = self._progress
    scale = scale >1 and 1 or scale
    self._ccbOwner.sp_progress_bar:setScaleX(scale)
    self._ccbOwner.tf_progress:setString(math.floor((self._progress)*100).."%")
end

function QUIDialogMazeExploreEndPointInfo:initListView()
	if not self._myNumListView then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._allAwardsTbl[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, itemData)

				list:registerItemBoxPrompt(index, 1, item._itemNode, nil, showItemInfo)

	            info.item = item
	            info.size = CCSizeMake(80,80)
	            return isCacheNode
	        end,
	        multiItems = 6,
	        spaceX = 20,
	        spaceY = 2,
	        enableShadow = false,
	        totalNumber = #self._allAwardsTbl 
 		}
 		self._myNumListView = QListView.new(self._ccbOwner.sheet_layout, cfg)  	
	else
		self._myNumListView:reload({totalNumber = #self._allAwardsTbl})
	end
end

function QUIDialogMazeExploreEndPointInfo:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetItemsBox.new()
		item._itemNode:setPosition(ccp(45,40))
		item._itemNode:setScale(0.8)
		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(80,80))
	end

	item._itemNode:setPromptIsOpen(true)
	item._itemNode:setGoodsInfo(itemData.id, itemData.typeName, itemData.count)
end

function QUIDialogMazeExploreEndPointInfo:_onTriggerGo()
  	app.sound:playSound("common_close")
	if self._callBack then
		self._callBack()
	end  	
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreMain"})
end

function QUIDialogMazeExploreEndPointInfo:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreEndPointInfo:viewAnimationOutHandler()
	self:popSelf()
end

return QUIDialogMazeExploreEndPointInfo
