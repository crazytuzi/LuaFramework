--[[
	文件名：PvpCoinStoreLayer.lua
	描述：竞技场声望商店
	创建人：xuchen
	修改人：chenqiang
	创建时间：2016.06.24
--]]
 
local EXCHANGE_VIEW = 1      	-- 兑换页面
local RANK_EXCHANGE_VIEW = 2  	-- 排名兑换页面
local eventName = EventsName.eRedDotPrefix .. tostring(ModuleSub.ePVPShop)  -- 小红点事件

local PvpCoinStoreLayer = class("PvpCoinStoreLayer",function()
    return display.newLayer()
end)

-- 构造函数
--[[
-- params结构：
	{
		tag		初始页面，1表示兑换页面，2表示排名兑换页面
		pvpInfo	服务器PVP模块 GetPVPInfo 方法返回的数据结构
	}
--]]
function PvpCoinStoreLayer:ctor(params)
	ui.registerSwallowTouch({node = self})
	-- 参数
	self.mPVPInfo = params.pvpInfo
	self.mTag = params.tag or 1
	
	-- 兑换列表
	self.mShopInfo = {}
	-- 排行榜兑换列表
	self.mRankShopInfo = {}

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

	-- 子背景
    -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 142))
    -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
    -- self.mParentLayer:addChild(subBgSprite)

    -- 判断是否传参, 没有传参则重新请求数据
    if not self.mPVPInfo then
    	self:requestGetPVPInfo()
    else
    	-- 历史最高排名
		self.mHistoryMaxRank = self.mPVPInfo.HistoryMaxRank
		-- 历史最高阶数
		self.mHistoryMaxStep = self.mPVPInfo.HistoryMaxStep
		-- 商店信息
		self.mPvpShopInfo = self.mPVPInfo.PVPShopInfo
	    -- 处理数据
	    self:dealWithData()
	    -- 初始化界面
		self:initUI()
    end
end

function PvpCoinStoreLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("兑换"),
            tag = EXCHANGE_VIEW,
        },
        {
            text = TR("排名兑换"),
            tag = RANK_EXCHANGE_VIEW,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        -- viewSize = cc.size(640, 80),
        -- btnSize = cc.size(138, 56),
        defaultSelectTag = self.mSubPageType,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mViewType == selectBtnTag then
                return 
            end

            self.mViewType = selectBtnTag
            -- 切换子页面
            if self.mViewType == EXCHANGE_VIEW then
            	self:refreshShopListView()
            else
            	self:refreshRankShopListView()
            end
        end
    })

    return tabLayer
end

-- 初始化界面
function PvpCoinStoreLayer:initUI()
	-- if not self.mMapBg1Sprite then
	-- 	-- 背景图1
	-- 	self.mMapBg1Sprite = ui.newSprite("dl_01.jpg")
	-- 	self.mMapBg1Sprite:setAnchorPoint(0.5, 1)
	-- 	self.mMapBg1Sprite:setPosition(320, 1136)
	-- 	self.mParentLayer:addChild(self.mMapBg1Sprite)
	-- end 

	-- "欢迎光临"问候语
	-- local greetSprite = ui.newSprite("c_74.png")
	-- greetSprite:setPosition(400, 940)
	-- self.mMapBg1Sprite:addChild(greetSprite)

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
		labelStr = TR("只有强者才能获得豪侠榜的奖励哟~"),
		color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
		offset = 20,
		dimensions = cc.size(310, 0),
	})
	tipsLabel:setAnchorPoint(0, 0.5)
	tipsLabel:setPosition(0, 770)
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
    -- 保存按钮，引导使用
    self.closeButton = closeButton

	-- 我的信息
	local myInfoBgSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 54))
	myInfoBgSprite:setPosition(mapBg2Size.width * 0.5, mapBg2Size.height * 0.9)
	mapBg2Sprite:addChild(myInfoBgSprite)
	self.mCoinNum = PlayerAttrObj:getPlayerAttrByName("PVPCoin")
	-- 我的声望(pvpcoin)
	self.mMyPVPCoin = ui.newLabel({
		text = TR("当前%s:   {%s}%s%s", Utility.getGoodsName(ResourcetypeSub.ePVPCoin),
			Utility.getDaibiImage(ResourcetypeSub.ePVPCoin), 
			Enums.Color.eYellowH,
			Utility.numberWithUnit(self.mCoinNum, 0)),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		x = myInfoBgSprite:getContentSize().width * 0.3,
		y = myInfoBgSprite:getContentSize().height * 0.5,
	})
	myInfoBgSprite:addChild(self.mMyPVPCoin)
	-- 最高排名
	self.mMaxRank = ui.newLabel({
		text = TR("最高排名:   %s%s", Enums.Color.eYellowH, self.mHistoryMaxRank),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		x = myInfoBgSprite:getContentSize().width * 0.7,
		y = myInfoBgSprite:getContentSize().height * 0.5,
	})
	myInfoBgSprite:addChild(self.mMaxRank)

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
    -- tableView:setAnchorPoint(0.5, 1)
    tableView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tableView)

    -- 导航按钮小红点逻辑
    local btnList = tableView:getTabBtns()
    local rankShopBtn = btnList[2]
   
	local function dealRedDotVisible(redDotSprite)
		local redData = RedDotInfoObj:isValid(ModuleSub.ePVPShop)
    	redDotSprite:setVisible(redData)
	end
    ui.createAutoBubble({parent = rankShopBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.ePVPShop), refreshFunc = dealRedDotVisible})
