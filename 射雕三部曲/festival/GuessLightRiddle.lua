--[[
    文件名: GuessLightRiddle.lua
    描述: 国庆活动——铸倚天
    创建人: lengjiazhi
    创建时间: 2017.09.22
-- ]]
local GuessLightRiddle = class("GuessLightRiddle", function (params)
    return display.newLayer()
end)

function GuessLightRiddle:ctor()

    ui.registerSwallowTouch({node = self})
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initUI()
    self:createAnswerBtns()
    self:createBottomView()
    self:requestGetInfo()
end

function GuessLightRiddle:initUI()
    --背景图
    local bgSprite = ui.newSprite("jrhd_88.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1035),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(55, 1035),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.活动期间晚上8点-10点，开启猜灯谜。"),
                TR("2.猜灯谜开启后，点击灯笼开始猜灯谜，同时开启倒计时，答完一道题后点击其他灯笼选择下一道题，结算一定时间内的答对题数。"),
                TR("3.每答对一道题就能获得一种神秘奖励。"),
                TR("4.一定时间内答对的题越多，排行越高，更有机会获得排名奖励。"),
                TR("5.遇见不会回答的问题记得选择跳过哦！选择跳过以后不会获得任何奖励。"),
                TR("6.答案需要填入ABCD后面的选项"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn)

    --倒计时背景
    local timeBgSprite = ui.newSprite("jrhd_91.png")
    timeBgSprite:setPosition(534, 600)
    self.mParentLayer:addChild(timeBgSprite)

    --本轮倒计时
    local todayEndLabel = ui.newLabel({
        text = TR("答题倒计时:#ff72000%s秒", Enums.Color.eNormalWhiteH),
        size = 18,
        })
    todayEndLabel:setAnchorPoint(0, 0.5)
    todayEndLabel:setPosition(460, 610)
    self.mParentLayer:addChild(todayEndLabel)
    self.mTodayEndLabel = todayEndLabel

    --正确回答数量
    local answerNumLabel = ui.newLabel({
        text = TR("正确回答数:#ffea000"),
        size = 18,
        })
    answerNumLabel:setAnchorPoint(0, 0.5)
    answerNumLabel:setPosition(460, 585)
    self.mParentLayer:addChild(answerNumLabel)
    self.mAnswerNumLabel = answerNumLabel

    --活动倒计时
    local activityEndLabel = ui.newLabel({
        text = TR("活动结束倒计时:%s10天00:00:00", Enums.Color.eGreenH),
        size = 20,
        outlineColor = Enums.Color.eOutlineColor,
        })
    activityEndLabel:setAnchorPoint(0, 0.5)
    activityEndLabel:setPosition(6, 570)
    self.mParentLayer:addChild(activityEndLabel)
    self.mActivityEndLabel = activityEndLabel

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)
end

