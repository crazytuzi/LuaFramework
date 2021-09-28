--[[
    文件名: BlessingTaskLayer.lua
    描述: 祝福任务页面
    创建人: yanghongsheng
    创建时间: 2018.8.14
-- ]]
local BlessingTaskLayer = class("BlessingTaskLayer", function (params)
    return display.newLayer()
end)

-- 五个孔明灯的位置
local Giftpos = {
    [1] = cc.p(95, 700),
    [2] = cc.p(530, 700),
    [3] = cc.p(315, 587),
    [4] = cc.p(95, 454),
    [5] = cc.p(530, 462),
}

-- 灯小红点事件名
local lightEventNamePrefix = "eLightEventNamePrefix"

function BlessingTaskLayer:ctor()
    -- 任务列表
    self.mTaskList = {}
    -- 奖励信息列表
    self.mPublishRewardList = {}
    -- 五个任务卡槽列表
    self.mLightTaskList = {}
    -- 灯按钮列表
    self.mLightBtnList = {}
    -- 完成次数列表
    self.mFinishNumList = {}

    ui.registerSwallowTouch({node = self})
    --
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建UI
    self:initUI()
end

function BlessingTaskLayer:onEnterTransitionFinish()
	local activityInfo = ActivityObj:getActivityItem(ModuleSub.eTimedBlessingTask)[1]
	if activityInfo and Player:getCurrentTime() > activityInfo.EndDate then
		LayerManager.removeLayer(self)
		-- 打开排行榜
		self:openRankShow(true)
	else
	    self:requestGetInfo()
	end
end

function BlessingTaskLayer:openRankShow(isCleanUp)
	LayerManager.addLayer({
        name = "activity.CommonActivityRankLayer",
        data = {
            moduleName = "TimedBlessingTaskBase",
            methodNameRank = "GetRank",
            methodNameReward = "GetRankReward",
            scoreName = TR("积分"),
        },
        cleanUp = isCleanUp,
    })
end