end

-- 处理数据
function PvpCoinStoreLayer:dealWithData()
	self.mShopInfo = {}
	self.mRankShopInfo = {}

	for _, info in ipairs(self.mPvpShopInfo) do
		if PvpShopModel.items[info.ShopId].needRank == 0 then
			table.insert(self.mShopInfo, info)
		else
			table.insert(self.mRankShopInfo, info)
		end
	end

	for i = #self.mShopInfo, 1 , -1 do
		local info = self.mShopInfo[i]

		local totalMaxNum = PvpShopModel.items[info.ShopId].totalMaxNum
		if totalMaxNum > 0 and info.BuyTotalNum >= totalMaxNum then
			-- 购买总次数大于限购总次数
			table.remove(self.mShopInfo, i)
		end 
		info.isCanBuy = self:isCanBuy(info)
	end
	table.sort(self.mShopInfo, function (a, b)
		if a.isCanBuy ~= b.isCanBuy then
			return a.isCanBuy
		end
	end)


	for i = #self.mRankShopInfo, 1 , -1 do
		local info = self.mRankShopInfo[i]

		if PvpShopModel.items[info.ShopId].needStep > self.mHistoryMaxStep then
			-- 需要的阶数大于历史最高阶数
			table.remove(self.mRankShopInfo, i)
		elseif info.BuyTotalNum >= PvpShopModel.items[info.ShopId].totalMaxNum then
			-- 购买总次数大于限购总次数
			table.remove(self.mRankShopInfo, i)
		else
			-- 可否兑换
			info.isCanBuy = self:isCanBuy(info)
		end 
	end
end

-- 能否兑换
--[[ 
	info:排行商城兑换信息
		{
			BuyTotalNum
	        BuyNum
	        ShopId
		}
]]
function PvpCoinStoreLayer:isCanBuy(info)
	if PvpShopModel.items[info.ShopId].perMaxNum > 0 then
		return info.BuyNum < PvpShopModel.items[info.ShopId].perMaxNum
	elseif PvpShopModel.items[info.ShopId].needStep < self.mHistoryMaxStep then
		return true
	else
	 	return (PvpShopModel.items[info.ShopId].needStep == self.mHistoryMaxStep) 
 			and (PvpShopModel.items[info.ShopId].needRank >= self.mHistoryMaxRank)
	end
end

function PvpCoinStoreLayer:createListView()
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
function PvpCoinStoreLayer:refreshShopListView()
	self.mListView:removeAllItems()
	for index = 1, #self.mShopInfo do
		local item = ccui.Layout:create()
		item:setContentSize(self.mCellSize)
		self.mListView:pushBackCustomItem(item)
		-- 刷新指定项
		self:refreshShopListItem(index)
	end
end

