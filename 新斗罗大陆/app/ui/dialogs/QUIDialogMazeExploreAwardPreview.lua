-- @Author: liaoxianbo
-- @Date:   2020-08-06 19:43:46
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-17 19:12:43
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreAwardPreview = class("QUIDialogMazeExploreAwardPreview", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIDialogMazeExploreAwardPreview:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_SkillInfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMazeExploreAwardPreview.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._chapterId = options.chapterId or 1
	self._ccbOwner.frame_tf_title:setString("奖励一览")
	self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()

	self._ccbOwner.style_s9s_bg:setVisible(false)

	local luckDrawIds = self._mazeExploreDataHandle:getAwardPreviewData(self._chapterId)

	self._allAwardsTbl = {} 
	local rewardAnalysis = function(awardTbl)
		for _,v in pairs(awardTbl) do
			table.insert(self._allAwardsTbl,v)
		end
	end
	for _, v in pairs(luckDrawIds) do
		local idTbl = string.split(v, ";")
		for _,id in pairs(idTbl) do
			-- local awardTbl = db:getluckyDrawById(id)
			local awards = {}
		    local luckyDraw = db:getLuckyDraw(id)
		    local index = 1
		    local isRandom = false
		    if luckyDraw ~= nil then
		        while true do
		            if luckyDraw["type_"..index] ~= nil then
		                if luckyDraw["probability_"..index] == -1 then
		                    if not db:checkItemShields(luckyDraw["id_"..index]) then
		                        table.insert(awards, {id = luckyDraw["id_"..index], typeName = luckyDraw["type_"..index], count = luckyDraw["num_"..index]})
		                    end
		                else
		                    isRandom = true
		                end
		            else
		                break
		            end
		            index = index + 1
		        end

		        if isRandom then
		            --当物品中有随机概率不是-1（即100%）的时候，则，不显示随机奖励，而统一用《神秘奖励》这个item代替所有。
		            table.insert(awards, {id = 400, typeName = ITEM_TYPE.ITEM, count = 0})
		        end
		    end

			rewardAnalysis(awards)
		end
	end
	self:sortSameAwrads()
	table.sort( self._allAwardsTbl, function(a,b)
		if a.id ~= 400 and b.id ~= 400 then
			return a.count < b.count
		else
			return a.id ~= 400
		end
	end )
	self:initListView()
end 

function QUIDialogMazeExploreAwardPreview:sortSameAwrads()
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

function QUIDialogMazeExploreAwardPreview:viewDidAppear()
	QUIDialogMazeExploreAwardPreview.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogMazeExploreAwardPreview:viewWillDisappear()
  	QUIDialogMazeExploreAwardPreview.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogMazeExploreAwardPreview:initListView()
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
	            info.size = CCSizeMake(100,100)
	            return isCacheNode
	        end,
	        multiItems = 5,
	        spaceX = 5,
	        spaceY = 5,
	        enableShadow = false,
	        totalNumber = #self._allAwardsTbl 
 		}
 		self._myNumListView = QListView.new(self._ccbOwner.sheet_layout, cfg)  	
	else
		self._myNumListView:reload({totalNumber = #self._allAwardsTbl})
	end
end

function QUIDialogMazeExploreAwardPreview:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetItemsBox.new()
		item._itemNode:setPosition(ccp(100/2,100/2))
		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
	end

	item._itemNode:setPromptIsOpen(true)
	item._itemNode:setGoodsInfo(itemData.id, itemData.typeName, itemData.count)
end

function QUIDialogMazeExploreAwardPreview:renderFunHandler(list, index, info)
    local isCacheNode = true
    local recordConfig = self._allAwardsTbl[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetItemsBox.new()
        isCacheNode = false
    end
    info.item = item
    item:setPromptIsOpen(true)
	item:setGoodsInfo(recordConfig.id, recordConfig.typeName, recordConfig.count)
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogMazeExploreAwardPreview:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMazeExploreAwardPreview:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreAwardPreview:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMazeExploreAwardPreview
