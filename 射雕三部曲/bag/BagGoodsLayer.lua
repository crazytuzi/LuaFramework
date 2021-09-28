--[[
    文件名：BagGoodsLayer.lua
    描述：道具界面
    创建人：yanxingrui
    修改人：lengjiazhi
    创建时间： 2016.5.6
--]]

local BagGoodsLayer = class("BagGoodsLayer", function(params)
    return display.newLayer()
end)

-- 构造函数，初始化本页面需要的数据并刷新表格
function BagGoodsLayer:ctor(params)

    self.mSelectId = params and params.selectId
    self.mSelIndex = nil
    self.mDataList = {}


    -- 包裹空间文字背景图片
    local countBack = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    countBack:setPosition(540, 940)
    self:addChild(countBack)

    countWordLabel = ui.newLabel({
        text = TR("包裹空间"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    countWordLabel:setAnchorPoint(cc.p(0, 0.5))
    countWordLabel:setPosition(390, 940)
    self:addChild(countWordLabel)

    local underGaryBgSprite = ui.newScale9Sprite("c_24.png", cc.size(626, 660))
    underGaryBgSprite:setPosition(320, 578)
    self:addChild(underGaryBgSprite)


    self:refreshGrid()


end

-- 显示包裹数量
function BagGoodsLayer:showBagCount()

    if self.mCountLabel then
        self.mCountLabel:removeFromParent()
        self.mCountLabel = nil
    end

    if self.mBuyBtn then
        self.mBuyBtn:removeFromParent()
        self.mBuyBtn = nil
    end

    -- 添加数量显示
    self.mCountLabel = ui.newLabel({
        text = TR("%d/%d", 0, 0),
        color = cc.c3b(0xd1, 0x7b, 0x00),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    -- self.mCountLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mCountLabel:setPosition(540, 940)
    self:addChild(self.mCountLabel)

    --扩充按钮
    self.mBuyBtn = ui.newButton({
        -- text = TR("扩充"),
        normalImage = "gd_27.png",
        position = cc.p(600, 940),
        -- size = cc.size(125, 57),
        clickAction = function()
            MsgBoxLayer.addExpandBagLayer(BagType.eGoodsBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    self:addChild(self.mBuyBtn)
    -- self.mBuyBtn:setScale(0.7)
    local bagTypeInfo = BagModel.items[BagType.eGoodsBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eGoodsBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eGoodsBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    -- local iconSprite = ui.newSprite("dw_05.png")
    -- iconSprite:setPosition(30,950)
    -- iconSprite:setScale(1.5)
    -- self:addChild(iconSprite)

    if self:getItemCount(BagType.eGoodsBag) == 0 then
        local sp = ui.createEmptyHint(TR("没有道具！"))
        sp:setPosition(320, 568)
        self:addChild(sp)
    end
end

-- 根据所选择的card显示相应的属性
function BagGoodsLayer:showAttrLabel(data)
    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self:addChild(self.mAttrSprite)

    local card = CardNode.createCardNode({
        instanceData = data,
        cardShape = Enums.CardShape.eSquare,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
    })
    card:setPosition(55, 65)
    self.mAttrSprite:addChild(card)

    --代金券过期处理
    if math.floor(data.ModelId / 100000) == 169 then
        local voucherStatus = ConfigFunc:getVoucherStatus(data)
        if voucherStatus == 0 or voucherStatus == -1 then
            local passedTipSprite = ui.newSprite("c_150.png")
            passedTipSprite:setPosition(40, 56)
            card:addChild(passedTipSprite)
            local passedTipLabel = ui.newLabel({
                text = TR("过期"),
                size = 22,
                outlineColor = Enums.Color.eBlack,
                })
            passedTipLabel:setPosition(27, 49)
            passedTipLabel:setRotation(-45)
            passedTipSprite:addChild(passedTipLabel)
        end
    end

    local NorGoodsModel = GoodsModel.items[data.ModelId] or GoodsVoucherModel.items[data.ModelId]
    local goodsModel
    if not NorGoodsModel then
        return
    elseif NorGoodsModel then
        goodsModel = NorGoodsModel
    end

    local nameLab = ui.newLabel({
        text = TR(goodsModel.name),
        size = 22,
        color = Utility.getQualityColor(goodsModel.quality, 1),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        anchorPoint = cc.p(0, 1),
        dimensions = cc.size(300, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    })
    nameLab:setPosition(115, 113)
    self.mAttrSprite:addChild(nameLab)

    local introLab = ui.newLabel({
        text = TR(goodsModel.intro),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0),
        dimensions = cc.size(350, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })

    local size = introLab:getContentSize()
    local height = math.min(size.height, 60)
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(cc.size(350, height))
    scrollView:setAnchorPoint(cc.p(0, 1))
    scrollView:setPosition(cc.p(115, 80))
    scrollView:setInnerContainerSize(introLab:getContentSize())
    scrollView:addChild(introLab)

    self.mAttrSprite:addChild(scrollView)

    -- 判断是否可以使用
    if NorGoodsModel then
        -- 需要合成的道具类型
        if GoodsSpModel.items[goodsModel.ID] then
            -- 创建合成按钮
            self.useBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                --size = cc.size(135,59),
                text = TR("合 成"),
                clickAction = function()
                    self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    self:useGoods({
                        data = data,
                        callback = function()
                            self:refreshGrid()
                        end,
                    })
                end
            })
            -- 穿透问题
            self.useBtn:setPropagateTouchEvents(false)
            self.mAttrSprite:addChild(self.useBtn)
        else
            if goodsModel.ifUse then
                -- 创建使用按钮
                self.useBtn = ui.newButton({
                    normalImage = "c_28.png",
                    position = cc.p(550, 65),
                    --size = cc.size(135,59),
                    text = TR("使 用"),
                    clickAction = function()
                        self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                        self:useGoods({
                            data = data,
                            callback = function()
                                self:refreshGrid()
                            end,
                        })
                    end
                })
                -- 穿透问题
                self.useBtn:setPropagateTouchEvents(false)
                self.mAttrSprite:addChild(self.useBtn)
            end

            -- 判断是否可以出售

            if goodsModel.sellTypeID > 0 and goodsModel.sellNum > 0 then
                if goodsModel.ifUse then
                    self.useBtn:setPosition(550, 97)
                end
                -- 创建出售按钮
                local saleBtn = ui.newButton({
                    normalImage = "c_28.png",
                    position = goodsModel.ifUse and cc.p(550, 37) or cc.p(550, 65),
                    --size = cc.size(135,58),
                    text = TR("出 售"),
                    clickAction = function(pSender)
                        self.mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                        self:onBtnSellClicked(data)
                    end
                })
                -- 穿透问题
                saleBtn:setPropagateTouchEvents(false)
                self.mAttrSprite:addChild(saleBtn)
            end
        end
    end
end

-- 刷新显示列表
function BagGoodsLayer:refreshGrid()

    self:showBagCount()

    -- 清空之前的显示列表
    if self.mGridView then
        self.mGridView:removeFromParent()
        self.mGridView = nil
    end

    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    -- 得到对应包裹里的数据
    self.mDataList = self:getItemData()

    if #self.mDataList > 0 then
        self.mGridView = require("common.GridView"):create({
            viewSize = cc.size(640, 645),
            colCount = 5,
            celHeight = 114,
            selectIndex = 1,
            -- needDelay = true,
            getCountCb = function()
                return #self.mDataList
            end,
            createColCb = function(itemParent, colIndex, isSelected)

                local attrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                    if GoodsObj:getNewPropsIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                        GoodsObj:getNewPropsIdObj():clearNewId(self.mDataList[colIndex].Id)
                        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagProps)
                    end
                end

                if GoodsObj:getNewPropsIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eNewCard)
                end

                -- 创建显示图片
                local card, Attr = CardNode.createCardNode({
                    instanceData = self.mDataList[colIndex],
                    cardShowAttrs = attrs,
                    onClickCallback = function()
                        self:showAttrLabel(self.mDataList[colIndex])
                        self.mGridView:setSelect(colIndex)
                        self.mSelIndex = colIndex
                        self.mSelectId = self.mDataList[colIndex].Id
                    end,
                })
                card:setPosition(64, 60)
                itemParent:addChild(card)

                --代金券过期处理
                if math.floor(self.mDataList[colIndex].ModelId / 100000) == 169 then
                    local voucherStatus = ConfigFunc:getVoucherStatus(self.mDataList[colIndex])
                    if voucherStatus == 0 or voucherStatus == -1 then
                        local passedTipSprite = ui.newSprite("c_150.png")
                        passedTipSprite:setPosition(40, 56)
                        card:addChild(passedTipSprite)
                        local passedTipLabel = ui.newLabel({
                            text = TR("过期"),
                            size = 22,
                            outlineColor = Enums.Color.eBlack,
                            })
                        passedTipLabel:setPosition(27, 49)
                        passedTipLabel:setRotation(-45)
                        passedTipSprite:addChild(passedTipLabel)
                    end
                end
            end,
        })

        self.mGridView:setPosition(320, 580)
        self:addChild(self.mGridView)

        local selIndex = 1
        for index, value in ipairs(self.mDataList) do
            if value.Id == self.mSelectId then
                selIndex = index
            end
        end
        if selIndex == 1 then
            if self.mSelIndex and self.mSelIndex <= 25 then
                self.mViewPos = nil
            end
        end
        self.mGridView:setSelect(selIndex)
        self:showAttrLabel(self.mDataList[selIndex])
        if self.mViewPos then
            self.mGridView.mScrollView:getInnerContainer():setPosition(self.mViewPos)
        end
        self.mSelIndex = selIndex
    end

end

-- 获取对应类的包裹的信息
function BagGoodsLayer:getPlayerBagInfo()
    local bagModelId = BagType.eGoodsBag
    local playerTypeInfo = {}
    for i, v in ipairs(BagInfoObj:getAllBagInfo()) do
        if v.BagModelId == bagModelId then
            playerTypeInfo = v
            break
        end
    end
    return playerTypeInfo
end

-- 得到对用type的包裹物品的数量
function BagGoodsLayer:getItemCount()
    local dataCount = #(GoodsObj:getPropsList())
    return dataCount
end

--得到对应数据和背包控件的类型
function BagGoodsLayer:getItemData()
    local itemData

    itemData = clone(GoodsObj:getPropsList())
    -- fashionDebrisData = clone(GoodsObj:getFashionDebrisList())
    -- table.insertto(itemData)
    table.sort(itemData, function (a, b)
        local modelA = GoodsModel.items[a.ModelId] or GoodsVoucherModel.items[a.ModelId]
        local modelB = GoodsModel.items[b.ModelId] or GoodsVoucherModel.items[b.ModelId]

        if not modelA or not modelB then 
            return false
        end

        --排序id
        if modelA.orderNum ~= modelB.orderNum then
            return modelA.orderNum < modelB.orderNum 
        end

        --比较模型id
        if a.ModelId ~= b.ModelId then
            return a.ModelId < b.ModelId
        end

        --比较数量
        if a.Num ~= b.Num then
            return a.Num > b.Num
        end

        return a.Id < b.Id
    end)

    return itemData
end

-- -- 关闭该页面时执行函数
-- function BagGoodsLayer:onExit()
--     GoodsObj:getNewPropsIdObj():clearNewId()
-- end

----------------------------物品使用-------------------
function BagGoodsLayer:useGoods(params)

    local data = params.data
    local goodsModel = GoodsModel.items[data.ModelId] or GoodsVoucherModel.items[data.ModelId]
    params.goodsModel = goodsModel

    local tempItemId = data.ModelId
    if math.floor(tempItemId / 100000) == 169 then    --代金券特殊处理
        -- 代金券
        LayerManager.addLayer({
            name = "bag.VoucherLayer",
            data = {isUse = true, modelId = data.ModelId, callback = params.callback, Id = data.Id},
            cleanUp = false,
        })
        return
    elseif GoodsSpModel.items[goodsModel.ID] then -- 需要合成的道具
        return self:_use_debries(params)
    elseif goodsModel.typeID == ResourcetypeSub.eTitleProps then --称号道具
        self:requestUseGoods(data, 1, params.callback)
        return
    elseif goodsModel.typeID == ResourcetypeSub.eLockedBox then --特殊宝箱
        local keyModelId = Utility.analysisStrResList(goodsModel.useResource)[1]
        local keyGoodModel = GoodsModel.items[keyModelId.modelId]
        local keyNum = Utility.getOwnedGoodsCount(keyGoodModel.typeID, keyGoodModel.ID)
        local selectCount = 0
        if keyNum <= 0 then
            ui.showFlashView(TR("没有足够的%s", keyGoodModel.name))
            return
        end

        MsgBoxLayer.addDIYLayer({
            bgSize = cc.size(600, 410),
            title = TR("选择使用数量"),
            btnInfos = {
                {
                    text = TR("确定"),
                    clickAction = function(layerObj)
                        self:requestUseGoods(data, selectCount, params.callback)
                        LayerManager.removeLayer(layerObj)
                    end
                },
                {
                    text = TR("取消"),
                    clickAction = function(layerObj)
                        LayerManager.removeLayer(layerObj)
                    end
                },
            },
            DIYUiCallback = function(layerObj, mBgSprite, mBgSize)
                local numLabel = ui.newLabel({
                    text = TR("是否使用1个%s开启1个%s？当前拥有钥匙：%d", keyGoodModel.name, goodsModel.name, keyNum),
                    size = 18,
                    color = Enums.Color.eBlack,
                    })
                numLabel:setAnchorPoint(0, 0.5)
                numLabel:setPosition(mBgSize.width * 0.05, mBgSize.height * 0.78)
                mBgSprite:addChild(numLabel)

                local tipLabel = ui.newLabel({
                    text = TR("开启后可随机获得下列一组奖励："),
                    size = 18,
                    color = Enums.Color.eBlack,
                    })
                tipLabel:setAnchorPoint(0, 0.5)
                tipLabel:setPosition(mBgSize.width * 0.05, mBgSize.height * 0.70)
                mBgSprite:addChild(tipLabel)

                local arrowUp = ui.newSprite("c_26.png")
                arrowUp:setPosition(mBgSize.width * 0.84-5, mBgSize.height * 0.64)
                arrowUp:setRotation(-90)
                mBgSprite:addChild(arrowUp)

                local arrowdown = ui.newSprite("c_26.png")
                arrowdown:setPosition(mBgSize.width * 0.84-5, mBgSize.height * 0.42)
                arrowdown:setRotation(90)
                mBgSprite:addChild(arrowdown)

                --奖励列表
                local boxList = ccui.ListView:create()
                boxList:setDirection(ccui.ScrollViewDir.vertical)
                boxList:setBounceEnabled(true)
                boxList:setContentSize(cc.size(520, 120))
                boxList:setGravity(ccui.ListViewGravity.centerHorizontal)
                boxList:setAnchorPoint(cc.p(0.5, 0))
                boxList:setPosition(mBgSize.width * 0.5, mBgSize.height * 0.38)
                mBgSprite:addChild(boxList)

                local boxOutputInfo = GoodsOutputRelation.items[goodsModel.goodsOutputOddsCode]

                for i,v in ipairs(boxOutputInfo) do
                    local layout = ccui.Layout:create()
                    layout:setContentSize(520, 120)

                    --奖励编号
                    local indexLabel = ui.newLabel({
                        text = i,
                        font = "c_81.png",
                        size = 34,
                        })
                    indexLabel:setPosition(460, 60)
                    layout:addChild(indexLabel)

                    local tempModelId = GoodsModel.items[v.outputModelID].goodsOutputOddsCode 
                    local outInfo = GoodsOutputRelation.items[tempModelId]
                    local tempGoods = {}
                    for i,v in ipairs(outInfo) do
                        local good = {}
                        good.resourceTypeSub = v.outputTypeID
                        good.modelId = v.outputModelID
                        good.num = v.outputNum
                        good.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
                        table.insert(tempGoods, good)
                    end

                    local cardList = ui.createCardList({
                        maxViewWidth = 420, 
                        viewHeight = 110, 
                        space = 5, 
                        cardDataList = tempGoods,
                    })
                    cardList:setAnchorPoint(0, 0.5)
                    cardList:setPosition(0, 50)
                    layout:addChild(cardList)

                    boxList:pushBackCustomItem(layout)
                end
                local boxNum = Utility.getOwnedGoodsCount(goodsModel.typeID, goodsModel.ID)
                local maxNum = boxNum > keyNum and keyNum or boxNum 
                print(boxNum, keyNum, maxNum, "uuuuu")
                local selectCountView = require("common.SelectCountView"):create({
                    maxCount = maxNum,
                    viewSize = cc.size(540, 150),
                    changeCallback = function(count)
                        selectCount = count
                        numLabel:setString(TR("是否使用%d个%s开启%d个%s？当前拥有钥匙：%d", count, keyGoodModel.name, count, goodsModel.name, keyNum))
                    end
                })
                selectCountView:setPosition(mBgSize.width / 2, 130)
                mBgSprite:addChild(selectCountView)
            end
            })
        return    
    end

    if not goodsModel.ifUse then
        ui.showFlashView(TR("该物品不能直接使用"))
    elseif goodsModel.typeID == ResourcetypeSub.eDiploma then
        -- 丹道
        return self:_use_diploma(params)
    elseif goodsModel.ID == 16050017 or goodsModel.ID == 16050018 then
        -- 帮派玄石
        return self:_use_guildStone(params)
    -- 至尊令
    elseif goodsModel.ID == 16050065 then
        return self:_use_zhizunling(params)
    -- 十连抽奖券
    elseif goodsModel.ID == 16050047 then
        return self:requestHeroRecruit(params, 4)
    elseif goodsModel.ID == 16050241 then
        return self:requestHeroRecruit(params, 3)
    elseif goodsModel.typeID == ResourcetypeSub.eBoxChoice -- 可选择礼包
        or goodsModel.typeID == ResourcetypeSub.eFashionChoice then  -- 时装选择包
        self:_use_choiceBox(params)
    elseif goodsModel.typeID == ResourcetypeSub.ePropsDebris then
        -- 道具碎片
        self:_use_propsDebris(params)
    elseif goodsModel.ID == 16050001 or goodsModel.ID == 16050048 then -- 突破相关
        self:_use_stepUp(params)
    elseif goodsModel.ID == 16050034 or goodsModel.ID == 16050046 then -- 内功洗练
        self:_use_zhenjue(params)
    elseif goodsModel.ID == 16050004 then -- 挖矿
        self:_use_forgingDigOre(params)
    elseif goodsModel.ID == 16050010 then -- 聚宝阁刷新令
        self:_use_mysteryShop(params)
    elseif goodsModel.ID == 16050234 then -- 搜捕令
        self:_use_battleBoss(params)
    elseif goodsModel.ID == 16050091 or goodsModel.ID == 16050016 then -- 江湖悬赏
        self:_use_xuanShang(params)
    elseif goodsModel.ID == 16050237 or goodsModel.ID == 16050238 or
        goodsModel.ID == 16050239 or goodsModel.ID == 16050240 then -- 装备锻造
        self:_use_equipStepUp(params)
    elseif goodsModel.ID == 16050020 then -- 搜捕令
        self:_use_treasureStepUp(params)
    elseif goodsModel.ID == 16050085 then -- 桃花岛
        self:_use_shenyuan(params)
    elseif goodsModel.ID == 16050003 then -- 豪侠招募令
        self:_use_ptZhaoMuLing(params)
    elseif goodsModel.ID == 16050013 then -- 关卡重置牌
        self:_use_resetBattle(params)
    elseif goodsModel.ID == 16050023 then -- 军功
        self:_use_jungong(params)
    elseif goodsModel.ID == 16050063 then -- 英雄帖
        self:_use_PvpInterCoin(params)
    else
        self:_use_normalGoods(params)
    end
end

-- 合成碎片
function BagGoodsLayer:_use_debries(params)
    local needsNumber = GoodsSpModel.items[params.data.ModelId].needsNumber
    local maxNum = math.floor(params.data.Num/needsNumber)
    self.layer2 = MsgBoxLayer.addMixGoodsCountLayer(TR("合成"), params.data.ModelId, maxNum <= 0 and 1 or maxNum,
        function (selCount)
            LayerManager.removeLayer(self.layer2)

            if params.data.Num < selCount*needsNumber then
                ui.showFlashView(TR("%s不足", GoodsModel.items[params.data.ModelId].name))
                return
            end
            self:requestUseGoods(params.data, selCount*needsNumber, params.callback)
        end
    )
end
-- 使用丹道
function BagGoodsLayer:_use_diploma(params)
    -- 丹道
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eTeacher) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eTeacher, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eTeacher, nil, true)
        end
    end
end

-- 使用帮派玄石
function BagGoodsLayer:_use_guildStone(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eGuild) then
        local isOpen, info = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eGuild, true)
        if GuildObj:getGuildInfo().Id == EMPTY_ENTITY_ID then
            ui.showFlashView(TR("请先加入一个帮派"))
        else
            LayerManager.showSubModule(ModuleSub.eGuild)
        end
    end
end

-- 使用至尊令
function BagGoodsLayer:_use_zhizunling(params)
    if params.data.Num == 1 then
        HttpClient:request({
            moduleName = "WechatChargeandlogin",
            methodName = "GoodsSell",
            svrMethodData = {params.data.Id, 1},
            callback = function(response)
                if response.Status == 0 then
                    ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
                end
                return params.callback and params.callback()
            end,
        })
    else
        self.layer2 = MsgBoxLayer.addUseGoodsCountLayer(TR("使用"), params.data.ModelId, params.data.Num,
            function (selCount)
                HttpClient:request({
                    moduleName = "WechatChargeandlogin",
                    methodName = "GoodsSell",
                    svrMethodData = {params.data.Id, selCount},
                    callback = function(response)
                        if response.Status == 0 then
                            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
                        end
                        return callback and callback()
                    end,
                })
                LayerManager.removeLayer(self.layer2)
            end
        )
    end
end

-- 使用普通物品
function BagGoodsLayer:_use_normalGoods(params)
    local data = params.data
    local goodsModel = params.goodsModel
    local maxUseCount = data.Num

    -- 检查是否依赖其他资源
    if goodsModel.useResource and goodsModel.useResource ~= "" and goodsModel.useResource ~= "0" then
        local useResource = Utility.analysisGameDrop(goodsModel.useResource)

        for _, v in ipairs(useResource) do
            -- 依赖资源名字
            local name = GoodsModel.items[v.modelId].name
            -- 依赖资源拥有数量
            -- TODO
            local haveCount = Utility.getOwnedGoodsCount(v.resourcetypeSub, v.modelId)--, {filterInTeam = true})
            -- 去掉已上阵的


            -- 检查依赖资源数量是否足够
            if haveCount < v.count then
                return tipItNotEnough(v.modelId, v.count)
            end

            -- 依赖资源最多可使用次数
            maxUseCount = math.min(maxUseCount, math.floor(haveCount / v.count))
        end
    end
    print("maxUseCount,",maxUseCount)

    if goodsModel.typeID == ResourcetypeSub.eBoxFixed -- 固定箱包类
        or goodsModel.typeID == ResourcetypeSub.eBoxOdds -- 概率箱包类
        then
        -- 检查背包容量

    end

    if maxUseCount == 1 then
        self:requestUseGoods(data, 1, params.callback)
    else
        -- 可使用多次
        -- 选择使用数量
        self.layer = MsgBoxLayer.addUseGoodsCountLayer(TR("使用"), data.ModelId, maxUseCount,
            function (selCount)
                if selCount == 0 then
                    LayerManager.removeLayer(self.layer)
                    return
                end
                self:requestUseGoods(data, selCount, params.callback)
                LayerManager.removeLayer(self.layer)
            end
        )
    end

end

-- 使用道具碎片
function BagGoodsLayer:_use_propsDebris(params)
    local data = params.data
    local goodsModel = params.goodsModel

    local haveCount = GoodsObj:getCountByModelId(goodsModel.ID)
    if data.Num >= goodsModel.maxNum then
        self:requestUseGoods(data, goodsModel.maxNum, params.callback)
    else
        ui.showFlashView(TR("需要集齐%s个%s", goodsModel.maxNum, goodsModel.name))
    end
end

-- 使用可选择礼包
function BagGoodsLayer:_use_choiceBox(params)
    local data = params.data
    local goodsModel = params.goodsModel
    local maxUseCount = data.Num

    self.choicelayer = MsgBoxLayer.addChoiceGoodsOutLayer(nil, goodsModel.ID, maxUseCount,
        function(selCount, selectedModelId)
            LayerManager.removeLayer(self.choicelayer)
            self:requestUseChoiceBox(data, selCount, selectedModelId, params.callback)
        end
    )
end

-- 使用江湖悬赏相关道具
function BagGoodsLayer:_use_xuanShang(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eXrxs) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eXrxs, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eXrxs, nil, true)
        end
    end
end

-- 使用内功洗练相关道具
function BagGoodsLayer:_use_zhenjue(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjueExtra) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eZhenjueExtra, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eZhenjueExtra, nil, true)
        end
    end
