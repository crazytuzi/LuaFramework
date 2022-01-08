-- 商城，购物中心管理器
-- Author: david.dai
-- Date: 2014-06-11 20:46:08
--

local MallManager = class('MallManager')
--随机商店事件键值
MallManager.RefreshSingleRandomStore = "MallManager.RefreshSingleRandomStore"
MallManager.RefreshAllRandomStore = "MallManager.RefreshAllRandomStore"
MallManager.BuySuccessFromRandomStore = "MallManager.BuySuccessFromRandomStore"
MallManager.BuyCoinCallBackEvent = "MallManager.BuyCoinCallBackEvent"
MallManager.ReceiveTraveBusiness = "MallManager.ReceiveTraveBusiness"
MallManager.ReceiveTraveBusinessBuyResult = "MallManager.ReceiveTraveBusinessBuyResult"

--随机商店种类数量
MallManager.kTotalRandomStoreTypeLength = 1

function MallManager:ctor()
	--随机商店列表
	self.randomStoreTable = {}

	self.travelBusiness = {} -- 游方商人
	--注册网络事件
	TFDirector:addProto(s2c.BUY_SUCCESS_NOTIFY, self, self.fixedStoreBuySuccessCallback);
	TFDirector:addProto(s2c.GET_HAS_PURCHASED, self, self.getHasPurchasedCallback);

	TFDirector:addProto(s2c.RANDOM_STORE_BUY_SUCCESS_NOTIFY, self, self.randomStoreBuySuccessCallback);
    TFDirector:addProto(s2c.RANDOM_STORE, self, self.refreshSingleRandomStoreCallback)
    TFDirector:addProto(s2c.ALL_RANDOM_STORE, self, self.refreshAllRandomStoreCallback)
    TFDirector:addProto(s2c.RANDOM_MALL_OPEN , self, self.refreshRandomStoreOpenCallback)

    -- 
    TFDirector:addProto(s2c.COUNT_BUY_COIN_RESULT , self, self.buyCoinResultCallback)
    TFDirector:addProto(s2c.USED_BUY_COIN_COUNT , self, self.UpdateCoinNumCallback)


    -- gift item
    TFDirector:addProto(s2c.SHOP_GIFT_INFO_LIST , self, self.UpdateGiftShopItemList)
    TFDirector:addProto(s2c.SHOP_GIFT_INFO , self, self.UpdateGiftShopItem)

    --mysteryshop
    TFDirector:addProto(s2c.MYSTERY_SHOP_LIST , self, self.receiveMysteryShopList)
    TFDirector:addProto(s2c.MYSTERY_SHOP_BUY_RESULT, self, self.receiveMysteryBuyResult)


    self.buyCoinNum = 0
    self.buyCoinResultList = TFArray:new()

    -- 
    self.GiftItmeList = MEMapArray:new()
end

-----------------------------------------------随机商店--------------------------------------------------

--创建随机商店
function MallManager:createRandomStore(networkData)
	local shop = requireNew("lua.gamedata.base.RandomStore"):new(networkData.type)
	shop:setAutoRefreshRemaining(networkData.nextAutoRefreshTime)
	shop:setRefreshCost(networkData.nextRefreshCost)
	shop:setManualRefreshCount(networkData.manualRefreshCount)
	if networkData.opentime then
		shop:setOpentime(networkData.opentime)
		shop:setOpenState(true)
	else
		shop:setOpenState(false)
	end
	--生成商品列表
	local commodityList,haveNotBuy = self:createCommodityList(networkData)
	shop:setCommodityList(commodityList)
	if haveNotBuy then
		local day_hour = math.floor(shop:getAutoRefreshTime() / 3600)
		if not shop.randomShopNextTime or shop.randomShopNextTime ~= day_hour then
			shop.randomShopNextTime = day_hour
			shop.newRandomShopMark = true
		end
	end
	return shop
end

--创建随机商品列表
function MallManager:createCommodityList(data)
	local index = 1
	local commodityList = {}
	local haveNotBuy = false
	if data.commodity and data.commodity ~= NULL then
		for _,tmp in pairs(data.commodity) do
			local commodity = self:createCommodity(tmp)
			commodityList[index] = commodity
			index = index + 1

			--红点逻辑
			if commodity:getNumber() > 0 then
				haveNotBuy = true
			end
		end
	end
	return commodityList,haveNotBuy
end

