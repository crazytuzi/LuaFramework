--[[
    文件名：ActivityWorldSecretLayer.lua
    文件描述：江湖秘藏
    创建人：yanghongsheng
    创建时间：2019.08.15
]]

local ActivityWorldSecretLayer = class("ActivityWorldSecretLayer",function()
    return display.newLayer()
end)

function ActivityWorldSecretLayer:ctor()
    --屏蔽下层触控
    ui.registerSwallowTouch({node = self})

    --创建标准适配层
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    self:initUI()

    self:requestGetInfo()
end

function ActivityWorldSecretLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite("jhmz_1.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    --创建返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        fontSize = 24,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(cc.p(600, 1045))
    self.mParentLayer:addChild(closeBtn)
    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        fontSize = 24,
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer("规则",
            {
                TR("1.参与每日任务，可获得活跃度兑换藏宝图，每天会清空已拥有的藏宝图。"),
                TR("2.使用1张藏宝图可任意抽取1个奖励，玩家每天最多可以抽取8个奖励。"),
                TR("3.抽取到的奖励需要到第二天才能领取。"),
                TR("4.抽取探索奖励后，若在第二天单笔充值1000元宝即可领取双倍的探索奖励。"),
                TR("5.活动期间累计获得一定数量的藏宝图会触发秘藏大宝箱，获得额外奖励，额外奖励不会翻倍。"),
                TR("6.活动结束前，请及时领取奖励。"),
            })
        end
    })
    ruleBtn:setPosition(cc.p(45, 1045))
    self.mParentLayer:addChild(ruleBtn)
    -- 活动倒计时
    self.mTimeLabel = ui.newLabel({
        text = "",
        size = 20,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    self.mTimeLabel:setPosition(320, 1000)
    self.mParentLayer:addChild(self.mTimeLabel)
    -- 累计宝藏图进度
    self.mProgLabel = ui.newLabel({
        text = TR("累计获得0/0次宝藏图可获得"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        color = cc.c3b(0xff, 0xf8, 0xea),
        size = 18,
    })
    self.mProgLabel:setAnchorPoint(cc.p(1, 0.5))
    self.mProgLabel:setPosition(536, 522)
    self.mParentLayer:addChild(self.mProgLabel)
    -- 宝箱按钮
    local boxBtn = ui.newButton({
        normalImage = "jhmz_12.png",
        clickAction = function ( ... )
            local drawNumRewardList = string.splitBySep(self.mSecretInfo.JianghuSecretInfo.DrawNumRewardStr, ",") or {}
            local isDraw = table.indexof(drawNumRewardList, tostring(self.mNumRewardInfo.Num))
            -- 按钮配置信息
            local btnInfo = {
                text = self.mSecretInfo.JianghuSecretInfo.TotalChooseNum >= self.mNumRewardInfo.Num and not isDraw and TR("领取") or TR("确定"),
                size = 22,
                color = cc.c3b(0xff, 0xff, 0xff),
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                    if self.mSecretInfo.JianghuSecretInfo.TotalChooseNum >= self.mNumRewardInfo.Num then
                        self:requestDrawNumReward(self.mNumRewardInfo.Num)
                    end
                end
            }   
            -- 奖励
            local chestReward = Utility.analysisStrResList(self.mNumRewardInfo.Reward) -- 宝箱奖励列表
            for _,v in ipairs(chestReward) do
                v.cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eBorder, CardShowAttr.eNum}
            end

            -- 弹出奖励页面
            MsgBoxLayer.addPreviewDropLayer(
                chestReward,
                TR("可获得以下奖励"),
                TR("宝箱奖励"),
                {btnInfo},
                {}
            )
        end
    })
    boxBtn:setPosition(573, 535)
    self.mParentLayer:addChild(boxBtn)
    self.mBoxRewardBtn = boxBtn
    -- 添加小红点
    local btnSize = self.mBoxRewardBtn:getContentSize()
    local redDotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.85, btnSize.height * 0.8)})
    redDotSprite:setVisible(false)
    self.mBoxRewardBtn:addChild(redDotSprite)
    self.mBoxRewardBtn.redDotSprite = redDotSprite
    -- 提示奖励领取时间
    local tempLabel = ui.newLabel({
        text = TR("#fff8ea探索奖励中，可在#ffe748每日凌晨点0点#fff8ea后领取"),
        size = 18,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    tempLabel:setPosition(320, 470)
    self.mParentLayer:addChild(tempLabel)
    -- 领取按钮
    self.mGetBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        clickAction = function ( ... )
            -- 若是最后一次奖励
            if self.mSecretInfo.EndTime-Player:getCurrentTime() > 0 and self.mSecretInfo.EndTime-Player:getCurrentTime() < 86400 and self.mSecretInfo.JianghuSecretInfo.DrawNum >= 1 then
                -- 是否选择了奖励
                if #self.mChooseRewardList > 0 then
                    MsgBoxLayer.addOKCancelLayer(
                        TR("这是本活动最后一次奖励，确认现在领取？"),
                        TR("提示"),
                        {
                            text = TR("确定"),
                            clickAction = function(layerObj)
                                self:requestDrawReward()
                                LayerManager.removeLayer(layerObj)
                            end
                        })
                else
                    ui.showFlashView(TR("请先选择探索奖励"))
                end
            else
                self:requestDrawReward()
            end
        end
    })
    self.mGetBtn:setPosition(320, 205)
    self.mParentLayer:addChild(self.mGetBtn)
