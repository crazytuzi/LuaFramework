--[[
	文件名：VipGiftLayer.lua
	描述：商城招募之Vip礼包页面
	创建人：chenzhong
	创建时间：2016.5.12
--]]

-- 当前页面是添加到ShopLayer的BgSprite上的，此layer中的元素不必适配，按照(640,1136)坐标系来
local VipGiftLayer = class("VipGiftLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{

	}
--]]
function VipGiftLayer:ctor(params)
	-- 设置页面大小
	self.mBgSize = cc.size(640, 1136)
	self:setContentSize(self.mBgSize)

	-- Vip礼包信息列表
	self.mVipGiftInfo = {}

	-- 添加UI
	self:initUI()

	-- 请求服务器，获取各个Vip礼包的信息
	self:requestShopGiftList()
end

-- 添加UI元素
function VipGiftLayer:initUI()
	local backSize = self.mBgSize
    local bgWidth = 647
    local bgHeight = 800

    -- 广告语
    local noticeSprite1 = ui.newSprite("sc_08.png")
    noticeSprite1:setPosition(320, 905)
    self:addChild(noticeSprite1)

    -- 描述等级背景
    local derisBg = ui.newScale9Sprite("sc_07.png", cc.size(594, 89))
    derisBg:setPosition(backSize.width * 0.5, 765)
    self:addChild(derisBg)

     -- 添加物品背景
    local bottomBg = ui.newScale9Sprite("c_97.png", cc.size(620, 514))
    bottomBg:setPosition(320, 205)
    bottomBg:setAnchorPoint(0.5, 0)
    self:addChild(bottomBg)

	-- 现在拥有的vip等级与经验
	local currVip = PlayerAttrObj:getPlayerAttrByName("Vip")
	local currVipExp = PlayerAttrObj:getPlayerAttrByName("VipEXP")
    local currVipNeedExp = VipModel.items[currVip].expTotal

	-- Vip等级未达到满级时
    local maxVip = VipModel.items_count - 1
	if currVip < maxVip then
        local nextVip = currVip + 1
        local nextVipNeedExp = VipModel.items[nextVip].expTotal

        -- 当前Vip背景
        local needCount = (nextVipNeedExp - currVipExp) * 2
        local descStr = TR("再充值%s元宝升至 VIP%s", math.ceil(needCount), nextVip)
        if math.ceil(needCount) < 0 then
            descStr = TR("充值任意金额激活新的vip等级")
        end
        local currVipBg = ui.newLabel({
            text = descStr,
            color = cc.c3b(0xb9, 0x52, 0x37),
            fontSize = 20,
        })
        currVipBg:setPosition(297, 60)
        derisBg:addChild(currVipBg)

        for i=1,2 do
            local vipNum = i == 1 and currVip or nextVip
            local pos = i == 1 and cc.p( 25, 33) or cc.p(475, 33)
            local bgSprite = ui.newSprite("sc_06.png")
            bgSprite:setPosition(pos)
            bgSprite:setAnchorPoint(0, 0.5)
            derisBg:addChild(bgSprite)

            local lvStartPos = cc.p(8, 22)
            local vipNode = ui.createVipNode(vipNum)
            vipNode:setPosition(lvStartPos)
            bgSprite:addChild(vipNode)
        end

		-- Vip经验进度条
        -- 当前Vip经验与本Vip等级所需的经验的差值 / 下一级Vip所需的经验与本Vip等级所需的经验
		local vipExpProgressBar = require("common.ProgressBar"):create({
	        bgImage = "sc_04.png",
            barImage = "sc_05.png",
	        currValue = (currVipExp - currVipNeedExp) * 2,
	        maxValue = (nextVipNeedExp - currVipNeedExp) * 2,
	        needLabel = true,
            size = 18,
            color = Enums.Color.eNormalWhite,
            outlineColor = Enums.Color.eBlack,
		})
		vipExpProgressBar:setAnchorPoint(cc.p(0.5, 0.5))
	    vipExpProgressBar:setPosition(297, 33)
	    derisBg:addChild(vipExpProgressBar)

	    -- 注册通知，进度条动态变化
	    Notification:registerAutoObserver(
	    	currVipBg,
	    	function ()
				local currVipExp = PlayerAttrObj:getPlayerAttrByName("VipEXP")
				local nextVipNeedExp = VipModel.items[PlayerAttrObj:getPlayerAttrByName("Vip") + 1].expTotal

	            vipExpProgressBar:setCurrValue(currVipExp)
	            vipExpProgressBar:setMaxValue(nextVipNeedExp)
        	end,
        	{EventsName.eVipEXP}
        )
	else
        local currVipBg = ui.newLabel({
            text = TR("当前您是VIP %d, 恭喜您达到最高VIP等级!", maxVip),
            color = cc.c3b(0xb9, 0x52, 0x37),
            fontSize = 20,
        })
        currVipBg:setPosition(297, 60)
        derisBg:addChild(currVipBg)
	end

    -- 没有Vip礼包的提示
    -- 暂时没有VIP礼包了，敬请期待哦~
    -- 能看到这一行字，在整个大陆也是凤毛麟角的存在
    self.mNoGiftTip = ui.newSprite("sc_17.png")
    self.mNoGiftTip:setPosition(320, 500)
    self:addChild(self.mNoGiftTip)
    self.mNoGiftTip:setVisible(false)

    -- 充值按钮
    self.mRechargeBtn = ui.newButton({
        normalImage = "sc_03.png",
        position = cc.p(320, 155),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    self:addChild(self.mRechargeBtn)
end

-- 创建一级ListView
function VipGiftLayer:createGiftListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(600, 520))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(20)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 710)
    self.mListView:setScrollBarEnabled(false)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self:addChild(self.mListView)

    -- 添加cellItem
    for i = 1, table.maxn(self.mVipGiftInfo) do
        self.mListView:pushBackCustomItem(self:createGiftCellByIndex(i))
    end
