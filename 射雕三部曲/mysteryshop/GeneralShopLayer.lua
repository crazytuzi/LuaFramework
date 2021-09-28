--[[
	文件名：GeneralShopLayer.lua
	描述：神秘商店之普通聚宝阁分页面
	创建人：libowen
    修改人:lengjiazhi
	创建时间：2016.7.7
--]]

-- 该页面作为子节点添加到已适配的父节点上，坐标按照 640 1136来即可
local GeneralShopLayer = class("GeneralShopLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
    params:
    Table params:
    {

    }
--]]
function GeneralShopLayer:ctor(params)

    self.mParams_ = params
	self:setContentSize(640, 1136)

	-- 初始化UI
	self:initUI()

	-- 请求服务器，获取普通聚宝阁数据
	self:requestGetInfo()
end

-- 初始化UI元素
function GeneralShopLayer:initUI()
	-- 背景框
    local bgSpr = ui.newScale9Sprite("c_94.png",cc.size(640, 868))
    bgSpr:setPosition(320, 550)
    self:addChild(bgSpr)

    -- 普通聚宝阁标题
    local title = ui.newLabel({
        text = TR("聚宝阁"),
        size = 26,
        color = cc.c3b(0x4e, 0x15, 0x0c),
        x = 320,
        y = 961,
    })
    self:addChild(title)

    --背景底板
    local underBgSprite = ui.newScale9Sprite("c_97.png", cc.size(570, 670))
    underBgSprite:setPosition(320, 598)
    self:addChild(underBgSprite)

    -- 添加ListView
    self:addListView()

    -- 剩余时间、拥有刷新 所在的蓝色背景条
    local line = ui.newScale9Sprite("jbg_03.png", cc.size(584, 60))
    line:setPosition(cc.p(320, 230))
    self:addChild(line)

    -- 剩余时间标签
    self.mTimeLabel = ui.newLabel({
        text = TR(""),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x83, 0x45, 0x00),
        x = line:getContentSize().width * 0.08,
        y = line:getContentSize().height * 0.5
    })
    line:addChild(self.mTimeLabel)

    -- 免费刷新次数/拥有刷新令/刷新消耗资源标签
    self.mFreeLabel = ui.newLabel({
        text = TR(""),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x83, 0x45, 0x00),
        x = line:getContentSize().width * 0.55,
        y = line:getContentSize().height * 0.5,
    })
    line:addChild(self.mFreeLabel)

    -- 去分解按钮
    local decomposeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("去分解"),
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
        position = cc.p(200, 165),
        size = cc.size(150, 60),
        clickAction = function()
            -- 跳转到炼化页面
            LayerManager.showSubModule(ModuleSub.eDisassemble)
        end
    })
    self:addChild(decomposeBtn)

    -- 刷新按钮
    self.mRefreshBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("刷新"),
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
        position = cc.p(440, 165),
        size = cc.size(150, 60),
        clickAction = function()
            self:refreshBtnClicked()
        end
    })
    self:addChild(self.mRefreshBtn)

    -- 刷新按钮后边的消耗品，免费时不显示
    self.mCostLabel = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eBrown
    })
    self.mCostLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mCostLabel:setPosition(505, 170)
    self:addChild(self.mCostLabel)


    --今日次数限制label
    local totalNumLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eRed,
        -- outlineColor = Enums.Color.eRed,
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    totalNumLabel:setPosition(420, 100)
    self:addChild(totalNumLabel)
    self.mTotalNumLabel = totalNumLabel
end

-- 创建物品滑动列表
function GeneralShopLayer:addListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setItemsMargin(10)
    self.mListView:setContentSize(cc.size(570, 660))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(325, 925)
    self:addChild(self.mListView)
end

