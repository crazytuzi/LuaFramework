local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlayerRecallTaskCell = class("QUIWidgetPlayerRecallTaskCell", QUIWidget)

local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetPlayerRecallTaskCell:ctor(options)
	local ccbFile = "ccb/Widget_playerRecall_feature.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		-- {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
	QUIWidgetPlayerRecallTaskCell.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetPlayerRecallTaskCell:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetPlayerRecallTaskCell:setInfo(info)
	if not info or next(info) == nil then return end

	self._info = info
	self._ccbOwner.tf_name:setString(info.desc)

	self._ccbOwner.node_info:setVisible(true)
	self._ccbOwner.node_btn_ok:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.tf_btn_go:setString("前  往") 

	local playerRecallInfo = remote.playerRecall:getInfo()
	local curTaskInfo = playerRecallInfo[tostring(info.id)]
	self._isReady = (curTaskInfo and curTaskInfo.completeCount or 0) > 0
	self._isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)

	if info.task_type == 8 then
    	local battleForce = remote.herosUtil:getMostHeroBattleForce()
		local curNum, curUnit = q.convertLargerNumber(battleForce)
    	-- local oldBattleForce = playerRecallInfo.old_topn_force
    	-- local curNum = math.floor((battleForce - oldBattleForce)/oldBattleForce*100)
		-- self._ccbOwner.tf_num:setString("任务进度："..curNum.."/"..10)
		local targetBattleForce = math.ceil(playerRecallInfo.old_topn_force * 1.1)
		local tarNum, tarUnit = q.convertLargerNumber(targetBattleForce)
		if battleForce >= targetBattleForce then
			self._ccbOwner.tf_num:setString((tarNum..(tarUnit or "")).."/"..(tarNum..(tarUnit or "")))
			-- self._ccbOwner.tf_num:setString(targetBattleForce.."/"..targetBattleForce)
		else
			-- self._ccbOwner.tf_num:setString(battleForce.."/"..targetBattleForce)
			self._ccbOwner.tf_num:setString((curNum..(curUnit or "")).."/"..(tarNum..(tarUnit or "")))
		end
	else
		-- self._ccbOwner.tf_num:setString("领奖次数："..(curTaskInfo and curTaskInfo.awardCount or 0).."/"..info.complete_count)
		self._ccbOwner.tf_num:setString(self._isReady and "1/1" or "0/1")
	end
	
	if self._isComplete then
		self._ccbOwner.sp_ishave:setVisible(true)
	else
		if self._isReady then
			self._ccbOwner.node_btn_ok:setVisible(true)
			-- makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
		else
			if info.shortcut_approach_new then
				self._ccbOwner.node_btn_go:setVisible(true)
			else
				-- self._ccbOwner.node_btn_ok:setVisible(true)
				-- makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
			end
		end
	end

	self._data = {}
	local luckyDrawConfig = remote.playerRecall:getLuckyDrawListByLuckyDrawId(info.lucky_draw)
	if not luckyDrawConfig or next(luckyDrawConfig) == nil then return end

	local index = 1
	while true do
		local id = luckyDrawConfig["id_"..index]
		local type = luckyDrawConfig["type_"..index]
		local num = luckyDrawConfig["num_"..index]
		if type and num then
			table.insert(self._data, {id = id, type = type, count = num})
			index = index + 1
		else
			break
		end
	end

	self:_initListView()
end

function QUIWidgetPlayerRecallTaskCell:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	        enableShadow = false,
	        spaceX = -15,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetPlayerRecallTaskCell:_renderItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
		app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
	end

    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.7)
		item._itemBox:setPosition(ccp(45,55))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(90,90))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetPlayerRecallTaskCell:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetPlayerRecallTaskCell:onTriggerOK()
	if not self._isComplete and self._isReady then
		remote.playerRecall:playerComeBackCompleteRequest(self._info.type, self._info.id)
	elseif not self._isReady then
		app.tip:floatTip("任务未完成")
	end
end

function QUIWidgetPlayerRecallTaskCell:onTriggerGo()
    app.sound:playSound("common_small")
	if self._info and self._info.shortcut_approach_new then
		local config = remote.playerRecall:getShortcutByID(self._info.shortcut_approach_new)
		if config then
    		QQuickWay:clickGoto(config)
    	else
    		app.tip:floatTip("快捷跳转无效～")
    	end
	end
end

return QUIWidgetPlayerRecallTaskCell