end

-- 创建ListView的每个cell
--[[
	params:
	index     						-- cell的索引号
--]]
function VipGiftLayer:createGiftCellByIndex(index)
    local info = self.mVipGiftInfo[index]

    -- 创建cell节点
 	local cellWidth, cellHeight = 205, 520
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景
    local cellBg = ui.newSprite("sc_02.png")
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5+12)
    customCell:addChild(cellBg)

    -- 礼包名字
    local cellName = ui.newLabel({
        text = GoodsModel.items[info.ModelId].name,
        color = Enums.Color.eLightYellow,
        outlineColor = Enums.Color.eBlack,
        fontSize = 20,
    })
    cellName:setPosition(cellWidth * 0.5, cellHeight * 0.89)
    customCell:addChild(cellName)

    -- 设置头像
    local cellHead = CardNode.createCardNode({
        resourceTypeSub = GoodsModel.items[info.ModelId].typeID,
        modelId = info.ModelId,
        cardShowAttrs = {CardShowAttr.eBorder},
        cardShape = Enums.CardShape.eSquare
    })
    cellHead:setAnchorPoint(cc.p(0.5, 1))
    cellHead:setPosition(cellWidth * 0.5, cellHeight * 0.83)
    customCell:addChild(cellHead)

    local picName = Utility.getDaibiImage(ResourcetypeSub.eDiamond)
    -- 设置原价
    local initPrice = ui.newLabel({
        text = TR("#935f41原价：{%s}%d", picName, info.InitPrice),
        color = Enums.Color.eNormalWhite,
        align = ui.TEXT_ALIGN_CENTER,
        size = 20,
    })
    initPrice:setPosition(cellWidth * 0.5, cellHeight * 0.32)
    customCell:addChild(initPrice)
    -- 删除线
    local initSprite = ui.newScale9Sprite("cdjh_14.png",cc.size(160, 3))
    initSprite:setPosition(cellWidth * 0.5, cellHeight * 0.32)
    customCell:addChild(initSprite)

    -- 设置现价
    local currPrice = ui.newLabel({
        text = TR("#258711现价：{%s}%d", picName, info.CurrPrice),
        color = Enums.Color.eNormalWhite,
        align = ui.TEXT_ALIGN_CENTER,
        size = 20
    })
    currPrice:setPosition(cellWidth * 0.5, cellHeight * 0.25)
    customCell:addChild(currPrice)

    -- 显示购买按钮
    local buyBtn = ui.newButton({
        normalImage = "c_95.png",
        text = TR("购买"),
        outlineColor = cc.c3b(0xc0, 0x49, 0x48),
        anchorPoint = cc.p(0.5,0.5),
        position = cc.p(cellWidth * 0.5, cellHeight * 0.16),
        clickAction = function()
           if Utility.isResourceEnough(ResourcetypeSub.eDiamond, info.CurrPrice, true) == true then
	            self:requestBuyGift(info.ModelId, 1)
	        end
        end
    })
    buyBtn:setScale(0.9)
    customCell:addChild(buyBtn)
   	-- 设置购买按钮状态
    for i, v in pairs(VipModel.items) do
        if info.ModelId == v.vipGoodsModelID then
            if PlayerAttrObj:getPlayerAttrByName("Vip") < v.LV then
                buyBtn:setEnabled(false)
            end
            break
        end
    end

    -- 添加ListView
    self:createHeaderListView(
        index,
    	customCell,
    	cc.p(cellWidth * 0.5, cellHeight * 0.50),
    	cc.size(180, 140)
    )

    return customCell
end

