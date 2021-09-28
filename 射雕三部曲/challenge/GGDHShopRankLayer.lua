--[[
    文件名：GGDHShopRankLayer.lua
    描述： 序列争霸商城排名奖励页面
    创建人：wusonglin
    创建时间：2016.6.20
-- ]]

local GGDHShopRankLayer = class("GGDHShopRankLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各个字段为
    {
        serverData -- 服务器数据，缓存
        rank -- 历史排名，必选参数，上个页面传入
        rankList -- 排行榜数据
    }
]]
function GGDHShopRankLayer:ctor(params)
	-- 屏蔽下层事件
	-- ui.registerSwallowTouch({node = self})
	-- 初始化数据
    if params.rank ~= nil then
        self.mRank = params.rank
        if self.mRank == 1000000 or self.mRank == 0 then
            self.mRank = TR("无排名")
        end
    end

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	self.mListView = nil

    local daibiBg = ui.newScale9Sprite("c_25.png",cc.size(590, 54))
    daibiBg:setPosition(cc.p(320, 930))
    self.mParentLayer:addChild(daibiBg)

    -- 代币数量
    local label = ui.newLabel({
        text = TR("当前豪侠令：{%s}%s%s",
            Utility.getDaibiImage(ResourcetypeSub.eGDDHCoin),
            Enums.Color.eYellowH,
            PlayerAttrObj:getPlayerAttrByName("GDDHCoin")),
        size = 24,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        color = Enums.Color.eNormalWhite,
        })
    label:setPosition(160, 930)
    self.mParentLayer:addChild(label)

    -- 创建刷新
    Notification:registerAutoObserver(label,
        function()
            label:setString(TR("当前豪侠令：{%s}%s%s",
                Utility.getDaibiImage(ResourcetypeSub.eGDDHCoin),
                Enums.Color.eYellowH,
                PlayerAttrObj:getPlayerAttrByName("GDDHCoin")))
        end
        , {EventsName.eGDDHCoin})

    -- 往届最高排名
    self.mOldRankLabel = ui.newLabel({
        text = TR("往届最高排名：%s%s",Enums.Color.eYellowH,self.mRank),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        alignType = ui.TEXT_ALIGN_CENTER,
    })
    self.mOldRankLabel:setPosition(cc.p(450, 930))
    self.mParentLayer:addChild(self.mOldRankLabel)


	self.mUnderBgSprite = ui.newScale9Sprite("c_17.png", cc.size(606, 760))
	self.mUnderBgSprite:setAnchorPoint(0.5, 1)
	self.mUnderBgSprite:setPosition(320, 880)
	self.mParentLayer:addChild(self.mUnderBgSprite)

    -- 判断是否缓存数据
    self.mRankList = params.rankList
    if self.mRankList then
        -- 利用缓存数据直接创建Listview
        print("利用缓存")
        self:createListview()
    else
        -- 请求网络数据
         print("请求网络数据")
        self:requestGetWrestleRaceShopInfo()
    end
end

-- 创建ListView列表
function GGDHShopRankLayer:createListview()
	if self.mListView then
		self.mListView:removeAllChildren(true)
	end
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(598, 740))-- LayerManager.heightNoBottom - 269 * Adapter.AutoScaleX - Adapter.AutoHeight(85)))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    -- self.mListView:setItemsMargin(5)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(303, 750)
    self.mUnderBgSprite:addChild(self.mListView)

    -- 添加数据
    for i = 1, #self.mRankList do
        self.mListView:pushBackCustomItem(self:createGddhRankView(i))
    end
end