-- 刷新按钮点击事件，1、2、3分别表示：免费刷新、道具刷新、元宝刷新
function GeneralShopLayer:refreshBtnClicked()
    -- 拥有的刷新令数量
    local resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].refreshUseResource)[1]
    local havePropNum = Utility.getOwnedGoodsCount(resourceInfo.resourceTypeSub, resourceInfo.modelId)

    -- 有免费刷新次数
    if self.mShopInfo.FreeCount > 0 then
        self:requestRefreshGoodsList(1)
    else
        -- 有刷新令
        if havePropNum > 0 then
            self:requestRefreshGoodsList(2)
        else
            resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].refreshUseResourceSub)[1]
            -- 首次用神魂刷新的时候弹出提示框, 以后不再弹出
            if self.mShopInfo.GoldCount <= 0 then
                MsgBoxLayer.addOKLayer(
                    TR("是否确定花费%s刷新?", Utility.getGoodsName(resourceInfo.resourceTypeSub)),
                    TR("提示"),
                     {{
                        text = TR("确定"),
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)

                            if Utility.isResourceEnough(resourceInfo.resourceTypeSub, resourceInfo.num) then
                                self:requestRefreshGoodsList(3)
                            end
                        end
                    }},{})
            elseif self.mShopInfo.GoldCount < self.mShopInfo.RefreshMysteryShopMaxNum then
                if Utility.isResourceEnough(resourceInfo.resourceTypeSub, resourceInfo.num) then
                    self:requestRefreshGoodsList(3)
                end
            else
                MsgBoxLayer.addOKLayer(
                    TR("已达到最大刷新次数,提升VIP等级可以增加购买刷新次数上限."),
                    TR("提示"),
                    {
                        {
                            text = TR("去充值"),
                            clickAction = function(layerObj, btnObj)
                                LayerManager.removeLayer(layerObj)
                                LayerManager.showSubModule(ModuleSub.eCharge, nil, false)
                            end
                        },
                        {
                            text = TR("取消")
                        }
                    }
                )
            end
        end
    end
end

-- 更新倒计时标签
function GeneralShopLayer:updateTime()
    -- 剩余 天 xx:xx:xx:
    local timeLeft = self.mShopInfo.LastFreshDate - Player:getCurrentTime()
    if timeLeft >= 0 then
    	self.mTimeLabel:setString(TR("剩余时间: %s%s",
            "#FFF000",
            MqTime.formatAsDay(timeLeft)
        ))
    -- 刷新时间到，重新请求数据
    else
    	self:stopAction(self.mSchelTime)
        self.mSchelTime = nil

        self:requestGetInfo()
    end

    -- print("更新时间")
end

-- 获取数据后，刷新页面
function GeneralShopLayer:refreshLayer()
	-- 刷新时间，开始倒计时
    self:updateTime()
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新次数标签和按钮后边的消耗
    -- 有免费刷新次数
    if self.mShopInfo.FreeCount > 0 then
        self.mFreeLabel:setString(TR("免费刷新次数: %s%d", "#FFF000", self.mShopInfo.FreeCount))
        -- self.mCostLabel:setString(TR(""))
        self.mRefreshBtn.mTitleLabel:setString(TR("刷新"))
        self.mRefreshBtn.mTitleLabel:setSystemFontSize(26)
    else
    	-- 刷新令模型Id及图片
        local resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].refreshUseResource)[1]
        local haveNum = Utility.getOwnedGoodsCount(resourceInfo.resourceTypeSub, resourceInfo.modelId)
        -- 有刷新令
        if haveNum > 0 then
            local propPic = Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, resourceInfo.modelId)
            self.mFreeLabel:setString(TR("拥有刷新令: {%s}%s%d", propPic, "#FFF000", haveNum))
            -- self.mCostLabel:setString(TR("{%s}X%d", propPic, propNum))
            self.mRefreshBtn.mTitleLabel:setString(TR("刷新{%s}X%d", propPic, resourceInfo.num))
            self.mRefreshBtn.mTitleLabel:setSystemFontSize(24)
        -- 无刷新令则消耗神魄
        else
            resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].refreshUseResourceSub)[1]
            local propPic = Utility.getDaibiImage(resourceInfo.resourceTypeSub)
            self.mFreeLabel:setString(TR("刷新消耗%s: {%s}#FFF000%d", Utility.getGoodsName(resourceInfo.resourceTypeSub), propPic, resourceInfo.num))
            self.mRefreshBtn.mTitleLabel:setString(TR("刷新{%s}X%d", propPic, resourceInfo.num))
            self.mRefreshBtn.mTitleLabel:setSystemFontSize(22)
        end
    end

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, #self.mGoodsList do
        -- 创建cell
        local cellWidth, cellHeight = 570, 156
        local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(cellWidth, cellHeight))

        -- 向已创建的cell添加UI元素
        self:addElementsToCell(customCell, i)

        -- 添加cell到listview
        self.mListView:pushBackCustomItem(customCell)
    end
    self.mTotalNumLabel:setString(TR("今日剩余刷新次数：%d/%d", self.mShopInfo.LimitNum, self.mShopInfo.TotalNum))
end

