

local QUIWidget = import(".QUIWidget")
local QUIWidgetHighTeaMenu = class("Widget_HighTea_Menu", QUIWidget)
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
QUIWidgetHighTeaMenu.EVENT_FOOD_MADE ="EVENT_FOOD_MADE"

function QUIWidgetHighTeaMenu:ctor(options)
	local ccbFile = "ccb/Widget_HighTea_Menu.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
	QUIWidgetHighTeaMenu.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
  
end


function QUIWidgetHighTeaMenu:onEnter()
	QUIWidgetHighTeaMenu.super.onEnter(self)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetHighTeaMenu:onExit()
	QUIWidgetHighTeaMenu.super.onExit(self)
	if self.prompt ~= nil then
    	self.prompt:removeItemEventListener(self)
    	self.prompt = nil
    end
end

function QUIWidgetHighTeaMenu:setInfo(info)
	self._info = info
	self:_handleData()
	self:_initListView()

	local canCook = self._info.canCook > 0

	if canCook then
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	end

end

function QUIWidgetHighTeaMenu:_handleData()
	local config = remote.activity:getHighTeaFoodConfigById(id)
	self._awards = {}

	local itemType = ITEM_TYPE.ITEM
    if tonumber(self._info.itemId) == nil then
        itemType = remote.items:getItemType(self._info.itemId)
    end
	table.insert(self._awards, {oType = "item", id = self._info.itemId, typeName = itemType, count = 1 ,isFood = true , isLike = self._info.isLike})
	table.insert(self._awards, {oType = "equal", id = QResPath("sp_new_word_equal"), width = 30,scale = 1})

	for i,v in ipairs(self._info.awardsTbl or {}) do
		itemType = ITEM_TYPE.ITEM
		if tonumber(v) == nil then
			itemType = remote.items:getItemType(v)
		end
		table.insert(self._awards, {oType = "item", id = v, typeName = itemType, count = 1  ,isFood = false})
		if i < #self._info.awardsTbl then
			table.insert(self._awards, {oType = "plus", id = QResPath("sp_new_word_add"), width = 10 ,scale = 1})
		end
	end

end


function QUIWidgetHighTeaMenu:_initListView()
	if not self._listView then
		-- local function showItemInfo(x, y, itemBox, listView)
		-- 	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		-- end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
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
				
				--注册事件
                -- list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        spaceX = 20,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._awards,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._awards , isCleanUp = true})
	end 
end

function QUIWidgetHighTeaMenu:setItemInfo( item, data ,index)
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setScale(0.85)
			item._itemBox:setPosition(ccp(40, 40))
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(80, 80))
			item._itemBox:setShowGoodsNameColor(COLORS.j)
			item._itemBox:setGoodsNamePosY(-45)
			item._itemBox:setGoodsNameScale(0.8)
		end

		local id = data.id 
		local count = tonumber(data.count)
		-- local itemType = remote.items:getItemType(id)
		local itemType = data.typeName 
		local num = remote.items:getItemsNumByID(id) or 0


		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			item._itemBox:setGoodsInfo(id, itemType, count)
		else
			item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
			if data.isNeedShowItemCount then
				item._itemBox:setItemCount(string.format("%d/%d",num, count))
			end
		end
		local name = item._itemBox:getItemName()

		if not  data.isFood then
			name = name.."(拥有："..num..")"
			if num > 0 then
				makeNodeFromGrayToNormal(item._itemBox)
			else
				makeNodeFromNormalToGray(item._itemBox)
			end

		end

		if data.isLike ~= nil then
			if item._loveSprite == nil then
				item._loveSprite = CCSprite:create(QResPath("sp_love"))
				item._loveSprite:setScale(0.6)
				item._loveSprite:setPosition(ccp(13,65))
				item._ccbOwner.parentNode:addChild(item._loveSprite)
			end
			item._loveSprite:setVisible(false)
			if data.isLike and data.isFood  then
				item._loveSprite:setVisible(true)
			end
		end

		item._itemBox:setName(name)
		-- if data.specialAwards then
		-- 	item._itemBox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
		-- 	-- item._itemBox:showBoxEffect("effects/Auto_Skill_light.ccbi",true, 0, -5, 1.2)
		-- end

		local isNeed = remote.stores:checkMaterialIsNeed(tonumber(id), count)
        item._itemBox:showGreenTips(isNeed) 
	else
		if not item._sprite then
			local sprite = CCSprite:create(data.id)
			item._sprite = sprite
			item._ccbOwner.parentNode:addChild(sprite)
		else
			local frame  = QSpriteFrameByPath(data.id)
			if frame then
				item._sprite:setDisplayFrame(frame)
			end
		end
		local width = 30
		if data.width then
			width = data.width
		end 
		if data.scale then
			item._sprite:setScale(data.scale )
		end

		item._ccbOwner.parentNode:setContentSize(CCSizeMake(width, 80))
		item._sprite:setPosition(width/2, 30)
	end
end

function QUIWidgetHighTeaMenu:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end


function QUIWidgetHighTeaMenu:_onTriggerOK(event)
	self:dispatchEvent({name = QUIWidgetHighTeaMenu.EVENT_FOOD_MADE , info = self._info })
end

function QUIWidgetHighTeaMenu:getContentSize( ... )
	return cc.size(self._ccbOwner.node_size:getContentSize().width + 2 ,self._ccbOwner.node_size:getContentSize().height )
end


return QUIWidgetHighTeaMenu