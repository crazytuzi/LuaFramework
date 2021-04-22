-- @Author: liaoxianbo
-- @Date:   2020-05-21 16:39:18
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-24 12:24:04
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMallSkinItemBox = class("QUIWidgetMallSkinItemBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

function QUIWidgetMallSkinItemBox:ctor(options)
	local ccbFile = "ccb/Widget_ShopSkin_ItemBox.ccbi"
    local callBacks = {
    }
    QUIWidgetMallSkinItemBox.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._maskSize = self._ccbOwner.sp_mask:getContentSize()
	self._showDialoghandBook = false
	self._canBeBuy = false
	self:initNode()
end

function QUIWidgetMallSkinItemBox:onEnter()
end

function QUIWidgetMallSkinItemBox:onExit()
end

function QUIWidgetMallSkinItemBox:initNode()
	if self._heroCardSprite == nil then
        self._heroCardSprite = CCSprite:create()
	    local ccclippingNode = CCClippingNode:create()
	    local spriteStencil = CCSprite:create("ui/update_mall/sp_pf_di_mengban.png")
	    -- local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), self._maskSize.width, self._maskSize.height)
	    -- layer:setPosition(-self._maskSize.width/2, -self._maskSize.height/2)
	    -- spriteStencil:setPosition(-self._maskSize.width/2, -self._maskSize.height/2)
	    ccclippingNode:setAlphaThreshold(0.5)
	    ccclippingNode:setStencil(spriteStencil)
	    ccclippingNode:addChild(self._heroCardSprite)
	    self._ccbOwner.node_card:addChild(ccclippingNode)
	end
end

function QUIWidgetMallSkinItemBox:refreshState( )
	if q.isEmpty(self._shopInfo) then return end
	local itemNum = remote.items:getItemsNumByID(self._shopInfo.item_id)
	self._skinState = remote.heroSkin:checkItemSkinIsHave(self._shopInfo.item_id)
	local isHave = self._skinState == remote.heroSkin.ITEM_SKIN_ACTIVATED or itemNum > 0
	self._ccbOwner.node_buybtn:setVisible(not isHave)
	self._ccbOwner.node_price:setVisible(not isHave)
	self._ccbOwner.sp_ishave:setVisible(isHave)
	self._canBeBuy = not isHave
end

