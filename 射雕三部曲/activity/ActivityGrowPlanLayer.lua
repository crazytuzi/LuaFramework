--[[
    文件名: ActivityGrowPlanLayer.lua
    描述: 成长计划页面, 模块Id为：ModuleSub.eExtraActivityGrowPlan
    效果图: 成长计划.png
    创建人: yanghongsheng
    创建时间: 2017.3.11
--]]

local ActivityGrowPlanLayer = class("ActivityGrowPlanLayer", function()
    return display.newLayer()
end)

-- 奖励领取状态
local ReceiveState = {
    able = 0, -- 可以领取了
    unable = 1, -- 不能领取
    had = 2, -- 已经领取
}

--[[
-- 参数 params 中的各项为：
    {
        activityIdList: 活动实体Id列表
        parentModuleId: 该活动的主模块Id

        cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
    }
]]
function ActivityGrowPlanLayer:ctor(params)
    params = params or {}
    -- 活动实体Id列表
    self.mActivityIdList = params.activityIdList
    -- 该活动的主模块Id
    self.mParentModuleId = params.parentModuleId
    -- 该页面的数据信息
    self.mLayerData = params.cacheData

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 领取成长奖励需要的Vip等级
    self.mNeedVipLv = LvPlanConfig.items[1].needVIPLV
    -- 元宝总数
    self.mAllDiamond = 0

    -- 初始化页面控件
    self:initUI()

    if not self.mLayerData then  -- 证明是第一次进入该页面
        --请求数据
        self:requestLvPlan()
    else
        -- 刷新成长礼包ListView
        self:refreshListView()
    end
end

-- 获取恢复数据
function ActivityGrowPlanLayer:getRestoreData()
    local retData = {
        activityIdList = self.mActivityIdList,
        parentModuleId = self.mParentModuleId,
        cacheData = self.mLayerData
    }

    return retData
end

-- 初始化页面控件
function ActivityGrowPlanLayer:initUI()
    -- 背景
    local bg = ui.newSprite("jc_23.jpg")
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(320,568)
    self.mParentLayer:addChild(bg)

    -- title图
    local titleSprite = ui.newSprite("jc_07.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(0,900)
    self.mParentLayer:addChild(titleSprite)

    --说明背景
    local decBgSize = cc.size(520, 110)
    local decBg = ui.newScale9Sprite("c_145.png", decBgSize)
    decBg:setAnchorPoint(cc.p(0,0.5))
    decBg:setPosition(cc.p(-10, 750))
    self.mParentLayer:addChild(decBg)

    -- --人物
    -- local figureSprite = ui.newSprite("jc_18.png")
    -- figureSprite:setPosition(420, 500)
    -- self.mParentLayer:addChild(figureSprite)

    -- 感叹号icon
    local gantan = ui.newSprite("c_63.png")
    gantan:setPosition(40, 765)
    self.mParentLayer:addChild(gantan)

    --成长计划说明标签
    local gantanX ,gantanY = gantan:getPosition()
    local introLabel1 = ui.newLabel({
        text = TR("%sVIP%d %s即可参与成长计划",
            "#ffe033",
            self.mNeedVipLv,
            Enums.Color.eWhiteH
        ),
        size = 22,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        x = gantanX + 30,
        y = gantanY - 15,
    })
    introLabel1:setAnchorPoint(cc.p(0, 0))
    self.mParentLayer:addChild(introLabel1)

    local introLabel = ui.newLabel({
        text = TR("%s畅领%s%d元宝%s成长计划",
            Enums.Color.eWhiteH,
            "#ffe033",
            self.mAllDiamond,
            Enums.Color.eWhiteH
        ),
        size = 22,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        x = gantanX + 30,
        y = gantanY - 50
    })
    introLabel:setAnchorPoint(cc.p(0, 0))
    self.mParentLayer:addChild(introLabel)
    self.introLabel = introLabel

    -- 下半部分背景图片大小
    local downBgSize = cc.size(640,700)
    -- 下半部分背景图片
    self.downBgSprite = ui.newScale9Sprite("c_19.png",downBgSize)
    self.downBgSprite:setAnchorPoint(cc.p(0.5, 0))
    self.downBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(self.downBgSprite)

    -- listView背景图大小
    local listViewBgSize = cc.size(downBgSize.width*0.95,downBgSize.height*0.8)
    -- listView背景图
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 1))
    listViewBgSprite:setPosition(320, 665)
    self.downBgSprite:addChild(listViewBgSprite)

    -- 创建成长礼包ListView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(listViewBgSize.width, listViewBgSize.height*0.98))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(listViewBgSize.width*0.5, listViewBgSize.height*0.5)
    listViewBgSprite:addChild(self.mListView)

    -- --成长计划icon
    -- local upBgSprite = ui.newScale9Sprite("jchd_13.png")
    -- upBgSprite:setPosition(320, 880)
    -- self.mParentLayer:addChild(upBgSprite)
    -- local plan = ui.newSprite("jchd_01.png")
    -- plan:setPosition(upBgSprite:getContentSize().width / 2, upBgSprite:getContentSize().height / 2 + 10)
    -- upBgSprite:addChild(plan)


    -- 充值按钮
    -- local chargeBtn = ui.newButton({
    --     normalImage = "tb_129.png",
    --     position = cc.p(360, 800),
    --     clickAction = function()
    --         LayerManager.showSubModule(ModuleSub.eCharge)
    --     end
    -- })
    -- self.mParentLayer:addChild(chargeBtn, 1)




    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)