-- 创建列表cell
function GGDHShopRankLayer:createGddhRankView(index)
	-- 初始化数据
    local info = self.mRankList[index]
    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = 598
    local height = 126
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(590, 120))
    cellSprite:setPosition(cc.p(299, 63))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 设置物品头像
    local header = CardNode.createCardNode({
        resourceTypeSub = info.typeID,
        modelId = info.modelID,
        num = info.num,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eAddMark,
            -- CardShowAttr.eSelected,
            CardShowAttr.eSynthetic,
            CardShowAttr.eNum,
        },
    })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(30, 63))
    custom_item:addChild(header)

    -- 显示物品名字
    local goodColorLv = Utility.getColorLvByModelId(info.modelID, info.typeID)
    local nameColor =  Utility.getColorValue(goodColorLv, 1)
    local nameLabel = ui.newLabel({
        text = string.format("%s", Utility.getGoodsName(info.typeID, info.modelID)),
        -- outlineColor = display.COLOR_BLACK,
        color = nameColor,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(cellSize.width * 0.25, cellSize.height * 0.7)
    cellSprite:addChild(nameLabel)

    -- 最高排名
    local gddhCoinLabel = ui.newLabel({
        text = TR("往届最高排名：%s%d", Enums.Color.eNormalGreenH, info.needRank),
        color = Enums.Color.eBlack
    })
    gddhCoinLabel:setScale(0.9)
    gddhCoinLabel:setAnchorPoint(cc.p(0, 0.5))
    gddhCoinLabel:setPosition(cellSize.width * 0.25, cellSize.height * 0.455)
    cellSprite:addChild(gddhCoinLabel)

    -- 显示可领取按钮
    local buyNum = 1
    local getBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(width * 0.82, height * 0.5),
        clickAction = function()
            if type(self.mRank) == "string"  then
                MsgBoxLayer.addOKLayer(TR("您没有往届排名哦，请在本届努力提高排名吧!"), TR("提示"))
            else
                if self.mRank > info.needRank then
                    MsgBoxLayer.addOKLayer(TR("您的往届排名不足哦，请在本届努力提高排名吧!"), TR("提示"))
                else
                    local playerInfo = PlayerAttrObj:getPlayerInfo()
                    if playerInfo.GDDHCoin < info.needGDDHCoin then
                        ui.showFlashView(TR("您的豪侠令不足哦，请再去获取一些吧!"))
                    else
                        self:requestWrestleRaceShopBuy(info.ID, buyNum)
                    end
                end
            end
        end,
    })
    custom_item:addChild(getBtn)

    -- 显示今日可兑换次数
    local maxLabel = ui.newLabel({
        text = "",
        size = 23,
        font = _FONT_PANGWA,
        color = Enums.Color.eBlack,
        -- outlineColor = display.COLOR_BLACK,
    })
    maxLabel:setAnchorPoint(cc.p(0, 0.5))
    maxLabel:setPosition(cellSize.width * 0.25, cellSize.height * 0.23)
    cellSprite:addChild(maxLabel)
    -- 处理显示数据
    if info.perMaxNum > 0 then
        --if info.perMaxNum - info.BuyNum > 0 then
            maxLabel:setString(TR("总次数: %s%s/%s",Enums.Color.eNormalGreenH, info.BuyNum, info.perMaxNum))
        -- else
        --     maxLabel:setString(TR("已达兑换上限"))
        -- end
        buyNum = info.perMaxNum
        if info.perMaxNum - info.BuyNum <= 0 then
            getBtn:setEnabled(false)
        end
    else
        if info.seasonMaxNum > 0 then
            -- if info.seasonMaxNum - info.BuySeasonNum > 0 then
                maxLabel:setString(TR("总次数: %s%s/%s",Enums.Color.eNormalGreenH , info.BuySeasonNum, info.seasonMaxNum))
            -- else
            --     maxLabel:setString(TR("已达兑换上限"))
            -- end
            buyNum = info.seasonMaxNum
            if info.seasonMaxNum - info.BuySeasonNum <= 0 then
                getBtn:setEnabled(false)
            end
        else
            if info.totalMaxNum > 0 then
                maxLabel:setString(TR("总次数: %s%s/%s",Enums.Color.eNormalGreenH , info.BuyTotalNum, info.totalMaxNum))
                buyNum = info.totalMaxNum
                if info.totalMaxNum - info.BuyTotalNum <= 0 then
                    getBtn:setVisible(false)

                    local tempSprite = ui.newSprite("jc_21.png")
                    tempSprite:setPosition(cellSize.width * 0.82, cellSize.height * 0.5)
                    cellSprite:addChild(tempSprite)
                end
            end
        end
    end

    local daibi = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eGDDHCoin,
        number = info.needGDDHCoin,
    })
    daibi:setAnchorPoint(cc.p(0, 0.5))
    daibi:setPosition(cellSize.width * 0.50, cellSize.height * 0.23)
    cellSprite:addChild(daibi)

    return custom_item