end

-- 使用突破相关道具
function BagGoodsLayer:_use_stepUp(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eHeroStepUp) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eHeroStepUp, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eHeroStepUp, nil, true)
        end
    end
end

-- 使用挖矿相关道具
function BagGoodsLayer:_use_forgingDigOre(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eChallengeGrab) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChallengeGrab, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eChallengeGrab, nil, true)
        end
    end
end

-- 使用聚宝阁刷新令
function BagGoodsLayer:_use_mysteryShop(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eMysteryShop) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eMysteryShop, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eMysteryShop, nil, true)
        end
    end
end

-- 使用搜捕令
function BagGoodsLayer:_use_battleBoss(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eBattleBoss) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleBoss, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eBattleBoss, nil, true)
        end
    end
end

-- 使用锻造石
function BagGoodsLayer:_use_equipStepUp(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eEquipStepUp) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eEquipStepUp, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eEquipStepUp, nil, true)
        end
    end
end

-- 使用神兵精魄
function BagGoodsLayer:_use_treasureStepUp(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eTreasureStepUp) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eTreasureStepUp, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eTreasureStepUp, nil, true)
        end
    end
end

-- 使用乌木
function BagGoodsLayer:_use_shenyuan(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eShengyuanWars) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eShengyuanWars, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eShengyuanWars, nil, true)
        end
    end