-- 每个礼包的奖品列表视图
--[[
	params:
	index            		-- 礼包的索引号
	parent     				-- 添加到哪个父节点上
	pos        				-- 在父节点中的位置
	size   					-- 大小
--]]
function VipGiftLayer:createHeaderListView(giftIndex, parent, pos, size)
	local info = self.mVipGiftInfo[giftIndex]

    local headerListView = ccui.ListView:create()
    headerListView:setDirection(ccui.ScrollViewDir.vertical)
    headerListView:setBounceEnabled(true) -- 设置弹力
    headerListView:setContentSize(size)
    headerListView:setItemsMargin(5) -- 改变两个cell之间的边界
    headerListView:setAnchorPoint(cc.p(0.5, 0.5))
    headerListView:setPosition(pos)
    headerListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    headerListView:setSwallowTouches(false)
    parent:addChild(headerListView)

    -- 创建cell
    local cellData = GoodsOutputRelation.items[info.ModelId]
    for i = 1, table.maxn(cellData) do
        headerListView:pushBackCustomItem(self:createHeaderListViewCellByIndex(i, cellData))
    end
end

-- 创建headerListView的每一个cell
--[[
	index      				-- cell的索引号
	data    				-- 创建cell相关的数据
--]]
function VipGiftLayer:createHeaderListViewCellByIndex(index, data)
    local itemInfo = data[index]

    -- 创建cell
    local width, height = 180, 45
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(width, height))

    if itemInfo then
        -- 创建头像
        local header = CardNode.createCardNode({
            resourceTypeSub = itemInfo.outputTypeID,
            modelId = itemInfo.outputModelID,
            cardShowAttrs = {CardShowAttr.eBorder},
            cardShape = Enums.CardShape.eSquare
        })
        header:setScale(0.4)
        header:setAnchorPoint(cc.p(0, 0.5))
        header:setPosition(width * 0.09, height * 0.5)
        layout:addChild(header)

        -- 创建label
        local nameLabel = ui.newLabel({
            text = string.format("#46220d%sx%s", Utility.getGoodsName(itemInfo.outputTypeID, itemInfo.outputModelID),
                Utility.numberWithUnit(itemInfo.outputNum)
            ),
            size = 16,
            dimensions = cc.size(110, 0),
        })
        nameLabel:setAnchorPoint(cc.p(0, 0.5))
      	nameLabel:setPosition(width * 0.31, height * 0.5)

        layout:addChild(nameLabel)
    end

    return layout
end

--------------------------网络相关------------------------
-- 请求服务器，获取各个Vip礼包的信息
function VipGiftLayer:requestShopGiftList()
	HttpClient:request({
	 	moduleName = "ShopGift",
	 	methodName = "ShopGiftList",
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data or data.Status ~= 0 then
                return
            end

            for i, v in ipairs(data.Value) do
                -- 无购买次数限制 或 未达到最大购买次数的礼包
                if v.MaxNum <= 0 or v.MaxNum > v.Num then
                    -- 比玩家Vip等级高6级以下的礼包
                    if i <= PlayerAttrObj:getPlayerAttrByName("Vip") + 6 then
                        table.insert(self.mVipGiftInfo, v)
                    end
                end
            end

            if #self.mVipGiftInfo ~= 0 then
                self:createGiftListView()
            else
                self.mNoGiftTip:setVisible(true)
            end
        end
    })
end

-- 请求购买Vip礼包
--[[
params:
    giftModelId:   礼包的ID
    num:           购买的数量
]]--
function VipGiftLayer:requestBuyGift(giftModelId, num)
    local requestData = {giftModelId, num}
    HttpClient:request({
    	moduleName = "ShopGift",
    	methodName = "BuyGift",
    	svrMethodData = requestData,
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

        	-- 先是调用BuyGift方法请求服务器，获取这个Vip礼包道具，
        	-- 然后再调用GoodsUse方法，请求服务器，使用掉这个道具，从而获得相应的礼物
            for i, v in ipairs(GoodsObj:getPropsList()) do
                if v.ModelId == data.Value.BaseGetGameResourceList[1].Goods[1].ModelId then
                    local requestData = {v.Id, v.ModelId, v.Num}
                        HttpClient:request({
                            moduleName = "Goods",
                            methodName = "GoodsUse",
                            svrMethodData = requestData,
                            callbackNode = self,
                            callback = function(data)
                                -- 容错处理
                                if not data.Value or data.Status ~= 0 then
                                    return
                                end

                                -- 飘窗显示物品掉落页面
                                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList, true)
                            end
                        })
                    break
                end
            end

            -- 刷新数据
            for i, v in ipairs(self.mVipGiftInfo) do
                if data.Value.BuyGiftRecord.ModelId == v.ModelId then
                    table.remove(self.mVipGiftInfo, i)
                end
            end

            -- 刷新页面
            self.mListView:removeAllItems()
            for i = 1, #self.mVipGiftInfo do
                self.mListView:pushBackCustomItem(self:createGiftCellByIndex(i))
            end

            -- 所有Vip礼包都购买了之后
            if #self.mVipGiftInfo == 0 then
                self.mNoGiftTip:setVisible(true)
            end
        end
    })
end

return VipGiftLayer