-- 初始页面
function BlessingTaskLayer:initUI()
    --背景图
    local bgSprite = ui.newSprite("jrhd_138.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1045),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(40, 1045),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.点击悬赏令，可以接受任务，完成任务获得奖励和积分。"),
                TR("2.点击刷新任务，可以刷新已完成的任务，每日可以获得免费刷新次数，每充值6元也可获得一次刷新次数"),
                TR("3.完成任务获得积分，积分达到一定时可以领取任务宝箱。"),
                TR("4.活动期间获得的总积分用于排行榜排名，总积分越高排名越高。"),
                TR("5.活动期间每日可以发布任务，发布任务后，若有其他侠客完成你发布的任务，则可领取奖励。"),
                TR("6.发布任务时可以选择自己想要的奖励，一种奖励一天只能选择一次。"),
                TR("7.若第一日发布的任务第二日才有侠客完成，那么第二日无法发布新的任务，清各位大侠每日尽早发布任务，以便有人完成。"),
                TR("8.每日完成任务数量达到一定时，可以快捷完成任务，快捷完成可以直接领取任务奖励和积分。"),
                TR("9.任务每日会自动刷新，任务刷新时有概率刷出传说任务，可以获得更丰厚的奖励。"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 发布任务按钮
    self.publishBtn = ui.newButton({
        normalImage = "zfrw_7.png",
        text = TR("发布任务"),
        position = cc.p(310, 180),
        clickAction = function(pSender)
            self:publishCallBack()
        end
    })
    self.mParentLayer:addChild(self.publishBtn)
    -- 添加发布任务小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eTimedBlessingTask, "PublishTaskReward"))
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = self.publishBtn,
        eventName = RedDotInfoObj:getEvents(ModuleSub.eTimedBlessingTask, "PublishTaskReward")})

    -- 快捷完成按钮
    local quickFinishBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("快捷完成"),
        position = cc.p(150, 180),
        clickAction = function(pSender)
            if self.mBaseInfo.DailyFinishNum < self.mConfigInfo.QuickCompletionNeedNum then
                ui.showFlashView(TR("需要完成%d次任务，才能使用快捷完成功能", self.mConfigInfo.QuickCompletionNeedNum))
                return
            end
            self:requestFastFinish()
        end
    })
    self.mParentLayer:addChild(quickFinishBtn)

    -- 快捷接受按钮
    local quickAcceptBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("快捷接受"),
        position = cc.p(460, 180),
        clickAction = function(pSender)
            if self.mBaseInfo.DailyFinishNum < self.mConfigInfo.QuickCompletionNeedNum then
                ui.showFlashView(TR("需要完成%d次任务，才能使用快捷接受功能", self.mConfigInfo.QuickCompletionNeedNum))
                return
            end
            self:requestFastAccept()
        end
    })
    self.mParentLayer:addChild(quickAcceptBtn)

    -- 刷新任务按钮
    self.refreshBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("刷新任务"),
        position = cc.p(320, 830),
        clickAction = function(pSender)
            if self.mBaseInfo.TotalNum < 1 then
                ui.showFlashView(TR("今日刷新次数已用完"))
                return
            elseif self.refreshCount < 1 then
                ui.showFlashView(TR("没有可刷新的任务"))
                return
            end

            MsgBoxLayer.selectCountLayer({
                    title = TR("选择次数"),
                    msgtext = TR("请选择刷新次数"),
                    maxNum = self.mBaseInfo.TotalNum < self.refreshCount and self.mBaseInfo.TotalNum or self.refreshCount,
                    OkCallback = function(count, layerObj)
                        self:requestRefreshTask(count)
                        LayerManager.removeLayer(layerObj)
                    end,
                })
        end
    })
    self.mParentLayer:addChild(self.refreshBtn)
    -- 剩余刷新次数
    self.refreshLabel = ui.newLabel({
        text = TR("剩余可刷新任务个数：2"),
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0xff, 0x97, 0x4a),
        outlineSize = 1,
    })
    self.refreshLabel:setPosition(320, 785)
    self.mParentLayer:addChild(self.refreshLabel)

    -- 任务宝箱按钮
    local taskRewardBtn = ui.newButton({
            normalImage = "zfrw_11.png",
            position = cc.p(590, 270),
            clickAction = function ()
                LayerManager.addLayer({
                        name = "festival.BlessingExchangLayer",
                        cleanUp = false,
                    })
            end
        })
    self.mParentLayer:addChild(taskRewardBtn)

    -- 排行榜
    local rankBtn = ui.newButton({
            normalImage = "tb_16.png",
            position = cc.p(590, 156),
            clickAction = function ()
                self:openRankShow(false)
            end
        })
    self.mParentLayer:addChild(rankBtn)

    -- 活动剩余时间
    local timeBg = ui.newScale9Sprite("c_25.png",cc.size(300, 50))
    timeBg:setPosition(330, 300)
    self.mParentLayer:addChild(timeBg)
    local timeLabel = ui.newLabel({
        text = TR("活动倒计时：00:00:00"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    timeLabel:setPosition(330, 300)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    -- 总积分
    local rewardTimeBg = ui.newScale9Sprite("c_25.png",cc.size(300, 50))
    rewardTimeBg:setPosition(330, 250)
    self.mParentLayer:addChild(rewardTimeBg)
    local totalScoreLabel = ui.newLabel({
        text = TR("总积分：0"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    totalScoreLabel:setPosition(330, 250)
    self.mParentLayer:addChild(totalScoreLabel)
    self.mTotalScoreLabel = totalScoreLabel

    -- 创建灯按钮
    self:createLightButton()
end

-- 创建灯按钮
function BlessingTaskLayer:createLightButton()
    self.mLightBtnList = {}
    if not self.mLightParent then
        self.mLightParent = cc.Node:create()
        self.mParentLayer:addChild(self.mLightParent)
    end
    self.mLightParent:removeAllChildren()

    -- 创建灯
    for i, pos in ipairs(Giftpos) do
        local lightBtn = ui.newButton({
                normalImage = "jrhd_139.png",
                titleImage = "zfrw_4.png",
                titlePosRateY = -0.1,
                -- titlePosRateX = 0.9,
                position = pos,
                clickAction = function ()
                    if self.mLightBtnList[i].taskInfo.TaskStatus ~= 2 then
                        self:createTaskBox(i)
                    else
                        ui.showFlashView(TR("该任务已完成，请刷新任务"))
                    end
                end
            })
        self.mLightParent:addChild(lightBtn)
        -- self:createAni(lightBtn)

        -- 添加小红点
        local redDot = ui.createAutoBubble({
            refreshFunc = function (reddotSprite)
                if not self.mLightBtnList[i] then return end
                -- 任务数据
                local taskInfo = self.mLightBtnList[i].taskInfo
                -- 任务模型
                local taskModel = self.mTaskList[taskInfo.TaskId]
                -- 已接受任务且完成任务
                if taskInfo.TaskStatus == 1 and (self.mFinishNumList[taskModel.TaskModuleId] or 0) >= taskModel.NeedFinishNum then
                    reddotSprite:setVisible(true)
                else
                    reddotSprite:setVisible(false)
                end
            end,
            parent = lightBtn,
            eventName = lightEventNamePrefix..i
        })
        redDot:setVisible(false)

        table.insert(self.mLightBtnList, lightBtn)
    end
end

-- 刷新灯按钮
function BlessingTaskLayer:refreshLightButton()
    self.refreshCount = 0 -- 刷新次数
    for _, taskInfo in pairs(self.mLightTaskList) do
        local lightBtn = self.mLightBtnList[taskInfo.OrderId]
        -- 任务状态
        if taskInfo.TaskStatus == 0 then
            lightBtn:setTitleImage("zfrw_4.png")
        elseif taskInfo.TaskStatus == 1 then
            lightBtn:setTitleImage("zfrw_5.png")
        elseif taskInfo.TaskStatus == 2 then
            lightBtn:setTitleImage("zfrw_6.png")
        end
        -- 任务类型
        if taskInfo.TaskType == 1 then
            lightBtn:loadTextures("jrhd_139.png", "jrhd_139.png")
        elseif taskInfo.TaskType == 2 then
            lightBtn:loadTextures("jrhd_140.png", "jrhd_140.png")
        end
        -- 保存任务信息
        lightBtn.taskInfo = taskInfo

        -- 已完成任务（可以刷新的任务）
        if taskInfo.TaskStatus == 2 then
            self.refreshCount = self.refreshCount + 1
        end

        -- 检测小红点显示
        Notification:postNotification(lightEventNamePrefix .. taskInfo.OrderId)
    end

    -- self.refreshLabel:setString(TR("剩余可刷新任务个数：%d", self.refreshCount))
end

-- 动画
function BlessingTaskLayer:createAni(node)
    -- 图片浮动效果
    local randNum = math.random(10, 20)
    local randTime = math.random(50, 100)/100
    local moveAction1 = cc.MoveBy:create(randTime, cc.p(0, randNum))
    local moveAction2 = cc.MoveBy:create(randTime, cc.p(0, -randNum*0.5))
    local moveAction3 = cc.MoveBy:create(randTime, cc.p(0, -randNum*0.5))
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.EaseSineOut:create(moveAction1),
        cc.EaseSineIn:create(moveAction2),
        cc.EaseSineOut:create(moveAction3)
    )))
end

function BlessingTaskLayer:createTaskBox(orderId)
    if not self.taskBox or tolua.isnull(self.taskBox) then
        local function DIYfunc(boxRoot, bgSprite, bgSize)
            local taskModel = self.mTaskList[self.mLightBtnList[orderId].taskInfo.TaskId]
            local finishNum = self.mFinishNumList[taskModel.TaskModuleId] or 0
            -- 任务描述
            local descLabel = ui.newLabel({
                text = TR("完成%s#258711%d/%d#46220d次", ModuleSubModel.items[taskModel.TaskModuleId].name, finishNum, taskModel.NeedFinishNum),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            descLabel:setPosition(bgSize.width*0.5, 400)
            descLabel:setAnchorPoint(cc.p(0.5, 0.5))
            bgSprite:addChild(descLabel)
            -- 完成后
            local tempLabel = ui.newLabel({
                text = TR("完成后可获得下列奖励的随机一种和%d点积分", self.mConfigInfo.TaskFinishScore),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
            tempLabel:setPosition(bgSize.width*0.5, 300)
            tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
            bgSprite:addChild(tempLabel)
            -- 列表
            local rewardList = Utility.analysisStrResList(self.mLightBtnList[orderId].taskInfo.RewardStr)
            local cardList = ui.createCardList({
                    maxViewWidth = bgSize.width-40,
                    cardDataList = rewardList,
                })
            cardList:setAnchorPoint(cc.p(0.5, 0.5))
            cardList:setPosition(bgSize.width*0.5, 210)
            bgSprite:addChild(cardList)
            -- 按钮
            local textStr = TR("接受")
            if self.mLightBtnList[orderId].taskInfo.TaskStatus == 0 then
                textStr = TR("接受")
            elseif finishNum < taskModel.NeedFinishNum then
                textStr = TR("前往")
            else
                textStr = TR("完成")
            end
            
            local taskBtn = ui.newButton({
                    normalImage = "fx_11.png",
                    text = textStr,
                    clickAction = function ()
                        -- 接受任务
                        if self.mLightBtnList[orderId].taskInfo.TaskStatus == 0 then
                            self:requestAcceptTask(orderId)
                        -- 前往
                        elseif (self.mFinishNumList[taskModel.TaskModuleId] or 0) < taskModel.NeedFinishNum then
                            LayerManager.showSubModule(taskModel.TaskModuleId)
                        -- 完成
                        else
                            self:requestTaskReward(orderId)
                            LayerManager.removeLayer(boxRoot)
                        end
                    end,
                })
            taskBtn:setPosition(bgSize.width*0.5, 60)
            bgSprite:addChild(taskBtn)

            boxRoot.refreshBtn = function (target)
                local textStr = TR("接受")
                if self.mLightBtnList[orderId].taskInfo.TaskStatus == 0 then
                    textStr = TR("接受")
                elseif (self.mFinishNumList[taskModel.TaskModuleId] or 0) < taskModel.NeedFinishNum then
                    textStr = TR("前往")
                else
                    textStr = TR("完成")
                end
                taskBtn:setTitleText(textStr)
            end
        end

        self.taskBox = LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            cleanUp = false,
            data = {
                bgImage = "jrhd_141.png",
                bgSize = cc.size(430, 682),
                isNoShowTitle = true,
                notNeedBlack = true,
                btnInfos = {},
                closeBtnInfo = {
                    normalImage = "tjl_08.png",
                },
                DIYUiCallback = DIYfunc,
                needTouchClose = true,
            }
        })
    else
        self.taskBox:refreshBtn()
    end
end

-- 发布任务
function BlessingTaskLayer:publishCallBack()
    -- 未发布任务
    if self.mPublishTaskInfo.TaskStatus == 0 then
        self:publishTaskBox()
    -- 可以领取／查看奖励
    else
        self:publishRewardBox()
    end
end

-- 发布任务奖励弹窗
function BlessingTaskLayer:publishRewardBox()
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 提示
        local textStr = TR("暂无其他侠客完成您发布的任务，请稍后再来查看")
        if self.mPublishTaskInfo.TaskStatus == 2 then
            textStr = TR("您的任务已经有其他侠客完成，请领取您的奖励")
        end
        local hintLabel = ui.newLabel({
            text = textStr,
            color = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(500, 0)
        })
        hintLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
        bgSprite:addChild(hintLabel)

        -- 黑背景
        local blackBg = ui.newScale9Sprite("c_17.png", cc.size(530, 160))
        blackBg:setAnchorPoint(cc.p(0.5, 0))
        blackBg:setPosition(bgSize.width*0.5, 120)
        bgSprite:addChild(blackBg)

        -- 奖励
        local rewardStrList = {}
        local rewardInfoList = Utility.analysisStrAttrList(self.mPublishTaskInfo.PublishTaskIdStr)
        for _, rewardInfo in pairs(rewardInfoList) do
            local rewardStr = self.mPublishRewardList[rewardInfo.value].Reward
            table.insert(rewardStrList, rewardStr)
        end
        local publishRewardStr = table.concat(rewardStrList, "||")
        local rewardList = Utility.analysisStrResList(publishRewardStr)
        local cardList = ui.createCardList({
            maxViewWidth = 500,
            cardDataList = rewardList,
        })
        cardList:setAnchorPoint(cc.p(0.5, 0.5))
        cardList:setPosition(bgSize.width*0.5, bgSize.height*0.5)
        bgSprite:addChild(cardList)

        -- 按钮
        local getBtn = ui.newButton({
                normalImage = "c_28.png",
                text = self.mPublishTaskInfo.TaskStatus == 2 and TR("领取") or TR("确定"),
                clickAction = function ()
                    if self.mPublishTaskInfo.TaskStatus == 2 then
                        self:requestPublishReward()
                        LayerManager.removeLayer(boxRoot)
                    else
                        LayerManager.removeLayer(boxRoot)
                    end
                end
            })
        getBtn:setPosition(bgSize.width*0.5, 60)
        bgSprite:addChild(getBtn)
    end

    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = cc.size(600, 400),
            title = TR("我发布的任务"),
            btnInfos = {},
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end

-- 发布任务弹窗
function BlessingTaskLayer:publishTaskBox()
    -- 任务选择列表
    self.mPublishTaskList = {}
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 提示
        local hintLabel = ui.newLabel({
            text = TR("选择其中%d个任务，发布任务", self.mConfigInfo.DailyPublishNum),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        hintLabel:setAnchorPoint(cc.p(0, 0))
        hintLabel:setPosition(45, bgSize.height-105)
        bgSprite:addChild(hintLabel)
        -- 黑背景
        local blackBg = ui.newScale9Sprite("c_17.png", cc.size(575, 800))
        blackBg:setAnchorPoint(cc.p(0.5, 1))
        blackBg:setPosition(bgSize.width*0.5, bgSize.height-115)
        bgSprite:addChild(blackBg)
        -- 列表
        local taskListView = ccui.ListView:create()
        taskListView:setDirection(ccui.ScrollViewDir.vertical)
        taskListView:setBounceEnabled(true)
        taskListView:setContentSize(cc.size(565, 780))
        taskListView:setItemsMargin(5)
        taskListView:setGravity(ccui.ListViewGravity.centerHorizontal)
        taskListView:setAnchorPoint(cc.p(0.5, 0.5))
        taskListView:setPosition(575/2, 800/2)
        blackBg:addChild(taskListView)
        -- 发布任务按钮
        local publishBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("发布任务"),
                position = cc.p(bgSize.width*0.5, 60),
                clickAction = function ()
                    if #(table.keys(self.mPublishTaskList)) < self.mConfigInfo.DailyPublishNum then
                        ui.showFlashView(TR("发布任务数量不足！"))
                        return
                    end
                    self:requestPublishTask()
                    LayerManager.removeLayer(boxRoot)
                end,
            })
        bgSprite:addChild(publishBtn)

        local taskIdList = table.keys(self.mTaskList)
        -- 刷新项
        local function refreshItem(index)
            local taskModel = self.mTaskList[taskIdList[index]]

            local cellSize = cc.size(taskListView:getContentSize().width, 120)

            local cellItem = taskListView:getItem(index - 1)
            if not cellItem then
                cellItem = ccui.Layout:create()
                cellItem:setContentSize(cellSize)
                taskListView:pushBackCustomItem(cellItem)
            end
            cellItem:removeAllChildren()

            local cellBg = ui.newScale9Sprite("c_18.png", cellSize)
            cellBg:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellItem:addChild(cellBg)

            local taskBg = ui.newSprite("zfrw_10.png")
            taskBg:setAnchorPoint(cc.p(0, 1))
            taskBg:setPosition(0, cellSize.height-5)
            cellItem:addChild(taskBg)

            local taskLabel = ui.newLabel({
                text = TR("任务"),
            })
            taskLabel:setAnchorPoint(cc.p(0, 0))
            taskLabel:setPosition(10, 5)
            taskBg:addChild(taskLabel)

            local descLabel = ui.newLabel({
                text = TR("完成%s%d次", ModuleSubModel.items[taskModel.TaskModuleId].name, taskModel.NeedFinishNum),
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(300, 0)
            })
            descLabel:setAnchorPoint(cc.p(0, 1))
            descLabel:setPosition(30, cellSize.height-50)
            cellItem:addChild(descLabel)

            -- 奖励
            local rewardId = self.mPublishTaskList[taskIdList[index]]
            if rewardId then
                local rewardList = Utility.analysisStrResList(self.mPublishRewardList[rewardId].Reward)
                local cardList = ui.createCardList({
                    maxViewWidth = 150,
                    cardDataList = rewardList,
                })
                cardList:setScale(0.75)
                cardList:setAnchorPoint(cc.p(0, 0.5))
                cardList:setPosition(370, cellSize.height*0.5)
                cellItem:addChild(cardList)
            end

            -- 选择
            local checkBox = ui.newCheckbox({
                    normalImage = "zfrw_8.png",
                    selectImage = "zfrw_9.png",
                    callback = function (status)
                        local selectTaskNum = #(table.keys(self.mPublishTaskList))
                        if status and selectTaskNum < self.mConfigInfo.DailyPublishNum then
                            self:createSelectRewardBox(taskIdList[index])
                        elseif status and selectTaskNum >= self.mConfigInfo.DailyPublishNum then
                            ui.showFlashView(TR("选择任务数量已达上限"))
                            self.mPublishTaskList[taskIdList[index]] = nil
                            boxRoot.refreshTaskList()
                        else
                            self.mPublishTaskList[taskIdList[index]] = nil
                            boxRoot.refreshTaskList()
                        end
                    end
                })
            checkBox:setPosition(530, cellSize.height*0.5)
            cellItem:addChild(checkBox)
            checkBox:setCheckState(self.mPublishTaskList[taskIdList[index]] and true or false)
        end

        -- 刷新列表
        boxRoot.refreshTaskList = function ()
            for i, _ in ipairs(taskIdList) do
                refreshItem(i)
            end
        end
        boxRoot.refreshTaskList()
    end

    self.publishTaskLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = cc.size(640, 1010),
            title = TR("任务列表"),
            btnInfos = {},
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end

function BlessingTaskLayer:createSelectRewardBox(taskId)
    local bgSize = cc.size(600, 400)
    local popLayer = LayerManager.addLayer({
        name = "commonLayer.PopBgLayer",
        cleanUp = false,
        data = {
            bgSize = bgSize,
            title = TR("选择奖励"),
            closeAction = function(pSender)
                self.publishTaskLayer.refreshTaskList()
                LayerManager.removeLayer(pSender)
            end,
        }
    })
    

    local popBgSprite = popLayer.mBgSprite

    -- 提示
    local hintLabel = ui.newLabel({
        text = TR("选择下列一种祝福奖励，若有玩家完成你发布的任务，则可获得奖励"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        dimensions = cc.size(500, 0)
    })
    hintLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
    popBgSprite:addChild(hintLabel)

    -- 黑背景
    local blackBg = ui.newScale9Sprite("c_17.png", cc.size(530, 240))
    blackBg:setAnchorPoint(cc.p(0.5, 0))
    blackBg:setPosition(bgSize.width*0.5, 30)
    popBgSprite:addChild(blackBg)

    -- 列表
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.horizontal)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(520, 130))
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(530/2, 240/2)
    blackBg:addChild(rewardListView)

    local hadSeleIdList = table.values(self.mPublishTaskList)

    for _, rewardInfo in pairs(self.mPublishRewardList) do
        if not table.indexof(hadSeleIdList, rewardInfo.Id) then
            local cellItem = ccui.Layout:create()
            cellItem:setContentSize(120, rewardListView:getContentSize().height)
            rewardListView:pushBackCustomItem(cellItem)

            local rewardCardInfo = Utility.analysisStrResList(rewardInfo.Reward)[1]
            rewardCardInfo.onClickCallback = function ()
                self.mPublishTaskList[taskId] = rewardInfo.Id
                self.publishTaskLayer.refreshTaskList()
                LayerManager.removeLayer(popLayer)
            end
            local cardNode = CardNode.createCardNode(rewardCardInfo)
            cardNode:setPosition(60, 70)
            cellItem:addChild(cardNode)
        end
    end
end

-- 刷新发布任务按钮
function BlessingTaskLayer:refreshPublishBtn()
    self.publishBtn:setEnabled(true)
    -- 未发布任务
    if self.mPublishTaskInfo.TaskStatus == 0 then
        self.publishBtn:setTitleText(TR("发布任务"))
    -- 已发布任务
    elseif self.mPublishTaskInfo.TaskStatus == 1 then
        self.publishBtn:setTitleText(TR("我的发布"))
    -- 可以领取奖励
    elseif self.mPublishTaskInfo.TaskStatus == 2 then
        self.publishBtn:setTitleText(TR("领取奖励"))
    -- 已领奖奖励
    elseif self.mPublishTaskInfo.TaskStatus == 3 then
        self.publishBtn:setTitleText(TR("已领取"))
        self.publishBtn:setEnabled(false)
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function BlessingTaskLayer:refreshLayer()
    -- 刷新时间
    self:refreshTime()

    -- 刷新总积分
    self.mTotalScoreLabel:setString(TR("总积分：%d", self.mBaseInfo.TotalScore))

    -- 刷新刷新次数
    self.refreshLabel:setString(TR("剩余可刷新任务个数：%d", self.mBaseInfo.TotalNum))

    -- 刷新灯
    self:refreshLightButton()

    -- 刷新发布任务按钮
    self:refreshPublishBtn()
end

-- 刷新时间
function BlessingTaskLayer:refreshTime()
    -- 刷新活动倒计时，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end

    self.mSchelTime = Utility.schedule(self, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("活动倒计时:  %s00:00:00", "#f8ea3a"))
            -- 停止倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end
        end
    end, 1.0)

    --  -- 领取奖励倒计时，开始倒计时
    -- if self.mRewardSchelTime then
    --     self:stopAction(self.mRewardSchelTime)
    --     self.mRewardSchelTime = nil
    -- end
    -- self.mRewardSchelTime = Utility.schedule(self, self.updateRewardTime, 1.0)
end

--=======================================网络请求========================================
--请求信息
function BlessingTaskLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data.Value, "祝福任务")
            -- 结束时间
            self.mEndTime = data.Value.EndTime

            -- 任务列表
            local tempList = data.Value.BlessingTaskActivityInfo.BlessingTaskConfigInfo
            for _, taskInfo in pairs(tempList) do
                self.mTaskList[taskInfo.TaskId] = taskInfo
            end

            -- 任务奖励列表
            local tempList = data.Value.BlessingTaskActivityInfo.BlessingTaskPublishRewardInfo
            for _, rewardInfo in pairs(tempList) do
                self.mPublishRewardList[rewardInfo.Id] = rewardInfo
            end

            -- 完成任务次数列表
            local completeNumInfo = Utility.analysisStrAttrList(data.Value.BlessingTaskBaseInfo.TaskFinishNumStr)
            for _, finishInfo in pairs(completeNumInfo) do
                self.mFinishNumList[finishInfo.fightattr] = finishInfo.value
            end

            -- 五个任务卡槽列表
            self.mLightTaskList = data.Value.BlessingTaskInfo

            -- 玩家发布任务信息
            self.mPublishTaskInfo = data.Value.BlessingPublishTaskInfo

            -- 祝福任务基础信息
            self.mBaseInfo = data.Value.BlessingTaskBaseInfo

            -- 祝福任务配置信息
            self.mConfigInfo = data.Value.BlessingTaskActivityInfo.BlessingTaskBaseConfigInfo

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 接受任务
function BlessingTaskLayer:requestAcceptTask(orderId)
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "AcceptTask",
        svrMethodData = {orderId},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("接受成功"))

            self.mLightTaskList = data.Value.BlessingTaskInfo
            self:refreshLightButton()
            -- 刷新页面
            self:createTaskBox(orderId)
        end
    })
