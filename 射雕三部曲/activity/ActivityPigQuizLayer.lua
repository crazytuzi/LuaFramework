--[[
	文件名：ActivityPigQuizLayer.lua
	描述：金猪赛跑竞猜页面
	创建人：yanghongsheng
	创建时间： 2019.1.22
--]]

local ActivityPigQuizLayer = class("ActivityPigRankLayer", function(params)
	return display.newLayer()
end)

function ActivityPigQuizLayer:ctor(params)
    -- 小猪投注节点
    self.mZhuItemList = {}
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 970),
        title = TR("金猪竞猜"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()

    self:requestInfo()
end

function ActivityPigQuizLayer:initUI()
    -- 提示文字
    local hintLabel = ui.newLabel({
            text = TR("点击输入想要投注的数量，选择适合的猪猪投注："),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    hintLabel:setAnchorPoint(cc.p(0, 0.5))
    hintLabel:setPosition(40, self.mBgSize.height-90)
    self.mBgSprite:addChild(hintLabel)

    -- 我投注牌
    self.mOwnResNumLabel = ui.newLabel({
            text = TR("我的投注牌：%d", 0),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mOwnResNumLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mOwnResNumLabel:setPosition(40, self.mBgSize.height-125)
    self.mBgSprite:addChild(self.mOwnResNumLabel)

    -- 黑背景
    local blackBg = ui.newScale9Sprite("c_17.png", cc.size(570, 705))
    blackBg:setAnchorPoint(cc.p(0.5, 1))
    blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-150)
    self.mBgSprite:addChild(blackBg)

    -- 竞猜倒计时
    self.mQuizTimeLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mQuizTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mQuizTimeLabel:setPosition(40, 60)
    self.mBgSprite:addChild(self.mQuizTimeLabel)

    -- 我的下注
    local ownQuizBtn = ui.newButton({
            normalImage = "tb_202.png", 
            clickAction = function ()
                self:createLogBox()
            end
        })
    ownQuizBtn:setPosition(500, 70)
    self.mBgSprite:addChild(ownQuizBtn)
end

function ActivityPigQuizLayer:createZhuItem(order)
    -- 小猪特效
    local zhuEffectList = {
        "hero_heizhu",
        "hero_baizhu",
        "hero_fenzhu",
        "hero_huazhu",
    }
    -- 位置列表
    local itemPosList = {
        cc.p(175, 650),
        cc.p(455, 650),
        cc.p(175, 290),
        cc.p(455, 290),
    }
    if not self.mZhuItemList[order] then
        -- 背景板
        local bgSprite = ui.newSprite("jzsp_13.png")
        bgSprite:setPosition(itemPosList[order])
        self.mBgSprite:addChild(bgSprite)
        -- 存入列表
        self.mZhuItemList[order] = bgSprite
        local bgSize = bgSprite:getContentSize()
        -- 创建小猪
        local zhuEffect = ui.newEffect({
            parent = bgSprite,
            effectName = zhuEffectList[order],
            position = cc.p(bgSize.width*0.5+20, 200),
            loop = true,
        })
        zhuEffect:setRotationSkewY(180)
        zhuEffect:setAnimation(0, "daiji", true)
        -- 创建赔率
        local quizLabel = ui.newLabel({
                text = TR("赔率：%s : %s", self.mPigConfig.FailureOdds, self.mPigConfig.VictoryOdds),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
        quizLabel:setPosition(bgSize.width*0.5, 150)
        bgSprite:addChild(quizLabel)
        -- 输入框
        local editBox = ui.newEditBox({
            image = "c_83.png",
            size = cc.size(100, 32),
            fontSize = 22,
            fontColor = cc.c3b(0x46, 0x22, 0x0d),
            placeColor = cc.c3b(255, 102, 243),
        })
        editBox:setPosition(bgSize.width*0.5, 115)
        editBox:setPlaceHolder(TR("输入数量"))
        bgSprite:addChild(editBox)
        bgSprite.editBox = editBox
        -- 投注按钮
        local quizBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("投注"),
                clickAction = function ()
                    local editStr = editBox:getText()
                    if editStr == "" or string.match(editStr, "%D") or tonumber(editStr) <= 0 then
                        ui.showFlashView(TR("请输入正整数"))
                        editBox:setText("")
                        return
                    end
                    local num = tonumber(editStr)
                    local ownNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, self.mPigConfig.GoodsModelId)
                    if ownNum < num then
                        ui.showFlashView(TR("%s不足", Utility.getGoodsName(ResourcetypeSub.eFunctionProps, self.mPigConfig.GoodsModelId)))
                        editBox:setText("")
                        return
                    end

                    -- 上限
                    if num > self.mPigConfig.QuizMaxNum then
                    	ui.showFlashView(TR("投注上限为%s，不能超过投注上限", self.mPigConfig.QuizMaxNum))
                    	editBox:setText("")
                    	return
                    end

                    self:requestQuiz(order, num)
                end
            })
        quizBtn:setPosition(bgSize.width*0.5, 45)
        bgSprite:addChild(quizBtn)
        bgSprite.quizBtn = quizBtn

        -- 刷新
        self.mZhuItemList[order].refreshItem = function (target)
            local quizSartTime = self.mPigAllData.NowTurnStartTime
            local lastQuizInfo = self.mQuizInfoList[#self.mQuizInfoList]
            local lastQuizTime = lastQuizInfo and lastQuizInfo.StartTime or 0
            -- 不在竞猜时间或已押注
            if self:getStatus() ~= 1 or quizSartTime == lastQuizTime then
                target.quizBtn:setEnabled(false)
                target.editBox:setEnabled(false)
                target.editBox:setText("0")
                if quizSartTime == lastQuizTime then
                    target.editBox:setText(lastQuizInfo and lastQuizInfo.QuizNum == order and lastQuizInfo.QuizScore or "0")
                end
            else
                target.editBox:setText("")
                target.quizBtn:setEnabled(true)
                target.editBox:setEnabled(true)
            end
        end
    end

    self.mZhuItemList[order]:refreshItem()
end

-- 创建竞猜倒计时
function ActivityPigQuizLayer:createQuizTimeUpdate()
    if self.mQuizTimeLabel.timeUpdate then
        self.mQuizTimeLabel:stopAction(self.mQuizTimeLabel.timeUpdate)
        self.mQuizTimeLabel.timeUpdate = nil
    end

    self.mQuizTimeLabel.timeUpdate = Utility.schedule(self.mQuizTimeLabel, function ()
        local timeLeft = self.mPigAllData.NowTurnStartTime+self.mPigAllData.TimedPigRunningConfig.QuizTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mQuizTimeLabel:setString(TR("竞猜结束倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mQuizTimeLabel:stopAction(self.mQuizTimeLabel.timeUpdate)
            self.mQuizTimeLabel.timeUpdate = nil
            self.mQuizTimeLabel:setString(TR("竞猜已结束"))
            -- 刷新状态
            self:refreshUI()
        end
    end, 1)
end

-- 判断当前时间是否在比赛时间段内
function ActivityPigQuizLayer.isMatchTime(startTimeStr, endTimeStr)
    -- timeStr转化成秒
    local function exchangeSecond(timeStr)
        local timeList = string.splitBySep(timeStr or "", ":")
        local secondSum = 0
        for i, time in ipairs(timeList) do
            if i == 1 then
                secondSum = secondSum + tonumber(time)*60*60
            elseif i == 2 then
                secondSum = secondSum+tonumber(time)*60
            elseif i == 3 then
                secondSum = secondSum+tonumber(time)
            end
        end
        return secondSum
    end
    local startTime = exchangeSecond(startTimeStr)
    local endTime = exchangeSecond(endTimeStr)
    -- 当前小时转成秒
    local curDate = MqTime.getLocalDate()
    local curSecond = curDate.hour*60*60+curDate.month*60+curDate.sec

    return curSecond >= startTime and curSecond < endTime
end

-- 我的竞猜记录
function ActivityPigQuizLayer:createLogBox()
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 累计获得积分
        local allScoreLabel = ui.newLabel({
                text = TR("累计获得积分：%s", self.mPigAllData.TimedPigRunningInfo.TotalScore),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
        allScoreLabel:setAnchorPoint(cc.p(0, 0.5))
        allScoreLabel:setPosition(40, 60)
        bgSprite:addChild(allScoreLabel)
        -- 列表
        local logListView = ccui.ListView:create()
        logListView:setDirection(ccui.ScrollViewDir.vertical)
        logListView:setBounceEnabled(true)
        logListView:setContentSize(cc.size(bgSize.width*0.9-10, bgSize.height-180))
        logListView:setItemsMargin(5)
        logListView:setGravity(ccui.ListViewGravity.centerHorizontal)
        logListView:setAnchorPoint(cc.p(0.5, 0))
        logListView:setPosition(bgSize.width*0.5, 105)
        bgSprite:addChild(logListView)
        -- 创建项
        local function createItem(quizInfo)
            local cellSize = cc.size(logListView:getContentSize().width, 120)
            local cellItem = ccui.Layout:create()
            cellItem:setContentSize(cellSize)
            logListView:pushBackCustomItem(cellItem)
            -- 背景
            local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
            bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellItem:addChild(bgSprite)
            -- 下注时间
            local curDate = MqTime.getLocalDate(quizInfo.StartTime)
            local timeLabel = ui.newLabel({
                    text = TR("下注轮次时间：%s-%s-%s %02d:%02d:%02d", curDate.year, curDate.month, curDate.day, curDate.hour, curDate.min, curDate.sec),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                })
            timeLabel:setPosition(cellSize.width*0.5, cellSize.height-40)
            cellItem:addChild(timeLabel)
            -- 竞猜是否成功
            local textStr = ""
            if quizInfo.StartTime == self.mPigAllData.NowTurnStartTime then
                textStr = TR("正在比赛中")
            elseif quizInfo.IfSuccess then
                textStr = TR("竞猜成功")
            else
                textStr = TR("竞猜失败")
            end
            local timeLabel = ui.newLabel({
                    text = textStr,
                    color = quizInfo.IfSuccess and Enums.Color.eNormalGreen or Enums.Color.eRed,
                })
            timeLabel:setAnchorPoint(cc.p(0, 0.5))
            timeLabel:setPosition(50, 40)
            cellItem:addChild(timeLabel)
            -- 赔率
            local timeLabel = ui.newLabel({
                    text = TR("赔率%s:%s", self.mPigConfig.FailureOdds, self.mPigConfig.VictoryOdds),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                })
            timeLabel:setAnchorPoint(cc.p(0, 0.5))
            timeLabel:setPosition(200, 40)
            cellItem:addChild(timeLabel)
            -- 获得积分
            local textStr = ""
            if quizInfo.StartTime == self.mPigAllData.NowTurnStartTime then
                textStr = TR("下注：{db_50505.png}#37ff40%s", quizInfo.QuizScore)
            elseif quizInfo.IfSuccess then
                textStr = TR("获取积分：#37ff40%s", quizInfo.QuizScore*self.mPigConfig.VictoryOdds)
            else
                textStr = TR("获取积分：#37ff40%s", quizInfo.QuizScore*self.mPigConfig.FailureOdds)
            end
            local timeLabel = ui.newLabel({
                    text = textStr,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                })
            timeLabel:setAnchorPoint(cc.p(0, 0.5))
            timeLabel:setPosition(350, 40)
            cellItem:addChild(timeLabel)
        end

        if next(self.mQuizInfoList) then
            for _, quizInfo in  ipairs(self.mQuizInfoList) do
                createItem(quizInfo)
            end
        else
            local emptyHint = ui.createEmptyHint(TR("您还没有参与竞猜"))
            emptyHint:setPosition(bgSize.width*0.5, bgSize.height*0.5)
            bgSprite:addChild(emptyHint)
        end
    end
    LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            cleanUp = false,
            data = {
                bgSize = cc.size(600, 700),
                title = TR("我的竞猜"),
                DIYUiCallback = DIYfunc,
                closeBtnInfo = {},
                btnInfos = {},
            }
        })
end

-- 获取当前状态
function ActivityPigQuizLayer:getStatus()
    local status = 0
    -- 不在两段比赛时间段内
    if not self.isMatchTime(self.mPigAllData.TimedPigRunningConfig.StartTimeOne, self.mPigAllData.TimedPigRunningConfig.EndTimeOne) and
        not self.isMatchTime(self.mPigAllData.TimedPigRunningConfig.StartTimeTwo, self.mPigAllData.TimedPigRunningConfig.EndTimeTwo) then

        return status
    end
    -- 竞猜结束时间
    local quizEndTime = self.mPigAllData.NowTurnStartTime + self.mPigAllData.TimedPigRunningConfig.QuizTime
    status = 1
    -- 在竞猜时间内
    if Player:getCurrentTime() < quizEndTime then
        return status
    end
    -- 赛跑结束时间
    local runEndTime = self.mPigAllData.NowTurnStartTime + self.mPigAllData.TimedPigRunningConfig.QuizTime + self.mPigAllData.TimedPigRunningConfig.GameTime
    status = 2
    -- 赛跑时间段内
    if Player:getCurrentTime() < runEndTime then
        return status
    end

    return status
end

-- 刷新投注
function ActivityPigQuizLayer:refreshZhuItem()
    for i = 1, 4 do
        self:createZhuItem(i)
    end
end

-- 刷新界面
function ActivityPigQuizLayer:refreshUI()
    self:refreshZhuItem()
    self.mOwnResNumLabel:setString(TR("我的投注牌：{db_50505.png}%d", Utility.numberWithUnit(Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, self.mPigConfig.GoodsModelId))))
    -- 创建竞猜倒计时
    if self:getStatus() == 1 then
        self:createQuizTimeUpdate()
    else
        self.mQuizTimeLabel:setString(TR("竞猜已结束"))
    end
end

--=========================服务器相关============================
-- 请求数据
function ActivityPigQuizLayer:requestInfo()
    HttpClient:request({
        moduleName = "TimedPigRunning",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            dump(response.Value)
            self.mPigAllData = response.Value
            self.mPigConfig = self.mPigAllData.TimedPigRunningConfig
            -- 押注信息
            self.mQuizInfoList = self.mPigAllData.TimedPigRunningQuizInfo
            table.sort(self.mQuizInfoList, function (quizInfo1, quizInfo2)
                return quizInfo1.StartTime < quizInfo2.StartTime
            end)


            self:refreshUI()
        end
    })
end

-- 请求投注
function ActivityPigQuizLayer:requestQuiz(order, num)
    HttpClient:request({
        moduleName = "TimedPigRunning",
        methodName = "Quiz",
        svrMethodData = {order, num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            self.mPigAllData.TimedPigRunningQuizInfo = response.Value.TimedPigRunningQuizInfo
            -- 押注信息
            self.mQuizInfoList = self.mPigAllData.TimedPigRunningQuizInfo
            table.sort(self.mQuizInfoList, function (quizInfo1, quizInfo2)
                return quizInfo1.StartTime < quizInfo2.StartTime
            end)

            self:refreshUI()
        end
    })
end

return ActivityPigQuizLayer