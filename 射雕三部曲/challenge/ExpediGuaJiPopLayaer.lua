--[[
    文件名: ExpediGuaJiPopLayaer.lua
    创建人: chenzhong
    创建时间: 2018.1.5
    描述:六大派挂机奖励弹窗页面
--]]

local ExpediGuaJiPopLayaer = class("ExpediGuaJiPopLayaer", function(params)
    return display.newLayer()
end)

--[[
    节点:
    callback
--]]
function ExpediGuaJiPopLayaer:ctor(params)
    self.mCallBack = params.callback
    -- 挂机的当前节点
    self.mNodeId = params.nodeId or 1111
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("挂 机"),
        bgSize = cc.size(640, 944),
        closeImg = nil,
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 显示中间背景
    local tmpBgSprite = ui.newScale9Sprite("c_17.png", cc.size(576, 640))
    tmpBgSprite:setAnchorPoint(cc.p(0.5, 0))
    tmpBgSprite:setPosition(self.mBgSize.width * 0.5, 230)
    self.mBgSprite:addChild(tmpBgSprite)

    local introBg = ui.newSprite("jzthd_01.png")
    introBg:setPosition(self.mBgSize.width/2, 170)
    self.mBgSprite:addChild(introBg)
    self.mIntroBg = introBg
    local introLabel = ui.newLabel({
        text = TR("奖励请在挂机结束后到本界面领取"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    introLabel:setPosition(self.mBgSize.width/2, 100)
    self.mBgSprite:addChild(introLabel)

    local warningLabel = ui.newLabel({
        text = TR("若您在挂机开始时断线(或遇见其他异常)\n仍能正常进入挂机,但需补充足够的体力(双倍令)才能领取奖励"),
        color = cc.c3b(0xcf, 0xcf, 0xcf),
        align = cc.TEXT_ALIGNMENT_CENTER,
        size = 22,
    })
    warningLabel:setPosition(self.mBgSize.width/2, -40)
    self.mBgSprite:addChild(warningLabel)

    -- 列表中每个条目的大小
    self.mListCellSize = cc.size(564, 200)
    --创建列表
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(self.mListCellSize.width, 620))
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mBgSize.width * 0.5, 240)
    self.mBgSprite:addChild(self.mListView)

    self.mConfirmButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("关闭"),
        position = cc.p(self.mBgSize.width / 2, 55),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(self.mConfirmButton)

    -- 获取挂机信息
    self:getGuaJiInfo()
end

-- 刷新ListView
function ExpediGuaJiPopLayaer:refreshListView()
    if self.emptyHintSprite then 
        self.emptyHintSprite:removeFromParent()
        self.emptyHintSprite = nil 
    end     
    if #self.mGuaJiInfo.RewardList <= 0 then 
        -- 空白提示
        local emptyHintSprite = ui.createEmptyHint(TR("正在挑战中..."))
        emptyHintSprite:setPosition(self.mBgSize.width * 0.5, 600)
        self.mBgSprite:addChild(emptyHintSprite)
        self.emptyHintSprite = emptyHintSprite
        return
    end 
    self.mListView:removeAllItems()

    -- 重新整理奖励数据（倒着排序）
    local newRewardList = {}
    for i,v in ipairs(self.mGuaJiInfo.RewardList) do
        newRewardList[i] = {}
        newRewardList[i].index = i
        newRewardList[i].reward = v
    end

    table.sort(newRewardList, function (a, b)
        return a.index > b.index
    end)
    
    self.mTotalPage = math.ceil(#newRewardList/10)
    self.mCurrentPage = 0
    -- 根据当前页数获取当前十条奖励
    local function getRewardListByPage()
        local list = {}
        for i,v in ipairs(newRewardList) do
            if i >= (self.mCurrentPage*10+1) and i <= (self.mCurrentPage*10+10) then 
                table.insert(list, v)
            end 
        end

        return list
    end
    -- 添加列表项函数
    local function addListItems(list)
        if not list or not next(list) then
            return
        end

        for i,v in ipairs(list) do
            self:refreshListViewItem(v)
        end
        -- 将列表跳到当前排名处
        ui.setListviewItemShow(self.mListView, self.mCurrentPage*10+1)
    end
    -- 注册滑动到列表底部监听，获取下一页
    self.mListView:addScrollViewEventListener(function(sender, eventType)
        if eventType == 6 then -- 触发底部弹性事件(BOUNCE__BOTTOM)
            if self.mCurrentPage < self.mTotalPage then
                self.mCurrentPage = self.mCurrentPage + 1
                local list = getRewardListByPage()
                addListItems(list)
            end
        end
    end)

    -- 初始化
    local list = getRewardListByPage()
    addListItems(list)
end

-- 刷新奖励中的一个条目
function ExpediGuaJiPopLayaer:refreshListViewItem(rewardInfo)
    local lvItem = ccui.Layout:create()
    lvItem:setAnchorPoint(cc.p(0.5, 0.5))
    lvItem:setContentSize(self.mListCellSize)
    self.mListView:pushBackCustomItem(lvItem)

    -- 条目的背景
    local cellBgSprite = ui.newScale9Sprite("c_54.png", self.mListCellSize)
    cellBgSprite:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("第%d次挑战", rewardInfo.index),
        size = 24,
        color = cc.c3b(0xfa, 0xf6, 0xf1),
        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
        outlineSize = 2,
    })
    titleLabel:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height - 22)
    cellBgSprite:addChild(titleLabel)

    -- 创建物品列表
    local tempList = Utility.analysisStrResList(rewardInfo.reward or "")
    for _, rewardItem in pairs(tempList) do
        rewardItem.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
    end
    local cardList = ui.createCardList({
        cardDataList = tempList,
        maxViewWidth = 500,
        allowClick = true,
        isSwallow = false,
    })
    cardList:setAnchorPoint(cc.p(0.5, 0.5))
    cardList:setPosition(self.mListCellSize.width / 2, 80)
    cellBgSprite:addChild(cardList)