end

--刷新成长奖励ListView
--[[
    index  当前ListView的条数
]]
function ActivityGrowPlanLayer:refreshListView(index)
    self.mListView:removeAllItems()
    self.mAllDiamond = 0
    for index, item in ipairs(self.mLayerData or {}) do
        local cellSize = cc.size(608, 130)
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)

        --cell背景图片
        local cellSpriteSize = cc.size(self.mListView:getContentSize().width*0.98 ,125)
        local cellSprite = ui.newScale9Sprite("c_18.png", cellSpriteSize)
        cellSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(cellSprite)

        --每一个cell的说明Label
        local textLabel1 = ui.newLabel({
            text = TR("%s%d%s级", "#27940e", item.LV, "#592817"),
            align = ui.TEXT_ALIGN_CENTER,
            size = 22,
            color = cc.c3b(0x59, 0x28, 0x17),
        })
        textLabel1:setPosition(70, cellSize.height / 2 + 17)
        cellSprite:addChild(textLabel1)

        local textLabel2 = ui.newLabel({
            text = TR("成长礼包"),
            size = 22,
            align = ui.TEXT_ALIGN_CENTER,
            color = cc.c3b(0x59, 0x28, 0x17),
        })
        textLabel2:setPosition(70, cellSize.height / 2 - 17)
        cellSprite:addChild(textLabel2)

        -- 箭头
        local arrowSprite = ui.newSprite("jc_15.png")
        arrowSprite:setPosition(cellSize.width*0.44, cellSize.height / 2)
        cellSprite:addChild(arrowSprite)

        -- 左边的元宝
        local leftCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            modelId = 0,
            Num = item.needDiamond,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        })
        leftCard:setSwallowTouches(false)
        leftCard:setPosition(cellSize.width*0.3, cellSize.height * 0.5 - 4)
        cellSprite:addChild(leftCard)

        -- 右边的元宝
        local rightCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            modelId = 0,
            Num = item.diamond,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        })
        rightCard:setSwallowTouches(false)
        rightCard:setPosition(cellSize.width*0.58, cellSize.height * 0.5 - 4)
        cellSprite:addChild(rightCard)

        local obtainButton
        -- 已领取
        if item.state == ReceiveState.had then
            obtainButton = ui.newSprite("jc_21.png")
        else
            obtainButton = ui.newButton({
                normalImage = item.state == ReceiveState.able and "c_28.png" or "c_82.png",
                text = TR("领取"),
                fontSize = 22,
                clickAction = function(sender, event)
                    -- Vip模块是否开启
                    if not ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
                        return
                    end

                    -- Vip等级是否足够
                    local currVipLv = PlayerAttrObj:getPlayerAttrByName("Vip")
                    if currVipLv < self.mNeedVipLv then
                           local btnInfo = {
                            {
                                text = TR("去充值"),
                                normalImage = "c_28.png",
                                clickAction = function(layerObj, btnObj)
                                    LayerManager.removeLayer(layerObj)
                                    LayerManager.showSubModule(ModuleSub.eCharge)
                                end
                            }
                        }
                        MsgBoxLayer.addOKLayer(TR("达到VIP%d级即可领取%d元宝成长计划", self.mNeedVipLv, self.mAllDiamond), TR("提示"), btnInfo, {})
                        return
                    end

                    -- 玩家等级是否足够
                    local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
                    if currLv < item.LV then
                        ui.showFlashView({
                            text = TR("玩家等级达到 %d 才能购买", item.LV)
                        })
                        return
                    end

                    -- 元宝是否足够
                    if Utility.isResourceEnough(ResourcetypeSub.eDiamond, item.needDiamond, true) then
                        self:requestReceiveLvPlan(item.LV, index)
                    end
                end
            })
        end
        obtainButton:setScale(1.1)
        obtainButton:setPosition(cellSize.width * 0.83, cellSize.height / 2)
        cellSprite:addChild(obtainButton)
        -- 元宝总数
        self.mAllDiamond = self.mAllDiamond + item.diamond
    end

    -- 刷新总元宝数
    self.introLabel:setString(TR("%s畅领%s%d元宝%s成长计划",
        Enums.Color.eWhiteH,
        "#ffe033",
        self.mAllDiamond,
        Enums.Color.eWhiteH
    ))
