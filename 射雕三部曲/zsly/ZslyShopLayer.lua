--[[
	文件名：ZslyShopLayer.lua
	描述：竞技场声望商店
	创建人：xuchen
	修改人：chenqiang
	创建时间：2016.06.24
--]]

local ZslyShopLayer = class("ZslyShopLayer",function()
    return display.newLayer()
end)

-- 两种商品类型
local ShopType = {
	eCommonShop = 1,
	eRewardShop = 2,
}

-- 构造函数
--[[
-- params结构：
	{
		tag		初始页面，1表示兑换页面，2表示排名兑换页面
		pvpInfo	服务器PVP模块 GetPVPInfo 方法返回的数据结构
	}
--]]
function ZslyShopLayer:ctor(params)
	ui.registerSwallowTouch({node = self})
	-- 参数
	self.mShopSellType = params.tag or 1
	-- 章节顺序id
	self.mZslyOrderIdList = {}
	self:dealZslyIdOrder()
	-- 列表
	self.mShopModelList = {}
	self.mShopInfoList = {}
	-- 排行榜兑换列表
	self.mRewardShopInfo = {}

	-- 创建标准父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA, 
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

    -- 创建背景
    self.mMapBg1Sprite = ui.newSprite("c_34.jpg")
	self.mMapBg1Sprite:setAnchorPoint(0.5, 1)
	self.mMapBg1Sprite:setPosition(320, 1136)
	self.mParentLayer:addChild(self.mMapBg1Sprite)

    -- 判断是否传参, 没有传参则重新请求数据
	self:requestGetInfo()
end

function ZslyShopLayer:dealZslyIdOrder()
	self.mZslyOrderIdList = {}
	local function dealOrder(floorId)
		if floorId == 0 then return end

		table.insert(self.mZslyOrderIdList, floorId)

		dealOrder(ZslyNodeModel.items[floorId].nextNodeId)
	end

	dealOrder(1001)
end

function ZslyShopLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("兑换"),
            tag = ShopType.eCommonShop,
        },
        {
            text = TR("奖励"),
            tag = ShopType.eRewardShop,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        defaultSelectTag = self.mShopSellType,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mShopSellType == selectBtnTag then
                return 
            end
            self.mShopSellType = selectBtnTag
            -- 切换子页面
        	self:refreshShopListView()
        end
    })

    return tabLayer
end

