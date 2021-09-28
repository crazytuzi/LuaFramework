--[[
    文件名：TeambattleShop.lua
    描述：  内功心法兑换界面
    创建人：  wusonglin
    创建时间：2016.7.18
-- ]]

local TeambattleShop = class("TeambattleShop", function(params)
    return display.newLayer()
end)

-- 自定义枚举（用于进行页面分页）
local TabPageTags = {
    eTagBlue   = 1,    -- 蓝色内功心法
    eTagPurple = 2,    -- 紫色内功心法
    eTagOrange = 3,    -- 橙色阵决
}
local needGoodId = 16050023

-- 初始化
function TeambattleShop:ctor(params)
    dump(params, "参数数据")
	-- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})
    self.mCrusadeInfo = params.crusadeInfo or {}

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {
                {
                    resourceTypeSub = ResourcetypeSub.eFunctionProps,
                    modelId = needGoodId
                },
                ResourcetypeSub.eGold,
                ResourcetypeSub.eDiamond
            }
    })
    self:addChild(tempLayer)
    self.mCommonLayer = tempLayer

    -- 请求服务器数据
    self:requestShopInfo()

    -- 创建基础UI
    self:initUI()
end

-- ui
function TeambattleShop:initUI()
    -- 显示npc
    local npcSprite = ui.newSprite("c_34.jpg")
    npcSprite:setAnchorPoint(cc.p(0.5, 0.5))
    npcSprite:setPosition(cc.p(320, 658))
    self.mParentLayer:addChild(npcSprite)

    local upBgSprite = ui.newScale9Sprite("zb_02.png")
    upBgSprite:setAnchorPoint(cc.p(0, 1))
    upBgSprite:setPosition(0, 1090)
    self.mParentLayer:addChild(upBgSprite)

    -- 显示面板的背景
    local mInfoBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 930))
    mInfoBgSprite:setAnchorPoint(cc.p(0.5, 0))
    mInfoBgSprite:setPosition(cc.p(320, 0))
    self.mParentLayer:addChild(mInfoBgSprite)

    -- 商品列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(606,720))
    listBg:setAnchorPoint(0.5, 0)
    listBg:setPosition(320, 120)
    self.mParentLayer:addChild(listBg)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(closeBtn)

    -- 图片信息
    local goodsImage = Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, needGoodId)
    -- 资源名字
    local goodsName = Utility.getGoodsName(ResourcetypeSub.eFunctionProps, needGoodId)

    -- 数量背景
    local haveContrBack = ui.newScale9Sprite("c_24.png", cc.size(120, 35))
    haveContrBack:setPosition(cc.p(180, 875))
    self.mParentLayer:addChild(haveContrBack)

    -- 数量Label
    self.mInfoLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0.5),
        size = 22,
        x = 20,
        y = 875,
    })
    self.mInfoLabel.refreshCount = function (target)
        target:setString(TR("当前%s: {%s}%s%d", goodsName, goodsImage, "#BD6E00", Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, needGoodId)))
    end
    self.mInfoLabel:refreshCount()
    self.mParentLayer:addChild(self.mInfoLabel)

    --
    for i = 1,#TeambattleMapModel.items do
        local mapNodeInfo = TeambattleMapModel.items[i]
        for k,v in pairs(mapNodeInfo) do
            self.mNodeModelData = self.mNodeModelData or {}
            self.mNodeModelData[k] = v
        end
    end

    self.mBattleNode = {}
    for k, v in pairs(self.mNodeModelData) do
        table.insert(self.mBattleNode, v)
    end
    --dump(self.mBattleNode, "asdjasdjasdjsd-----")
end

-- 创建显示的列表控件
function TeambattleShop:createListView()
    -- 创建ListView列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(606, 700))-- LayerManager.heightNoBottom - 269 * Adapter.AutoScaleX - Adapter.AutoHeight(85)))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(5)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 130)
    self.mParentLayer:addChild(self.mListView)

    -- 添加数据
    for i = 1, #self.mBlueList do
        self.mListView:pushBackCustomItem(self:createCellView(i, self.mBlueList))
    end
end