--创建随机商品
function MallManager:createCommodity(data)
	local commodity = requireNew("lua.gamedata.base.RandomCommodity"):new(data)
	return commodity
end

--重置随机商品列表
function MallManager:resetCommodityList(store,data)
	local index = 1
	local commodityList = store:getCommodityList() or {}
	local exist = nil
	local haveNotBuy = false
	if data.commodity and data.commodity ~= NULL then
		for _,tmp in pairs(data.commodity) do
			exist = commodityList[index]
			if exist then
				exist:setData(tmp)
			else
				local commodity = self:createCommodity(tmp)
				commodityList[index] = commodity
			end
			index = index + 1

			--红点逻辑
			if commodityList[index] and commodityList[index]:getNumber() > 0 then
				haveNotBuy = true
			end
		end
	end

	if haveNotBuy then
		local day_hour = math.floor(store:getAutoRefreshTime() / 3600)
		if not store.randomShopNextTime or store.randomShopNextTime ~= day_hour then
			store.randomShopNextTime = day_hour
			store.newRandomShopMark = true
		end
	end
	return commodityList
end

--添加随机商店
function MallManager:addRandomStore(networkData)
	local store = self.randomStoreTable[networkData.type]
	if store then
		self:resetCommodityList(store,networkData)
		store:setAutoRefreshRemaining(networkData.nextAutoRefreshTime)
		store:setRefreshCost(networkData.nextRefreshCost)
		store:setManualRefreshCount(networkData.manualRefreshCount)
		if networkData.opentime then
			store:setOpentime(networkData.opentime)
			store:setOpenState(true)
		else
			store:setOpenState(false)
		end
		--print("reset random store : ",store.type)
	else
		store = self:createRandomStore(networkData)
		self.randomStoreTable[store.type] = store
		--print("add random store : ",store.type)
	end
	return store
end

--重置所有随机商店
function MallManager:resetAllRandomStore(networkData)
	if self.randomStoreTable and #self.randomStoreTable > 0 then
		for _,v in pairs(self.randomStoreTable) do
			self:addRandomStore(v)
		end
	end
end

--获取随机商店列表
function MallManager:getrandomStoreTable()
	return self.randomStoreTable
end

--获取随机特定类型的商店
function MallManager:getRandomStoreByType(type)
	--print("MallManager:getRandomStoreByType(type)",type)
	return self.randomStoreTable[type]
end

--------------------------------随机商店网络相关处理---------------------------------------
--请求服务器刷新特定类型的随机商店
function MallManager:requestRefreshRandomStoreByType(type)
	print("请求服务器刷新特定类型的随机商店 type = ", type)
	showLoading();
    TFDirector:send(c2s.REFRESH_RANDOM_STORE,{type})
end

--请求服务器刷新所有随机商店
function MallManager:requestGetAllRandomStore()
    TFDirector:send(c2s.GET_ALL_RANDOM_STORE,{})
end

--请求服务器获取特定类型的随机商店
function MallManager:requestGetRandomStoreByType(type)
	showLoading();
    TFDirector:send(c2s.GET_RANDOM_STORE,{type})
end

--刷新单个随机商店，网络事件回调
function MallManager:refreshSingleRandomStoreCallback(event)
	--print("----------------------------------------------------------------------")
	--print("MallManager:refreshSingleRandomStoreCallback(event)")
	--print("----------------------------------------------------------------------")
	local data = event.data
	self:addRandomStore(data)
	hideLoading()
	-- print("data : ",data)
	TFDirector:dispatchGlobalEventWith(MallManager.RefreshSingleRandomStore , data)
end
--随机商店开启，网络事件回调
function MallManager:refreshRandomStoreOpenCallback(event)
	--print("----------------------------------------------------------------------")
	--print("MallManager:refreshRandomStoreOpenCallback(event)")
	--print("----------------------------------------------------------------------")
	local data = event.data
	local store = self.randomStoreTable[data.type]
	if store then
		if data.opentime then
			store:setOpenState(true)
			store:setOpentime(data.opentime)
			-- toastMessage(store.configure.name .. "开启")
			toastMessage(stringUtils.format(localizable.MallManager_mall_open, store.configure.name))
		end
	end
end

--刷新所有随机商店，网络事件回调
function MallManager:refreshAllRandomStoreCallback(event)
	--print("----------------------------------------------------------------------")
	--print("MallManager:refreshAllRandomStoreCallback(event)")
	--print("----------------------------------------------------------------------")
	local data = event.data
	self:resetAllRandomStore(data)
	TFDirector:dispatchGlobalEventWith(MallManager.RefreshAllRandomStore , data)