-- 更新时间
function GuessLightRiddle:updateTime()
    local timeLeft = self.mActivityEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mActivityEndLabel:setString(TR("活动结束倒计时:%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mActivityEndLabel:setString(TR("活动结束倒计时:%s 00:00:00", Enums.Color.eGreenH))        
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        LayerManager.removeLayer(self)
    end
end

--答题倒计时更新
function GuessLightRiddle:updateAnswerTime()
    local timeLeftToday = self.mEndTime - Player:getCurrentTime()
    if timeLeftToday > 0 then
        self.mTodayEndLabel:setString(TR("答题倒计时:#ff7200%s%s秒", timeLeftToday, Enums.Color.eNormalWhiteH))
        if not tolua.isnull(self.mAnswerTime) then
            self.mAnswerTime:setString(TR("%s%s秒", timeLeftToday, Enums.Color.eBlackH))
        end
    else
        -- 停止倒计时
        if self.mAnswerSchel then
            self:stopAction(self.mAnswerSchel)
            self.mAnswerSchel = nil
        end
        self.mTodayEndLabel:setString(TR("答题倒计时:#ff7200%s%s秒", 0, Enums.Color.eNormalWhiteH))
        -- self:requestGetInfo()
        ui.showFlashView(TR("答题时间到"))
        if self.mBlackBg then
            self.mAnswerTime:setString(TR("%s%s秒", 0, Enums.Color.eBlackH))
            self.mBlackBg:removeFromParent()
            self.mBlackBg = nil
        end
    end
end


--创建答题按钮
function GuessLightRiddle:createAnswerBtns()
    self.mLightBtns = {}
    for i = 1, 8 do
        self:createOneLight(i)
    end
end
--创建单个按钮
function GuessLightRiddle:createOneLight(index)

    local randOffset = math.random(-1, 1) --上下随机浮动
    local startPosX = (index-1)*110
    local startPosY = index%2 == 0 and 862 or 700
    local lightBtn = ui.newButton({
            normalImage = "jrhd_89.png",
            clickAction = function()
                self:requestGetTopic()
            end
        })
    lightBtn:setPosition(startPosX, startPosY)
    self.mParentLayer:addChild(lightBtn)

    --循环移动
    local move = cc.MoveBy:create(0.05, cc.p(-3, 0))
    local callFun = cc.CallFunc:create(function(pSender)
        local curPosx, curPosy = pSender:getPosition()
        local randOffset = math.random(-1, 1)
        local startPosY = index%2 == 0 and 862 or 700

        if curPosx < -110 then
            pSender:setPosition(curPosx + 860, startPosY)
        end 
    end)
    local sq = cc.RepeatForever:create(cc.Sequence:create(move, callFun)) 
    lightBtn:runAction(sq)
end

--创建下方底板
function GuessLightRiddle:createBottomView()
    --下方背景板
    local bgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 560))
    bgSprite:setAnchorPoint(0.5, 0)
    bgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(bgSprite)
    
    --灰色底板
    local garySprite = ui.newScale9Sprite("c_17.png", cc.size(604, 350))
    garySprite:setPosition(320, 335)
    self.mParentLayer:addChild(garySprite)
    
    --个人信息底板
    local myInfoBgSprite = ui.newScale9Sprite("c_17.png", cc.size(650, 40))
    myInfoBgSprite:setPosition(320, 120)
    self.mParentLayer:addChild(myInfoBgSprite)

   --下方排行榜
    local rankListView = ccui.ListView:create()
    rankListView:setDirection(ccui.ScrollViewDir.vertical)
    rankListView:setBounceEnabled(true)
    rankListView:setContentSize(cc.size(600, 330))
    rankListView:setItemsMargin(5)
    rankListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rankListView:setAnchorPoint(cc.p(0.5, 0))
    rankListView:setPosition(320, 170)
    self.mParentLayer:addChild(rankListView)
    self.mRankListView = rankListView
end

--创建数据显示
function GuessLightRiddle:createInfoView()
    local myRankLabel = ui.newLabel({
        text = TR("我的排名：%s%s", Enums.Color.eRedH, self.mMyRank == 0 and TR("未上榜") or self.mMyRank),
        size = 21,
        outlineColor = cc.c3b(0x1e, 0x1e, 0x53),
    })
    myRankLabel:setAnchorPoint(0, 0.5)
    myRankLabel:setPosition(40, 120)
    self.mParentLayer:addChild(myRankLabel)
    self.mMyRankLabel = myRankLabel

    local myScoreLabel = ui.newLabel({
        text = TR("答对的题数：%s%s", Enums.Color.eGreenH, self.mAnswerNum),
        size = 21,
        outlineColor = cc.c3b(0x1e, 0x1e, 0x53),
    })
    myScoreLabel:setAnchorPoint(0, 0.5)
    myScoreLabel:setPosition(392, 120)
    self.mParentLayer:addChild(myScoreLabel)
    self.mMyScoreLabel = myScoreLabel

    --活动倒计时
    local startTimeLabel = ui.newLabel({
        text = TR("活动开启时间:%s~%s", self.mStartDate, self.mEndDate),
        size = 20,
        outlineColor = Enums.Color.eOutlineColor,
        })
    startTimeLabel:setAnchorPoint(0, 0.5)
    startTimeLabel:setPosition(6, 595)
    self.mParentLayer:addChild(startTimeLabel)
    -- self.mstartTimeLabel = startTimeLabel

    self.mAnswerNumLabel:setString(TR("正确回答数:#ffea00%s", self.mAnswerNum))
end