-- 创建列表cell
function TeambattleShop:createCellView(index, data)
    -- body
    local info = data[index]

    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = 606
    local height = 120
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(width-20, height))
    cellSprite:setPosition(cc.p(width / 2, height / 2))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 设置物品头像
    local header = CardNode.createCardNode({
        resourceTypeSub = info.resourceTypeSub,
        modelId = info.modelId,
        num = info.num,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eNum,
        },
    })
    header:setAnchorPoint(0, 0.5)
    header:setPosition(cc.p(30, height/2))
    custom_item:addChild(header)

    -- 显示物品名字
    local nameLabel = ui.newLabel({
        text = Utility.getGoodsName(info.resourceTypeSub, info.modelId),
        color = Utility.getColorValue(Utility.getColorLvByModelId(info.modelId, info.resourceTypeSub), 1),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(140, cellSize.height * 0.75)
    cellSprite:addChild(nameLabel)

    -- 显示价格
    local terrLabel = ui.newLabel({
        text = TR("价格: {%s}%s%s",Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, needGoodId), Enums.Color.eNormalGreenH, info.needTeamBattleCoins),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    terrLabel:setAnchorPoint(cc.p(0, 0.5))
    terrLabel:setPosition(140, cellSize.height * 0.45)
    cellSprite:addChild(terrLabel)

    -- 显示拥有的碎片数量
    local haveNum = GoodsObj:getCountByModelId(info.modelId)
    local maxNum = GoodsModel.items[info.modelId].maxNum
    local countLabel = ui.newLabel({
        text = TR("当前拥有: %s%d/%d", ((haveNum >= maxNum) and Enums.Color.eNormalGreenH or "#46220D"), haveNum, maxNum),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    countLabel:setAnchorPoint(cc.p(0, 0.5))
    countLabel:setPosition(140, cellSize.height * 0.15)
    cellSprite:addChild(countLabel)

    local isSuccessFight = false
    if info.needNodeModelID ~= 0 then
        for _, bigNode in ipairs(self.mCrusadeInfo) do
            for _, smallNode in ipairs(bigNode) do
                if smallNode.NodeModelID == info.needNodeModelID then
                    if smallNode.SuccessFightCount > 0 then
                        isSuccessFight = true
                        break
                    end
                end
            end
            if isSuccessFight then
                break
            end
        end
    else
        isSuccessFight = true
    end


    if not isSuccessFight then
        local vipLimit = ui.newLabel({
            text = TR("需通关[%s]", TeambattleNodeModel.items[info.needNodeModelID].name),
            color = Enums.Color.eRed,
            size = 18,
        })
        vipLimit:setPosition(cc.p(width * 0.81, height * 0.45 + 40))
        cellSprite:addChild(vipLimit)
    end

    -- 显示总限购
    local maxBuyLabel = ui.newLabel({
        text = TR("总限购:%s/%s", info.TotalBuyCount, info.totalMaxNum),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    maxBuyLabel:setAnchorPoint(cc.p(0, 0.5))
    maxBuyLabel:setPosition(cc.p(300, height * 0.15))
    cellSprite:addChild(maxBuyLabel)
    maxBuyLabel:setVisible(false)
    if info.totalMaxNum > 0 then
        maxBuyLabel:setVisible(true)
    end

    -- 显示兑换按钮
    local exchangeNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, needGoodId)
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("兑换"),
        fontSize = 24,
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(width * 0.83, height * 0.45),
        clickAction = function()
            if info.resourcetypeSub == ResourcetypeSub.eNewZhenJueDebris then
                -- 弹出选择数量 参照兑换界面
                local params = {
                    title = TR("兑换"),
                    exchangePrice = info.needTeamBattleCoins,
                    modelID = info.modelId,
                    typeID  = info.resourceTypeSub,
                    resourcetypeCoin = ResourcetypeSub.eFunctionProps, -- 精髓的 resourcetype没有 暂时用元宝替代
                    maxNum = math.floor(exchangeNum / info.needTeamBattleCoins),
                    modelIdCoin = needGoodId,
                    oKCallBack = function(exchangeCount, layerObj, btnObj)
                        if exchangeCount ~= 0 then
                            self:requestBuyItem(info.ID, exchangeCount)
                            layerObj:removeFromParent()
                        else
                            ui.showFlashView({text = TR("请输入数量"),})
                        end
                    end,
                }
                self.mMsgLayer = MsgBoxLayer.addExchangeGoodsCountLayer(params)
            else
                -- 弹出选择数量 参照兑换界面
                local params = {
                    title = TR("兑换"),
                    exchangePrice = info.needTeamBattleCoins,
                    modelID = info.modelId,
                    typeID  = info.resourceTypeSub,
                    resourcetypeCoin = ResourcetypeSub.eFunctionProps, -- 精髓的 resourcetype没有 暂时用元宝替代
                    maxNum = math.floor(exchangeNum / info.needTeamBattleCoins),
                    modelIdCoin = needGoodId,
                    oKCallBack = function(exchangeCount, layerObj, btnObj)
                        if exchangeCount ~= 0 then
                            self:requestBuyItem(info.ID, exchangeCount)
                            layerObj:removeFromParent()
                        else
                            ui.showFlashView({text = TR("请输入数量"),})
                        end
                    end,
                }
                self.mMsgLayer = MsgBoxLayer.addExchangeGoodsCountLayer(params)
            end
        end,
    })
    custom_item:addChild(exchangeBtn)

    if Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, needGoodId) < info.needTeamBattleCoins or info.TotalBuyCount >= info.totalMaxNum and info.totalMaxNum ~= 0 then
        exchangeBtn:setEnabled(false)
    end

    --购买通关限制
    if not isSuccessFight then
        exchangeBtn:setEnabled(false)
    end

    return custom_item
end

-- Tab分页点击回调
function TeambattleShop:onSelectChange(selectTag)
    -- 执行刷新页面操作
    if selectTag == TabPageTags.eTagBlue then
        if self.mListView ~= nil then
            self.mListView:removeAllChildren()
             for i = 1, #self.mBlueList do
                self.mListView:pushBackCustomItem(self:createCellView(i, self.mBlueList, Enums.Color.eNormalBlueH))
            end
            self.mListView:jumpToTop()
        end
    elseif selectTag == TabPageTags.eTagPurple then
        if self.mListView ~= nil then
            self.mListView:removeAllChildren()
            for i = 1, #self.mPurpleList do
                self.mListView:pushBackCustomItem(self:createCellView(i, self.mPurpleList, Enums.Color.ePurpleH))
            end
            self.mListView:jumpToTop()
        end
    elseif selectTag == TabPageTags.eTagOrange then
        if self.mListView ~= nil then
            self.mListView:removeAllChildren()
            for i = 1, #self.mOrangeList do
                self.mListView:pushBackCustomItem(self:createCellView(i, self.mOrangeList, Enums.Color.eNormalYellowH))
            end
            self.mListView:jumpToTop()
        end
    end
end

--[-----------请求网络接口---------]--
function TeambattleShop:requestShopInfo()
	HttpClient:request({
        moduleName = "TeambattleShopinfo",
        methodName = "ShopInfo",
        svrMethodData = {},
        callback = function(data)
        	-- 判断返回数据
            if data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value
            -- 存放数据的容器
            self.mBlueList   = {} -- 蓝色
			self.mPurpleList = {} -- 紫色
			self.mOrangeList = {} -- 橙色

			for i, v in ipairs(TeambattleShopModel.items) do
				local item = Utility.analysisStrResList(v.outResource)
                item[1].needTeamBattleCoins = v.needTeamBattleCoins
                item[1].totalMaxNum = v.totalMaxNum
                item[1].tab = v.tab
                item[1].ID = v.ID
                item[1].needNodeModelID = v.needNodeModelID
                item[1].TotalBuyCount = 0
                -- 网络数据判断
                for m, n in ipairs(dataInfo.BuyShopInfo) do
                    if n.ShopId == v.ID then
                        item[1].TotalBuyCount = n.TotalBuyCount
                        break
                    end
                end
                -- 数据放入容器
                table.insert(self.mBlueList, item[1])
			end

            for i=1, 6 do
                for m, n in ipairs(dataInfo.TeambattleFightinfo) do
                    if TeambattleNodeModel.items[n.NodeModelID].chapterModelID == self.mBattleNode[i].ID then
                        if self.mCrusadeInfo[i] == nil then
                            self.mCrusadeInfo[i] = {}
                        end
                        table.insert(self.mCrusadeInfo[i], n)
                    end
                end
            end

			dump(dataInfo, "服务器返回数据")
            -- 添加数据
            self:createListView()
        end,
    })
end

-- 进行道具购买，领取
--[[
params:
    shopId: 商品ID，
    num:    购买数量
]]--
function TeambattleShop:requestBuyItem(shopId, num)
    HttpClient:request({
        moduleName = "TeambattleShopinfo",
        methodName = "BuyShop",
        svrMethodData = {shopId, num},
        callback = function(data)
            -- 判断返回数据
            if data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value
            -- 兑换成功，获得以下物品
            ui.ShowRewardGoods(dataInfo.BaseGetGameResourceList)
            -- 更新数据
            self.mInfoLabel:refreshCount()

            -- 发送消息通知
            Notification:postNotification(EventsName.ePropRedDotPrefix .. tostring(needGoodId))

            -- 处理数据
            local isFind = false
            for i, v in ipairs(self.mBlueList) do
                if v.ID == shopId then
                    v.TotalBuyCount = v.TotalBuyCount + num
                    --self.mListView:removeItem(i - 1)
                    --self.mListView:pushBackCustomItem(self:createCellView(i, self.mBlueList, Enums.Color.eNormalBlueH))
                    isFind = true
                    break
                end
            end

            -- if isFind == false then
            --     for i, v in ipairs(self.mPurpleList) do
            --         if v.ID == shopId then
            --             v.TotalBuyCount = v.TotalBuyCount + num
            --             self.mListView:removeItem(i - 1)
            --             self.mListView:pushBackCustomItem(self:createCellView(i, self.mPurpleList, Enums.Color.ePurpleH))
            --             isFind = true
            --             break
            --         end
            --     end
            -- end

            -- if isFind == false then
            --     for i, v in ipairs(self.mOrangeList) do
            --         if v.ID == shopId then
            --             v.TotalBuyCount = v.TotalBuyCount + num
            --             self.mListView:removeItem(i - 1)
            --             self.mListView:pushBackCustomItem(self:createCellView(i, self.mOrangeList, Enums.Color.eNormalYellowH))
            --             isFind = true
            --             break
            --         end
            --     end
            -- end

            -- 添加数据
            self.mListView:removeAllItems()
            for i = 1, #self.mBlueList do
                self.mListView:pushBackCustomItem(self:createCellView(i, self.mBlueList, Enums.Color.eNormalBlueH))
            end
        end,
    })
end

return TeambattleShop
