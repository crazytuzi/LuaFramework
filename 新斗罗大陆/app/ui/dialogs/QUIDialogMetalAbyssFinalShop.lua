local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalAbyssFinalShop = class("QUIDialogMetalAbyssFinalShop", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetMetalAbyssFinalShop = import("..widgets.QUIWidgetMetalAbyssFinalShop")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
function QUIDialogMetalAbyssFinalShop:ctor(options)
	local ccbFile = "ccb/Dialog_MetalAbyss_FinalShop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
    QUIDialogMetalAbyssFinalShop.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false 

    self._userInfo = options.userInfo

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)

end


function QUIDialogMetalAbyssFinalShop:viewDidAppear()
    QUIDialogMetalAbyssFinalShop.super.viewDidAppear(self)
    self:setInfo()
end

function QUIDialogMetalAbyssFinalShop:viewWillDisappear()
    QUIDialogMetalAbyssFinalShop.super.viewWillDisappear(self)
   
end

--[[
	curDiscount 折扣
	costNum 	购买价格
	name 		货品名称

	count 		购买数量
	id 			道具id
	itemType	道具类型
--]]
function QUIDialogMetalAbyssFinalShop:setInfo()
	self._items = {}

	local infos = remote.metalAbyss:getAbyssWaveShopInfo()
-- message AbyssShopInfo {
--     optional int32 id = 1; //量表id
--     optional int32 index = 2; //哪个物品的index
--     optional int32 buyCount = 3; //购买次数
-- }
	for i,v in ipairs(infos) do
		local dataConfig = remote.metalAbyss:getMetalAbyssFinalRewardById(v.id)
		local index = v.index
		local info = {}
		info.curDiscount = dataConfig["discount_"..index] and dataConfig["discount_"..index] or 100
		info.costNum = dataConfig["resource_number_"..index]
		info.costType = dataConfig["resource_"..index]
		info.count = dataConfig["num_"..index]
		info.id = dataConfig["id_"..index]
		info.itemType = dataConfig["type_"..index]
		info.name =""
		info.canBuy = v.buyCount == nil or v.buyCount < 1
		info.gridId = i
		-- QPrintTable(info)
		table.insert( self._items, info )
	end

	self:initListView()
end


function QUIDialogMetalAbyssFinalShop:initListView()
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_content:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	-- self._ccbOwner.node_no:setVisible(not next(self._items))
	
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderCallBack),
	        curOriginOffset = 7,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = false,
	      	spaceY = 0,
	      	spaceX = 10,
	      	isVertical = false,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end
end

function QUIDialogMetalAbyssFinalShop:_renderCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._items[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetMetalAbyssFinalShop.new()
		item:addEventListener(QUIWidgetMetalAbyssFinalShop.EVENT_BUY_REWARD, handler(self,self.clickGetHandler))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    list:registerBtnHandler(index, "btn_buy", "_onTriggerGet", nil, "true")
    item:registerItemBoxPrompt(index, list)
    
    return isCacheNode
end

function QUIDialogMetalAbyssFinalShop:clickGetHandler(event)
	local info = event.info
	if not info then
		return
	end
	if info.canBuy == false then
		app.tip:floatTip("已购买")
		return
	end
	if info.costType then
		local currencyInfo = remote.items:getWalletByType(info.costType)
		local money = remote.user[currencyInfo.name] or 0
		if money < info.costNum  then

			if "token" == info.costType then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			else
				QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, info.costType, info.costNum)
			end

			return
		end
	end

	--购买对应的货品

	remote.metalAbyss:abyssBuyGoodRequest(info.gridId,function(data)
		local awards =  data.prizes or {}
		if data.wallet then
			remote.user:update(data.wallet)
		end
		if data.items then 
			remote.items:setItems(data.items) 
		end
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
                if self:safeCheck() then

                	remote.metalAbyss:setAbyssWaveShopInfoBuyTimes(info.gridId)
                    self:setInfo()
                end
    		end}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜获得金属深渊奖励")
		end,function(  )
			-- body
		end)
end

function QUIDialogMetalAbyssFinalShop:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
	if self._callback then
		self._callback()
	end

end

return QUIDialogMetalAbyssFinalShop