-- 初始化界面
function ZslyShopLayer:initUI()
	--上部分背景图
	local topBgSprite = ui.newSprite("hslj_01.jpg")
	topBgSprite:setAnchorPoint(0.5, 1)
	topBgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(topBgSprite)

	--人物图
	local personSprite = ui.newSprite("xshd_20.png")
	personSprite:setPosition(380, 615)
	self.mParentLayer:addChild(personSprite)

	-- 
	local tipsLabel = ui.createLabelWithBg({
		bgFilename = "c_145.png",
		bgSize = cc.size(370, 88),
		labelStr = TR("本店只收兽魂和珍兽精华哟~"),
		color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
		offset = 20,
		dimensions = cc.size(310, 0),
	})
	tipsLabel:setAnchorPoint(0, 0.5)
	tipsLabel:setPosition(0, 790)
	self.mParentLayer:addChild(tipsLabel)

	-- 添加黑底
    local decBgSize = cc.size(640, 147)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1065))
    self.mParentLayer:addChild(decBg)

	-- 背景图2
	local mapBg2Sprite = ui.newScale9Sprite("c_19.png")
	mapBg2Sprite:setContentSize(cc.size(647, 617))
	mapBg2Sprite:setAnchorPoint(0.5, 0)
	mapBg2Sprite:setPosition(320, 95)
	self.mParentLayer:addChild(mapBg2Sprite)
	local mapBg2Size = mapBg2Sprite:getContentSize()

	-- 关闭按钮
	local closeButton = ui.newButton({
	 	normalImage = "c_29.png",
        -- anchorPoint = cc.p(0.5, 0),
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end	
	})
	self.mParentLayer:addChild(closeButton, 2)

	-- 我的信息
	local myInfoBgSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 54))
	myInfoBgSprite:setPosition(mapBg2Size.width * 0.5, mapBg2Size.height * 0.9)
	mapBg2Sprite:addChild(myInfoBgSprite)
	-- 我的兽魂
	self.mMyZslyCoin = ui.newLabel({
		text = string.format("%s:  {%s}%s%s", Utility.getGoodsName(ResourcetypeSub.eZslyCoin),
			Utility.getDaibiImage(ResourcetypeSub.eZslyCoin), 
			Enums.Color.eYellowH,
			Utility.numberWithUnit(Utility.getOwnedGoodsCount(ResourcetypeSub.eZslyCoin, 0))),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		x = myInfoBgSprite:getContentSize().width * 0.3,
		y = myInfoBgSprite:getContentSize().height * 0.5,
	})
	myInfoBgSprite:addChild(self.mMyZslyCoin)
	-- 我的珍兽精华
	self.mMyZhenshouCoin = ui.newLabel({
		text = string.format("%s:  {%s}%s%s", Utility.getGoodsName(ResourcetypeSub.eZhenshouCoin),
			Utility.getDaibiImage(ResourcetypeSub.eZhenshouCoin), 
			Enums.Color.eYellowH,
			Utility.numberWithUnit(Utility.getOwnedGoodsCount(ResourcetypeSub.eZhenshouCoin, 0))),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		x = myInfoBgSprite:getContentSize().width * 0.7,
		y = myInfoBgSprite:getContentSize().height * 0.5,
	})
	myInfoBgSprite:addChild(self.mMyZhenshouCoin)
	-- 最高排名
	local historyId = self.mZslyOrderIdList[self.mHistoryMaxNum] or 0
	if historyId > 2000 then
		historyId = self.mZslyOrderIdList[self.mHistoryMaxNum-1]
	end
	self.mMaxRank = ui.newLabel({
		text = TR("最高层:   %s%s", Enums.Color.eYellowH, ZslyNodeModel.items[historyId] and ZslyNodeModel.items[historyId].name or TR("0层")),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	self.mMaxRank:setAnchorPoint(0, 0.5)
	self.mMaxRank:setPosition(20, 730)
	self.mParentLayer:addChild(self.mMaxRank)

	-- 兑换信息层
	local listLayer = ui.newScale9Sprite("c_17.png", cc.size(606, 500))
	listLayer:setAnchorPoint(0.5, 0.5)
	listLayer:setPosition(320, 275)
	-- listLayer:setContentSize(cc.size(640, 520))
	mapBg2Sprite:addChild(listLayer)

	self.listViewSize = cc.size(606, 480)		-- listView大小
    self.mCellSize = cc.size(606, 120)         	-- 单个条目的大小
	self.mListView = self:createListView()
	self.mListView:setPosition(303, 10)
    listLayer:addChild(self.mListView)

	-- 兑换和排名兑换按钮
	local tableView = self:showTabLayer()
    tableView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tableView)

    -- 导航按钮小红点逻辑
    local btnList = tableView:getTabBtns()
    local rankShopBtn = btnList[2]
   
	local function dealRedDotVisible(redDotSprite)
		local redData = RedDotInfoObj:isValid(ModuleSub.eZhenshouLaoyu, "CanExchangeReward")
    	redDotSprite:setVisible(redData)
	end
    ui.createAutoBubble({parent = rankShopBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshouLaoyu, "CanExchangeReward"), refreshFunc = dealRedDotVisible})
end

-- 处理数据
function ZslyShopLayer:dealWithData(purchaseList)
	-- 表数据
	self.mShopModelList = {}
	for _, shopInfo in pairs(ZslyShopModel.items) do
		for _, shop in pairs(shopInfo) do
			self.mShopModelList[shop.sellType] = self.mShopModelList[shop.sellType] or {}
			table.insert(self.mShopModelList[shop.sellType], shop)
		end
	end

	-- 服务器数据
	self.mShopInfoList = {}
	if purchaseList and next(purchaseList) then
		for _, shopInfo in pairs(purchaseList or {}) do
			self.mShopInfoList[shopInfo.SellType] = self.mShopInfoList[shopInfo.SellType] or {}
			self.mShopInfoList[shopInfo.SellType][shopInfo.Num] = shopInfo
		end
	end
	self.mShopInfoList[ShopType.eRewardShop] = self.mShopInfoList[ShopType.eRewardShop] or {}
	self.mShopInfoList[ShopType.eCommonShop] = self.mShopInfoList[ShopType.eCommonShop] or {}

	-- 排序
	self:sortList()
