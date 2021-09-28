--[[
    文件名: IcefireResultLayer.lua
    描述: Pvp 战斗胜利结算页面
    创建人: suntao
    创建时间: 2016.06.20
-- ]]

require("ice.IcefireHelper")

local IcefireResultLayer = class("IcefireResultLayer", function(params)
    local parent = display.newLayer()
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = parent})
    return parent
end)

-- 构造函数
--[[
-- 参数 params 中的各项为
    {
        isWin   -- 是否赢
        randNum -- 奖励随机值
        bossId  -- boss模型id
    }
]]
function IcefireResultLayer:ctor(params)
    self.mIsWin = params.isWin
    self.mRandNum = params.randNum
    self.mBossId = params.bossId
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    local bgSprite = ui.newSprite(self.mIsWin and "zdjs_01.png" or "zdjs_02.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite, -10)

    -- 显示背景图
    local bgEffect = ui.newEffect({
        parent = self.mParentLayer,
        effectName = self.mIsWin and "effect_ui_zhandoushengli" or "effect_ui_zhandoushibai",
        position = cc.p(320, 514),
        animation = "zhandoushenglipvp",
        loop = false,
        endRelease = true,
        completeListener = function()
            ui.newEffect({
                parent = self.mParentLayer,
                zorder = -1,
                effectName = self.mIsWin and "effect_ui_zhandoushengli" or "effect_ui_zhandoushibai",
                animation = "zhandoushenglixunhuanpvp",
                position = cc.p(320, 514),
                loop = true,
                endRelease = false,
            })
        end,
    })

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function IcefireResultLayer:initUI()
    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("确定"),
        textColor = Enums.Color.eWhite,
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mCloseBtn:setPosition(320, 140)
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 奖励列表
    self.mRewardListView = ui.createCardList({
        maxViewWidth = 500,
        cardDataList = {},
        needAction = true,
        space = 20,
        needArrows = true,
    })
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRewardListView:setPosition(320, 280)
    self.mParentLayer:addChild(self.mRewardListView)

    -- 赢了
    if self.mIsWin then
        self:createPlayerHead()
        -- 强行拾取3秒
        self:getCdTime(3, function()
            local rewardList = self:getConfigReward()
            self.mRewardListView.refreshList(rewardList)
            -- 显示完奖励显示关闭按钮
            self.mCloseBtn:setVisible(false)
            local time = #rewardList*0.3
            Utility.performWithDelay(self.mCloseBtn, function ( ... )
                self.mCloseBtn:setVisible(true)
            end, time)
            -- 请求奖励刷新缓存
            self:requestReward()
        end)
    end
end

-- 强行拾取3秒
--[[
    cdTime      拾取时间
    callback    回调
]]
function IcefireResultLayer:getCdTime(cdTime, callback)
        -- 隐藏关闭按钮
    self.mCloseBtn:setVisible(false)
    -- 奖励拾取倒计时
    local tempLabel = ui.newLabel({
        text = TR("正在拾取守卫身上的宝石"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    tempLabel:setPosition(290, 280)
    self.mParentLayer:addChild(tempLabel)
    local timeLabel = ui.newNumberLabel({
        imgFile = "jc_37.png",
        text = 3,
    })
    timeLabel:setPosition(450, 280)
    self.mParentLayer:addChild(timeLabel)

    local time = cdTime
    self.mTimeUpdate = Utility.schedule(timeLabel, function()
        if time <= 0 then
            timeLabel:stopAction(self.mTimeUpdate)
            self.mTimeUpdate = nil
            timeLabel:removeFromParent()
            tempLabel:removeFromParent()
            self.mCloseBtn:setVisible(true)
            if callback then callback() end
        else
            timeLabel:setString(time)
            time = time - 1
        end
    end, 1)
end

-- 创建玩家显示
function IcefireResultLayer:createPlayerHead()
    -- 头像父节点
    if not self.mHeadParent then
        self.mHeadParent = cc.Node:create()
        self.mHeadParent:setAnchorPoint(cc.p(0.5, 0.5))
        self.mHeadParent:setPosition(320, 570)
        self.mParentLayer:addChild(self.mHeadParent)
    end
    -- 队伍成员
    local teamPlayerList = string.splitBySep(IcefireHelper.ownPlayerInfo.TeamPlayerIdList or "", ",")
    -- 节点大小
    local itemSpace = 120
    local parentSize = cc.size(640, #teamPlayerList*itemSpace)
    self.mHeadParent:setContentSize(parentSize)
    -- 创建head
    for i, playerId in ipairs(teamPlayerList) do
        -- 玩家head
        local playerInfo = IcefireHelper:getPlayerData(playerId)
        local playerHead = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = playerInfo.HeadImageId,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        playerHead:setPosition(150, (i-0.5)*itemSpace)
        self.mHeadParent:addChild(playerHead)
        -- 玩家名字
        local playerNameLabel = ui.newLabel({
            text = playerInfo.Name,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 18,
        })
        playerNameLabel:setPosition(150, (i-0.5)*itemSpace-60)
        self.mHeadParent:addChild(playerNameLabel)
        -- boss Head
        local bossModel = IcefireBossModel.items[self.mBossId]
        local bossHead = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = bossModel.heroModelID,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        bossHead:setPosition(490, (i-0.5)*itemSpace)
        self.mHeadParent:addChild(bossHead)
        -- vs图
        local vsSprite = ui.newSprite("zdjs_07.png")
        vsSprite:setPosition(320, (i-0.5)*itemSpace)
        self.mHeadParent:addChild(vsSprite)
    end
end

-- 获取配置奖励
function IcefireResultLayer:getConfigReward()
    local bossModel = IcefireBossModel.items[self.mBossId]
    local bossReward = Utility.analysisStrResList(bossModel.reward)
    -- 计算加成
    require("ice.IcefireHelper")
    local teamPlayerList = string.splitBySep(IcefireHelper.ownPlayerInfo.TeamPlayerIdList or "", ",")
    local addR = IcefireTeamaddModel.items[#teamPlayerList].addR or 0
    addR = (addR/10000-1)+1
    for _, resInfo in pairs(bossReward) do
        resInfo.num = resInfo.num * addR
        if resInfo.num % 1 >= 0.5 then 
            resInfo.num=math.ceil(resInfo.num)
        else
            resInfo.num=math.floor(resInfo.num)
        end
    end

    local randReward = nil
    for _, resModel in pairs(IcefireBossDropRelation.items[bossModel.dropID] or {}) do
        if resModel.minOdds <= self.mRandNum and resModel.maxOdds >= self.mRandNum then
            randReward = {
                resourceTypeSub = resModel.typeID,
                modelId = resModel.modelID,
                num = resModel.num,
            }
            break
        end
    end
    if randReward then
        table.insert(bossReward, randReward)
    end
    return bossReward
end

--=============================网络相关========================
-- 请求奖励
function IcefireResultLayer:requestReward()
    HttpClient:request({
        moduleName = "IcefireTeamHall",
        methodName = "RefreshReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
        end
    })
end

return IcefireResultLayer