end

--------------------------------------------------固定商店-------------------------------------------------
--固定商店事件键值
MallManager.BuySuccessFromFixedStore = "MallManager.BuySuccessFromFixedStore"

--获取固定商店所有商品列表
function MallManager:getFixedStoreCommodityList()
	local list = TFArray:new()
	for v in ShopData:iterator() do
		if self:isSellBox(v) then
			if v:isLimiteTime() then
				print("v.begin_time = ",v.begin_time)
				print("v.end_time = ",v.end_time)
				if GetGameTime() >= timestampTodata(v.begin_time) and GetGameTime() < timestampTodata(v.end_time) then
					list:pushBack(v)
				end
			else
				list:pushBack(v)
			end
		end
	end
	return list
end

--是否售完的礼包
function MallManager:isSellBox( shop )
	local item = ItemData:objectByID(shop.res_id)
	if item and item.type == EnumGameItemType.Box and shop:isLimited() then
		local now_count = self:getPurchasedCount(shop.id)
		local max_num = shop:getMaxNum(MainPlayer:getVipLevel())
		--max_num = math.min(max_num,maxNumYouCanBuy)
		-- print("shop limited : ",max_num,now_count)
		if now_count >= max_num then
			return false
		end
	end

	return true
end

--获取固定商店特定类型的商品列表
function MallManager:getFixedStoreCommodityListByType(type)
	local list = TFArray:new()
	for v in ShopData:iterator() do
		if type == v.type then
			if v:isLimiteTime() then
				if GetGameTime() >= timestampTodata(v.begin_time) and GetGameTime() < timestampTodata(v.end_time) then
					list:pushBack(v)
				end
			else
				list:pushBack(v)
			end
		end
	end
	return list
end

--获取固定商店中所有礼包商品
function MallManager:getFixedSotreForGiftsOnly()
	local list = TFArray:new()
	for v in ShopData:iterator() do
		if EnumShopType.Box == v.type then
			if v:isLimiteCount() then
				local purchasedLogs = self.purchasedLogs or {}
				purchasedLogs[v.id] = purchasedLogs[v.id] or 0
				if purchasedLogs[v.id] == 0 or purchasedLogs[v.id] < v:getMaxNum(MainPlayer:getVipLevel()) then
					if v:isLimiteTime() then
						if GetGameTime() >= timestampTodata(v.begin_time) and GetGameTime() < timestampTodata(v.end_time) then
							list:pushBack(v)
						end
					else
						list:pushBack(v)
					end
				end
			else
				if v:isLimiteTime() then
					if GetGameTime() >= timestampTodata(v.begin_time) and GetGameTime() < timestampTodata(v.end_time) then
						list:pushBack(v)
					end
				else
					list:pushBack(v)
				end
			end
		end
	end
	return list
end

--加载我的个人商品（限制）购买日志
function MallManager:loadingMyPurchasedLogs(callback)
	showLoading()
	self.loadingMyPurchasedLogsCallback = callback
	TFDirector:send(c2s.GET_FIXED_STORE ,{})

	--if self.purchasedLogs == nil then
	--	showLoading()
	--	TFDirector:send(c2s.GET_FIXED_STORE ,{}) 
	--else
	--	self:loadingCompleteCallback()
	--end
end

--获取限制购买的商品列表
function MallManager:getPurchasedLogs()
	return self.purchasedLogs
end

--获取已经购买的数量
function MallManager:getPurchasedCount(id)
	if self.purchasedLogs == nil then
		self:loadingMyPurchasedLogs()
		print("shop 111")
		return 0
	else
		local count = self.purchasedLogs[id] or 0
		print("shop count = ", count)
		return count
	end
end

--获取已经购买商品的回调函数，由网络层回调
function MallManager:getHasPurchasedCallback(event)
	local data = event.data
	self.purchasedLogs = {}
	if data.commodity then
		for _,v in pairs(data.commodity) do
			self.purchasedLogs[v.commodityId] = v.num
		end
	end
	
	if self.loadingMyPurchasedLogsCallback then
		hideLoading()
		local fuc = self.loadingMyPurchasedLogsCallback
		self.loadingMyPurchasedLogsCallback = nil
		fuc()
	else
		hideLoading()
		self:loadingCompleteCallback()
	end
end