-- 刷新listview单个Item
function PvpCoinStoreLayer:refreshShopListItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    local cellSize = self.mCellSize

    if nil == lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end  
    lvItem:removeAllChildren()

    -- 条目背景
	local cellBgSprite = ui.newScale9Sprite("c_18.png")
	cellBgSprite:setContentSize(cellSize.width - 20, cellSize.height)
	cellBgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
	lvItem:addChild(cellBgSprite)

	-- 资源类型
	local typeId = PvpShopModel.items[self.mShopInfo[index].ShopId].typeID
	local goodsModelId = PvpShopModel.items[self.mShopInfo[index].ShopId].modelID
	local count = PvpShopModel.items[self.mShopInfo[index].ShopId].num
	-- goods头像
	local goodSprite = require("common.CardNode").new()
	local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
	goodSprite:setCardData({resourceTypeSub = typeId, modelId = goodsModelId, num = count, cardShowAttrs = showAttrs})
	goodSprite:setAnchorPoint(0, 0.5)
	goodSprite:setPosition(25, cellBgSprite:getContentSize().height * 0.5)
	cellBgSprite:addChild(goodSprite)

	--goods名称
	local goodsName = Utility.getGoodsName(typeId, goodsModelId)
	local goodColorLv = Utility.getColorLvByModelId(goodsModelId, typeId)
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

	-- 豪侠榜阶数
	local step = PvpShopModel.items[self.mShopInfo[index].ShopId].needStep
	local stepLabel = ui.newLabel({
		text = TR("豪侠榜阶数: %s%s", Enums.Color.eNormalGreenH, step),
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		x = 140,
		y = cellSize.height - 48,
	})
	cellBgSprite:addChild(stepLabel)

	-- 声望
	local pvpCoin = PvpShopModel.items[self.mShopInfo[index].ShopId].needPVPCoin
	local pvpCoinColor = nil
	if PlayerAttrObj:getPlayerAttrByName("PVPCoin") >= pvpCoin then
		pvpCoinColor = Enums.Color.eYellow
	else
		pvpCoinColor = Enums.Color.eRed
	end
	local pvpCoinLabel = ui.newLabel({
		text = string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.ePVPCoin), 
			Utility.numberWithUnit(pvpCoin, 0)),
		color = pvpCoinColor,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		anchorPoint = cc.p(0, 1),
		x = 140,
		y = cellSize.height - 75,
	})
	cellBgSprite:addChild(pvpCoinLabel)

	-- 今日剩余次数
	local leveTimes 
	local levelLabel 
	if PvpShopModel.items[self.mShopInfo[index].ShopId].perMaxNum ~= 0 then
		leveTimes = PvpShopModel.items[self.mShopInfo[index].ShopId].perMaxNum - self.mShopInfo[index].BuyNum
		levelLabel = ui.newLabel({
			text = TR("今日剩余%s%s次", Enums.Color.eYellowH, tostring(leveTimes)),
			outlineColor = Enums.Color.eOutlineColor,
			outlineSize = 2,
			anchorPoint = cc.p(0, 1),
			x = 270,
			y = cellSize.height - 80,	
		})
	else
		leveTimes = 1
		levelLabel = ui.newLabel({
			text = TR(""),
			outlineColor = Enums.Color.eOutlineColor,
			outlineSize = 2,
			anchorPoint = cc.p(0, 1),
			x = 270,
			y = cellSize.height - 80,	
		})
	end
	cellBgSprite:addChild(levelLabel)

	-- 兑换按钮
	local exchangeBtn = ui.newButton({
	 	normalImage = "c_28.png",
        text = TR("兑换"),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(440, cellSize.height * 0.5),
        clickAction = function()
         	local shopId = self.mShopInfo[index].ShopId
         	local perMaxNum = PvpShopModel.items[self.mShopInfo[index].ShopId].perMaxNum
         	local dayNum 
         	if perMaxNum == 0 then
         		dayNum = nil
         	else
         		dayNum = perMaxNum - self.mShopInfo[index].BuyNum
         	end

         	local price = PvpShopModel.items[self.mShopInfo[index].ShopId].needPVPCoin
         	local afford = math.floor(self.mCoinNum/price)
         	local maxNum = 1

         	if dayNum then
	         	if afford >= dayNum then
	         		maxNum = dayNum
	         	elseif afford <= 0 then
	         		maxNum = 1
	         	else
	         		maxNum = afford
	         	end
         	else
         		if afford <= 0 then
         			maxNum = 1
         		else
         			maxNum = afford
         		end
         	end

         	-- 参数列表
         	local params = {
				title = TR("兑换"),                          
				exchangePrice = PvpShopModel.items[shopId].needPVPCoin,     
				modelID = PvpShopModel.items[shopId].modelID,               
				typeID  = PvpShopModel.items[shopId].typeID,                
				resourcetypeCoin = ResourcetypeSub.ePVPCoin,             
				maxNum = maxNum,                          
				oKCallBack = function(exchangeCount, layerObj, btnObj)
					LayerManager.removeLayer(layerObj)
					self:exchangeGoods(self.mShopInfo[index], exchangeCount)
				end,                      
			}
         	MsgBoxLayer.addExchangeGoodsCountLayer(params)
		end,	
	})
	cellBgSprite:addChild(exchangeBtn)

	if leveTimes == 0 then
		exchangeBtn:setEnabled(false)
	end
