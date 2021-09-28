--[[
    文件名：ActivityTimeSeckill.lua
    --文件描述：限时秒杀活动
    --创建人：lichunsheng
    --创建时间：2017.08.15
]]

local ActivityTimeSeckill = class("ActivityTimeSeckill",function()
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

--初始化
function ActivityTimeSeckill:ctor()
    --屏蔽下层触控
    ui.registerSwallowTouch({node = self})
    --创建适配父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    self:requestGetInfo()
    --self:initUI()
end

--界面
--[[
    params:服务器返回的value数据
]]
function ActivityTimeSeckill:initUI(params)
    if not params then
        return
    end
    --活动类型
    self.mPageType = params[1].PayType or 1
    --活动结束时间
    self.mBegainTime = params[1].BeginDate or 0
    --活动开始时间
    self.mEndTime = params[1].EndDate or 0
    --累计充值
    self.mPunch = params[1].AccChargeMoney or 0
    --创建底层背景
    local parentSprite = ui.newSprite("xsms_01.png")
    parentSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(parentSprite)

    --创建关闭按钮
    local closeBtn = ui.newButton({
        text = "",
        normalImage = "c_29.png",
        position = cc.p(590, 955),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    --创建充值的标题（分为单比和累计）
    local titleSprite = ui.newSprite("xsms_05.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(cc.p(40, 795))
    self.mParentLayer:addChild(titleSprite)

    --c创建累计充值的Label背景
    local punchBg = ui.newSprite("xsms_04.png")
    punchBg:setAnchorPoint(cc.p(0, 0.5))
    punchBg:setPosition(cc.p(20, 710))
    self.mParentLayer:addChild(punchBg)

    --创建累计充值lable
    self.mPunchLable = ui.newLabel({
        text = TR("当前已累计充值:%s元宝", self.mPunch),
        size = 22,
        color = cc.c3b(0x74, 0x29, 0x29),
        x = 40,
        y = 710,
        anchorPoint = cc.p(0, 0.5)
    })
    self.mParentLayer:addChild(self.mPunchLable)
    --1单笔充值 2累计充值
    if self.mPageType == 1 then
        punchBg:setVisible(false)
        self.mPunchLable:setVisible(false)
    elseif self.mPageType == 2 then
        titleSprite:setTexture("xsms_06.png")
        self.mPunchLable:setString(TR("当前已累计充值:%s元宝", self.mPunch))
    end

    --活动结束倒计时lable
    local activityTime = self.mEndTime - self.mBegainTime
    self.mCountDownLable = ui.newLabel({
        text = "",
        size = 20,
        color = cc.c3b(0x33, 0x64, 0x07),
        x = 50,
        y = 655,
        anchorPoint = cc.p(0, 0.5),
    })
    self.mParentLayer:addChild(self.mCountDownLable)

    --倒计时
    Utility.schedule(self.mCountDownLable, function()
        local currTime = self.mEndTime - Player:getCurrentTime()
        self.mCountDownLable:setString(TR("倒计时:  %s",  MqTime.toCoutDown(currTime)))
    end, 1)

    --添加充值按钮
    self.mLingquBtn = ui.newButton({
        text = "",
        normalImage = "xsms_02.png",
        position = cc.p(320, 130),
        clickAction = function()
            LayerManager.addLayer({
                name = "recharge.RechargeLayer",
                cleanUp = true,
            })
        end
    })
    self.mParentLayer:addChild(self.mLingquBtn)

    --创建listView控件
    if not self.mListView then
        self.listViewSize = cc.size(558, 460)
        self.mListView = ccui.ListView:create()
        self.mListView:setItemsMargin(5)
         self.mListView:setDirection(ccui.ScrollViewDir.vertical)
         self.mListView:setBounceEnabled(true)
         self.mListView:setContentSize(self.listViewSize)
         self.mListView:setPosition(320, 400)
         self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
         self.mListView:setChildrenActionType(0)
         self.mParentLayer:addChild(self.mListView)
         self:refreshListView(params, false)
    end
end

function ActivityTimeSeckill:refreshListView(value, Receive)
    --排序
    table.sort(value, function(item1, item2)
        if item1.Status ~= item2.Status then
            if item1.Status ~= 1 and item2.Status ~= 1 then
                return item1.Status < item2.Status
            end
            return item1.Status == 1 or item2.Status ~= 1
        end

        return item1.ChargeMoney < item2.ChargeMoney
    end)


    self.mGetInitData = value

    self.mListView:removeAllItems()
    for i=1, table.nums(value) do
        local items = self:addItems(value[i], i)
        self.mListView:pushBackCustomItem(items)
    end
end

function ActivityTimeSeckill:addItems(data, tag)
    local layout = ccui.Layout:create()
    layout:setContentSize(558, 150)

    local bgSprite = ui.newScale9Sprite("xsms_03.png", cc.size(550, 150))
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(cc.p(279, 75))
    layout:addChild(bgSprite)

    --创建需要充值条件lable
    --1单笔充值 2累计充值
    local needPunchLable = ui.newLabel({
        text = TR("再充值:#501b1b %d元宝", data.ChargeMoney),
        size = 22,
        color = cc.c3b(0x33, 0x64, 0x07),
        x = 20,
        y = 125,
        anchorPoint = cc.p(0, 0.5),
    })
    bgSprite:addChild(needPunchLable)

    if self.mPageType == 1 then
        local needPunch = data.ChargeMoney or 0
        needPunchLable:setString(TR("单笔充值:#501b1b%d元宝", needPunch))
    elseif self.mPageType == 2 then
        local needPunch = (data.ChargeMoney - self.mPunch) or 0
        needPunchLable:setString(TR("再充值:#501b1b%d元宝", needPunch))
        -- if needPunch <= 0 then
        --     needPunchLable:setVisible(false)
        -- end
    end


    --创建领取按钮
    local receiveState = data.Status or 0
    if receiveState == 1 then
        needPunchLable:setString(TR("#336407已完成充值，请领取奖励"))
    elseif receiveState == 2 then
        needPunchLable:setString(TR("#501b1b奖励已领取"))
    end

    -- 可领取和不可领取按钮状态
    if receiveState ~= 2 then
        local receiveBtn = ui.newButton({
            text = TR("领取"),
            fontSize = 24,
            normalImage = (receiveState == 0) and "c_82.png" or "c_28.png",
            position = cc.p(465, 70),
            clickAction = function()
                if receiveState == 1 then
                    self:requestReceive(data.NumberId, tag)
                elseif receiveState == 0 then
                    ui.showFlashView(TR("不可领取奖励"))
                elseif receiveState == 2 then
                    ui.showFlashView(TR("已领取过奖励"))
                end
            end
        })
        bgSprite:addChild(receiveBtn)
    else
        local isLearnLabel = ui.createSpriteAndLabel({
                imgName = "c_156.png",
                labelStr = TR("已领取"),
                fontSize = 24,
            })
        isLearnLabel:setPosition(cc.p(465, 70))
        bgSprite:addChild(isLearnLabel)
    end

    --创建充值元宝
    local yuanbaoCard, retAttr = CardNode.createCardNode({
        resourceTypeSub = 1111,
        modelId = 0,
        num = data.BuyNum,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
    })
    yuanbaoCard:setPosition(cc.p(60, 60))
    bgSprite:addChild(yuanbaoCard)
    yuanbaoCard:setScale(0.8)
    --创建尖头
    local arrowSprite = ui.newSprite("c_26.png")
    arrowSprite:setPosition(cc.p(120, 60))
    bgSprite:addChild(arrowSprite)

    --创建产出物品CardList
    local outResData = Utility.analysisStrResList(data.GetResource) or {}

    for index, item in pairs(outResData) do
        if item.num > 1 then
            item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        else
            item.cardShowAttrs = {CardShowAttr.eBorder}
        end
    end
    local outResCardList = ui.createCardList({
        maxViewWidth = 340,
        space = -15,
        cardDataList = outResData,
        allowClick = true,
    })
    outResCardList:setAnchorPoint(cc.p(0, 0.5))
    outResCardList:setPosition(cc.p(130, 50))
    bgSprite:addChild(outResCardList)
    outResCardList:setScale(0.8)

    return layout
end

--获取页面恢复信息
function ActivityTimeSeckill:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

--===================网络========================

--请求网络数据
function ActivityTimeSeckill:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedMiaosha",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mGetInitData = clone(response.Value)
            self:initUI(response.Value)

        end
    })
end


--领取奖励请求
function ActivityTimeSeckill:requestReceive(propId, btnTag)
    HttpClient:request({
        moduleName = "TimedMiaosha",
        methodName = "Receive",
        svrMethodData = {propId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mGetInitData[btnTag].Status = 2
            self:refreshListView(self.mGetInitData, true)

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end


return ActivityTimeSeckill