--获取商品现在的价格
function MallManager:getNowPrice(id)
	local shop = ShopData:objectByID(id)
	if shop == nil then
		print("无法找到该物品 id ==" ..id)
		return
	end
	local now_price = shop.consume_number
	if shop.consume_add ~= 0 then
		local now_num = self.purchasedLogs[id] or 0
		now_price = now_price + now_num*shop.consume_add
	end
	return now_price
end

--获取商品的总价
function MallManager:getTotalPrice(id,num)
	local shop = ShopData:objectByID(id)
	if shop == nil then
		print("无法找到该物品 id ==" ..id)
		return
	end
	local total_price = num * shop.consume_number
	if shop.consume_add ~= 0 then
		local now_price = self:getNowPrice(id)
		total_price = (now_price + now_price + shop.consume_add * (num-1))*num/2
	end
	return total_price
end
--获取商品的总价
function MallManager:getTotalOldPrice(id,num)
	local shop = ShopData:objectByID(id)
	if shop == nil then
		print("无法找到该物品 id ==" ..id)
		return
	end
	if not shop.old_price or shop.old_price <= 0 then
		print("该商品没有优惠 id ==" ..id)
		return
	end
	local now_price = shop.old_price
	if shop.consume_add ~= 0 then
		local now_num = self.purchasedLogs[id] or 0
		now_price = now_price + now_num*shop.consume_add
	end
	local total_price = num * shop.old_price
	if shop.consume_add ~= 0 then
		local now_price = self:getNowPrice(id)
		total_price = (now_price + now_price + shop.consume_add * (num-1))*num/2
	end
	return total_price
end

--计算玩家最多能够买多少个目标商品,消耗完对应资源最多能购买的个数
function MallManager:calculateMaxNumberCanBuy(id)
	local shop = ShopData:objectByID(id)
	if shop == nil then
		print("无法找到该物品 id ==" ..id)
		return 0
	end

	if shop.consume_number < 1 then
		print("[非法价格]-商品的价格小于1" ..id)
		return 0
	end

	local currentResValue = MainPlayer:getResValueByType(shop.consume_type)
	if shop.consume_add ~= 0 then
		local total_price = 0
		local now_price = self:getNowPrice(id)
		local num = 1
		local mark = true
		while mark do
			total_price = (now_price + now_price + shop.consume_add * (num-1))*num/2
			if total_price > currentResValue then
				num = num -1
				break
			elseif total_price == currentResValue then
				break
			end
			num = num + 1
		end
		return num
	else
		return math.floor(currentResValue/shop.consume_number)
	end
end
---------------------------------------------------通用方法----------------------------------------------

function MallManager:restart()
	--self.purchasedLogs = nil
	-- TFDirector:unRequire('lua.table.t_s_gift_shop')
	-- ShopData = require('lua.table.t_s_gift_shop')			--商店
	-- BaseDataManager:BindShopData()

	-- print("MallManager:restart() len = ", ShopData:length())

	ShopData:clear()
end

