--[[
    文件名：ActivityTimeOnlineLayer.lua
    文件描述：限时在线奖励
    创建人：yanghongsheng
    创建时间：2019.09.10
]]

local ActivityTimeOnlineLayer = class("ActivityTimeOnlineLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

function ActivityTimeOnlineLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- -- 创建顶部资源栏和底部导航栏
    -- local topResource = require("commonLayer.CommonLayer"):create({
    --     needMainNav = true,
    --     topInfos = {
    --         ResourcetypeSub.eVIT,
    --         ResourcetypeSub.eDiamond,
    --         ResourcetypeSub.eGold
    --     }
    -- })
    -- self:addChild(topResource)

    -- 初始化页面控件
    self:initUI()

	self:requestGetInfo()
end

function ActivityTimeOnlineLayer:initUI()
    -- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 990),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(closeBtn, 1)
    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(45, 990),
        clickAction = function ()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.每天在相应时间段可以进行江湖游历。"),
                TR("2.在线时间满足一定条件即可领取游历奖励。"),
                TR("3.游历途中如果下线，奖励领取时间会有一定延迟。"),
        	})
        end,
    })
    self.mParentLayer:addChild(ruleBtn, 1)
    -- 预览按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_79.png",
        position = cc.p(125, 990),
        clickAction = function ()
            self:createPreRewardBox()
        end,
    })
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 背景
    local bgSprite = ui.newSprite("jrhd_172.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    -- 卷轴
    local bgSize = bgSprite:getContentSize()
    local tempSprite = ui.newSprite("jrhd_171.png")
    tempSprite:setPosition(bgSize.width*0.5, 0)
    bgSprite:addChild(tempSprite)
    local tempSprite = ui.newSprite("jrhd_171.png")
    tempSprite:setPosition(bgSize.width*0.5, bgSize.height)
    bgSprite:addChild(tempSprite)
    -- title
    local titleSprite = ui.newSprite("jrhd_173.png")
    titleSprite:setPosition(tempSprite:getContentSize().width*0.5, tempSprite:getContentSize().height*0.5+10)
    tempSprite:addChild(titleSprite)
    -- 提示语
    self.mHintLabel = ui.newLabel({
        text = "",
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    self.mHintLabel:setPosition(320, 940)
    self.mParentLayer:addChild(self.mHintLabel)

    self:createMap()
end

-- 创建滑动地图
function ActivityTimeOnlineLayer:createMap()
    local mapSprite = ui.newSprite("fb_42.jpg")
    mapSprite:setScale(0.8)
    mapSprite:setAnchorPoint(cc.p(0, 0))
    self.mMapSprite = mapSprite

    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(525, 737))
    worldView:setInnerContainerSize(cc.size(525, mapSprite:getContentSize().height*0.8))
    worldView:setAnchorPoint(cc.p(0.5, 0))
    worldView:setPosition(cc.p(320, 180))
    worldView:setDirection(ccui.ScrollViewDir.vertical)
    worldView:setSwallowTouches(false)
    worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.worldView = worldView
    self.worldView:addChild(mapSprite)

    self.worldView:scrollToPercentVertical(100, 0, true)
end

-- 创建奖励预览弹窗
function ActivityTimeOnlineLayer:createPreRewardBox()
    local rewardData = {}
    for _, config in ipairs(self.mOnlineRewardConfig) do
        local item = {
            title = TR("累计登录%s分钟", config.OnlineMinutes),
            resourceList = Utility.analysisStrResList(config.Reward)
        }
        table.insert(rewardData, item)
    end

    LayerManager.addLayer({
        name = "festival.RewardPreviewPopLayer",
        cleanUp = false,
        data = {
            title = TR("奖励预览"),
            itemsData = rewardData,
        }
    })
end

-- 刷新界面
function ActivityTimeOnlineLayer:refreshUI()
    -- 提示文字刷新
    self:refreshHintLabel()
    -- 地图节点
    self:refreshNode()
    -- 地图位置
    self:refreshMapPos()
end

-- 提示文字刷新
function ActivityTimeOnlineLayer:refreshHintLabel()
    -- 是否有奖励领取
    local isDraw = false
    for _, config in ipairs(self.mOnlineRewardConfig) do
        if self.mOnlineRewardInfo.OnlineMinutes >= config.OnlineMinutes and
            not table.indexof(self.mReveciedRewardList, tostring(config.OnlineMinutes)) then
            isDraw = true
            break
        elseif self.mOnlineRewardInfo.OnlineMinutes < config.OnlineMinutes then
            break
        end
    end
    if isDraw then
        self.mHintLabel:setString(TR("恭喜大侠成功寻觅宝藏！点击图标领取"))
        return
    end
    -- 是否开始
    if Player:getCurrentTime() < self.mOnlineBaseConfig.StartTime then
        local startDate = MqTime.getLocalDate(self.mOnlineBaseConfig.StartTime)
        local endDate = MqTime.getLocalDate(self.mOnlineBaseConfig.EndTime)
        self.mHintLabel:setString(TR("今日游历开启时间为：%02d:%02d:%02d-%02d:%02d:%02d", startDate.hour, startDate.min, startDate.sec, endDate.hour, endDate.min, endDate.sec))
        return
    end
    -- 是否结束
    if Player:getCurrentTime() > self.mOnlineBaseConfig.EndTime or
        self.mOnlineRewardInfo.OnlineMinutes >= self.mOnlineRewardConfig[#self.mOnlineRewardConfig].OnlineMinutes then
        self.mHintLabel:setString(TR("本次游历已经结束，请大侠明日再来"))
        return
    end

    self.mHintLabel:setString(TR("当前还未寻觅到宝藏，请大侠继续游历！"))
end
-- 刷新地图节点
function ActivityTimeOnlineLayer:refreshNode()
    -- 父节点
    if not self.mNodeParent then
        self.mNodeParent = cc.Node:create()
        self.mMapSprite:addChild(self.mNodeParent)
    end
    -- 清除节点
    self.mNodeParent:removeAllChildren()
    self.mRewardTimeNode = nil

    -- 循环创建
    for i, config in ipairs(self.mOnlineRewardConfig) do
        local pos = self.getNodePos(i)
        -- 已领取
        if table.indexof(self.mReveciedRewardList, tostring(config.OnlineMinutes)) then
            local tempSprite = ui.newSprite("jc_21.png")
            tempSprite:setPosition(pos)
            self.mNodeParent:addChild(tempSprite)
        -- 可领取
        elseif self.mOnlineRewardInfo.OnlineMinutes >= config.OnlineMinutes then
            local resInfo = Utility.analysisStrResList(config.Reward)[1]
            resInfo.onClickCallback = function ()
                self:requestGetReward(config.OnlineMinutes)
            end
            resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
            local tempCard = CardNode.createCardNode(resInfo)
            tempCard:setPosition(pos)
            self.mNodeParent:addChild(tempCard)
        -- 领取倒计时
        elseif not self.mRewardTimeNode and Player:getCurrentTime() < self.mOnlineBaseConfig.EndTime then
            local bgSize = cc.size(220, 60)
            self.mRewardTimeNode = ui.newScale9Sprite("c_103.png", bgSize)
            self.mRewardTimeNode:setPosition(pos)
            self.mNodeParent:addChild(self.mRewardTimeNode)

            local startTimeLeft = self.mOnlineBaseConfig.StartTime-Player:getCurrentTime()
            local tempLabel = ui.newLabel({
                text = startTimeLeft > 0 and TR("开始游历倒计时：") or TR("下次寻觅倒计时："),
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
            tempLabel:setPosition(bgSize.width*0.5, bgSize.height-20)
            self.mRewardTimeNode:addChild(tempLabel)

            local timeLabel = ui.newLabel({
                text = "",
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                color = cc.c3b(0xff, 0xe7, 0x48),
            })
            timeLabel:setPosition(bgSize.width*0.5, 15)
            self.mRewardTimeNode:addChild(timeLabel)

            local time = (config.OnlineMinutes - self.mOnlineRewardInfo.OnlineMinutes)*60+1
            time = time - (Player:getCurrentTime()-self.mOnlineRewardInfo.UpdateTime)
            if startTimeLeft > 0 then
                time = startTimeLeft+1
            end
            Utility.schedule(timeLabel, function ()
                time = time-1
                if time < 0 then
                    self:requestGetInfo()
                else
                    timeLabel:setString(string.format("%s", MqTime.formatAsDay(time)))
                end
            end, 1)
        end
    end
end
-- 刷新地图位置
function ActivityTimeOnlineLayer:refreshMapPos()
    local pos = nil
    for i, config in ipairs(self.mOnlineRewardConfig) do
        if self.mOnlineRewardInfo.OnlineMinutes >= config.OnlineMinutes and
            not table.indexof(self.mReveciedRewardList, tostring(config.OnlineMinutes)) then
            pos = self.getNodePos(i)
            break
        elseif self.mOnlineRewardInfo.OnlineMinutes < config.OnlineMinutes then
            pos = self.getNodePos(i)
            break
        end
        pos = self.getNodePos(i)
    end

    if pos.y > self.worldView:getContentSize().height*1.2 then
        self.worldView:scrollToPercentVertical(0, 0, true)
    else
        self.worldView:scrollToPercentVertical(100, 0, true)
    end
end
-- 获取节点位置
function ActivityTimeOnlineLayer.getNodePos(i)
    local nodePosList = {
        cc.p(485, 239),
        cc.p(256, 465),
        cc.p(494, 833),
        cc.p(187, 1023),
        cc.p(229, 1386),
        cc.p(375, 1606),
    }
    i = ((i-1) % #nodePosList) + 1
    
    return nodePosList[i]
end

--=========================网络相关=========================
-- 请求数据
function ActivityTimeOnlineLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedOnlineReward",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value, "初始化数据：")
            self.mOnlineRewardConfig = response.Value.TimedOnlineRewardConfig
            table.sort(self.mOnlineRewardConfig, function(config1, config2)
                return config1.OnlineMinutes < config2.OnlineMinutes
            end)
            self.mOnlineBaseConfig = response.Value.TimedOnlineRewardBaseConfig
            self.mOnlineRewardInfo = response.Value.TimedOnlineRewardInfo
            self.mReveciedRewardList = string.splitBySep(self.mOnlineRewardInfo.DrawRewardStr or "", ",")
            local time = self.mOnlineRewardInfo.TimedOnlineRewardCountdown - (Player:getCurrentTime()-self.mOnlineRewardInfo.UpdateTime)
            if self.mOnlineRewardInfo.TimedOnlineRewardCountdown <= 0 then
                time = self.mOnlineRewardInfo.TimedOnlineRewardCountdown
            end
            PlayerAttrObj:changeAttr({TimedOnlineRewardCountdown = time})

            
            self:refreshUI()
        end
    })
end
-- 请求奖励
function ActivityTimeOnlineLayer:requestGetReward(onlineTime)
    HttpClient:request({
        moduleName = "TimedOnlineReward",
        methodName = "DrawReward",
        svrMethodData = {onlineTime},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            
            self.mOnlineRewardInfo = response.Value.TimedOnlineRewardInfo
            self.mReveciedRewardList = string.splitBySep(self.mOnlineRewardInfo.DrawRewardStr or "", ",")

            local time = self.mOnlineRewardInfo.TimedOnlineRewardCountdown - (Player:getCurrentTime()-self.mOnlineRewardInfo.UpdateTime)
            if self.mOnlineRewardInfo.TimedOnlineRewardCountdown <= 0 then
                time = self.mOnlineRewardInfo.TimedOnlineRewardCountdown
            end
            PlayerAttrObj:changeAttr({TimedOnlineRewardCountdown = time})


            self:refreshUI()
        end
    })
end
-- 刷新外部奖励倒计时
function ActivityTimeOnlineLayer.refreshRewardCount()
    HttpClient:request({
        moduleName = "TimedOnlineReward",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            
            local onlineInfo = response.Value.TimedOnlineRewardInfo
            local time = onlineInfo.TimedOnlineRewardCountdown - (Player:getCurrentTime()-onlineInfo.UpdateTime)
            if onlineInfo.TimedOnlineRewardCountdown <= 0 then
                time = onlineInfo.TimedOnlineRewardCountdown
            end
            PlayerAttrObj:changeAttr({TimedOnlineRewardCountdown = time})
        end
    })
end

return ActivityTimeOnlineLayer