--创建答题弹窗
function GuessLightRiddle:createBoxPop(info)
    --黑底
    local blackBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    blackBg:setContentSize(640, 1136)
    blackBg:setPosition(0, 0)
    self.mParentLayer:addChild(blackBg)
    self.mBlackBg = blackBg

     -- 注册屏蔽下层页面事件
    ui.registerSwallowTouch({
        node = blackBg,
        allowTouch = true,
    })

    -- 背景
    local bgSprite = ui.newSprite("jrhd_90.png")
    local bgSize = bgSprite:getContentSize()
    bgSprite:setPosition(320, 668)
    blackBg:addChild(bgSprite)

    -- 问题label
    local quesionLabel = ui.newLabel({
        text = info.Content,
        color = Enums.Color.eBlack,
        size = 22,
        dimensions = cc.size(bgSize.width*0.8, 0),
        x = 80,
        y = bgSize.height - 130
        })
    quesionLabel:setAnchorPoint(cc.p(0, 0.5))
    bgSprite:addChild(quesionLabel)

    -- 提示label
    local tipLabel = ui.newLabel({
        text = TR("点击下方输入答案："),
        color = Enums.Color.eBlack,
        size = 18,
        x = 80,
        y = bgSize.height - 190
        })
    tipLabel:setAnchorPoint(cc.p(0, 0.5))
    bgSprite:addChild(tipLabel)

    --答题框
    local editBox = ui.newEditBox({
        image = "bsxy_10.png",
        size = cc.size(500, 45),
        fontSize = 26,
        fontColor = Enums.Color.eNormalWhite,
    })
    editBox:setPosition(cc.p(bgSize.width * 0.5 + 10, bgSize.height * 0.30 + 10))
    editBox:setPlaceHolder(TR("点击输入答案"))
    bgSprite:addChild(editBox)

    --答题按钮
    local answerBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        clickAction = function ()
            local inputText = editBox:getText()
            self:requestQuiz(inputText)
            self.mBlackBg:removeFromParent()
            self.mBlackBg = nil
        end
        })
    answerBtn:setPosition(bgSize.width * 0.5 + 10, bgSize.height * 0.15)
    bgSprite:addChild(answerBtn)

    --取消按钮
    local answerBtn = ui.newButton({
        normalImage = "jrhd_92.png",
        -- text = TR("跳过"),
        clickAction = function ( )
            self.mBlackBg:removeFromParent()
            self.mBlackBg = nil
        end
        })
    answerBtn:setPosition(bgSize.width * 0.92, bgSize.height * 0.82)
    bgSprite:addChild(answerBtn)

    local answerTime = ui.newLabel({
        text = TR("%s%s秒", 300, Enums.Color.eBlackH),
        color = Enums.Color.eRed,
        size = 20,
        })
    answerTime:setPosition(bgSize.width * 0.90, bgSize.height - 190)
    bgSprite:addChild(answerTime)
    self.mAnswerTime = answerTime

    if self.mIsDoing then
        if self.mAnswerSchel then
            self:stopAction(self.mAnswerSchel)
            self.mAnswerSchel = nil
        end
        self:updateAnswerTime()
        self.mAnswerSchel = Utility.schedule(self, self.updateAnswerTime, 1.0)
    end
end