end

function PvpCoinStoreLayer:refreshRankShopListView()
	self.mListView:removeAllItems()
	for index = 1, #self.mRankShopInfo do
		local item = ccui.Layout:create()
		item:setContentSize(self.mCellSize)
		self.mListView:pushBackCustomItem(item)
		-- 刷新指定项
		self:refreshRankShopListItem(index)
	end
end

function PvpCoinStoreLayer:refreshRankShopListItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    local cellSize = self.mCellSize

    if nil == lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end  
    lvItem:removeAllChildren()

    -- 条目背景
	local cellBgSprite = ui.newScale9Sprite("c_18.png")
	cellBgSprite:setContentSize(cellSize.width - 20, cellSize.height)
	cellBgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
	lvItem:addChild(cellBgSprite)

	-- 资源类型
	local typeId = PvpShopModel.items[self.mRankShopInfo[index].ShopId].typeID
	local goodModelId = PvpShopModel.items[self.mRankShopInfo[index].ShopId].modelID
	local count = PvpShopModel.items[self.mRankShopInfo[index].ShopId].num
	-- goods头像
	local goodSprite = require("common.CardNode").new()
	local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
	goodSprite:setCardData({resourceTypeSub = typeId, modelId = goodModelId, num = count, cardShowAttrs = showAttrs})
	goodSprite:setAnchorPoint(0, 0.5)
	goodSprite:setPosition(25, cellBgSprite:getContentSize().height * 0.5)
	cellBgSprite:addChild(goodSprite)

	--goods名称
	local goodsName = Utility.getGoodsName(typeId, goodModelId)
	local goodColorLv = Utility.getColorLvByModelId(goodModelId, typeId)
	local nameColor = Utility.getColorValue(goodColorLv, 1)
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

	-- 豪侠榜阶数
	local step = PvpShopModel.items[self.mRankShopInfo[index].ShopId].needStep
	local stepLabel = ui.newLabel({
		text = TR("豪侠榜阶数: %s%s", Enums.Color.eNormalGreenH, step),
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		x = 140,
		y = cellSize.height - 48,
	})
	cellBgSprite:addChild(stepLabel)

	-- 声望
	local pvpCoin = PvpShopModel.items[self.mRankShopInfo[index].ShopId].needPVPCoin
	local pvpCoinColor = nil
	if PlayerAttrObj:getPlayerAttrByName("PVPCoin") >= pvpCoin then
		pvpCoinColor = Enums.Color.eYellow
	else
		pvpCoinColor = Enums.Color.eRed
	end
	local pvpCoinLabel = ui.newLabel({
		text = string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.ePVPCoin), 
			Utility.numberWithUnit(pvpCoin, 0)),
		color = pvpCoinColor,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		anchorPoint = cc.p(0, 1),
		x = 140,
		y = cellSize.height - 75,
	})
	cellBgSprite:addChild(pvpCoinLabel)

	-- 需要排名
	local needRank = PvpShopModel.items[self.mRankShopInfo[index].ShopId].needRank
	local needRankLabel = ui.newLabel({
		text = TR("需要排名: %s%s", Enums.Color.eNormalGreenH, needRank),
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		x = 280,
		y = cellSize.height - 48,
	})
	cellBgSprite:addChild(needRankLabel)

	-- 可兑换次数
	local leveTimes = PvpShopModel.items[self.mRankShopInfo[index].ShopId].totalMaxNum - self.mRankShopInfo[index].BuyTotalNum
	local levelLabel = ui.newLabel({
		text = TR("可兑换: %s%s次", Enums.Color.eYellowH, tostring(leveTimes)),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		anchorPoint = cc.p(0, 1),
		x = 280,
		y = cellSize.height - 82,
	})
	cellBgSprite:addChild(levelLabel)

	-- 兑换按钮
	local exchangeBtn = ui.newButton({
	 	normalImage = "c_28.png",
        text = TR("兑换"),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(440, cellSize.height * 0.5),
        clickAction = function()
         	self:exchangeGoods(self.mRankShopInfo[index], 1)
        end,	
	})
	cellBgSprite:addChild(exchangeBtn)
	exchangeBtn:setEnabled(self.mRankShopInfo[index].isCanBuy)