end

-- 排序列表数据
function ActivityGrowPlanLayer:sortListData()
    table.sort(self.mLayerData or {}, function(a, b)
        if a.state ~= b.state then
            return a.state < b.state
        end

        return a.LV < b.LV
    end)
end

-----------------网络相关-------------------
function ActivityGrowPlanLayer:requestLvPlan()
    HttpClient:request({
        moduleName = "LvPlan",
        methodName = "GetLvPlanInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end
            -- 可以领取奖励的等级列表
            local canlist = response.Value.CanRewardLvList
            -- 已经领取的奖励等级列表
            local rewardList = response.Value.RewardLvList
            -- 整理列表显示的数据
            local tempList = {}
            for key, item in pairs(LvPlanRewardModel.items) do
                local tempItem = clone(item)
                tempItem.state = table.indexof(rewardList, key) and ReceiveState.had or
                    table.indexof(canlist, key) and ReceiveState.able or  ReceiveState.unable
                table.insert(tempList, tempItem)
            end

            self.mLayerData = tempList
            -- 排序列表数据
            self:sortListData()
            -- 刷新成长礼包ListView
            self:refreshListView()
        end
    })
end

--领取奖励
--[[
    LV     领取当前奖励的等级
    index  当前ListView的条数
]]
function ActivityGrowPlanLayer:requestReceiveLvPlan(LV, index)
    HttpClient:request({
        moduleName = "LvPlan",
        methodName = "ReceiveLvPlan",
        svrMethodData = {LV},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end

            -- 修改该记录数据的状态（由可以领取改为已领取）
            local tempItem = self.mLayerData[index]
            tempItem.state = ReceiveState.had

            -- 排序列表数据
            self:sortListData()
            -- 刷新成长礼包ListView
            self:refreshListView()
            -- 提示领取到的奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end

return ActivityGrowPlanLayer