function QUIWidgetMallSkinItemBox:setItemBox(index,itemInfo, shopId,parentNode )
	if q.isEmpty(itemInfo) then return end

	self._ccbOwner.node_card:setVisible(itemInfo.shop_label == 2)
	self._ccbOwner.node_avart:setVisible(itemInfo.shop_label == 1)
	self._ccbOwner.node_normal:setVisible(itemInfo.shop_label == 1)
	self._ccbOwner.sp_isNewSkin:setVisible(itemInfo.is_new == 1)

	self._showHeroId = nil
	self._showHeroSkinId = nil
	self._shopInfo = itemInfo

	self:refreshState()

	self._shopId = shopId
	self._ccbOwner.node_fashion_title:removeAllChildren()
	self._ccbOwner.node_avart:removeAllChildren()
	self._ccbOwner.new_price:setString(itemInfo.resource_number_1 or 0)
	local itemConfig = db:getItemByID(itemInfo.item_id)
	if q.isEmpty(itemConfig) == false then
		local content = itemConfig.content
		if content then
			local skinTbl = string.split(content, "^")
			local skinInfo = remote.heroSkin:getSkinConfigDictBySkinId(skinTbl[2])
			if q.isEmpty(skinInfo) == false then
				self._showHeroId = skinInfo.character_id
				self._showHeroSkinId = skinInfo.skins_id
				if skinInfo.quality then
					local titlePath = remote.fashion:getHeadTitlePathByQuality( skinInfo.quality )
			    	if titlePath then
				    	local sp = CCSprite:create(titlePath)
				    	if sp then
				    		self._ccbOwner.node_fashion_title:addChild(sp)
				    	end
				    end					
				end
				if skinInfo.skins_card and itemInfo.shop_label == 2 then
					self._showDialoghandBook = true			
			    	local frame = QSpriteFrameByPath(skinInfo.skins_card)
			    	if frame then
			    		self._heroCardSprite:setDisplayFrame(frame)
						if skinInfo.handBook_display_shop then
							local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinInfo.handBook_display_shop)
							local _isturn = skinDisplaySetConfig.isturn or 1
							if skinDisplaySetConfig.x then
								self._heroCardSprite:setPositionX(skinDisplaySetConfig.x)
							end
							if skinDisplaySetConfig.y then
								self._heroCardSprite:setPositionY(skinDisplaySetConfig.y)
							end
							if skinDisplaySetConfig.scale then
								self._heroCardSprite:setScaleX(_isturn * skinDisplaySetConfig.scale)
								self._heroCardSprite:setScaleY(skinDisplaySetConfig.scale)
							end
							if skinDisplaySetConfig.rotation then
								self._heroCardSprite:setRotation(skinDisplaySetConfig.rotation)
							end
						end		   		
			    	end
			    else
			    	self._showDialoghandBook = false
	    		    self._avatar = QUIWidgetActorDisplay.new(self._showHeroId, {heroInfo = {skinId = self._showHeroSkinId}})
				    self._avatar:setScaleX(-(itemInfo.scale or 1))
				    self._avatar:setScaleY(itemInfo.scale or 1)
				    self._avatar:setPosition(ccp(itemInfo.offersetX or 0, itemInfo.offersetY or -80))
				    local ccclippingNode = CCClippingNode:create()
				    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), self._maskSize.width, self._maskSize.height)
				    layer:setPosition(-self._maskSize.width/2, -self._maskSize.height/2)
				    ccclippingNode:setAlphaThreshold(1)
				    ccclippingNode:setStencil(layer)
				    ccclippingNode:addChild(self._avatar)
				    self._ccbOwner.node_avart:addChild(ccclippingNode)					    
			    end

			    local charcterConfig = db:getCharacterByID(self._showHeroId)
			    if q.isEmpty(charcterConfig) == false then
			    	self._ccbOwner.tf_heroName:setString(charcterConfig.name or "")
			    	local nameWidth = self._ccbOwner.tf_heroName:getContentSize().width
			    	self._ccbOwner.tf_skinName:setString(skinInfo.skins_name or "")
			    	nameWidth = nameWidth+ self._ccbOwner.tf_skinName:getContentSize().width
			    	q.autoLayerNode({self._ccbOwner.tf_heroName,self._ccbOwner.tf_skinName}, "x", 0)
			    	self._ccbOwner.node_name:setPositionX(-120 - nameWidth/2)
			    end
			end
		end
	end
end

function QUIWidgetMallSkinItemBox:getContentSize()
	return self._ccbOwner.bg_size:getContentSize()
end

function QUIWidgetMallSkinItemBox:_clickHandBookCellHandler()
	-- if not self._showDialoghandBook then return end
    -- 选择英雄
    local selectActorId = tostring(self._showHeroId)
    local onlineHerosIDs = remote.handBook:getOnlineHerosID()
    local pos = 0
    for i, actorId in ipairs(onlineHerosIDs) do
        if actorId == selectActorId then
            pos = i
            break
        end
    end
    if pos > 0 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain",
            options = {herosID = onlineHerosIDs, pos = pos,isSkinShop = true,showSkinId=self._showHeroSkinId}})
    else
        app.tip:floatTip("敬请期待")
    end
end

function QUIWidgetMallSkinItemBox:_clickBuyItemHandler()
	if not self._canBeBuy then return end

	local buyItemFunc = function()
		local itemInfo = self._shopInfo
		local buyInfo = remote.exchangeShop:getShopBuyInfo(self._shopId)
		local buyNum = buyInfo[tostring(itemInfo.grid_id)] or 0

		local index = itemInfo.index
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverStoreDetail", 
			options = {shopId = self._shopId, itemInfo = itemInfo, index = index, callback = function( )
				self:refreshState()
			end}})
	end
	if self._skinState == remote.heroSkin.ITEM_SKIN_HAS then --礼包里面有此皮肤或者背包有
	    app:alert({content = "当前背包内有对应皮肤道具,快去激活吧！", title = "系统提示", btnDesc = {"前往激活","继续购买"},callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack"})
            elseif state == ALERT_TYPE.CANCEL then
            	buyItemFunc()
            end
        end})
        return
	end

	buyItemFunc()

end

return QUIWidgetMallSkinItemBox