end

-- 获取恢复数据
function GGDHShopRankLayer:getRestoreData()
    local retData = {
       	rank = self.mRank,
        rankList = self.mRankList
	}

    return retData
end

--[[----------------------------网络相关--------------------------]]-----
function GGDHShopRankLayer:requestGetWrestleRaceShopInfo()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "GetWrestleRaceShopInfo",
        svrMethodData = {},
        callback = function(data)

            if data.Status ~= 0 then
                return
            end

            self.mRankList = {}
            --存放功勋兑换数据
            self.mGddhCoinList = {}
            --存放豪侠令兑换数据
            self.mGddhCoinList = {}
            -- 处理数据
            for i, v in ipairs(GddhShopModel.items) do
                if v.needRank == 0 then
                    table.insert(self.mGddhCoinList, v)
                else
                    table.insert(self.mRankList, v)
                end
            end
            -- table.sort(self.mRankList, function(a, b) return a.needRank > b.needRank end)

            --dump(self.mRankList)

            for i, v in ipairs(data.Value) do
                for m, n in ipairs(self.mGddhCoinList) do
                    if v.ShopId == n.ID then
                        self.mGddhCoinList[m].BuyNum = v.BuyNum
                        self.mGddhCoinList[m].BuySeasonNum = v.BuySeasonNum
                        self.mGddhCoinList[m].BuyTotalNum = v.BuyTotalNum
                    end
                end
                for m, n in ipairs(self.mRankList) do
                    if v.ShopId == n.ID then
                        self.mRankList[m].BuyNum = v.BuyNum
                        self.mRankList[m].BuySeasonNum = v.BuySeasonNum
                        self.mRankList[m].BuyTotalNum = v.BuyTotalNum
                        if n.totalMaxNum <= n.BuyNum then
                            self.mRankList[m].CanBuy = false
                        else
                            self.mRankList[m].CanBuy = true
                        end
                    end
                end
            end
            table.sort(self.mRankList, function (a, b)
                if a.CanBuy ~= b.CanBuy then
                    return a.CanBuy
                end
                if a.needRank ~= b.needRank then
                    return a.needRank > b.needRank
                end
            end)
            -- 创建Listview
            self:createListview()
        end
    })
end

-- 进行道具购买，领取
--[[
params:
    shopId: 商品ID，
    num:    购买数量
]]--
function GGDHShopRankLayer:requestWrestleRaceShopBuy(shopId, num)
     HttpClient:request({
        moduleName = "Gddh",
        methodName = "WrestleRaceShopBuy",
        svrMethodData = {shopId, num},
        callback = function(response)
            -- 领取奖励失败了
            if not response or response.Status ~= 0 then
                return
            end

            -- 显示获得的奖励信息
            if response.Value then
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
            end

            -- 处理显示数据
            local buyNum = num
            for i, v in ipairs(self.mRankList) do
                if shopId == v.ID then
                    v.BuyNum = v.BuyNum + buyNum
                    v.BuyTotalNum = v.BuyTotalNum + buyNum
                    v.BuySeasonNum = v.BuySeasonNum + buyNum
                    -- self.mListView:removeItem(i - 1)
                    -- self.mListView:insertCustomItem(self:createGddhRankView(i), #self.mRankList - 1)
                end
            end
			self:createListview()
        end,
    })
end

return GGDHShopRankLayer