end

-- 刷新进度
function ExpediGuaJiPopLayaer:refreshProgress()
    self.mIntroBg:removeAllChildren()
    local guaJiInfo = self.mGuaJiInfo
    -- 结束时间
    self.mEndTime = math.floor(guaJiInfo.EndTime)
    local introSize = self.mIntroBg:getContentSize()
    -- 是否正在挂机
    local isGuaJiStr = (self.mEndTime-Player:getCurrentTime()) > 0 and TR("光明顶挂机中...") or TR("光明顶挂机已经完成")
    local isGuajiLabel = ui.newLabel({
        text = isGuaJiStr,
        size = 22,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        outlineSize = 2,
    })
    isGuajiLabel:setPosition(introSize.width/2, 70)
    self.mIntroBg:addChild(isGuajiLabel)

    -- 进度
    local progressLabel = ui.newLabel({
        text = TR("挂机进度:%d/%d", guaJiInfo.Num, guaJiInfo.TotalNum),
        size = 22,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        outlineSize = 2,
    })
    progressLabel:setPosition(introSize.width*0.25, 30)
    self.mIntroBg:addChild(progressLabel)

    -- 剩余时间
    local timeLabel = ui.newLabel({
        text = TR(""),
        size = 22,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        outlineSize = 2,
    })
    timeLabel:setPosition(introSize.width*0.75, 30)
    self.mIntroBg:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    
    -- 刷新时间
    local currTime = Player:getCurrentTime()
    self.mTimeLabel:setString(TR("挂机剩余时间:%s", MqTime.formatAsDay(self.mEndTime-currTime)))
    if (self.mEndTime-currTime) <= 0 then 
        self.mConfirmButton:setTitleText(TR("领 取"))
        self.mConfirmButton:setClickAction(function()
            -- todo
            self:getReward()
        end)
        return
    end 
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end

-- 挂机剩余时间
function ExpediGuaJiPopLayaer:updateTime()
    local currTime = Player:getCurrentTime()
    local leftTime = self.mEndTime-currTime
    if leftTime > 0 then
        self.mTimeLabel:setString(TR("挂机剩余时间:%s", MqTime.formatAsDay(leftTime)))
    else
        self.mTimeLabel:setString(TR("挂机剩余时间:00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 刷新页面
        self.mConfirmButton:setTitleText(TR("领 取"))
        self.mConfirmButton:setClickAction(function()
            -- 获取挂机奖励
            self:getReward()
        end)

        -- 刷新页面的信息
        self:getGuaJiInfo()
    end
end

-- 挂机后获取挂机相关信息
function ExpediGuaJiPopLayaer:getGuaJiInfo()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "AllChapterInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response,"response")
            self.mGuaJiInfo = response.Value.GuajiInfo or {}
            ExpediGuaJiObj:setGuaJiInfo(response.Value.GuajiInfo or {})

            -- 刷新奖励内容
            self:refreshListView()
            -- 刷新挂机进度说明
            self:refreshProgress()
        end
    })
end

-- 挂机后获取挂机相关信息
function ExpediGuaJiPopLayaer:getReward()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "DrawGuajiReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- dump(response,"response")
            if not response or response.Status ~= 0 then
                -- 体力不足
                if response.Status == -1119 then 
                    local vitNum = self.mGuaJiInfo.TotalNum*(ExpeditionMapModel.items[1].challengeUse or 10) 
                    if  vitNum > PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                        MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eVIT, vitNum)
                    end  
                elseif response.Status == -8919 then -- 双倍令不足
                    ui.showFlashView(TR("双倍令不足！"))
                end    
                return
            end
            -- 挂机奖励重置
            ExpediGuaJiObj:reset()
            Notification:postNotification(EventsName.eExpeditionGuaJi)

            -- 飘窗显示奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            if self.mCallBack then 
                self.mCallBack()
            end     
            LayerManager.removeLayer(self)

            -- 检查是否升级
            PlayerAttrObj:showUpdateLayer()
        end
    })
end

return ExpediGuaJiPopLayaer