end

------------------------------------网络相关------------------------------------------dun
function PvpCoinStoreLayer:exchangeGoods(info, num)
	if PvpShopModel.items[info.ShopId].needPVPCoin * num > PlayerAttrObj:getPlayerAttrByName("PVPCoin") then
		ui.showFlashView(TR("当前%s不足", ResourcetypeSubName[ResourcetypeSub.ePVPCoin]))
		return
	end
	-- if PvpShopModel.items[info.ShopId].needRank < self.mHistoryMaxRank 
	-- 	and PvpShopModel.items[info.ShopId].needRank ~= 0 then
	-- 	ui.showFlashView(TR("排名未达到要求"))
	-- 	return
	-- end

	HttpClient:request({
 		moduleName = "PVPShop",
        methodName = "PVPShopBuy",
        svrMethodData = {info.ShopId, num},
        callback = function(response)
        	if not response or response.Status ~= 0 then
        		return
        	end

        	-- 刷新自己的声望
        	self.mMyPVPCoin:setString(TR("当前%s   {%s}%s%s", Utility.getGoodsName(ResourcetypeSub.ePVPCoin),
        		Utility.getDaibiImage(ResourcetypeSub.ePVPCoin), 
        		Enums.Color.eYellowH,
				Utility.numberWithUnit(PlayerAttrObj:getPlayerAttrByName("PVPCoin"), 0)))

        	-- 刷新购买次数 
        	info.BuyNum = info.BuyNum + num
        	info.BuyTotalNum = info.BuyTotalNum + num

        	self:dealWithData()
			self.mCoinNum = PlayerAttrObj:getPlayerAttrByName("PVPCoin")


        	if PvpShopModel.items[info.ShopId].needRank == 0 then
        		self:refreshShopListView()
        	else
        		self:refreshRankShopListView()
    		 	Notification:postNotification(eventName)
        	end

        	-- ui.showFlashView(TR("兑换成功"))
        	ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end	
	})
end

-- PVP信息
function PvpCoinStoreLayer:requestGetPVPInfo()
	HttpClient:request({
    	moduleName = "PVP",
    	methodName = "GetPVPInfo",
    	callback = function(response)
    	    if response.Status ~= 0 then return end

	        self.mPVPInfo = response.Value

	        -- 历史最高排名
			self.mHistoryMaxRank = response.Value.HistoryMaxRank
			-- 历史最高阶数
			self.mHistoryMaxStep = response.Value.HistoryMaxStep
			-- 商店信息
			self.mPvpShopInfo = response.Value.PVPShopInfo

		    -- 处理数据
		    self:dealWithData()
		    -- 初始化界面
			self:initUI()
    	end
	})
end

-- ========================== 新手引导 ===========================
function PvpCoinStoreLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function PvpCoinStoreLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向返回按钮
        [11608] = {clickNode = self.closeButton},
    })
end

return PvpCoinStoreLayer
