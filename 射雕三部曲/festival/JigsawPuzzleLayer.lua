--[[
    文件名: JigsawPuzzleLayer.lua
	描述: 新拼图活动
	创建人: lengjiazhi
	创建时间: 2017.12.28
-- ]]
local JigsawPuzzleLayer = class("JigsawPuzzleLayer", function (params)
	return display.newLayer()
end)

function JigsawPuzzleLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    self.mTouchSwallowLayer = ui.newStdLayer()
    self:addChild(self.mTouchSwallowLayer)

    self.mTouchNode = ui.registerSwallowTouch({
        node = self.mTouchSwallowLayer,
        allowTouch = true,
        })

	self:initUI()
	self:requestGetInfo()
end

function JigsawPuzzleLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("pt_01.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

    -- 顶部状态栏
    local topBgSize = cc.size(660, 100)
    local topBgSprite = ui.newScale9Sprite("bp_22.png", topBgSize)
    topBgSprite:setAnchorPoint(cc.p(0.5, 1))
    topBgSprite:setPosition(320, 1136)
    self.mTouchSwallowLayer:addChild(topBgSprite)
    self.mTopBgSprite = topBgSprite
    self.mTopBgSize = topBgSize

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1085),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mTouchSwallowLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(40, 1085),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.每日获得一张被打乱的拼图，点击开始拼图，开始拼图和计时。"),
                [2] = TR("2.滑动碎片进行移动，将所有碎片移动到正确的位置时，结算拼图移动步数、时间、并进行排行和发奖。"),
                [3] = TR("3.点击一键拼图，直接拼好图片获得奖励，但是成绩不计入排行榜。"),
                [4] = TR("4.每日排行榜根据拼图移动步数和完成时间排名，总榜根据拼图移动步数、完成时间、拼图完成数进行排名。"),
                [5] = TR("5.每天的最后5分钟为结算期，期间只能进行一键拼图。"),
        	})
        end})
    self.mTouchSwallowLayer:addChild(ruleBtn, 1)

    -- 设置规则按钮
    local perViewBtn = ui.newButton({
        normalImage = "c_79.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(105, 1085),
        clickAction = function()
            self:createPreviewPop()
        end})
    self.mTouchSwallowLayer:addChild(perViewBtn, 1)

    --排行榜
    local rankBtn = ui.newButton({
        normalImage = "tb_16.png",
        clickAction = function ()
            LayerManager.addLayer({
                name = "festival.JigsawPuzzleRankLayer",
                })
        end
        })
    rankBtn:setPosition(578, 990)
    self.mTouchSwallowLayer:addChild(rankBtn)

    --一键还原按钮
    local oneKeyBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("一键拼图"),
        clickAction = function ()
            self:SureView()
        end
        })
    oneKeyBtn:setPosition(545, 695)
    self.mTouchSwallowLayer:addChild(oneKeyBtn)
    self.mOneKeyBtn = oneKeyBtn

    local oneKeyPrice = ui.newLabel({
        text = string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.eDiamond), 2000),
        size = 22,
        outlineColor = Enums.Color.eOutlineColor
        })
    oneKeyPrice:setPosition(545, 650)
    self.mTouchSwallowLayer:addChild(oneKeyPrice)
    self.mOneKeyPrice = oneKeyPrice

    --开始拼图按钮
    local startBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("开始拼图"),
        clickAction = function()
            self:requestStart()
        end
        })
    startBtn:setPosition(545, 588)
    self.mTouchSwallowLayer:addChild(startBtn)
    self.mStartBtn = startBtn

    -- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 530))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 0)
    self.mParentLayer:addChild(self.mBottomBg)

    self.mUnderSprite = ui.newScale9Sprite("c_17.png", cc.size(616, 400))
    self.mUnderSprite:setPosition(320, 250)
    self.mTouchSwallowLayer:addChild(self.mUnderSprite)


    --倒计时背景
    local timeBgSprite = ui.newScale9Sprite("c_25.png", cc.size(630, 45))
    timeBgSprite:setPosition(320, 475)
    self.mParentLayer:addChild(timeBgSprite)

    --活动倒计时
    local timeLabel = ui.newLabel({
        text = TR("活动倒计时：00:00:00"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        })
    timeLabel:setPosition(50, 475)
    timeLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    --每日倒计时
    local dailytimeLabel = ui.newLabel({
        text = TR("每日倒计时：00:00:00"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        })
    dailytimeLabel:setPosition(380, 475)
    dailytimeLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(dailytimeLabel)
    self.mDailyTimeLabel = dailytimeLabel

    -- 创建ListView视图
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(600, 380))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(308, 390)
    self.mUnderSprite:addChild(self.mListView)

    self.mRewardListView = rewardListView

    --拼图背景图
    local bgSprite = ui.newSprite("pt_19.png")
    bgSprite:setPosition(235, 770)
    self.mParentLayer:addChild(bgSprite)
    self.mJigsawBgSprite = bgSprite

    self:createGameInfoView()
end

-- 创建预览框
function JigsawPuzzleLayer:createPreviewPop()
    if not self.mPerReward then return end

    -- 项数据表
    local itemsData = {}
    -- 构造数据
    for i, resoureStr in pairs(self.mPerReward) do
        local item = {}
        item.resourceList = Utility.analysisStrResList(resoureStr.Reward)
        item.title = TR("第")..i..TR("张奖励")

        table.insert(itemsData, item)
    end

    LayerManager.addLayer({
            name = "festival.RewardPreviewPopLayer",
            data = {title = TR("奖励预览"), itemsData = itemsData},
            cleanUp = false,
        })
end

--创建右边拼图进度信息
function JigsawPuzzleLayer:createGameInfoView()
    --时间
    local timeSprite = ui.newSprite("pt_18.png")
    timeSprite:setPosition(545, 905)
    self.mParentLayer:addChild(timeSprite)
    --进度计时
    local countingTimeLabel = ui.newLabel({
        text = "00:00:00",
        color = Enums.Color.eGreen,
        outlineColor = Enums.Color.eOutlineColor,
        size = 22,
        })
    countingTimeLabel:setPosition(545, 850)
    self.mParentLayer:addChild(countingTimeLabel)
    self.mCountingTimeLabel = countingTimeLabel

    --步数
    local moveCountSprite = ui.newSprite("pt_17.png")
    moveCountSprite:setPosition(545, 790)
    self.mParentLayer:addChild(moveCountSprite)

    --步数数字
    local moveCountLabel = ui.newLabel({
        text = "0",
        color = Enums.Color.eGold,
        outlineColor = Enums.Color.eOutlineColor,
        size = 30,
        })
    moveCountLabel:setPosition(545, 740)
    self.mParentLayer:addChild(moveCountLabel)
    self.mMoveCountLabel = moveCountLabel

    local bgBottom = ui.newScale9Sprite("c_17.png", cc.size(650, 40))
    bgBottom:setPosition(320, 20)
    self.mParentLayer:addChild(bgBottom)

    local myRankLabel = ui.newLabel({
        text = TR("我的排名：%s%s", Enums.Color.eRedH, 0),
        outlineColor = Enums.Color.eOutlineColor,
        size = 22,
        })
    myRankLabel:setAnchorPoint(0, 0.5)
    myRankLabel:setPosition(55, 20)
    self.mParentLayer:addChild(myRankLabel)
    self.mMyRankLabel = myRankLabel

    local myMoveCount = ui.newLabel({
        text = TR("步数：%s%s", Enums.Color.eGoldH, 0),
        outlineColor = Enums.Color.eOutlineColor,
        size = 22,
        })
    myMoveCount:setAnchorPoint(0, 0.5)
    myMoveCount:setPosition(280, 20)
    self.mParentLayer:addChild(myMoveCount)
    self.mMyMoveCount = myMoveCount

    local myTimeCount = ui.newLabel({
        text = TR("时间：%s%s", Enums.Color.eGreenH, "00:00:00"),
        outlineColor = Enums.Color.eOutlineColor,
        size = 22,
        })
    myTimeCount:setAnchorPoint(0, 0.5)
    myTimeCount:setPosition(400, 20)
    self.mParentLayer:addChild(myTimeCount)
    self.mMyTimeCount = myTimeCount

end

--一键还原确认框
function JigsawPuzzleLayer:SureView()
    local price = Utility.analysisStrResList(self.mConsumeResource)
	MsgBoxLayer.addOKCancelLayer(
		TR("一键拼图将花费%s%s%s%s，并且不会将您的成绩计入排行榜，是否确认一键拼图？", Enums.Color.eOrangeH, price[1].num, Enums.Color.eNormalWhiteH, ResourcetypeSubName[price[1].resourceTypeSub]),
		TR("提示"),
		{
			text = TR("确定"),
			clickAction = function(layerObj)
                if self.mStatus == 2 then
                    ui.showFlashView(TR("已经完成拼图了"))
                    return
                end
				if not Utility.isResourceEnough(price[1].resourceTypeSub, price[1].num) then
					return
				end
				self:requestOneKeyReset()
				LayerManager.removeLayer(layerObj)
			end
		}
    )
end

-- 更新时间
function JigsawPuzzleLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    local timeLeftDaily = self.mDailyTime - Player:getCurrentTime()
    -- dump(timeLeft, "timeLeft")
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时：%s00:00:00", Enums.Color.eGreenH))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        LayerManager.removeLayer(self)
    end
    if timeLeftDaily > 0 then
        if timeLeftDaily < 300 or self.mLockStatus then
            self.mDailyTimeLabel:setString(TR("每日倒计时：%s%s", Enums.Color.eRedH, TR("结算中")))
        else
            self.mDailyTimeLabel:setString(TR("每日倒计时：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeftDaily)))
        end
    else
        self.mDailyTimeLabel:setString(TR("每日倒计时：%s00:00:00", Enums.Color.eGreenH))
        -- -- 停止倒计时
        -- if self.mSchelTime then
        --     self:stopAction(self.mSchelTime)
        --     self.mSchelTime = nil
        -- end
        -- LayerManager.removeLayer(self)
        self:requestGetInfo()
    end

    if timeLeftDaily <= 300 then
        self.mLockStatus = true
        self.mTouchNode:setSwallowTouches(true)
    end
    
end

--创建顶部信息
function JigsawPuzzleLayer:createTopView()
    self.mTopBgSprite:removeAllChildren()
    local tipLabel = ui.newLabel({
        text = TR("完成拼图可获得："),
        size = 22,
        outlineColor = Enums.Color.eOutlineColor,
        })
    tipLabel:setPosition(240 ,self.mTopBgSize.height * 0.5)
    self.mTopBgSprite:addChild(tipLabel)

    local rewardList = Utility.analysisStrResList(self.mReward)
    for i,v in ipairs(rewardList) do
        v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
    end
    local cardList = ui.createCardList({
        cardDataList = rewardList,
        allowClick = true,
        maxViewWidth = 280,
        viewHeight = self.mTopBgSize.height,
        space = 10,
    })
    cardList:setAnchorPoint(cc.p(0, 0))
    cardList:setPosition(320, 10)
    cardList:setScale(0.8)
    self.mTopBgSprite:addChild(cardList)

    if self.mBigFinalPic then
        self.mBigFinalPic:removeFromParent()
        self.mBigFinalPic = nil
    end

    local bigFinalPic = ui.newSprite(string.format("qt_%s.jpg", self.mOrderId))
    bigFinalPic:setPosition(235, 770)
    self.mParentLayer:addChild(bigFinalPic)
    self.mBigFinalPic = bigFinalPic
end

-- local tempJigsaw = "1,2,3,4,5,6,7,8,9"
local startPos = cc.p(88, 375) --第一个拼图的初始位置

--创建拼图
function JigsawPuzzleLayer:createJigsaw()
    self.mJigsawBgSprite:removeAllChildren()
    local tempArray = string.splitBySep(self.mOrder, ",")
    local tempRow = {}
    self.mArray = {}
    self.mNodePosList = {}
    for i,v in ipairs(tempArray) do
        if i%3 ~= 0 then
            table.insert(tempRow, v)
        else
            table.insert(tempRow, v)
            table.insert(self.mArray, tempRow)
            tempRow = {}
        end
    end

    for i, rowArray in ipairs(self.mArray) do
        for n, m in ipairs(rowArray) do
            if tonumber(m) == 9 then
                -- local tempEmptyNode = ui.newScale9Sprite("c_17.png", cc.size(144, 144))
                -- tempEmptyNode:setPosition(startPos.x + (n-1)*144, startPos.y - (i-1)*144)
                -- self.mParentLayer:addChild(tempEmptyNode)
            else
                local tempPicSprite = ui.newButton({
                    normalImage = string.format("pt_%s_0%d.jpg", self.mOrderId, tonumber(m)),
                })
                tempPicSprite:setPosition(startPos.x + (n-1)*144, startPos.y - (i-1)*144)
                self.mJigsawBgSprite:addChild(tempPicSprite)
                tempPicSprite:setZoomScale(0)

                local beginPos
                tempPicSprite:addTouchEventListener(function (pSender, eventType )
                    if eventType == ccui.TouchEventType.began then 
                        beginPos = pSender:getTouchBeganPosition()
                        -- dump(beginPos, "beginPos")
                    elseif eventType == ccui.TouchEventType.moved then
                        local movePos = pSender:getTouchMovePosition()
                        local distance = math.sqrt(math.pow(movePos.x - beginPos.x, 2) + math.pow(movePos.y - beginPos.y, 2))
                        if distance > 20 then
                            -- dump(movePos, "movedPos")
                            self:moveFunc(pSender,beginPos, movePos, i, n)
                        end
                    elseif eventType == ccui.TouchEventType.ended then
                        local endPos = pSender:getTouchEndPosition()
                        -- local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
                        -- if distance < (5 * Adapter.MinScale) then
                        -- end
                        -- dump(endPos, "endPos")
                    end
                end)

            end
        end
    end
end

--触摸判断
function JigsawPuzzleLayer:moveFunc(node, beganPos, movePos, row, col)
    self.mTouchNode:setSwallowTouches(true)

    local direction

    local offX = beganPos.x - movePos.x
    local offY = beganPos.y - movePos.y

    if math.abs(offX) > math.abs(offY) then
        if offX < 0 then
            direction = 1 --右
        else
            direction = 2 --左
        end
    else
        if offY < 0 then
            direction = 3 --上
        else
            direction = 4 --下
        end
    end

    -- print(row, col, "pppp")
    -- dump(direction, "direction")
    if direction == 1 then
        local targetGrid = self.mArray[row][col + 1]
        if targetGrid then
            if tonumber(targetGrid) == 9 then
                self.mArray[row][col], self.mArray[row][col + 1] = self.mArray[row][col + 1], self.mArray[row][col]
                self:moveAction(node, cc.p(144, 0))
            else
                self.mTouchNode:setSwallowTouches(false)
            end
        else
            self.mTouchNode:setSwallowTouches(false)
        end
    elseif direction == 2 then
        local targetGrid = self.mArray[row][col - 1]
        if targetGrid then
            if tonumber(targetGrid) == 9 then
                self.mArray[row][col], self.mArray[row][col - 1] = self.mArray[row][col - 1], self.mArray[row][col]
                self:moveAction(node, cc.p(-144, 0))
            else
                self.mTouchNode:setSwallowTouches(false)
            end
        else
            self.mTouchNode:setSwallowTouches(false)
        end
    elseif direction == 3 then
        if self.mArray[row - 1] then
            local targetGrid = self.mArray[row - 1][col]
            if targetGrid then
                if tonumber(targetGrid) == 9 then
                    self.mArray[row][col], self.mArray[row - 1][col] = self.mArray[row - 1][col], self.mArray[row][col]
                    self:moveAction(node, cc.p(0, 144))
                else
                    self.mTouchNode:setSwallowTouches(false)
                end
            else
                self.mTouchNode:setSwallowTouches(false)
            end
        else
            self.mTouchNode:setSwallowTouches(false)
        end
    elseif direction == 4 then
        if self.mArray[row + 1] then
            local targetGrid = self.mArray[row + 1][col]
            if targetGrid then
                if tonumber(targetGrid) == 9 then
                    self.mArray[row][col], self.mArray[row + 1][col] = self.mArray[row + 1][col], self.mArray[row][col]
                    self:moveAction(node, cc.p(0, -144))
                else
                    self.mTouchNode:setSwallowTouches(false)
                end
            else
                self.mTouchNode:setSwallowTouches(false)
            end
        else
            self.mTouchNode:setSwallowTouches(false)
        end
    end
end

--移动动画
function JigsawPuzzleLayer:moveAction(node, moveConfig)
    local moveBy = cc.MoveBy:create(0.5, moveConfig)
    local callFun = cc.CallFunc:create(function()
        self:handData()
    end)
    local sq = cc.Sequence:create(moveBy, callFun)
    node:runAction(sq)
end
--把数组转换为字符串
function JigsawPuzzleLayer:handData()
    local tempStr = ""
    for i,v in ipairs(self.mArray) do
        for n,m in ipairs(v) do
            if i == 1 and n == 1 then
                tempStr = tempStr..m
            else
                tempStr = tempStr..","..m
            end
        end
    end
    -- self.mOrder = "1,2,3,4,5,6,7,8,9"
    self:requestPuzzle(tempStr)
end

--刷新信息
function JigsawPuzzleLayer:refreshInfo()
    self.mMoveCountLabel:setString(self.mNum)
    
    self.mStartBtn:setEnabled(self.mStatus == 0)
    self.mOneKeyBtn:setEnabled(self.mStatus ~= 2)
    self.mTouchNode:setSwallowTouches(self.mStatus ~= 1)
    self.mBigFinalPic:setVisible(self.mStatus ~= 1)
    if self.mStatus == 2 then
        local rankStr = self.mMyRank == 0 and TR("未上榜") or self.mMyRank
        self.mMyRankLabel:setString(TR("我的排名：%s%s", Enums.Color.eRedH, rankStr))
        self.mMyMoveCount:setString(TR("步数：%s%s", Enums.Color.eGoldH, self.mStep))
        self.mMyTimeCount:setString(TR("时间：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(self.mTotalSeconds)))
        self.mCountingTimeLabel:setString(MqTime.formatAsDay(self.mTotalSeconds))
        self.mMyMoveCount:setVisible(true)
        self.mMyTimeCount:setVisible(true)

        self.mStartBtn:setTitleText(TR("已完成"))
        self.mOneKeyBtn:setTitleText(TR("已完成"))
    else
        self.mMyRankLabel:setString(TR("我的排名：%s未完成", Enums.Color.eRedH))
        self.mMyMoveCount:setVisible(false)
        self.mMyTimeCount:setVisible(false)
        self.mStartBtn:setTitleText(TR("开始拼图"))
        self.mOneKeyBtn:setTitleText(TR("一键拼图"))
    end

    if self.mLockStatus then
        self.mTouchNode:setSwallowTouches(true)
    end
end

--拼图计时
function JigsawPuzzleLayer:countTime()
    self.mTimeTick = self.mTimeTick + 1
    self.mCountingTimeLabel:setString(MqTime.formatAsDay(self.mTimeTick))
end

--刷新下方排行榜
function JigsawPuzzleLayer:refreshRankList()
    self.mListView:removeAllChildren()

    for i,v in ipairs(self.mDailyRank) do
        local layout = ccui.Layout:create()
        layout:setContentSize(600, 124)

        --背景图
        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(590, 124))
        bgSprite:setPosition(300, 62)
        layout:addChild(bgSprite)

        --排名
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
            outlineColor = Enums.Color.eOutlineColor
            })
        nameLabel:setAnchorPoint(0, 0.5)
        nameLabel:setPosition(220, 95)
        layout:addChild(nameLabel)

        --积分
        local scoreLabel = ui.newLabel({
            text = TR("步数：%s%s",Enums.Color.eOrangeH, v.Score),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 21,
            })
        scoreLabel:setAnchorPoint(0, 0.5)
        scoreLabel:setPosition(220, 65)
        layout:addChild(scoreLabel)

        -- --等级
        local scoreLabel = ui.newLabel({
            text = TR("时间：#249029%s", MqTime.formatAsDay(v.DailyTotalSeconds)),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 21,
            })
        scoreLabel:setAnchorPoint(0, 0.5)
        scoreLabel:setPosition(220, 35)
        layout:addChild(scoreLabel)

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

        self.mListView:pushBackCustomItem(layout)
    end
end
--=======================================网络请求========================================
--请求信息
function JigsawPuzzleLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedPuzzlematch", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	       	-- dump(data, "data")
	       	self.mEndTime = data.Value.ActivityEndTime
            self.mDailyTime = data.Value.EndTime
            self.mNum = data.Value.Num
            self.mOrderId = data.Value.OrderId
            self.mReward = data.Value.Reward
            self.mStatus = data.Value.Status
            self.mMyRank = data.Value.MyRank
            self.mOrder = data.Value.Order
            self.mConsumeResource = data.Value.ConsumeResource
            self.mTimeTick = data.Value.TimeTick
            self.mLockStatus = data.Value.LockStatus
            self.mPerReward = data.Value.PerReward
            self.mStep = data.Value.Step
            self.mTotalSeconds = data.Value.TotalSeconds
            self.mDailyRank = data.Value.DailyRank

            self:createTopView()
            self:createJigsaw()
            self:refreshInfo()
            self:refreshRankList()

            local onePrice = Utility.analysisStrResList(self.mConsumeResource)
            self.mOneKeyPrice:setString(string.format("{%s}%s",Utility.getDaibiImage(onePrice[1].resourceTypeSub), onePrice[1].num))

            --拼图计时
            if self.mTimeTick > 0 and self.mStatus ~= 2 then
                if self.mCountSchelTime then
                    self:stopAction(self.mCountSchelTime)
                    self.mCountSchelTime = nil
                end
                -- self:countTime()
                self.mCountSchelTime = Utility.schedule(self, self.countTime, 1.0)
            end

            --倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end
            self:updateTime()
            self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
        end
    })