--打开商城首页
function MallManager:openRecruitLayer()
	local layer = AlertManager:addLayerByFile("lua.logic.mall.RecruitLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
end

function MallManager:openMallLayer(defaultIndex)
	self.defaultIndex = defaultIndex
	self:loadingMyPurchasedLogs()
end

function MallManager:openMallLayerByType(type,index)
	local layer = AlertManager:addLayerByFile("lua.logic.mall.MallLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
    layer:showInfo(type,index or 1)
end

function MallManager:openGiftsShop()
	self.defaultIndex = 2
	self:loadingMyPurchasedLogs()
end

function MallManager:loadingCompleteCallback()
	local layer = AlertManager:addLayerByFile("lua.logic.mall.MallLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
    
    if self.defaultIndex then
    	layer:showInfo(EnumMallType.NormalMall,self.defaultIndex)
    end
    self.defaultIndex = nil
end

function MallManager:openQunHaoShopHome()
	local layer = AlertManager:addLayerByFile("lua.logic.mall.MallLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
    layer:showInfo(EnumMallType.QunHaoMall,1)
end

function MallManager:openFactionMallLayer()
	local layer = AlertManager:addLayerByFile("lua.logic.mall.MallLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
    layer:showInfo(EnumMallType.FactionMall,1)
end

function MallManager:openCardRoleMallLayer()
	local layer = AlertManager:addLayerByFile("lua.logic.mall.MallLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
    layer:showInfo(EnumMallType.CardRoleMall,1)
end

function MallManager:openYouFangLayer()
	if not self:getTravelBusinessData() then
		toastMessage(localizable.youfangLayer_no_data)
		return
	end

	local layer = AlertManager:addLayerByFile("lua.logic.shop.YouFangLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
	AlertManager:show()
end

---------------------------------------------------购买逻辑-----------------------------------
--购买固定商店物品
function MallManager:buyCommodityForFixedStore(id,num)
	TFDirector:send(c2s.PURCHASE_ORDER_FOR_FIXED_STORE ,{id,num}) 
end

--购买成功回调方法
function MallManager:fixedStoreBuySuccessCallback( event )
	local data = event.data
	local shop = ShopData:objectByID(data.commodityId)
	local item = ItemData:objectByID(shop.res_id)
	if shop.is_limited ~= 0 then
		self.purchasedLogs = self.purchasedLogs or {}
		self.purchasedLogs[data.commodityId] = self.purchasedLogs[data.commodityId] or 0
		self.purchasedLogs[data.commodityId] = self.purchasedLogs[data.commodityId] + data.num
	end


	TFDirector:dispatchGlobalEventWith(MallManager.BuySuccessFromFixedStore , shop.type,data.commodityId)
	
	if self.BuySuccessFromFixedStoreCallBack then
		self.BuySuccessFromFixedStoreCallBack()
		self.BuySuccessFromFixedStoreCallBack = nil;
	end
	--if item then
	--	toastMessage("恭喜你成功购买"..item.name .. data.num)
	--end
end

--购买随机商店物品
function MallManager:buyCommodityForRandomStore(type,id,num)
	TFDirector:send(c2s.PURCHASE_ORDER_FOR_RANDOM_STORE ,{type,id,num}) 
end

--购买随机商店商品成功回调方法
function MallManager:randomStoreBuySuccessCallback( event )
	local data = event.data
	--print("randomStoreBuySuccessCallback -> : ",data)
	local store = self:getRandomStoreByType(data.type)
	local commodity = store:getCommodity(data.commodityId)

	--if commodity == nil then
	--	toastMessage("恭喜你成功购买了一个找不到的商品")
	--	return
	--end

	local shopEntry = commodity:getShopEntry()
	local goodsTemplate  = commodity:getTemplate()
	local currentNum = commodity:getNumber() - data.num
	--print("current number  : ",currentNum)
	commodity:setNumber(currentNum)
	
	--if goodsTemplate then
	--	toastMessage("恭喜你成功购买"..goodsTemplate.name .. data.num)
	--end

	TFDirector:dispatchGlobalEventWith(MallManager.BuySuccessFromRandomStore , data)
end

function MallManager:openItemShoppingLayer(itemid,callBack,autoShow)
	for v in ShopData:iterator() do
		if v.res_id == itemid then
			--self.targetItemId = v.id
			self:loadingMyPurchasedLogs(function() self:checkVipLimited(v.id,callBack,autoShow) end)
			--self:openShoppingLayer( v.id ,callBack)
			return;
		end
	end
end

--[[
sb需求支持
]]
function MallManager:checkVipLimited(targetId,callBack,autoShow)
	local shop = ShopData:objectByID(targetId)
	if shop ~= nil  then
		if shop:isLimiteVip() then
			local vipLevel = MainPlayer:getVipLevel()
			local max_num = shop:getMaxNum(vipLevel)
			local now_count = max_num - self:getPurchasedCount(shop.id)
			if now_count <= 0 then
				local levelUpToIncrease = shop:isVipLevelUpIncreaseNum(vipLevel)
				if levelUpToIncrease then
					-- local msg = "今日购买次数已用完！\n\n提升VIP可获得更多购买次数。";
					--local msg = "今日购买次数已用完！\n\n提升VIP可获得更多购买次数。\n\n是否前往充值？";
					local msg = localizable.MallManager_up_vip_tip
                    CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer(function()
                            		if autoShow and vipLevel < MainPlayer:getVipLevel() then
                            			self:openShoppingLayer(targetId,callBack)
                            		end
                            	end);
                        end,
                        function()
                            AlertManager:close()
                        end,
                        {
                        --title = "提升VIP" ,
                        title = localizable.MallManager_vip_up,
                        msg = msg,
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                    )
                else
                	CommonManager:showOperateSureLayer(
                        function()
                            AlertManager:close()
                        end,
                        function()
                            AlertManager:close()
                        end,
                        {
                        --title =  "购买次数已用完",
                        title = localizable.MallManager_out_time,
                        --msg = "今日购买次数已用完,不能再购买该物品"
                        msg = localizable.MallManager_out_time_tip
                        }
                    )
				end
			else
				self:openShoppingLayer( targetId ,callBack)
			end
		else
			self:openShoppingLayer( targetId ,callBack)
		end
	end
	self.targetItemId = nil
end

function MallManager:openShoppingLayer(id,callBack)
	self.BuySuccessFromFixedStoreCallBack = callBack;
	
	--购买界面显示
	local layer = require('lua.logic.mall.ShoppingLayer'):new(id)
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	AlertManager:show()
	return layer
end

function MallManager:openRandomStoreShoppingLayer( type, commodityData)
	--购买界面显示
	local layer = require('lua.logic.mall.RandomStoreShoppingLayer'):new(type,commodityData)
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	AlertManager:show()
end

MallManager.NewGiftType = EnumServiceType.MALL * 256 + 1
MallManager.NewGoodsType = EnumServiceType.MALL * 256 + 2
MallManager.NewXiyouType = EnumServiceType.MALL * 256 + 3
MallManager.NewZhenBaoType = EnumServiceType.MALL * 256 + 4


--红点判断逻辑
--是否该新礼包可购买时
function MallManager:isNewGif(id)
	return false;
end

--是否有新礼包可购买时
function MallManager:isHaveNewGif()
	local enabled = RedPointManager:isRedPointEnabled(MallManager.NewGiftType)
	if not enabled then
		--这里进行客户端逻辑判断
	end
	return enabled
end


--是否有新的商品
function MallManager:isHaveNewGoods()
	local enabled = RedPointManager:isRedPointEnabled(MallManager.NewGoodsType)
	if not enabled then
		--这里进行客户端逻辑判断
		enabled = self.randomStoreTable[1].newRandomShopMark
		if enabled then
			RedPointManager:setRedPointEnabled(MallManager.NewGoodsType,enabled)
		end
	end
	return enabled
end

--进入随机商店，红点消失
function MallManager:onIntoGoodsLayer()
	--服务端记录，并推送前端
	self.randomStoreTable[1].newRandomShopMark = false
	RedPointManager:setRedPointEnabled(MallManager.NewGoodsType,false)
end

--是否有新的商品
function MallManager:isHaveXiyouNewGoods()
	if self.randomStoreTable[RandomStoreType.Xiyou]:isOpen() == false then
		return false
	end
	local enabled = RedPointManager:isRedPointEnabled(MallManager.NewXiyouType)
	if not enabled then
		--这里进行客户端逻辑判断
		enabled = self.randomStoreTable[RandomStoreType.Xiyou].newRandomShopMark
		if enabled then
			RedPointManager:setRedPointEnabled(MallManager.NewXiyouType,enabled)
		end
	end
	return enabled
end

--进入随机商店，红点消失
function MallManager:onIntoXiyouLayer()
	RedPointManager:setRedPointEnabled(MallManager.NewXiyouType,false)
	if self.randomStoreTable[RandomStoreType.Xiyou]:isOpen() == false then
		return
	end
	--服务端记录，并推送前端
	self.randomStoreTable[RandomStoreType.Xiyou].newRandomShopMark = false
end
--是否有新的商品
function MallManager:isHaveZhenBaoNewGoods()
	if self.randomStoreTable[RandomStoreType.Zhenbao]:isOpen() == false then
		return false
	end
	local enabled = RedPointManager:isRedPointEnabled(MallManager.NewZhenBaoType)
	if not enabled then
		--这里进行客户端逻辑判断
		enabled = self.randomStoreTable[RandomStoreType.Zhenbao].newRandomShopMark
		if enabled then
			RedPointManager:setRedPointEnabled(MallManager.NewZhenBaoType,enabled)
		end
	end
	return enabled
end

--进入随机商店，红点消失
function MallManager:onIntoZhenBaoLayer()
	RedPointManager:setRedPointEnabled(MallManager.NewZhenBaoType,false)
	if self.randomStoreTable[RandomStoreType.Zhenbao]:isOpen() == false then
		return
	end
	--服务端记录，并推送前端
	self.randomStoreTable[RandomStoreType.Zhenbao].newRandomShopMark = false
end


--是否有商场刷新道具 
function MallManager:isEnoughRefrshTool(callback, shopType)
	local enough = false


	local configure = RandomMallConfigure:objectByID(shopType)
	if configure == nil then
		return false
	end

	local itemId = configure.token_id
	local need 	 = configure.token_num

    -- 判断扫荡道具 30033
    local tool = BagManager:getItemById(itemId)
    if tool and tool.num >= need then
        enough = true

        --local msg = "此次刷新需要刷新令" .. need .. "个，是否确定刷新？" ;
        local msg = stringUtils.format(localizable.MallManager_refresh_tip, need) ;
        -- msg = msg .. "\n\n(当前拥有刷新令：" .. tool.num..")";
        msg = stringUtils.format(localizable.MallManager_refresh_tool, need, tool.num)
        CommonManager:showOperateSureLayer(
            -- function()
            --      MissionManager:resetChallengeCount( missionId );
            -- end,
            callback,
            nil,
            {
                msg = msg
            }
        )
    end

	return enough
end


function MallManager:resetBuyCoin()
	if self.buyCoinResultList == nil then
		-- self.buyCoinResultList = MEMapArray:new()
		self.buyCoinResultList = TFArray:new()
	else
		self.buyCoinResultList:clear()
	end
end

function MallManager:BuyCoin(count)

	showLoading()
	TFDirector:send(c2s.REQUEST_COUNT_BUY_COIN, {count})
end

function MallManager:UpdateCoinNumCallback(event)
	self.buyCoinNum = event.data.count

	print("self.buyCoinNum = ", self.buyCoinNum)
end

function MallManager:buyCoinResultCallback(event)
	hideLoading()
	-- print("---MallManager:buyCoinResultCallback  = ", event.data)
	-- 	required int32 consume = 1;				//消耗的元宝数量
	-- required int32 coin=2;					//获得铜币数量
	-- required int32 mutil=3;					//倍数

	local result = event.data.result
	local count = 0
	for k,v in pairs(result) do
		self.buyCoinResultList:pushFront(v)
		count = count + 1
	end

	self.buyCoinNum = self.buyCoinNum + count
	TFDirector:dispatchGlobalEventWith(self.BuyCoinCallBackEvent, {})
end

function MallManager:resetBuyCoinNum()
	self.buyCoinNum = 0
end

function MallManager:UpdateGiftShopOneItem(data)
	local giftItemId 	= data.id
	local giftItem 	 	= nil
	local bNewGiftItem  = false

-- BaseDataManager:BindShopData()

	giftItem = ShopData:objectByID(giftItemId)
	if giftItem == nil then
		giftItem = {}
		bNewGiftItem = true
	end


	-- print("---- UpdateGiftShopOneItem =", data)

	giftItem.id 						= data.id					-- = 1;				//商店序号
	giftItem.type 						= data.type					-- =2;				//礼包商城类型
	giftItem.res_type 					= data.resType          	-- =3;			//出售道具的资源类型
	giftItem.res_id 					= data.resId				-- = 4;			//出售道具的ID
	giftItem.number 					= data.number				-- =5;			//单次购买数量
	giftItem.consume_type 				= data.consumeType       	-- =6;		//购买道具的资源类型
	giftItem.consume_id 				= data.consumeId			-- = 7;		//购买道具的ID
	giftItem.consume_number 			= data.consumeNumber		-- =8;	//花费值
	giftItem.is_limited 				= data.isLimited			-- = 9;		//是否有出售限制
	giftItem.consume_add 				= data.consumeAdd 			-- =10;		//每次购买递增价格值
	giftItem.need_vip_level 			= data.needVipLevel 		-- =11;		//购买所需的vip等级
	giftItem.begin_time 				= data.beginTime			-- =12;		//上架时间
	giftItem.end_time 					= data.endTime				-- = 13;		//下架时间
	giftItem.max_type 					= data.maxType				-- = 14;			//最大值类型
	giftItem.max_num 					= data.maxNum				-- =15;			//出售上限值
	giftItem.vip_max_num_map 			= data.vipMaxNumMap         -- =16;	//各VIP等级下可购买数量
	giftItem.old_price 					= data.oldPrice				-- = 17;		//原价
	giftItem.limit_type 				= data.limitType			-- =18;		//限制类型
	giftItem.ishot 						= data.isHot                -- =19;			//是否热卖
	giftItem.time_type 					= data.timeType				-- = 20;		//限时类型
	giftItem.lastSendTime 				= data.lastSendTime        	-- =21;		//上次发送时间
	giftItem.orderNo 					= data.orderNo              -- =22;			//排序值


	giftItem.begin_time = giftItem.begin_time or 0
	giftItem.end_time 	= giftItem.end_time or 0

	giftItem.begin_time =  math.ceil(giftItem.begin_time/1000)
	giftItem.end_time   =  math.ceil(giftItem.end_time/1000)

	-- print('giftItem.begin_time11 = ', giftItem.begin_time)
	-- print('giftItem.end_time11 = ', giftItem.end_time)
	-- -- 时间转换 1979/1/1 1:00:00
	giftItem.begin_time = os.date("%Y/%m/%d %X",giftItem.begin_time)
	giftItem.end_time   = os.date("%Y/%m/%d %X",giftItem.end_time)

	-- print('giftItem.begin_time22 = ', giftItem.begin_time)
	-- print('giftItem.end_time22 = ', giftItem.end_time)

	if bNewGiftItem then
		ShopData:pushbyid(giftItemId, giftItem)
	end
end

function MallManager:UpdateGiftShopItem(event)
	if event.data then

		-- print("---------------MallManager:UpdateGiftShopItem")

		self:UpdateGiftShopOneItem(event.data)

		-- TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE, {})
		BaseDataManager:BindShopData()


		self:sortGiftShopItem()

		TFDirector:dispatchGlobalEventWith(MallManager.BuySuccessFromFixedStore , {})
	end
end
function MallManager:receiveMysteryShopList(event)
	if event.data then
		self.travelBusiness = event.data
		TFDirector:dispatchGlobalEventWith(MallManager.ReceiveTraveBusiness , {})
	end
end

function MallManager:receiveMysteryBuyResult(event)
	if event.data then
		if event.data.state == 0 then
			self.travelBusiness = {}
		end

		TFDirector:dispatchGlobalEventWith(MallManager.ReceiveTraveBusinessBuyResult, event.data.state)
	end
end

function MallManager:getTravelBusinessData()
	if not self.travelBusiness.info then
		return nil
	end

	local now = MainPlayer:getNowtime()

	if not (self.travelBusiness.beginTime < now and self.travelBusiness.endTime > now) then
		return nil
	end

	for i,v in pairs(self.travelBusiness.info) do
		return v;
	end
end

function MallManager:getTravelBusinessLeftTime()
	if not self.travelBusiness then
		return nil
	end

	local now = MainPlayer:getNowtime()
	if not (self.travelBusiness.beginTime < now and self.travelBusiness.endTime > now) then
		return nil
	end

	return (self.travelBusiness.endTime - now)
end




function MallManager:UpdateGiftShopItemList(event)
	if event.data == nil then
		return
	end
	-- print("MallManager:UpdateGiftShopItemList event.data = ", event.data)

	local bNeedClear = event.data.type or 0
	
	if bNeedClear == 1 then
		print("---------------clear all list")
		ShopData:clear()
	end

	if event.data.giftList == nil then
		return
	end

	-- print("---------------MallManager:UpdateGiftShopItemList")


	for i,v in pairs(event.data.giftList) do
		
		-- print("v = ", v)
		self:UpdateGiftShopOneItem(v)
	end

	BaseDataManager:BindShopData()

	self:sortGiftShopItem()

	TFDirector:dispatchGlobalEventWith(MallManager.BuySuccessFromFixedStore , {})

end


function MallManager:sortGiftShopItem()

	local function cmpFun(item1, item2)
		local orderNo1 = item1.orderNo or 0
		local orderNo2 = item2.orderNo or 0

		if orderNo1 < orderNo2 then
			return false
		end

		return true
	end

	if ShopData:length() > 0 then
		-- 排序
		ShopData:sort(cmpFun)
	end
end

function MallManager:getShopByResId( resId )
	for v in ShopData:iterator() do
        if v.res_id == resId then
            return v
        end
    end
    return nil
end

function MallManager:checkShopOneKey( resId )
	local shop = self:getShopByResId( resId )
	if shop then
		if shop:isLimiteTime() then
			print('this goods has limiteTime resId = ',resId)
			return false
		end
		if shop:isLimiteVip() then
			print('this goods has vip level limit resId = ',resId)
			return false
		end
		self:openShoppingLayer(shop.id)
	else
		print('cannot fint the goods in t_s_gift_shop by resId = ',resId)
		return false
	end
	return true
end

function MallManager:buyYouFang(id)
	TFDirector:send(c2s.PURCHASE_ORDER_FOR_MYSTERY_STORE ,{id}) 
end

return MallManager:new()