end

-- 创建奖励显示
function ActivityWorldSecretLayer:createRewardShow()
    if not self.mGridReward then
        self.mGridReward = require("common.GridView"):create({
                viewSize = cc.size(480, 200),
                colCount = 4,
                celHeight = 100,
                selectIndex = 1,
                -- needDelay = true,
                getCountCb = function()
                    return #self.mChooseRewardList
                end,
                createColCb = function(itemParent, colIndex, isSelected)
                    local rewardIndex = tonumber(self.mChooseRewardList[colIndex])
                    local rewardConfig = self.mSecretInfo.JianghuSecretRewardConfig[rewardIndex]
                    local rewardInfo = Utility.analysisStrResList(rewardConfig.Reward)[1]
                    rewardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
                    -- 创建显示图片
                    local card, Attr = CardNode.createCardNode(rewardInfo)
                    card:setPosition(itemParent:getContentSize().width*0.5, itemParent:getContentSize().height*0.5)
                    itemParent:addChild(card)
                    -- 是否双倍
                    if self.mSecretInfo.JianghuSecretInfo.IsDouble and (self:getStatus() == 2 or (self.mSecretInfo.EndTime-Player:getCurrentTime() > 0 and self.mSecretInfo.EndTime-Player:getCurrentTime() < 86400)) then
                        local tempSprite, tempLabel = ui.createStrImgMark("c_62.png", TR("双倍"))
                        tempSprite:setPosition(itemParent:getContentSize().width*0.5-10, itemParent:getContentSize().height*0.5+10)
                        itemParent:addChild(tempSprite)
                    end

                end,
            })
        self.mGridReward:setPosition(320, 343)
        self.mParentLayer:addChild(self.mGridReward)
    end

    -- 刷新
    self.mGridReward:reloadData()

    -- 空提示
    if not self.mRewardHintSprite then
        self.mRewardHintSprite = ui.newSprite("jhmz_3.png")
        self.mRewardHintSprite:setPosition(320, 343)
        self.mParentLayer:addChild(self.mRewardHintSprite)
    end
    self.mRewardHintSprite:setVisible(#self.mChooseRewardList <= 0)
end

-- 创建探索秘藏奖池页面
function ActivityWorldSecretLayer:createSecretPondLayer()
    if not self.mSubLayer then
        self.mSubLayer = cc.Node:create()
        self.mParentLayer:addChild(self.mSubLayer)
    end
    self.mSubLayer:removeAllChildren()

    -- 背景
    local bgSprite = ui.newSprite("jhmz_10.png")
    bgSprite:setPosition(320, 835)
    bgSprite:setScaleY(0.85)
    self.mSubLayer:addChild(bgSprite)

    -- 提示文字
    local tempLabel = ui.newLabel({
        text = TR("点击选择可探索的秘藏"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 18,
    })
    tempLabel:setPosition(320, 964)
    self.mSubLayer:addChild(tempLabel)

    -- 奖池
    local pondGrid = require("common.GridView"):create({
            viewSize = cc.size(540, 220),
            colCount = 6,
            celHeight = 72,
            selectIndex = 1,
            -- needDelay = true,
            getCountCb = function()
                return #self.mBaseRewardList
            end,
            createColCb = function(itemParent, colIndex)
                local rewardIndex = tonumber(self.mBaseRewardList[colIndex])
                local rewardConfig = self.mSecretInfo.JianghuSecretRewardConfig[rewardIndex]
                local rewardInfo = Utility.analysisStrResList(rewardConfig.Reward)[1]
                rewardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

                local isSelected = table.indexof(self.mChooseRewardList, tostring(rewardIndex)) and true or false
                -- 点击响应
                rewardInfo.onClickCallback = function ()
                    -- 选择奖励
                    if self.mSecretInfo.JianghuSecretInfo.CanChooseNum > 0 and not isSelected then
                        MsgBoxLayer.addOKCancelLayer(
                            TR("是否要选择探索奖励%s%s*%s", Enums.Color.eOrangeH, Utility.getGoodsName(rewardInfo.resourceTypeSub, rewardInfo.modelId), rewardInfo.num),
                            TR("探索奖励"),
                            {
                                text = TR("确定"),
                                clickAction = function(layerObj)
                                    self:requestChooseReward(rewardIndex)
                                    LayerManager.removeLayer(layerObj)
                                end
                            })
                    -- 查看详情
                    else
                        CardNode.defaultCardClick(rewardInfo)
                    end
                end
                -- 创建显示图片
                local card, Attr = CardNode.createCardNode(rewardInfo)
                card:setPosition(itemParent:getContentSize().width*0.5, itemParent:getContentSize().height*0.5)
                card:setScale(0.7)
                itemParent:addChild(card)
                card:setGray(isSelected)

                -- 是否已选择
                local selectSprite = ui.newSprite("zy_19.png")
                selectSprite:setPosition(itemParent:getContentSize().width*0.5, itemParent:getContentSize().height*0.5)
                selectSprite:setVisible(isSelected)
                itemParent:addChild(selectSprite)
            end,
        })
    pondGrid:setPosition(320, 842)
    self.mSubLayer:addChild(pondGrid)

    -- 当前拥有次数
    local chooseNumLabel = ui.newLabel({
        text = TR("当前拥有：{jhmz_19.png}%s", self.mSecretInfo.JianghuSecretInfo.CanChooseNum),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    chooseNumLabel:setPosition(320, 718)
    self.mSubLayer:addChild(chooseNumLabel)

    -- 提示图
    local hintSprite = ui.newSprite("jhmz_13.png")
    hintSprite:setPosition(20, 555)
    hintSprite:setAnchorPoint(cc.p(0, 0.5))
    self.mSubLayer:addChild(hintSprite)

    -- 创建活跃进度条
    local progNode = self:createProgNode()
    progNode:setPosition(290, 610)
    self.mSubLayer:addChild(progNode)
end

-- 创建秘藏领奖页面
function ActivityWorldSecretLayer:createSecretPrizeLayer()
    if not self.mSubLayer then
        self.mSubLayer = cc.Node:create()
        self.mParentLayer:addChild(self.mSubLayer)
    end
    self.mSubLayer:removeAllChildren()

    -- 免费领取背景
    local tempSprite = ui.newSprite("jhmz_5.png")
    tempSprite:setScale(0.8)
    tempSprite:setPosition(180, 870)
    self.mSubLayer:addChild(tempSprite)
    -- 免费领取
    local tempSprite = ui.newSprite("jhmz_7.png")
    tempSprite:setPosition(180, 870)
    self.mSubLayer:addChild(tempSprite)
    -- 可领取提示背景
    local bgSize = cc.size(150, 30)
    local tempSprite = ui.newScale9Sprite("c_103.png", bgSize)
    tempSprite:setPosition(180, 790)
    self.mSubLayer:addChild(tempSprite)
    -- 可领取提示
    local tempLabel = ui.newLabel({
        text = TR("可领取{jhmz_16.png}奖励"),
        size = 18,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    tempLabel:setPosition(bgSize.width*0.5, bgSize.height*0.5)
    tempSprite:addChild(tempLabel)

    -- 充值领取背景
    local rechargeBtn = ui.newButton({
        normalImage = "jhmz_6.png",
        clickAction = function ()
            LayerManager.addLayer({name = "recharge.RechargeLayer"})
        end
    })
    rechargeBtn:setScale(0.8)
    rechargeBtn:setPosition(467, 870)
    self.mSubLayer:addChild(rechargeBtn)
    -- 充值领取
    local rechargeBgSprite = ui.newSprite("jhmz_8.png")
    rechargeBgSprite:setPosition(467, 870)
    self.mSubLayer:addChild(rechargeBgSprite)
    -- 充值数量
    local rechargeNumLabel = ui.newNumberLabel({
        text = self.mSecretInfo.ChargeNum*20,
        imgFile = "c_81.png",
    })
    rechargeNumLabel:setScale(0.7)
    rechargeNumLabel:setPosition(110, rechargeBgSprite:getContentSize().height*0.5)
    rechargeBgSprite:addChild(rechargeNumLabel)
    -- 可领取提示背景
    local bgSize = cc.size(150, 30)
    local tempSprite = ui.newScale9Sprite("c_103.png", bgSize)
    tempSprite:setPosition(467, 790)
    self.mSubLayer:addChild(tempSprite)
    -- 可领取提示
    local tempLabel = ui.newLabel({
        text = TR("可领取{jhmz_17.png}奖励"),
        size = 18,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    tempLabel:setPosition(bgSize.width*0.5, bgSize.height*0.5)
    tempSprite:addChild(tempLabel)

    -- 进度条
    local progNode = self:createProgNode()
    progNode:setPosition(290, 680)
    self.mSubLayer:addChild(progNode)

    -- 提示文字
    local hintSprite = ui.newSprite("jhmz_4.png")
    hintSprite:setAnchorPoint(cc.p(0, 0.5))
    hintSprite:setPosition(30, 590)
    self.mSubLayer:addChild(hintSprite)
end

-- 创建活跃进度条
function ActivityWorldSecretLayer:createProgNode()
    local progNode = cc.Node:create()

    -- 背景
    local bgSprite = ui.newScale9Sprite("jhmz_14.png", cc.size(540, 60))
    progNode:addChild(bgSprite)
    local bgSize = bgSprite:getContentSize()
    -- 活跃图标
    local imgSprite = ui.newSprite("db_1135.png")
    imgSprite:setPosition(5, bgSize.height*0.5)
    imgSprite:setScale(0.8)
    bgSprite:addChild(imgSprite)
    -- 进度数据
    table.sort(self.mSecretInfo.JianghuSecretActionConfig, function (config1, config2)
        return config1.ActionNum < config2.ActionNum
    end )
    local progLength = 465      -- 进度条总长度
    local progItemLength = progLength/#self.mSecretInfo.JianghuSecretActionConfig
    local progItemWidth = progItemLength-40

    local beforeConfig = nil
    for i, configInfo in ipairs(self.mSecretInfo.JianghuSecretActionConfig) do
        -- 进度条
        local progMax = beforeConfig and configInfo.ActionNum-beforeConfig.ActionNum or configInfo.ActionNum
        local progCur = self.mSecretInfo.JianghuSecretInfo.ActionValue >= configInfo.ActionNum and progMax or self.mSecretInfo.JianghuSecretInfo.ActionValue-(beforeConfig and beforeConfig.ActionNum or 0)
        local tempBarBg = ui.newScale9Sprite("tjl_10.png", cc.size(progItemWidth, 35))
        tempBarBg:setAnchorPoint(cc.p(0, 0.5))
        bgSprite:addChild(tempBarBg)
        tempBarBg:setPosition(30+(i-1)*progItemLength, bgSize.height*0.5)
        local tempBar = require("common.ProgressBar"):create({
            -- bgImage = "tjl_10.png",
            barImage = "tjl_09.png",
            currValue = progCur,
            maxValue = progMax,
            contentSize = cc.size(progItemWidth, 40),
            needLabel = false,
            percentView = false,
            color = Enums.Color.eBrown
        })
        tempBar:setAnchorPoint(cc.p(0, 0.5))
        tempBar:setPosition(30+(i-1)*progItemLength, bgSize.height*0.5)
        bgSprite:addChild(tempBar)

        -- 进度条上数字
        local barNumLabel = ui.newLabel({
            text = configInfo.ActionNum,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
        barNumLabel:setPosition(progItemWidth*0.5, 20)
        tempBar:addChild(barNumLabel)

        local status = self:getStatus()
        -- 宝箱
        if status == 1 then
            local drawList = string.splitBySep(self.mSecretInfo.JianghuSecretInfo.DrawActionStr, ",")
            local isDraw = table.indexof(drawList, tostring(configInfo.ActionNum)) and true or false
            local boxImg = ui.newSprite(isDraw and "r_10.png" or "r_09.png")
            boxImg:setScale(0.4)
            boxImg:setPosition(10+i*progItemLength, bgSize.height*0.5)
            bgSprite:addChild(boxImg)

            -- 领劵按钮背景
            local getNumBg = ui.newSprite("jhmz_20.png")
            getNumBg:setPosition(10+i*progItemLength, bgSize.height+20)
            bgSprite:addChild(getNumBg)
            getNumBg:setGray(configInfo.ActionNum > self.mSecretInfo.JianghuSecretInfo.ActionValue)
            getNumBg:setScale(0.67)
            -- 领劵按钮
            local getNumBtn = ui.newButton({
                normalImage = "jhmz_18.png",
                clickAction = function ( ... )
                    if isDraw then
                        ui.showFlashView("已领取")
                        return
                    end
                    self:requestDrawActionNum(configInfo.ActionNum)
                end
            })
            getNumBtn:setPosition(10+i*progItemLength, bgSize.height+20)
            bgSprite:addChild(getNumBtn)
            getNumBtn:setEnabled(configInfo.ActionNum <= self.mSecretInfo.JianghuSecretInfo.ActionValue)
            -- 添加小红点
            local btnSize = getNumBtn:getContentSize()
            local redDotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.85, btnSize.height * 0.8)})
            getNumBtn:addChild(redDotSprite)
            redDotSprite:setVisible(configInfo.ActionNum <= self.mSecretInfo.JianghuSecretInfo.ActionValue and not isDraw)
        -- 劵
        else
            local juanImg = ui.newSprite("jhmz_11.png")
            juanImg:setPosition(10+i*progItemLength, bgSize.height*0.5)
            bgSprite:addChild(juanImg)
            juanImg:setGray(configInfo.ActionNum > self.mSecretInfo.JianghuSecretInfo.ActionValue)
        end

        -- 领取数量
        local numLabel = ui.newLabel({
            text = TR("x%s", configInfo.RewardNum),
            color = cc.c3b(245, 245, 146),
            outlineColor = cc.c3b(153, 24, 5),
            size = 24,
        })
        numLabel:setPosition(10+i*progItemLength, bgSize.height*0.5+30)
        bgSprite:addChild(numLabel)

        beforeConfig = configInfo
    end

    -- 跳转每日任务按钮
    local getActiveBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("获取活跃度"),
        fontSize = 20,
        clickAction = function ( ... )
            LayerManager.addLayer({name = "dailytask.DailyTaskLayer", data = {exitCallBacak = function ()
                self:requestGetInfo()
            end}, cleanUp = false})
        end
    })
    getActiveBtn:setScale(0.8)
    getActiveBtn:setPosition(bgSize.width+10, bgSize.height*0.5)
    bgSprite:addChild(getActiveBtn)

    return progNode
end

-- 创建活动倒计时
function ActivityWorldSecretLayer:createTimeUpdate()

    if self.mTimeLabel.timeUpdate then
        self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
        self.mTimeLabel.timeUpdate = nil
    end

    self.mTimeLabel.timeUpdate = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mSecretInfo.EndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("活动倒计时：#ffe74800:00:00"))
            self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
            self.mTimeLabel.timeUpdate = nil
            LayerManager.removeLayer(self)
        end
    end, 1)
end

-- 刷新界面
function ActivityWorldSecretLayer:refreshUI()
    -- 奖励显示
    self:createRewardShow()
    -- 页面
    if self:getStatus() == 1 then
        self:createSecretPondLayer()
    else
        self:createSecretPrizeLayer()
    end
    -- 领取按钮
    -- 最后一天领两次
    local canDraw = self.mSecretInfo.EndTime-Player:getCurrentTime() > 0 and self.mSecretInfo.EndTime-Player:getCurrentTime() < 86400 and self.mSecretInfo.JianghuSecretInfo.DrawNum < 2
    self.mGetBtn:setEnabled(self:getStatus() == 2 or canDraw)
    -- 累计进度
    self.mProgLabel:setString(TR("累计获得#ffe748%s/%s#fff8ea次宝藏可获得", self.mSecretInfo.JianghuSecretInfo.TotalChooseNum, self.mNumRewardInfo.Num))
    -- 累计奖励小红点
    local drawNumRewardList = string.splitBySep(self.mSecretInfo.JianghuSecretInfo.DrawNumRewardStr, ",") or {}
    local isDraw = table.indexof(drawNumRewardList, tostring(self.mNumRewardInfo.Num))
    self.mBoxRewardBtn.redDotSprite:setVisible(self.mSecretInfo.JianghuSecretInfo.TotalChooseNum >= self.mNumRewardInfo.Num and not isDraw)
    -- 活动倒计时
    self:createTimeUpdate()
end

-- 刷新界面
function ActivityWorldSecretLayer:refreshData()
    -- 奖池数据
    self.mBaseRewardList = {}
    self.mBaseRewardList = string.splitBySep(self.mSecretInfo.JianghuSecretInfo.BaseRecord, ",")
    -- 选择奖励
    self.mChooseRewardList = {}
    self.mChooseRewardList = string.splitBySep(self.mSecretInfo.JianghuSecretInfo.ChooseInfo, ",")
    -- 奖励配置修改索引
    local tempList = {}
    for _, rewardConfig in pairs(self.mSecretInfo.JianghuSecretRewardConfig) do
        tempList[rewardConfig.Id] = rewardConfig
    end
    self.mSecretInfo.JianghuSecretRewardConfig = tempList
    -- 累计已领取奖励
    self.mNumRewardInfo = nil
    local DrawNumRewardList = string.splitBySep(self.mSecretInfo.JianghuSecretInfo.DrawNumRewardStr, ",") or {}
    table.sort(DrawNumRewardList, function (num1, num2)
        return tonumber(num1) < tonumber(num2)
    end)
    table.sort(self.mSecretInfo.JianghuSecretNumRewardConfig, function (config11, config2)
        return config11.Num < config2.Num
    end)
    local hadDrawNum = tonumber(DrawNumRewardList[#DrawNumRewardList] or 0)
    for i, configInfo in ipairs(self.mSecretInfo.JianghuSecretNumRewardConfig) do
        if configInfo.Num > hadDrawNum then
            self.mNumRewardInfo = configInfo
            break
        end
    end
    if not self.mNumRewardInfo then
        self.mNumRewardInfo = self.mSecretInfo.JianghuSecretNumRewardConfig[#self.mSecretInfo.JianghuSecretNumRewardConfig]
    end
end

-- 获取界面状态(1: 探索抽奖 2: 可领取奖励)
function ActivityWorldSecretLayer:getStatus()
    -- 第一天不能领奖
    if Player:getCurrentTime() - self.mSecretInfo.StartDate < 86400 then
        return 1
    end
    -- 领过一次不能领
    if self.mSecretInfo.JianghuSecretInfo.DrawNum >= 1 then
        return 1
    end

    return 2
end

--=======================网络数据=========================
--请求网络数据
function ActivityWorldSecretLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedJianghuSecretInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value)
            self.mSecretInfo = response.Value
            self:refreshData()
            self:refreshUI()
        end
    })
end

--请求领取探索次数
function ActivityWorldSecretLayer:requestDrawActionNum(actionNum)
    HttpClient:request({
        moduleName = "TimedJianghuSecretInfo",
        methodName = "DrawActionNum",
        svrMethodData = {actionNum},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            ui.showFlashView(TR("获得探索劵"))
            self.mSecretInfo.JianghuSecretInfo = response.Value.JianghuSecretInfo
            self:refreshData()
            self:refreshUI()
        end
    })
end

--请求选择探索奖励
function ActivityWorldSecretLayer:requestChooseReward(rewardId)
    HttpClient:request({
        moduleName = "TimedJianghuSecretInfo",
        methodName = "ChooseReward",
        svrMethodData = {{rewardId}},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.mSecretInfo.JianghuSecretInfo = response.Value.JianghuSecretInfo
            self:refreshData()
            self:refreshUI()
        end
    })
end

--请求领取奖励
function ActivityWorldSecretLayer:requestDrawReward()
    HttpClient:request({
        moduleName = "TimedJianghuSecretInfo",
        methodName = "DrawReward",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mSecretInfo.JianghuSecretInfo = response.Value.JianghuSecretInfo
            self:refreshData()
            self:refreshUI()
        end
    })
end

--请求领取累计奖励
function ActivityWorldSecretLayer:requestDrawNumReward(num)
    HttpClient:request({
        moduleName = "TimedJianghuSecretInfo",
        methodName = "DrawNumReward",
        svrMethodData = {num},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mSecretInfo.JianghuSecretInfo = response.Value.JianghuSecretInfo
            self:refreshData()
            self:refreshUI()
        end
    })
end

return ActivityWorldSecretLayer