end

-- 使用豪侠招募令
function BagGoodsLayer:_use_ptZhaoMuLing(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eRecruit) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eRecruit, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eRecruit, nil, true)
        end
    end
end

-- 使用关卡重置牌
function BagGoodsLayer:_use_resetBattle(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eBattleForTen) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleForTen, true)
        if isOpen then
            LayerManager.addLayer({
                name = "battle.ConFightLayer",
                data = {}
            })
        end
    end
end

-- 使用军功
function BagGoodsLayer:_use_jungong(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eTeambattleShop) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eTeambattleShop, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.eTeambattleShop, nil, true)
        end
    end
end

-- 使用英雄帖
function BagGoodsLayer:_use_PvpInterCoin(params)
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePVPInter) then
        local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePVPInter, true)
        if isOpen then
            LayerManager.showSubModule(ModuleSub.ePVPInter, nil, true)
        end
    end
end

-- 显示奖励
function BagGoodsLayer:responseUseGoods(res, data, callback)
    resourceList = clone(res.Value.BaseGetGameResourceList or {})
    -- 删除体力和耐力
    for _, v in ipairs(resourceList) do
        if v.PlayerAttr then
            local function remove()
                for k, attr in pairs(v.PlayerAttr) do
                    if attr.ResourceTypeSub == ResourcetypeSub.eVIT or attr.ResourceTypeSub == ResourcetypeSub.eSTA then
                        table.remove(v.PlayerAttr, k)
                        return true
                    end
                end
                return false
            end

            while remove() do
            end

            if table.nums(v.PlayerAttr) == 0 then
                v.PlayerAttr = nil
            end
        end
    end

    if resourceList[1] and table.nums(resourceList[1]) > 0 then
        MsgBoxLayer.addGameDropLayer(resourceList, {}, "", "", {{text = TR("确定")}})
    else
        ui.showFlashView(TR("使用成功"))
    end

    return callback and callback()