end

function ZslyShopLayer:sortList()
	for _, shopList in pairs(self.mShopModelList) do
		table.sort(shopList, function (shopModel1, shopModel2)
			-- 总限购
			local totalNum1 = self.mShopInfoList[shopModel1.sellType][shopModel1.num] and self.mShopInfoList[shopModel1.sellType][shopModel1.num].TotalBuyNum or 0
			local totalNum2 = self.mShopInfoList[shopModel2.sellType][shopModel2.num] and self.mShopInfoList[shopModel2.sellType][shopModel2.num].TotalBuyNum or 0
			local isTotalCanBuy1 = shopModel1.lifeBuyNum == 0 or (totalNum1 < shopModel1.lifeBuyNum)
			local isTotalCanBuy2 = shopModel2.lifeBuyNum == 0 or (totalNum2 < shopModel2.lifeBuyNum)
			if isTotalCanBuy1 ~= isTotalCanBuy2 then
				return isTotalCanBuy1
			end

			-- 开启条件
			local isOpen1 = shopModel1.openNeed == 0 or (self.mHistoryMaxNum >= table.indexof(self.mZslyOrderIdList, shopModel1.openNeed))
			local isOpen2 = shopModel2.openNeed == 0 or (self.mHistoryMaxNum >= table.indexof(self.mZslyOrderIdList, shopModel2.openNeed))
			if isOpen1 ~= isOpen2 then
				return isOpen1
			end

			-- 日限购
			local dayNum1 = self.mShopInfoList[shopModel1.sellType][shopModel1.num] and self.mShopInfoList[shopModel1.sellType][shopModel1.num].TodayBuyNum or 0
			local dayNum2 = self.mShopInfoList[shopModel2.sellType][shopModel2.num] and self.mShopInfoList[shopModel2.sellType][shopModel2.num].TodayBuyNum or 0
			local isDayCanBuy1 = shopModel1.dailyBuyNum == 0 or (dayNum1 < shopModel1.dailyBuyNum)
			local isDayCanBuy2 = shopModel2.dailyBuyNum == 0 or (dayNum2 < shopModel2.dailyBuyNum)
			if isDayCanBuy1 ~= isDayCanBuy2 then
				return isDayCanBuy1
			end

			return shopModel1.num < shopModel2.num
		end)
	end
end

function ZslyShopLayer:createListView()
	local listView = ccui.ListView:create()
	listView:setContentSize(self.listViewSize)
	listView:setItemsMargin(5)
	listView:setDirection(ccui.ListViewDirection.vertical)
	listView:setGravity(ccui.ListViewGravity.centerHorizontal)
 	listView:setBounceEnabled(true)
    listView:setAnchorPoint(0.5, 0)
    -- listView:setPosition(320, 273)

    return listView
end

-- 刷新整个listview, viewTpye为兑换和排名兑换
function ZslyShopLayer:refreshShopListView()
	self.mListView:removeAllItems()
	local shopList = self.mShopModelList[self.mShopSellType] or {}
	for index = 1, #shopList do
		local item = ccui.Layout:create()
		item:setContentSize(self.mCellSize)
		self.mListView:pushBackCustomItem(item)
		-- 刷新指定项
		self:refreshShopListItem(index)
	end
end

