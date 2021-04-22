-- @Author: liaoxianbo
-- @Date:   2020-04-10 15:58:18
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-27 15:06:18
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerAwards = class("QUIWidgetSoulTowerAwards", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIWidgetSoulTowerAwards:ctor(options)
	local ccbFile = "ccb/Widget_SoulTower_awards.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulTowerAwards.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._title = options.title or "当前奖励"
	self._luckAward = options.targetAwardTbl
	self._isProess = options.isProess or false
	if options.isTable and q.isEmpty(self._luckAward) == false then
		local awardInfo = {}
	    if self._luckAward.floor_reward then
	        local floorAwardInfo = db:getluckyDrawById(self._luckAward.floor_reward)
	        for _,v in pairs(floorAwardInfo) do
	            table.insert(awardInfo, v )
	        end
	    end
	    if self._luckAward.wave_reward then
	        local waveAwardInfo = db:getluckyDrawById(self._luckAward.wave_reward)
	        for _,v in pairs(waveAwardInfo) do
	            table.insert(awardInfo, v )
	        end        
	    end
	    self._items = self:sortSameAwrads(awardInfo)		
	else
		self._items = db:getluckyDrawById(self._luckAward)
	end
	self._ccbOwner.node_title:setVisible(not self._isProess)
	self._ccbOwner.tf_title:setString(self._title)
end

function QUIWidgetSoulTowerAwards:onEnter()
	if q.isEmpty(self._items) then
		self._ccbOwner.tf_noawards:setVisible(true)
		if self._isProess then
			self._ccbOwner.node_title:setVisible(false)
		end
	else
		if self._isProess then
			self._ccbOwner.node_title:setVisible(true)
			self:setPositionY(-20)
		end		
		self._ccbOwner.tf_noawards:setVisible(false)
		self:initListView()
	end
end

function QUIWidgetSoulTowerAwards:sortSameAwrads(awards)
    --合并相同的道具
    local tempAwards = {}
    local tempAwards2 = {}
    for _, v in pairs(awards) do
        if v.typeName ~= ITEM_TYPE.HERO then
            if tonumber(v.id) ~= nil and tonumber(v.id) > 0 then
                if tempAwards[v.id] then
                    tempAwards[v.id].count = tempAwards[v.id].count + v.count
                else
                    tempAwards[v.id] = v
                end
            else
                if tempAwards[v.typeName] then
                    tempAwards[v.typeName].count = tempAwards[v.typeName].count + v.count
                else
                    tempAwards[v.typeName] = v
                end
            end
        else
            table.insert(tempAwards2, v)
        end
    end
    awards = tempAwards2
    for k,v in pairs(tempAwards) do
        if tonumber(v.id) ~= nil and tonumber(v.id) > 0 then
            local int = math.ceil(v.count/9999)
            for i= 1,int do
                local temp = clone(v)
                local tempCount = v.count - 9999
                if tempCount < 0 then
                    temp.count = v.count
                else
                    v.count = v.count - 9999
                    temp.count = 9999
                end 
                table.insert(awards,temp)
            end
        else
            table.insert(awards,v)
        end
    end 

    return awards
end

function QUIWidgetSoulTowerAwards:onExit()
end

function QUIWidgetSoulTowerAwards:initListView()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			-- body
			local itemConfig = db:getItemByID(itemBox._itemID)
			if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
				local actorId = db:getActorIdBySoulId( itemBox._itemID )
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", options = {actorId = actorId}}, {isPopCurrentDialog = false})
			else
				app.tip:itemTip(itemBox._itemType, itemBox._itemID)
			end
		end
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemInfo = self._items[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetQlistviewItem.new()
	            	isCacheNode = false
	            end

	            self:setItemInfo(item,itemInfo,index)
	            info.item = item
	            info.size = item._ccbOwner.parentNode:getContentSize()

			    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        spaceX = 10,
	        enableShadow = false,
	        isVertical = false,
	        totalNumber = #self._items,
	        autoCenter = true,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._items})
	end	

end

function QUIWidgetSoulTowerAwards:setItemInfo( item, data ,index)
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.7)
		item._itemBox:setPosition(ccp(35, 35))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(70, 70))

	end
	local id = data.id 
	local count = tonumber(data.count)
	local itemType = data.typeName

	item._itemBox:setGoodsInfo(id, itemType, count)

	local isNeed = remote.stores:checkMaterialIsNeed(tonumber(id), count)
    item._itemBox:showGreenTips(isNeed) 
	
end

function QUIWidgetSoulTowerAwards:getContentSize()
end

return QUIWidgetSoulTowerAwards