end


----------------------------网络请求---------------------------
-- 点击出售
function BagGoodsLayer:onBtnSellClicked(data)
    local function do_request(cnt)
        -- 出售道具
        HttpClient:request({
            moduleName = "Goods",
            methodName = "GoodsSell",
            svrMethodData = {data.Id, data.ModelId, cnt},
            callback = function(value)
                if value.Status ~= 0 then
                    return
                end
                ui.showFlashView(TR("出售完成"))
                self:refreshGrid()
            end,
        })
    end

    -- 获取道具
    local goodsModel = GoodsModel.items[data.ModelId] or GoodsVoucherModel.items[data.ModelId]

    -- 出售确认框
    local function confirm(cnt, price)
        local name = goodsModel.name
        local price = goodsModel.sellNum * cnt
        local selltype = ResourcetypeSubName[goodsModel.sellTypeID]
        -- MsgBoxLayer.addOKCancelLayer(msgText, title, okBtnInfo, cancelBtnInfo, closeBtnInfo, needCloseBtn)
        self.layer = MsgBoxLayer.addOKLayer(
            TR("出售%s个%s?共计%s%s", cnt, name, price, selltype),
            TR("出售"),
            {{
                normalImage = "c_28.png",
                text = TR("确定"),
                clickAction = function()
                    do_request(cnt)
                    LayerManager.removeLayer(self.layer)
                end,
            }},{}
        )
    end

    -- 如果物品数量大于1，点击出售时弹出个数的选择框
    if data.Num > 1 then
        MsgBoxLayer.addSellGoodsCountLayer(TR("出售"), data.ModelId, data.Num,
            function (selCount)
                confirm(selCount)
            end
        )
    else
        confirm(1)
    end