--刷新排行榜
function GuessLightRiddle:refreshRankView()
    self.mRankListView:removeAllChildren()

    for i,v in ipairs(self.mDailyRank) do
        local layout = ccui.Layout:create()
        layout:setContentSize(600, 124)

        --背景图
        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(590, 124))
        bgSprite:setPosition(300, 62)
        layout:addChild(bgSprite)

        -- 排名
        local rankLabel = ui.createLabelWithBg({
            bgFilename = "c_47.png",
            labelStr = v.Rank,
            fontSize = 20,
            alignType = ui.TEXT_ALIGN_CENTER,
            outlineColor = Enums.Color.eBlack,
            -- offset = -5,
        })

        rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
        rankLabel:setPosition(cc.p(60, 65))
        layout:addChild(rankLabel)

        if v.Rank <= 3 then
            local picName = nil
            if v.Rank == 1 then
                picName = "c_44.png"
            elseif v.Rank == 2 then
                picName = "c_45.png"
            elseif  v.Rank == 3 then
                picName = "c_46.png"
            end

            local spr = ui.newSprite(picName)
            spr:setAnchorPoint(cc.p(0.5, 0.5))
            spr:setPosition(rankLabel:getPosition())
            layout:addChild(spr)
            -- spr:setScale(0.6)

            rankLabel:setVisible(false)
        end
        if v.PlayerId == EMPTY_ENTITY_ID then
            --暂无提示
            local tipsLabel = ui.newLabel({
                text = TR("暂无"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 25,
                })
            tipsLabel:setAnchorPoint(0, 0.5)
            tipsLabel:setPosition(120, 65)
            layout:addChild(tipsLabel)

        else
            --头像
            local headCard = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = v.HeadImageId, 
                IllusionModelId = v.IllusionModelId,
                cardShowAttrs = {CardShowAttr.eBorder},
                allowClick = false,
            })
            headCard:setPosition(160, 65)
            layout:addChild(headCard)

            --名字
            local nameLabel = ui.newLabel({
                text = v.PlayerName,
                color = cc.c3b(0xd1,0x7b, 0x00),
                size = 22,
                -- outlineColor = Enums.Color.eBlack
                })
            nameLabel:setAnchorPoint(0, 0.5)
            nameLabel:setPosition(220, 95)
            layout:addChild(nameLabel)

            --积分
            local scoreLabel = ui.newLabel({
                text = TR("答对题数：#249029%s", v.Num),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 21,
                })
            scoreLabel:setAnchorPoint(0, 0.5)
            scoreLabel:setPosition(220, 35)
            layout:addChild(scoreLabel)

       end

        local rewardList = Utility.analysisStrResList(v.Reward)
        for i,v in ipairs(rewardList) do
            v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        end
        local cardList = ui.createCardList({
                maxViewWidth = 210  , -- 显示的最大宽度
                viewHeight = 100, -- 显示的高度，默认为120
                space = 3, -- 卡牌之间的间距, 默认为 10
                cardDataList = rewardList
            })
        cardList:setAnchorPoint(0, 0.5)
        cardList:setPosition(365, 62)
        layout:addChild(cardList)

        self.mRankListView:pushBackCustomItem(layout)
    end
end

--刷新积分数据
function GuessLightRiddle:refreshScore()
    self.mMyRankLabel:setString(TR("我的排名：%s%s", Enums.Color.eRedH, self.mMyRank == 0 and TR("未上榜") or self.mMyRank))
    self.mMyScoreLabel:setString(TR("答对的题数：%s%s", Enums.Color.eGreenH, self.mAnswerNum))
    self.mAnswerNumLabel:setString(TR("正确回答数:#ffea00%s", self.mAnswerNum))
end
--=======================================网络请求========================================
--请求信息
function GuessLightRiddle:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedQuiz", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "ReceiveReward")
            self.mIsDoing = data.Value.IsDoing
            self.mDailyRank = data.Value.Rank
            self.mAnswerNum = data.Value.Num
            self.mActivityEndTime = data.Value.ActivityEndTime
            self.mEndTime = data.Value.EndTime
            self.mMyRank = data.Value.MyRank
            self.mStartDate = data.Value.StartDate
            self.mEndDate = data.Value.EndDate

            self:createInfoView()
            self:refreshRankView()

            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end
            self:updateTime()
            self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

            if self.mIsDoing then
                if self.mAnswerSchel then
                    self:stopAction(self.mAnswerSchel)
                    self.mAnswerSchel = nil
                end
                self:updateAnswerTime()
                self.mAnswerSchel = Utility.schedule(self, self.updateAnswerTime, 1.0)
            end
        end
    })
end

--请求题目
function GuessLightRiddle:requestGetTopic()
    HttpClient:request({
        moduleName = "TimedQuiz", 
        methodName = "GetTopic",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            self.mIsDoing = true
            self.mEndTime = data.Value.EndTime

            self:createBoxPop(data.Value)
        end
    })
end

--答题
function GuessLightRiddle:requestQuiz(answer)
    HttpClient:request({
        moduleName = "TimedQuiz", 
        methodName = "Quiz",
        svrMethodData = {answer},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            self.mIsDoing = data.Value.IsDoing
            self.mAnswerNum = data.Value.Num
            self.mDailyRank = data.Value.Rank
            self.mMyRank = data.Value.MyRank
            self:refreshRankView()
            self:refreshScore()

            if not data.Value.BaseGetGameResourceList then
                ui.showFlashView(TR("很抱歉您答错了"))
            else
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList, true)
            end
        end
    })
end

return GuessLightRiddle