-- 刷新listview单个Item
function ZslyShopLayer:refreshShopListItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    local cellSize = self.mCellSize

    if nil == lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end  
    lvItem:removeAllChildren()

    local shopModel = self.mShopModelList[self.mShopSellType][index]
    local shopInfo = self.mShopInfoList[self.mShopSellType][shopModel.num] or {}

    -- 条目背景
	local cellBgSprite = ui.newScale9Sprite("c_18.png")
	cellBgSprite:setContentSize(cellSize.width - 20, cellSize.height)
	cellBgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
	lvItem:addChild(cellBgSprite)

	-- 资源类型
	local resInfo = Utility.analysisStrResList(shopModel.shopsStr)[1]
	-- goods头像
	local goodSprite = require("common.CardNode").new()
	local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
	goodSprite:setCardData({resourceTypeSub = resInfo.resourceTypeSub, modelId = resInfo.modelId, num = resInfo.num, cardShowAttrs = showAttrs})
	goodSprite:setAnchorPoint(0, 0.5)
	goodSprite:setPosition(25, cellBgSprite:getContentSize().height * 0.5)
	cellBgSprite:addChild(goodSprite)

	--goods名称
	local goodsName = Utility.getGoodsName(resInfo.resourceTypeSub, resInfo.modelId)
	local goodColorLv = Utility.getColorLvByModelId(resInfo.modelId, resInfo.resourceTypeSub)
	local nameColor =  Utility.getColorValue(goodColorLv, 1)
	local goodsNameLabel = ui.newLabel({
		text = goodsName,
		color = nameColor,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		anchorPoint = cc.p(0, 1),
		x = 140,
		y = cellSize.height - 15,
	})
	cellBgSprite:addChild(goodsNameLabel)

	-- 条件
	if shopModel.openNeed ~= 0 and self.mHistoryMaxNum < table.indexof(self.mZslyOrderIdList, shopModel.openNeed) then
		local openNeedLabel = ui.newLabel({
			text = TR("通关普通关卡%s", ZslyNodeModel.items[shopModel.openNeed].name),
			color = Enums.Color.eBlack,
			anchorPoint = cc.p(0, 1),
			x = 140,
			y = cellSize.height - 48,
		})
		cellBgSprite:addChild(openNeedLabel)
	end

	-- 代币
	local needCoinInfoList = Utility.analysisStrResList(shopModel.buyNeed)
	local coinText = ""
	for _, coinInfo in pairs(needCoinInfoList) do
		local ownCoinNum = Utility.getOwnedGoodsCount(coinInfo.resourceTypeSub, coinInfo.modelId)
		local coinColor = ownCoinNum >= coinInfo.num and Enums.Color.eYellowH or Enums.Color.eRedH
		coinText = coinText .. string.format("{%s}%s%s", Utility.getDaibiImage(coinInfo.resourceTypeSub, coinInfo.modelId), coinColor, coinInfo.num)
	end
	
	local coinLabel = ui.newLabel({
		text = coinText,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		anchorPoint = cc.p(0, 1),
		x = 140,
		y = cellSize.height - 75,
	})
	cellBgSprite:addChild(coinLabel)

	-- 今日剩余次数
	local leveTimes = nil 
	if shopModel.dailyBuyNum ~= 0 then
		leveTimes = shopModel.dailyBuyNum - (shopInfo.TodayBuyNum or 0)
		levelLabel = ui.newLabel({
			text = TR("今日剩余%s%s次", Enums.Color.eYellowH, tostring(leveTimes)),
			outlineColor = Enums.Color.eOutlineColor,
			outlineSize = 2,
			anchorPoint = cc.p(0, 1),
			x = 350,
			y = cellSize.height - 80,	
		})
		cellBgSprite:addChild(levelLabel)
	end

	-- 兑换按钮
	local exchangeBtn = ui.newButton({
	 	normalImage = "c_28.png",
        text = TR("兑换"),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(440, cellSize.height * 0.6),
        clickAction = function()
        	-- 该珍兽是否开放
        	local isShow = nil
        	if Utility.isZhenshou(resInfo.resourceTypeSub) then
        		isShow = ZhenshouModel.items[resInfo.modelId].isShow
        	elseif Utility.isZhenshouDebris(resInfo.resourceTypeSub) then
        		local zhoushouModelId = GoodsModel.items[resInfo.modelId].outputModelID
        		isShow = ZhenshouModel.items[zhoushouModelId].isShow
        	end
        	if isShow and isShow == 0 then
        		ui.showFlashView(TR("该珍兽还没开放"))
        		return
        	end
         	
         	local exchangeNum = nil
         	-- 今日限购
         	if leveTimes then
         		exchangeNum = leveTimes
         		if exchangeNum < 1 then
	         		ui.showFlashView(TR("今日购买数量已达上限"))
	         		return
	         	end
         	end
         	
         	-- 总限购限购
         	if shopModel.lifeBuyNum ~= 0 then
	         	local totalNum = shopModel.lifeBuyNum - (shopInfo.TotalBuyNum or 0)
	         	if exchangeNum then
	         		exchangeNum = exchangeNum < totalNum and exchangeNum or totalNum
	         	else
	         		exchangeNum = shopModel.lifeBuyNum
	         	end
	         	if exchangeNum < 1 then
	         		ui.showFlashView(TR("购买数量已达上限"))
	         		return
	         	end
         	end
         	
         	-- 代币兑换数量
         	for _, coinInfo in pairs(needCoinInfoList) do
         		local ownCoinNum = Utility.getOwnedGoodsCount(coinInfo.resourceTypeSub, coinInfo.modelId)
         		local buyNum = math.floor(ownCoinNum / coinInfo.num)
         		if exchangeNum then
         			exchangeNum = exchangeNum < buyNum and exchangeNum or buyNum
         		else
         			exchangeNum = buyNum
         		end
         		if buyNum < 1 then
         			ui.showFlashView(TR("%s不足", Utility.getGoodsName(coinInfo.resourceTypeSub, coinInfo.modelId)))
	         		return
         		end
         	end
         	
         	if exchangeNum == 1 then
         		self:exchangeGoods(shopModel.num, shopModel.sellType, 1)
         	else
	         	-- 参数列表
	         	local params = {
					title = TR("兑换"),
					coinList = needCoinInfoList,
					modelID = resInfo.modelId,
					typeID  = resInfo.resourceTypeSub,                
					maxNum = exchangeNum,                          
					oKCallBack = function(exchangeCount, layerObj, btnObj)
						LayerManager.removeLayer(layerObj)
						self:exchangeGoods(shopModel.num, shopModel.sellType, exchangeCount)
					end,                      
				}
	         	MsgBoxLayer.addExchangeGoodsListCountLayer(params)
	         end
		end,	
	})
	cellBgSprite:addChild(exchangeBtn)

	-- 没开启
	if shopModel.openNeed ~= 0 and self.mHistoryMaxNum < table.indexof(self.mZslyOrderIdList, shopModel.openNeed) then
		exchangeBtn:setEnabled(false)
	-- 没有总限购次数
	elseif shopModel.lifeBuyNum ~= 0 and shopModel.lifeBuyNum <= (shopInfo.TotalBuyNum or 0) then
		exchangeBtn:setEnabled(false)
		exchangeBtn:setTitleText(TR("已兑换"))
	-- 没有今日兑换次数
	elseif leveTimes and leveTimes <= 0 then
		exchangeBtn:setEnabled(false)
	end