end

-- 完成任务
function BlessingTaskLayer:requestTaskReward(orderId)
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "DrawTaskReward",
        svrMethodData = {orderId},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            
            -- 五个任务卡槽列表
            self.mLightTaskList = data.Value.BlessingTaskInfo
            -- 祝福任务基础信息
            self.mBaseInfo = data.Value.BlessingTaskBaseInfo
            -- 完成任务次数列表
            local completeNumInfo = Utility.analysisStrAttrList(data.Value.BlessingTaskBaseInfo.TaskFinishNumStr)
            for _, finishInfo in pairs(completeNumInfo) do
                self.mFinishNumList[finishInfo.fightattr] = finishInfo.value
            end

            self:refreshLayer()
            

            -- 刷新总积分
            -- self.mTotalScoreLabel:setString(TR("总积分：%d", self.mBaseInfo.TotalScore))
        end
    })
end

-- 刷新任务
function BlessingTaskLayer:requestRefreshTask(count)
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "Refresh",
        svrMethodData = {count},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("刷新成功"))

            self.mLightTaskList = data.Value.BlessingTaskInfo
            self:refreshLightButton()

            self.mBaseInfo.TotalNum = self.mBaseInfo.TotalNum - count
            -- 刷新刷新次数
            self.refreshLabel:setString(TR("剩余可刷新任务个数：%d", self.mBaseInfo.TotalNum))
        end
    })