end

-- 请求物品使用
function BagGoodsLayer:requestUseGoods(data, count, callback)
    local isOutputFashion = false
    for _,v in pairs(GoodsOutputRelation.items[data.ModelId] or {}) do
        if (v.outputTypeID == ResourcetypeSub.eFashionClothes) then
            isOutputFashion = true
            break
        end
    end
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, count},
        callback = function(response)
            -- 如果产出物里包括绝学，就更新绝学缓存
            if (isOutputFashion == true) then
                FashionObj:refreshFashionList()
            end
            if response.Status == 0 then
                return self:responseUseGoods(response, data, callback)
            end
        end,
    })

end

-- 使用十连抽奖券
function BagGoodsLayer:requestHeroRecruit(params, recruitType)
    HttpClient:request({
        moduleName = "HeroRecruit",
        methodName = "Recruit",
        svrMethodData = {recruitType, 0}, -- 使用道具、非免费
        callback = function(response)
            if recruitType == 3 then
                local layer = LayerManager.addLayer({
                    name = "shop.HeroRecruitShowActionLayer",
                    data = {
                        heroInfo = response.Value.BaseGetGameResourceList[1].Hero,
                        goodInfo = response.Value.BaseGetGameResourceList[1].Goods,
                        recruitBtnType = recruitType,
                        closeCallBack = function()
                            LayerManager.removeLayer(layer)
                            return params.callback and params.callback()
                        end
                    },
                    cleanUp = false,
                })
            elseif recruitType == 4 then
                local layer = LayerManager.addLayer({
                    name = "shop.HeroRecruitShowTenActionLayer",
                    data = {
                        heroList = response.Value.BaseGetGameResourceList[1].Hero,
                        goodInfo = response.Value.BaseGetGameResourceList[1].Goods,
                        recruitBtnType = recruitType,
                        btnCallBack = function ()
                            if GoodsObj:getCountByModelId(16050047) < 1 then
                                LayerManager.removeLayer(layer)
                                ui.showFlashView(TR("%s不足", Utility.getGoodsName(ResourcetypeSub.eFunctionProps, 16050047)))
                                return params.callback and params.callback()
                            else
                                self:requestHeroRecruit(params, 4)
                            end
                        end,
                        closeCallBack = function()
                            LayerManager.removeLayer(layer)
                            return params.callback and params.callback()
                        end
                    },
                    cleanUp = false,
                })
            end
        end,
    })
end

-- 请求使用可选礼包
function BagGoodsLayer:requestUseChoiceBox(data, cnt, selectedModelId, callback)
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUseForBoxChoice",
        svrMethodData = {data.Id, data.ModelId, selectedModelId, cnt},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            if cnt == 1 and ResourcetypeSub.eHero == math.floor(selectedModelId / 10000) then
                LayerManager.addLayer({
                    name = "shop.HeroRecruitShowActionLayer",
                    data = {heroInfo = response.Value.BaseGetGameResourceList[1].Hero, isNotRecruit = true},
                })
            else
                return self:responseUseGoods(response, data, callback)
            end
        end,
    })
end

return BagGoodsLayer
