--[[
    文件名: TimeLimitTheBountyLayer.lua
    描述: 限时赏金页面
    创建人: liaoyuangang
    修改人：lengjiazhi 2017.3.9
    创建时间: 2016.07.18
--]]

local TimeLimitTheBountyLayer = class("TimeLimitTheBountyLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 200))
end)

--
function TimeLimitTheBountyLayer:ctor()
	-- 吞噬触摸
    ui.registerSwallowTouch({
        node = self,
        endedEvent = function(touch, event)
            -- self:onCloseBtnClick()
            LayerManager.removeLayer(self)
        end,

    })

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 当前的限时赏金信息
    self.mTimeLimitData = {}

    -- 初始化页面
    self:initUI()
end

--
function TimeLimitTheBountyLayer:onEnterTransitionFinish()
    local tempStatus = TimeLimitObj:getRewardStatus()
    if tempStatus == Enums.TimeLimitStatus.eGetSvrData then
        -- 请求限时赏金信息
        TimeLimitObj:requestGetInfo()
    end
end

-- 初始化页面
function TimeLimitTheBountyLayer:initUI()
    -- 背景图

    local bgSprite = ui.newSprite("x__01.png")
    bgSprite:setPosition(320, 610)
    self.mParentLayer:addChild(bgSprite)

    -- local womanSprite = ui.newSprite("x__02.png")
    -- womanSprite:setPosition(360, 700)
    -- self.mParentLayer:addChild(womanSprite)

    -- local titleBackSprite = ui.newSprite("x__05.png")
    -- titleBackSprite:setPosition(210, 805)
    -- self.mParentLayer:addChild(titleBackSprite)

    -- local titleSprite = ui.newSprite("x__06.png")
    -- titleSprite:setPosition(125, 805)
    -- self.mParentLayer:addChild(titleSprite)

    -- local tipSprite = ui.newSprite("x__04.png")
    -- tipSprite:setPosition(225, 710)
    -- self.mParentLayer:addChild(tipSprite)

    -- local goodsBackSprite = ui.newScale9Sprite("x__03.png",cc.size(640,145))
    -- goodsBackSprite:setPosition(320, 570)
    -- self.mParentLayer:addChild(goodsBackSprite)

    -- 剩余时间
    local freeTimeLabel = ui.newLabel({
        text = TR("剩余时间：%s","--:--:--"),
        size = 30,
        color = Enums.Color.eBlack,
        -- outlineColor = cc.c3b(37, 101, 189),
        -- outlineSize = 2,
        alignType = ui.TEXT_ALIGN_RIGHT
    })
    freeTimeLabel:setAnchorPoint(cc.p(0.5, 0.5))
    freeTimeLabel:setPosition(320, 405)
    self.mParentLayer:addChild(freeTimeLabel)

    -- 当前限时赏金的提示信息
    local hintLabel = ui.newNumberLabel({
        text = "",
        imgFile = "x__02.png",
    })
    hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
    hintLabel:setPosition(260, 673)
    self.mParentLayer:addChild(hintLabel)

    -- 创建奖励预览列表
    local cardNodeList = ui.createCardList({
        maxViewWidth = 620, -- 显示的最大宽度
        viewHeight = 125, -- 显示的高度，默认为120
        space = 10, -- 卡牌之间的间距, 默认为 10
        cardDataList = {},
        needArrows = true, -- 当需要滑动显示时是否需要左右箭头, 默认为false
    })
    cardNodeList:setAnchorPoint(cc.p(0.5, 0.5))
    cardNodeList:setPosition(320, 500)
    self.mParentLayer:addChild(cardNodeList)

    -- 领取/前往 按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领 取"),
        fontSize = 24,
        -- textColor = Enums.Color.eNormalWhite,
        -- outlineColor = Enums.Color.eBlack,
        clickAction = function()
            self:onCloseBtnClick()
        end,
    })
    self.mCloseBtn:setPosition(320, 330)
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 注册数据改变后的处理函数
    local function dealLimitDataChange()
        local tempInfo = TimeLimitObj:getTimeLimitInfo()
        freeTimeLabel:stopAllActions()
        if tempInfo and tempInfo.TriggerLv then
            Utility.schedule(freeTimeLabel, function()
                local tempTime = math.max(0, tempInfo.EndDate - Player:getCurrentTime())
                freeTimeLabel:setString(TR("剩余时间：%s", MqTime.formatAsDay(tempTime)))
            end, 1)
        end

        -- 玩家属性信息
        local playerInfo = PlayerAttrObj:getPlayerInfo()
        -- 刷新奖励列表
        local configItem = TimeLimitObj:getConfigItem()
        -- 设置提示信息
        hintLabel:setString(tostring(configItem and configItem.receiveLV or 100))

        -- 更新奖励列表
        local rewardList = Utility.analysisStrResList(configItem and configItem.reward or "")
        cardNodeList.refreshList(rewardList)

        -- 设置按钮提示信息
        if configItem and (not playerInfo.IsTriggerReceived or playerInfo.IsTriggerReceived == 0) then
            -- 判断当前是否已触发了限时秒杀
            if playerInfo.Lv < configItem.receiveLV then
                if LayerManager.getTopCleanLayerName() == "battle.BattleNormalNodeLayer" then
                    self.mCloseBtn:setTitleText(TR("确 定"))
                else
                    self.mCloseBtn:setTitleText(TR("去下一章"))
                end
            else
                self.mCloseBtn:setTitleText(TR("领 取"))
            end
        else
            self.mCloseBtn:setTitleText(TR("关 闭"))

            Utility.performWithDelay(self.mParentLayer, function()
                LayerManager.removeLayer(self)
            end, 0.1)
        end
    end
    -- 注册数据改变事件
    local eventNames = {EventsName.eRedDotPrefix .. tostring(ModuleSub.eTimeLimitTheBounty)}
    Notification:registerAutoObserver(self.mParentLayer, dealLimitDataChange, eventNames)
    dealLimitDataChange()
end

-- 关闭／领取／去副本按钮点击事件
function TimeLimitTheBountyLayer:onCloseBtnClick()
    -- 玩家属性信息
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    -- 当前奖励的配置信息
    local configItem = TimeLimitObj:getConfigItem()
    --
    if configItem and (not playerInfo.IsTriggerReceived or playerInfo.IsTriggerReceived == 0) then
        if playerInfo.Lv < configItem.receiveLV then
            if LayerManager.getTopCleanLayerName() == "battle.BattleNormalNodeLayer" then
                LayerManager.removeLayer(self)
            else
                -- LayerManager.showSubModule(ModuleSub.eBattleNormal)
                LayerManager.addLayer({name = "battle.BattleNormalNodeLayer"})
            end
        else
            TimeLimitObj:requestReceivedReward(function(response)
                if not response or response.Status ~= 0 then
                    LayerManager.removeLayer(self)
                    return
                end
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
            end)
        end
    else
        LayerManager.removeLayer(self)
    end
end

return TimeLimitTheBountyLayer