end

-- 发布任务
function BlessingTaskLayer:requestPublishTask()
    local publishStrList = {}
    for taskId, rewardId in pairs(self.mPublishTaskList) do
        local publishStr = taskId.."|"..rewardId
        table.insert(publishStrList, publishStr)
    end

    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "PublishTask",
        svrMethodData = {table.concat(publishStrList, ",")},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("发布成功，请耐心等待其他侠客完成您的任务"))

            self.mPublishTaskInfo = data.Value.BlessingPublishTaskInfo
            self:refreshPublishBtn()
        end
    })
end

-- 请求发布奖励
function BlessingTaskLayer:requestPublishReward()
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "DrawPublishTaskReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self.mPublishTaskInfo = data.Value.BlessingPublishTaskInfo
            self:refreshPublishBtn()
        end
    })
end

-- 快捷接受
function BlessingTaskLayer:requestFastAccept()
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "FastAccept",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("接受成功"))

            self.mLightTaskList = data.Value.BlessingTaskInfo
            self:refreshLightButton()
        end
    })
end

-- 快捷完成
function BlessingTaskLayer:requestFastFinish()
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "FastFinish",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            
            -- 五个任务卡槽列表
            self.mLightTaskList = data.Value.BlessingTaskInfo
            -- 祝福任务基础信息 
            self.mBaseInfo = data.Value.BlessingTaskBaseInfo
            -- 完成任务次数列表
            local completeNumInfo = Utility.analysisStrAttrList(data.Value.BlessingTaskBaseInfo.TaskFinishNumStr)
            for _, finishInfo in pairs(completeNumInfo) do
                self.mFinishNumList[finishInfo.fightattr] = finishInfo.value
            end

            self:refreshLayer()
        end
    })
end

return BlessingTaskLayer