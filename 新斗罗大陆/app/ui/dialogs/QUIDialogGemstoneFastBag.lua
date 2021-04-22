local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneFastBag = class("QUIDialogGemstoneFastBag", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetGemstoneFastBagItem = import("..widgets.QUIWidgetGemstoneFastBagItem")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogGemstoneFastBag:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_zhuangbei.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClickNoWear)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClickWear)},
		{ccbCallbackName = "onTriggerLink", callback = handler(self, self._onTriggerLink)},
	}
	QUIDialogGemstoneFastBag.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.node_no:setVisible(false)
	q.setButtonEnableShadow(self._ccbOwner.btn_spar_shop)
	q.setButtonEnableShadow(self._ccbOwner.btn_gemstone_shop)

	self._canType = clone(options.canType)
	self._selfType = options.selfType
	self._quality = options.quality
	if self._canType == nil then
		self._canType = {true,true,true,true}
	end
	if self._selfType ~= nil then
		self._canType[self._selfType] = true
	end
	self._actorId = options.actorId
	self._pos = options.pos

	self._suits = {}
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if heroInfo.gemstones ~= nil then
		for _,gemstone in ipairs(heroInfo.gemstones) do
			if gemstone.position ~= self._pos then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
				self._suits[itemConfig.gemstone_set_index] = true
			end
		end
	end
	self:selectNoWear()
end

function QUIDialogGemstoneFastBag:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._gemstones,
	        spaceY = -12,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._gemstones})
	end
	self._ccbOwner.node_no:setVisible(#self._gemstones == 0)
end

function QUIDialogGemstoneFastBag:renderFunHandler( list, index, info )
    local isCacheNode = true
    local gemstone = self._gemstones[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetGemstoneFastBagItem.new()
        isCacheNode = false
    end
    
    info.item = item
    info.size = item:getContentSize()
	item:setInfo(gemstone, self._actorId)
	if gemstone.position == nil or gemstone.position == 0 then
		if self._canType ~= nil and self._canType[gemstone.gemstoneType] == false then
			item:setDuplicateVisible(true)
	    else
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
			if self._suits[itemConfig.gemstone_set_index] and not gemstone.isFragment then
				item:setSuitVisible(true)
			end
			if self._quality and itemConfig.gemstone_quality > self._quality then
				item:setTuijianVisible(true)
			end
		end
	end
    list:registerBtnHandler(index,"btn_wear", handler(self, self.clickWearHandler), nil, true)
    list:registerBtnHandler(index,"btn_icon", handler(self, self.clickIconHandler))
    list:registerBtnHandler(index, "btn_info", "_onTriggerInfo", nil, true)
    return isCacheNode
end

--点击装备
function QUIDialogGemstoneFastBag:clickWearHandler(x, y, touchNode, listView )
	local index = listView:getCurTouchIndex()
   	self:wearGemstone(index)
end

function QUIDialogGemstoneFastBag:wearGemstone(index)
    local gemstone = self._gemstones[index]
    if gemstone.isFragment then
    	remote.gemstone:gemstoneComposeRequest(gemstone.itemId, function (data)
	    		if self:safeCheck()	then
					local awards = {{id = data.gemstones[1].itemId, typeName = ITEM_TYPE.GEMSTONE, count = 1}}
				    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
				        options = {awards = awards, isVip = isVip}},{isPopCurrentDialog = false} )
				    dialog:setTitle("恭喜您成功合成魂骨")
			    	self:selectNoWear()
				end
			end)
	    return
    end

    if self._canType ~= nil and self._canType[gemstone.gemstoneType] == false then
        app.tip:floatTip("魂师大人，魂师不能装备同类魂骨，请为魂师装备别的魂骨~") 
        return
    end
    self._sid = gemstone.sid
	self:playEffectOut()
end

function QUIDialogGemstoneFastBag:clickIconHandler(x, y, touchNode, listView )
	local index = listView:getCurTouchIndex()
    local gemstone = self._gemstones[index]
    if gemstone.isFragment then
    	app.tip:itemTip(ITEM_TYPE.GEMSTONE_PIECE, gemstone.id)
    else
    	app.tip:gemstoneTip(ITEM_TYPE.GEMSTONE, gemstone.sid)
    end
end

