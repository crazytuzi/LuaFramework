-- @Author: liaoxianbo
-- @Date:   2020-05-06 15:36:12
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-18 13:27:11
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSpecialAwards = class("QUIWidgetSpecialAwards", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QRichText = import("...utils.QRichText")

function QUIWidgetSpecialAwards:ctor(options)
	local ccbFile = "ccb/Widget_Special_Awards.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSpecialAwards.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._specialItems = self:sortSameAwrads(options.awards or {})
	self._ccbOwner.tf_title_name:setString(options.title or "")

	if options.subtitle then
		self._ccbOwner.node_lablel:removeAllChildren()
		local richText1 = QRichText.new(nil, 623,{autoCenter = true})
		richText1:setString(options.subtitle)
	   	richText1:setAnchorPoint(ccp(0.5, 0.5))
		self._ccbOwner.node_lablel:addChild(richText1)

		self._ccbOwner.sheet:setPositionY(self._ccbOwner.sheet:getPositionY()- 40)
	end
end

function QUIWidgetSpecialAwards:sortSameAwrads(awards)
    --合并相同的道具
    local tempAwards = {}
    local tempAwards2 = {}
    local index = 1
    for _,v in pairs(awards) do
    	if tempAwards[v.id] then
    		tempAwards[v.id].count = tempAwards[v.id].count + v.count
    	else
    		tempAwards[v.id] = {id = v.id,count = v.count,typeName = v.typeName}
    	end
    end
    for _,v in pairs(tempAwards) do
    	table.insert(tempAwards2, v)
    end
    return tempAwards2
end

function QUIWidgetSpecialAwards:onEnter()
	self:initListView()
end

function QUIWidgetSpecialAwards:onExit()
end

function QUIWidgetSpecialAwards:initListView()
	if not self._allListView then
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
	            local itemInfo = self._specialItems[index]
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
	        totalNumber = #self._specialItems,
	        autoCenter = true,
		}
		self._allListView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._allListView:reload({totalNumber = #self._specialItems})
	end	

end


function QUIWidgetSpecialAwards:setItemInfo( item, data ,index)
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
	
end

function QUIWidgetSpecialAwards:getContentSize()
end

return QUIWidgetSpecialAwards