-- 向创建的cell添加UI元素
--[[
    cell                -- 需要添加UI元素的cell
    cellIndex           -- cell索引号
--]]
function GeneralShopLayer:addElementsToCell(cell, cellIndex)
    -- 获取cell数据
    local groupInfo = self.mGoodsList[cellIndex]

    -- 获取cell宽高
    local cellWidth = cell:getContentSize().width
    local cellHeight = cell:getContentSize().height

    local underTray = ui.newScale9Sprite("c_96.png", cc.size(558, 71))
    underTray:setPosition(cellWidth * 0.5, -15)
    cell:addChild(underTray)

    -- 格子坐标
    local boxPos = {
        [1] = cc.p(cellWidth * 0.25, cellHeight * 0.5 ),
        [2] = cc.p(cellWidth * 0.74, cellHeight * 0.5 )
    }
    --dump(groupInfo, "88888")
    for i = 1, #groupInfo do
        -- 格子
        local cellBox = ui.newScale9Sprite("c_65.png", cc.size(260, 140))
        cellBox:setPosition(boxPos[i])
        cell:addChild(cellBox)
        local boxSize = cellBox:getContentSize()

        -- 格子内容父节点
        local cellParentNode = cc.Node:create()
        -- cellParentNode:setScale(0.9)
        cellParentNode:setPosition(cc.p(cellBox:getContentSize().width * 0.05, -cellBox:getContentSize().height * 0.035))
        cellBox:addChild(cellParentNode)

        -- 头像
        local header = CardNode.createCardNode({
            resourceTypeSub = groupInfo[i].SellResourceTypeSub,
            modelId = groupInfo[i].SellGoodsModelId,
            num = groupInfo[i].SellNum,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eDebris}
        })
        header:setAnchorPoint(cc.p(0, 0.5))
        header:setPosition(boxSize.width * 0.02, boxSize.height * 0.52)
        cellParentNode:addChild(header)



        -----拥有 x/x 标签----
        local haveLabel = ui.newLabel({
            text = TR(""),
            size = 20,
            color = cc.c3b(0x00, 0x95, 0x23),
            x = boxSize.width * 0.38 + 10,
            y = boxSize.height * 0.55,
            align = ui.TEXT_ALIGN_CENTER
        })
        haveLabel:setAnchorPoint(cc.p(0, 0.5))
        cellParentNode:addChild(haveLabel)
        -- 人物
        if Utility.isHero(groupInfo[i].SellResourceTypeSub) then
            local haveNum = HeroObj:getCountByModelId(groupInfo[i].SellGoodsModelId)
            haveLabel:setString(TR("拥有: %d", haveNum))
        -- 人物碎片
        elseif Utility.isHeroDebris(groupInfo[i].SellResourceTypeSub) then
            local haveNum = GoodsObj:getCountByModelId(groupInfo[i].SellGoodsModelId)
            haveLabel:setString(TR("拥有: %d/%d", haveNum, GoodsModel.items[groupInfo[i].SellGoodsModelId].maxNum))
        -- 道具
        elseif Utility.isGoods(groupInfo[i].SellResourceTypeSub) then
            local haveNum = GoodsObj:getCountByModelId(groupInfo[i].SellGoodsModelId)
            haveLabel:setString(TR("拥有: %d", haveNum))
        end

        -- 资源名称
        local tempName = Utility.getGoodsName(groupInfo[i].SellResourceTypeSub, groupInfo[i].SellGoodsModelId)
        -- 资源名字颜色
        local tempColor = Utility.getColorValue(
            Utility.getColorLvByModelId(groupInfo[i].SellGoodsModelId, groupInfo[i].SellResourceTypeSub),
            1)
        local resName = ui.newLabel({
            text = TR("%s", tempName),
            anchorPoint = cc.p(0, 0.5),
            size = 22,
            color = tempColor,
            outlineColor = Enums.Color.eBlack,
        })
        resName:setPosition(cc.p(boxSize.width * 0.38 + 10, boxSize.height * 0.82))
        cellParentNode:addChild(resName)

        -- 消耗
        -- local picName = Utility.getResTypeSubImage(groupInfo[i].BuyResourceTypeSub)
        local costNum = groupInfo[i].BuyNum
        -- local costLabel = ui.createLabelWithBg({
        --     -- bgFilename = "hs_04.png",
        --     bgSize = cc.size(100, 45),
        --     color = Enums.Color.eNormalWhite,
        --     alignType = ui.TEXT_ALIGN_CENTER,
        --     labelStr = TR("{%s}%d", picName, costNum)
        -- })
        -- costLabel:setPosition(boxSize.width * 0.72, boxSize.height * 0.75)
        -- cellBox:addChild(costLabel)

        -- 售价标签
        -- local tempLabel = ui.newLabel({
        --     text = TR("售价:"),
        --     size = 22
        --     })
        -- tempLabel:setAnchorPoint(cc.p(0, 0.5))
        -- tempLabel:setPosition(boxSize.width * 0.43, boxSize.height * 0.67)
        -- cellParentNode:addChild(tempLabel)

        local costLabel = ui.createDaibiView({
            resourceTypeSub = groupInfo[i].BuyResourceTypeSub,
            -- goodsModelId: 如果类型不是玩家属性，则需要传入模型Id
            number = groupInfo[i].BuyNum,
            fontColor = Enums.Color.eNormalWhite,
            -- fontColor = Enums.Color.eBlue,
            outlineColor = cc.c3b(0xb7, 0x25, 0x25),
        })
        -- costLabel:setScale(0.75)
        costLabel:setAnchorPoint(0.5, 0.5)
        costLabel:setPosition(boxSize.width * 0.66, boxSize.height * 0.28)
        cellParentNode:addChild(costLabel,10)
        -- 代币sprite
        costLabel:getChildren()[1]:setScale(0.75)
        -- 代币label
        costLabel:getChildren()[2]:setPosition(cc.p(
            costLabel:getChildren()[2]:getPositionX() - 5,
            costLabel:getChildren()[2]:getPositionY()))
        -- 购买按钮
        local buyButton = ui.newButton({
            -- normalImage = groupInfo[i].BuyResourceTypeSub == ResourcetypeSub.eHeroCoin and "c_59.png" or "c_61.png",
            normalImage = "c_59.png",
            -- size = cc.size(127 * 0.8, 55 * 0.8),
            -- text = TR("购买"),
            fontSize = 32,
            outlineColor = cc.c3b(0xff, 0xff, 0xff),
            outlineSize = 2,
            position = cc.p(boxSize.width * 0.66, boxSize.height * 0.28),
            clickAction = function()
                -- 此处购买花费只可能是 元宝 或者 神魂，获取代币名
                local name = ResourcetypeSubName[groupInfo[i].BuyResourceTypeSub]
                local haveNum = PlayerAttrObj:getPlayerAttr(groupInfo[i].BuyResourceTypeSub)

                if haveNum >= costNum then
                    self:requestMysteryShopBuyGoods(groupInfo[i].Id, cellIndex)
                else
                    -- 元宝不足给弹窗提示，神魂不足给飘窗提示
                    if groupInfo[i].BuyResourceTypeSub == ResourcetypeSub.eDiamond then
                        MsgBoxLayer.addGetDiamondHintLayer()
                    else
                        ui.showFlashView({
                            text = TR("%s不足", name)
                        })
                    end
                end
            end
        })
        -- buyButton:setScale(0.7)
        cellParentNode:addChild(buyButton)
        if cellIndex == 1 and i == 1 then
            self.mFirstBuyBtn = buyButton
        end

        -- 玩家神魂数量
        local playerResNum = PlayerAttrObj:getPlayerAttr(groupInfo[i].BuyResourceTypeSub)
        -- 按钮状态
        if groupInfo[i].IsSell ~= false or groupInfo[i].BuyNum > playerResNum then
            buyButton:setEnabled(false)
        end

        --------左上角羁绊标签--------
        local relationPics = {
            [Enums.RelationStatus.eIsMember] = "c_57.png",         -- 推荐
            [Enums.RelationStatus.eTriggerPr] = "c_58.png",        -- 缘分
            [Enums.RelationStatus.eSame] = "c_62.png"              -- 已上阵
        }
        local relationStr = {
            [Enums.RelationStatus.eIsMember] = TR("推荐"),
            [Enums.RelationStatus.eTriggerPr] = TR("缘分"),
            [Enums.RelationStatus.eSame] = TR("已上阵")
        }
        local relationSpr = nil
        local relationLab = nil

        -- 突破石单独处理，显示推荐
        if groupInfo[i].SellGoodsModelId == 16050001 then
            relationSpr = ui.newSprite(relationPics[Enums.RelationStatus.eIsMember])
            relationSpr:retain()
            relationLab = ui.newLabel({
                text = relationStr[Enums.RelationStatus.eIsMember],
                size = 21,
                outlineColor = Enums.Color.eBlack,
                })

        -- 英雄
        elseif Utility.isHero(groupInfo[i].SellResourceTypeSub) then
            local status = FormationObj:getRelationStatus(groupInfo[i].SellGoodsModelId, ResourcetypeSub.eHero)

            if status ~= Enums.RelationStatus.eNone then
                relationSpr = ui.newSprite(relationPics[status])
                relationSpr:retain()
                relationLab = ui.newLabel({
                text = relationStr[status],
                size = 21,
                outlineColor = Enums.Color.eBlack
                })
                if HeroModel.items[groupInfo[i].SellGoodsModelId].quality <= 10 then
                    relationSpr:setVisible(false)
                end
            end
        -- 英雄碎片
        elseif Utility.isHeroDebris(groupInfo[i].SellResourceTypeSub) then
            local item = GoodsModel.items[groupInfo[i].SellGoodsModelId]
            local status = FormationObj:getRelationStatus(item.outputModelID, ResourcetypeSub.eHero)

            if status ~= Enums.RelationStatus.eNone then
                relationSpr = ui.newSprite(relationPics[status])
                relationSpr:retain()
                relationLab = ui.newLabel({
                text = relationStr[status],
                size = 21,
                outlineColor = Enums.Color.eBlack
                })
                if HeroModel.items[item.outputModelID].quality <= 10 then
                    relationSpr:setVisible(false)
                end
            end
        end

        if relationSpr then
            relationSpr:setPosition(-10, boxSize.height + 5)
            relationSpr:setAnchorPoint(cc.p(0, 1))
            cellParentNode:addChild(relationSpr)
            relationSpr:release()
            relationLab:setPosition(13, boxSize.height - 25)
            relationLab:setRotation(-45)
            cellParentNode:addChild(relationLab)
        end
    end