--选择未穿戴
function QUIDialogGemstoneFastBag:selectNoWear()
	local gemstones = {}
	local sparInfo = remote.gemstone:getGemstoneByWear(false)
	local sparPieceInfo = db:getItemsByCategory(ITEM_CONFIG_CATEGORY.GEMSTONE_PIECE)
	for i, v in pairs(sparInfo) do
		local info = clone(v)
		info.isFragment = false
		table.insert(gemstones, info)
	end
	for i, v in pairs(sparPieceInfo) do
		local info = clone(v)
		info.isFragment = true
		table.insert(gemstones, info)
	end

	self._gemstones = self:updateHaveItems(gemstones)
	self:shortGemStone()
	self:_setSelectByIndex(1,true)
	self:_setSelectByIndex(2,false)
	self:initListView()
end

function QUIDialogGemstoneFastBag:updateHaveItems(gemstones)
    local tbl = {}
    for i, v in pairs(gemstones) do
        if v.isFragment then
        	local num = remote.items:getItemsNumByID(v.id)
            local itemInfo = remote.gemstone:getStoneCraftInfoByPieceId(v.id)
            if itemInfo and itemInfo.component_id_1 == v.id then 
                local needCount = itemInfo.component_num_1
                if num >= needCount then
					v.itemId = itemInfo.item_id
					v.count = num
                    table.insert(tbl, v) 
                end
            end
        else
            table.insert(tbl, v)        
        end
    end
    return tbl
end

--选择已穿戴
function QUIDialogGemstoneFastBag:selectWear()
	self._gemstones = remote.gemstone:getGemstoneByWear(true)
	self:shortGemStone()
	self:_setSelectByIndex(1,false)
	self:_setSelectByIndex(2,true)
	self:initListView()
end

--为gemstone排序
function QUIDialogGemstoneFastBag:shortGemStone()
	if self._actorId ~= nil then
		local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
		table.sort(self._gemstones, function (a, b)
			if a.isFragment and b.isFragment then
	            if a.colour == b.colour then
	                local na = remote.items:getItemsNumByID(a.id)
	                local nb = remote.items:getItemsNumByID(b.id)
	                if na == nb then
	                    return a.id < b.id
	                else
	                    return na > nb
	                end
	            else
	                return a.colour > b.colour
	            end
	        elseif a.isFragment ~= b.isFragment then
	            return a.isFragment
	        else
				local canA = self._canType[a.gemstoneType]
				local canB = self._canType[b.gemstoneType]
				if canA ~= canB then
					return canA == true
				end
				if a.gemstoneQuality ~= b.gemstoneQuality then
					return a.gemstoneQuality > b.gemstoneQuality
				end
				if canA == true then
					local suitA = UIHeroModel:checkCanSuit(a.itemId)
					local suitB = UIHeroModel:checkCanSuit(b.itemId)
					if suitA ~= suitB then
						return suitA == true
					end
				end
				if a.craftLevel ~= b.craftLevel then
					return a.craftLevel > b.craftLevel
				end
				if a.level ~= b.level then
					return a.level > b.level
				end
				return a.sid > b.sid
			end
		end)
	end
end

function QUIDialogGemstoneFastBag:_setSelectByIndex(index, isSelect)
    self._ccbOwner["btn_award_"..index]:setHighlighted(isSelect)
    self._ccbOwner["btn_award_"..index]:setEnabled(not isSelect)
end

function QUIDialogGemstoneFastBag:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGemstoneFastBag:_onTriggerClickNoWear(e)
	if e ~= nil then
		app.sound:playSound("common_menu")
	end
	self:selectNoWear()
end

function QUIDialogGemstoneFastBag:_onTriggerClickWear(e)
	if e ~= nil then
		app.sound:playSound("common_menu")
	end
	self:selectWear()
end

function QUIDialogGemstoneFastBag:_onTriggerLink(e)
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIDialogGemstoneFastBag:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:enableTouchSwallowTop()
	self:playEffectOut()
end

function QUIDialogGemstoneFastBag:viewAnimationOutHandler()
	local sid = self._sid
	local actorId = self._actorId
	local pos = self._pos
	QUIDialogGemstoneFastBag.super.viewAnimationOutHandler(self)
	if sid ~= nil then
	    remote.gemstone:gemstoneLoadRequest(sid, 1, actorId, pos, function ()
	    	remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_WEAR, sid = sid, actorId = actorId})
	    end)
	end
end

return QUIDialogGemstoneFastBag