end

--请求开始拼图
function JigsawPuzzleLayer:requestStart()
	HttpClient:request({
        moduleName = "TimedPuzzlematch", 
        methodName = "Start",
        svrMethodData = {self.mOrderId},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	       	dump(data, "data")
            self.mTimeTick = 0
            self.mStatus = data.Value.Status

            self.mTouchNode:setSwallowTouches(self.mStatus == 0)
            self.mStartBtn:setEnabled(self.mStatus == 0)
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_xinpintu",
                position = cc.p(235, 770),
                loop = false,
                animation = "xiao",
            })

            if self.mCountSchelTime then
                self:stopAction(self.mCountSchelTime)
                self.mCountSchelTime = nil
            end
            self.mCountSchelTime = Utility.schedule(self, self.countTime, 1.0)
            -- self:countTime()
            self:refreshInfo()
        end
    })
end

--请求移动
function JigsawPuzzleLayer:requestPuzzle(order)
    HttpClient:request({
        moduleName = "TimedPuzzlematch", 
        methodName = "Puzzle",
        svrMethodData = {self.mOrderId, order},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                self.mTouchNode:setSwallowTouches(false)
                self:createJigsaw()
                return
            end
            -- dump(data, "data")
            self.mOrder = order 
            self.mStatus = data.Value.Status
            self.mNum = data.Value.Num
            if self.mStatus == 2 then
                self.mMyRank = data.Value.MyRank
                self.mTimeTick = data.Value.TimeTick
                self.mOrder = data.Value.Order
                self.mLockStatus = data.Value.LockStatus
                self.mStep = data.Value.Step
                self.mTotalSeconds = data.Value.TotalSeconds
                self.mDailyRank = data.Value.DailyRank

                if self.mCountSchelTime then
                    self:stopAction(self.mCountSchelTime)
                    self.mCountSchelTime = nil
                end
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
                self:refreshRankList()

                ui.newEffect({
                    parent = self.mParentLayer,
                    effectName = "effect_ui_xinpintu",
                    position = cc.p(235, 770),
                    loop = false,
                    animation = "liubian",
                    completeListener = function()
                        MqAudio.playEffect("pintu_02.mp3")
                        ui.newEffect({
                            parent = self.mParentLayer,
                            effectName = "effect_ui_xinpintu",
                            position = cc.p(235, 770),
                            loop = false,
                            animation = "da",
                        })
                    end
                })
            end

            self:refreshInfo()
            self:createJigsaw()
        end
    })
end

--请求一键拼图
function JigsawPuzzleLayer:requestOneKeyReset()
	HttpClient:request({
        moduleName = "TimedPuzzlematch", 
        methodName = "Reset",
        svrMethodData = {self.mOrderId},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
            -- dump(data, "data")

            self.mStatus = data.Value.Status
            self.mOrder = data.Value.Order
            self.mStep = data.Value.Step
            self.mTotalSeconds = data.Value.TotalSeconds
            self.mMyRank = data.Value.MyRank


            if self.mCountSchelTime then
                self:stopAction(self.mCountSchelTime)
                self.mCountSchelTime = nil
            end
            self:refreshInfo()
            self:createJigsaw()

            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_xinpintu",
                position = cc.p(235, 770),
                loop = false,
                animation = "liubian",
                completeListener = function()
                    MqAudio.playEffect("pintu_02.mp3")    
                    ui.newEffect({
                        parent = self.mParentLayer,
                        effectName = "effect_ui_xinpintu",
                        position = cc.p(235, 770),
                        loop = false,
                        animation = "da",
                    })
                end
            })

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

        end
    })
end

return JigsawPuzzleLayer