end

-- 整理物品信息，2个为一组
function GeneralShopLayer:handleGoodsInfo()
	self.mGoodsList = {}
	local tempList = {}
	for i = 1, #self.mShopInfo.MysteryShopGoodsList do
		table.insert(tempList, self.mShopInfo.MysteryShopGoodsList[i])
		if i % 2 == 0 then
			table.insert(self.mGoodsList, tempList)
			tempList = {}
		end
	end

	if #tempList ~= 0 then
		table.insert(self.mGoodsList, tempList)
	end
end

-- 获取第一个购买按钮，用于新手导引
function GeneralShopLayer:getFirstBuyButton()
    return self.mFirstBuyBtn
end

-----------------------网络相关-------------------------
-- 请求服务器，获取玩家普通聚宝阁相关数据
function GeneralShopLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "GetInfo",
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetInfo:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mShopInfo = data.Value

            -- 物品信息分组
            self:handleGoodsInfo()

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，购买相应物品
--[[
    params:
    id               -- 物品Id号
    cellIndex        -- cell索引号
--]]
function GeneralShopLayer:requestMysteryShopBuyGoods(id, cellIndex)
    HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "MysteryShopBuyGoods",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
        	--dump(data, "requestMysteryShopBuyGoods:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 更新数据，改变商品购买状态
            for i, v in ipairs(self.mShopInfo.MysteryShopGoodsList) do
                if v.Id == id then
                    self.mShopInfo.MysteryShopGoodsList[i].IsSell = 1
                    break
                end
            end

            -- 数据重新分组
            self:handleGoodsInfo()

            -- 移除每个cell上的所有，重新添加
            for i, v in ipairs(self.mListView:getItems()) do
                v:removeAllChildren()
                self:addElementsToCell(v, i)
            end

            -- 飘窗显示获得的物品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

-- 请求服务器，刷新物品
--[[
    params:
    rType           -- 刷新类型 1:免费刷新 2:道具刷新 3:神魄刷新
--]]
function GeneralShopLayer:requestRefreshGoodsList(rType)
    HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "RefreshtGoodsList",
        svrMethodData = {rType},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestRefreshGoodsList:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 更新数据
            self.mShopInfo.FreeCount = data.Value.FreeCount
            self.mShopInfo.GoldCount = data.Value.GoldCount
            self.mShopInfo.RefreshMysteryShopMaxNum = data.Value.RefreshMysteryShopMaxNum
            self.mShopInfo.MysteryShopGoodsList = data.Value.MysteryShopGoodsList
            self.mShopInfo.LimitNum = data.Value.LimitNum

            -- 物品信息分组
            self:handleGoodsInfo()

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

return GeneralShopLayer