end

------------------------------------网络相关------------------------------------------dun
function ZslyShopLayer:exchangeGoods(numId, sellType, num)
	HttpClient:request({
 		moduleName = "ZslyInfo",
        methodName = "PurchaseGoods",
        svrMethodData = {numId, sellType, num},
        callback = function(response)
        	if not response or response.Status ~= 0 then
        		return
        	end

        	ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

        	self.mShopInfoList[response.Value.PurchaseInfo.SellType][response.Value.PurchaseInfo.Num] = response.Value.PurchaseInfo

        	self:sortList()
        	self:refreshShopListView()

        	-- 刷新自己的声望
        	self.mMyZslyCoin:setString(string.format("%s  {%s}%s%s", Utility.getGoodsName(ResourcetypeSub.eZslyCoin),
        		Utility.getDaibiImage(ResourcetypeSub.eZslyCoin), 
        		Enums.Color.eYellowH,
				Utility.numberWithUnit(Utility.getOwnedGoodsCount(ResourcetypeSub.eZslyCoin, 0))))
        	self.mMyZhenshouCoin:setString(string.format("%s  {%s}%s%s", Utility.getGoodsName(ResourcetypeSub.eZhenshouCoin),
        		Utility.getDaibiImage(ResourcetypeSub.eZhenshouCoin), 
        		Enums.Color.eYellowH,
				Utility.numberWithUnit(Utility.getOwnedGoodsCount(ResourcetypeSub.eZhenshouCoin, 0))))
        end	
	})
end

-- PVP信息
function ZslyShopLayer:requestGetInfo()
	HttpClient:request({
    	moduleName = "ZslyInfo",
    	methodName = "GetStorePurchaseInfo",
    	callback = function(response)
    	    if response.Status ~= 0 then return end

	        self.mHistoryMaxNum = table.indexof(self.mZslyOrderIdList, response.Value.CommonMaxNodeId) or 0
	        self:dealWithData(response.Value.StorePurchase)
		    -- 初始化界面
			self:initUI()

			self:refreshShopListView()
    	end
	})
end

return ZslyShopLayer
