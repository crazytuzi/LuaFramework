--[[
	文件名：ActivityPigCompetitionLayer.lua
	描述：金猪赛跑
	创建人：yanghongsheng
	创建时间：2019.01.21
--]]

local ActivityPigCompetitionLayer = class("ActivityPigCompetitionLayer", function(params)
	return display.newLayer()
end)


function ActivityPigCompetitionLayer:ctor(params)
	params = params or {}

    self.mIsRun = false     -- 是否在跑
    self.mSpeed = 300        -- 跑道移动速度(px/s)
    self.mRunStatus = 0     -- 是否赛跑中状态（0:不在比赛时间段 1:竞猜时间 2:赛跑时间）
    self.mRunRankData = {}  -- 赛跑途中名次数据
    -- 背景地图父节点
    self.mMapLayer = ui.newStdLayer()
    self:addChild(self.mMapLayer)
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eVIT,
        }
    })
    self:addChild(topResource)

	-- 添加UI
	self:initUI()

    -- 请求服务器
    self:requestGetInfo()
end

-- 添加UI元素
function ActivityPigCompetitionLayer:initUI()
    -- 创建背景
    self:createMoveBg()
    -- 每帧刷新函数
    self:moveUpdate()
    -- 创建猪
    self:createPigList()

    -- 标题
    local titleSprite = ui.newSprite("jzsp_11.png")
    titleSprite:setPosition(350, 1000)
    self.mParentLayer:addChild(titleSprite)

    -- 倒计时背景
    local timeBg = ui.newSprite("jzsp_12.png")
    timeBg:setPosition(470, 900)
    self.mParentLayer:addChild(timeBg)

    -- 本期结束倒计时
    self.mActivityTimeLabel = ui.newLabel({
            text = TR("本期结束倒计时："),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mActivityTimeLabel:setPosition(timeBg:getContentSize().width*0.5, 50)
    timeBg:addChild(self.mActivityTimeLabel)

    -- 下一轮倒计时
    self.mTurnTimeLabel = ui.newLabel({
            text = TR("下一轮倒计时："),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mTurnTimeLabel:setPosition(timeBg:getContentSize().width*0.5, 25)
    timeBg:addChild(self.mTurnTimeLabel)

    -- 当前竞猜积分
    local scoreNode, scoreLabel = ui.createSpriteAndLabel({
            imgName = "c_103.png",
            scale9Size = cc.size(240, 40),
            labelStr = TR("当前竞猜积分："),
            fontSize = 20,
            fontColor = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    scoreNode:setAnchorPoint(cc.p(1, 0.5))
    scoreNode:setPosition(630, 140)
    self.mParentLayer:addChild(scoreNode)
    self.mScoreLabel = scoreLabel

    -- 当前提示
    self.mHintLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(300, 0),
        })
    self.mHintLabel:setAnchorPoint(cc.p(0, 1))
    self.mHintLabel:setPosition(10, 920)
    self.mParentLayer:addChild(self.mHintLabel)

    -- 竞猜倒计时
    self.mQuizTimeLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mQuizTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mQuizTimeLabel:setPosition(10, 875)
    self.mParentLayer:addChild(self.mQuizTimeLabel)

    -- 创建按钮
    self:createBtnList()
end

-- 创建背景
function ActivityPigCompetitionLayer:createMoveBg()
    if self.mGZSpriteList then
        for _, sprite in pairs(self.mGZSpriteList) do
            sprite:removeFromParent()
        end
    end
    if self.mPDSpriteList then
        for _, sprite in pairs(self.mPDSpriteList) do
            sprite:removeFromParent()
        end
    end
    if self.mCSpriteList then
        for _, sprite in pairs(self.mCSpriteList) do
            sprite:removeFromParent()
        end
    end
    -- 创建观众
    local guanzhongSprite1 = ui.newSprite("jzsp_1.png")
    guanzhongSprite1:setAnchorPoint(cc.p(1, 1))
    guanzhongSprite1:setPosition(640, 1136)
    self.mMapLayer:addChild(guanzhongSprite1)
    local guanzhongSprite2 = ui.newSprite("jzsp_1.png")
    guanzhongSprite2:setAnchorPoint(cc.p(1, 1))
    guanzhongSprite2:setPosition(640-guanzhongSprite1:getContentSize().width+5, 1136)
    self.mMapLayer:addChild(guanzhongSprite2)
    self.mGZSpriteList = {guanzhongSprite1, guanzhongSprite2}
    -- 创建跑道
    local paodaoSprite1 = ui.newSprite("jzsp_8.png")
    paodaoSprite1:setAnchorPoint(cc.p(1, 0))
    paodaoSprite1:setPosition(640, 70)
    self.mMapLayer:addChild(paodaoSprite1)
    local paodaoSprite2 = ui.newSprite("jzsp_8.png")
    paodaoSprite2:setAnchorPoint(cc.p(1, 0))
    paodaoSprite2:setPosition(640-paodaoSprite1:getContentSize().width+15, 70)
    self.mMapLayer:addChild(paodaoSprite2)
    self.mPDSpriteList = {paodaoSprite1, paodaoSprite2}
    -- 创建草
    local caoSprite1 = ui.newSprite("jzsp_4.png")
    caoSprite1:setAnchorPoint(cc.p(1, 0))
    caoSprite1:setPosition(640, 70)
    self.mMapLayer:addChild(caoSprite1)
    local caoSprite2 = ui.newSprite("jzsp_4.png")
    caoSprite2:setAnchorPoint(cc.p(1, 0))
    caoSprite2:setPosition(640-caoSprite1:getContentSize().width+15, 70)
    self.mMapLayer:addChild(caoSprite2)
    self.mCSpriteList = {caoSprite1, caoSprite2}
end

-- 创建猪
function ActivityPigCompetitionLayer:createPigList()
    self.mPigNodeList = {}
    local posYList = {740, 560, 390, 220}
    -- 创建白猪
    local zhuEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "hero_heizhu",
            position = cc.p(580, posYList[1]),
            loop = true,
        })
    zhuEffect:setRotationSkewY(180)
    zhuEffect:setAnimation(0, "daiji", true)
    table.insert(self.mPigNodeList, zhuEffect)
    -- 创建粉猪
    local zhuEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "hero_baizhu",
            position = cc.p(580, posYList[2]),
            loop = true,
        })
    zhuEffect:setRotationSkewY(180)
    zhuEffect:setAnimation(0, "daiji", true)
    table.insert(self.mPigNodeList, zhuEffect)
    -- 创建白猪
    local zhuEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "hero_fenzhu",
            position = cc.p(580, posYList[3]),
            loop = true,
        })
    zhuEffect:setRotationSkewY(180)
    zhuEffect:setAnimation(0, "daiji", true)
    table.insert(self.mPigNodeList, zhuEffect)
    -- 创建白猪
    local zhuEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "hero_huazhu",
            position = cc.p(580, posYList[4]),
            loop = true,
        })
    zhuEffect:setRotationSkewY(180)
    zhuEffect:setAnimation(0, "daiji", true)
    table.insert(self.mPigNodeList, zhuEffect)
end

-- 注册每帧刷新函数
function ActivityPigCompetitionLayer:moveUpdate()
    -- 检查重设位置
    local function resetPos(sprite, speed)
        local x, y = sprite:getPosition()
        local width = sprite:getContentSize().width-30
        if x >= width+640 then
            sprite:setPosition(640-width+50+speed, y)
        end
    end
    -- 移动位置
    local function movePos(sprite, speed)
        -- 检查重设位置
        resetPos(sprite, speed)

        local x, y = sprite:getPosition()
        x = x + speed
        sprite:setPosition(x, y)
    end

    local curTime = 5
    self:scheduleUpdate(function(dt)
        if self.mIsRun then
            -- 移动跑道
            local speed = self.mSpeed*(dt/1)
            for _, sprite in pairs(self.mPDSpriteList) do
                movePos(sprite, speed)
            end
            -- 移动观众
            for _, sprite in pairs(self.mGZSpriteList) do
                movePos(sprite, speed-5) 
            end
            -- 移动草
            for _, sprite in pairs(self.mCSpriteList) do
                movePos(sprite, speed-5) 
            end
            -- 移动终点
            if self.mEndNode then
                local endX, endY = self.mEndNode:getPosition()
                self.mEndNode:setPosition(endX+speed, endY)
            end

            -- 背景速度
            local runEndTime = self.mPigAllData.NowTurnStartTime + self.mPigAllData.TimedPigRunningConfig.QuizTime + self.mPigAllData.TimedPigRunningConfig.GameTime
            local remainderTime = runEndTime - Player:getCurrentTime()
            if remainderTime < 15 and remainderTime > 10 then
                self.mSpeed = 300 + (15 - remainderTime)*30
            end

            -- 最后一段
            if remainderTime < 6 then
                -- 创建终点
                self:createEnd(remainderTime)
            end

            curTime = curTime + dt
            if not self.mEndNode and curTime >= 5 then
                curTime = 0
                self:setZhuRank()
            end
        end
    end)
end

-- 创建按钮
function ActivityPigCompetitionLayer:createBtnList()
    local btnInfoList = {
        -- 规则
        {
            normalImage = "c_72.png",
            position = cc.p(50, 1050),
            clickAction = function(pSender)
            	MsgBoxLayer.addRuleHintLayer(TR("规则"), {
            		TR("1.活动开启后可参与金猪赛跑竞猜，选择一个猪猪投注。"),
					TR("2.每日活动期间会不间断开启赛跑，竞猜成功可获得相应赔率的积分，竞猜失败只能获得1:1的积分。"),
					TR("3.竞猜积分可在积分商城中兑换奖励。"),
                    TR("4.金猪赛跑积分每期都会清除，请及时使用。"),
        		})
            end,
        },
        -- 退出
        {
            normalImage = "c_29.png",
            position = cc.p(594, 1050),
            clickAction = function(pSender)
                LayerManager.removeLayer(self)
            end,
        },
        -- 积分商店
        {
            normalImage = "jzsp_15.png",
            position = cc.p(80, 150),
            clickAction = function(pSender)
                self:exchangePopView()
            end,
        },
        -- 有奖竞猜
        {
            normalImage = "jzsp_14.png",
            position = cc.p(180, 150),
            clickAction = function(pSender)
                self:createQuizLayer()
            end,
        },
        -- 上轮排名
        {
            normalImage = "jzsp_16.png",
            position = cc.p(280, 150),
            clickAction = function(pSender)
                self:createRankLayer()
            end,
        },
    }

    for _, btnInfo in pairs(btnInfoList) do
        local tempBtn = ui.newButton(btnInfo)
        self.mParentLayer:addChild(tempBtn)
    end
end

-- 创建小猪排行榜弹窗
function ActivityPigCompetitionLayer:createRankLayer()
	-- 小猪特效
    local zhuEffectList = {
        "hero_heizhu",
        "hero_baizhu",
        "hero_fenzhu",
        "hero_huazhu",
    }
    -- 位置列表
    local PosYList = {740, 565, 390, 215}
    -- 数字图片
    local numPicList = {"jzsp_18.png", "jzsp_19.png", "jzsp_20.png", "jzsp_23.png"}
    -- 排名数据
    local rankList = {}
    local tempList = self.mPigAllData.GlobalPigRunningHistory and self.mPigAllData.GlobalPigRunningHistory.SettlementInfo
    if tempList and next(tempList) then
	    for i = 1, 4 do
	        table.insert(rankList, tempList[tostring(i)])
	    end
	end

    local function DIYfunc(boxRoot, bgSprite, bgSize)
    	-- 去押注下一轮
    	local nextTurnBtn = ui.newButton({
    			normalImage = "c_28.png",
    			text = TR("押注下一轮"),
    			clickAction = function ()
    				self:createQuizLayer()
    				LayerManager.removeLayer(boxRoot)
    			end,
    		})
    	nextTurnBtn:setPosition(bgSize.width*0.5, 60)
    	bgSprite:addChild(nextTurnBtn)
    	-- 空提示
    	if not next(rankList) then
    		local emptyHint = ui.createEmptyHint(TR("暂无排名"))
    		emptyHint:setPosition(bgSize.width*0.5, bgSize.height*0.5)
    		bgSprite:addChild(emptyHint)
    		return
    	end

    	-- 背景
    	local sprite = ui.newSprite("jzsp_22.png")
    	sprite:setAnchorPoint(cc.p(0.5, 1))
    	sprite:setPosition(bgSize.width*0.5, bgSize.height-70)
    	bgSprite:addChild(sprite)
    	
    	for i, rank in ipairs(rankList) do
    		-- 背景图
    		local tempBg = ui.newSprite("jzsp_17.png")
    		tempBg:setPosition(bgSize.width*0.5, PosYList[i])
    		bgSprite:addChild(tempBg)
    		local tempBgSize = tempBg:getContentSize()
    		-- 彩带
    		if i == 1 then
    			local tempSprite = ui.newSprite("jzsp_21.png")
    			tempSprite:setPosition(tempBgSize.width*0.5, tempBgSize.height*0.5)
    			tempBg:addChild(tempSprite)
    		end
			-- 猪特效
    		local zhu = ui.newEffect({
				parent = tempBg,
				effectName = zhuEffectList[rank],
				animation = "daiji",
				loop = true,
				position = cc.p(tempBgSize.width*0.5, tempBgSize.height*0.5-40)
			})
			zhu:setRotationSkewY(180)

    		-- 数字图片
    		local numSprite = ui.newSprite(numPicList[i])
    		numSprite:setAnchorPoint(cc.p(0.5, 0))
    		numSprite:setPosition(tempBgSize.width*0.5, -30)
    		tempBg:addChild(numSprite)

		end

    end
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgSize = cc.size(630, 900),
            title = TR("排名"),
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {},
            btnInfos = {},
        }
    })
end

--兑换弹窗
function ActivityPigCompetitionLayer:exchangePopView()
    --弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 766),
        title = TR("积分兑换"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    local curScoreLabel = ui.newLabel({
        text = TR("当前可用积分：#249029%s#46220d", self.mPigAllData.TimedPigRunningInfo.NowScore),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
        })
    curScoreLabel:setAnchorPoint(0, 0.5)
    curScoreLabel:setPosition(40, 640)
    self.mPopBgSprite:addChild(curScoreLabel)
    self.mCurScoreLabelPop = curScoreLabel

    local hintLabel = ui.newLabel({
    		text = TR("本期活动结束后积分将会全部清除，请注意结束倒计时"),
    		color = cc.c3b(0x37, 0xff, 0x40),
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    	})
    hintLabel:setPosition(300, 680)
    self.mPopBgSprite:addChild(hintLabel)

    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(539, 576))
    grayBgSprite:setPosition(299, 325)
    self.mPopBgSprite:addChild(grayBgSprite)

    -- 奖励列表控件
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(530, 555))
    rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(299, 325)
    self.mPopBgSprite:addChild(rewardListView)

    for i,v in ipairs(self.mPigAllData.ExchangInfo) do
        local layout = ccui.Layout:create()
        layout:setContentSize(530, 140)

        local itemBgSprite = ui.newScale9Sprite("c_18.png", cc.size(526, 136))
        itemBgSprite:setPosition(265, 70)
        layout:addChild(itemBgSprite)

        local rewardList = Utility.analysisStrResList(v.Reward)

        local cardListView = ui.createCardList({
            maxViewWidth = 350,
            viewHeight = 120,
            space = 10, 
            cardDataList = rewardList
            })
        cardListView:setAnchorPoint(0, 0.5)
        cardListView:setPosition(20, 70)
        layout:addChild(cardListView)

        local exchangeBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("兑换"),
            clickAction = function()
                if v.Num > self.mPigAllData.TimedPigRunningInfo.NowScore then
                    ui.showFlashView(TR("积分不足！"))
                    return
                end
                self:requestExchangeReward(v.Num)
            end
            })
        exchangeBtn:setPosition(450, 80)
        layout:addChild(exchangeBtn)

        local needScore = ui.newLabel({
            text = TR("需要积分：%s%s", Enums.Color.eGoldH, v.Num),
            size = 20,
            outlineColor = Enums.Color.eOutlineColor,
            })
        needScore:setPosition(420, 35)
        layout:addChild(needScore)

        rewardListView:pushBackCustomItem(layout)
    end
end

-- 创建小猪竞猜弹窗
function ActivityPigCompetitionLayer:createQuizLayer()
    LayerManager.addLayer({name = "activity.ActivityPigQuizLayer", cleanUp = false})
end

-- 创建1，2，3，4数字图标
function ActivityPigCompetitionLayer:createPaodaoNum(isClean)
    if not self.mNumParent then
        self.mNumParent = cc.Node:create()
        self.mParentLayer:addChild(self.mNumParent)
    end
    self.mNumParent:removeAllChildren()

    if not isClean then
        local posYList = {770, 600, 425, 255}
        local numPicList = {"jzsp_7.png", "jzsp_2.png", "jzsp_5.png", "jzsp_6.png"}
        for i = 1, 4 do
            local numSprite = ui.newSprite(numPicList[i])
            numSprite:setPosition(560, posYList[i])
            self.mParentLayer:addChild(numSprite)
        end
    end
end

-- 创建终点
function ActivityPigCompetitionLayer:createEnd(remainderTime)
    if not self.mEndNode then
        self.mEndNode = cc.Node:create()
        self.mMapLayer:addChild(self.mEndNode)
        -- 终点x坐标
        local distance = self.mSpeed*remainderTime
        local posXList = self.getPosXList()
        self.mEndNode:setPosition(posXList[1]-distance, 507)
        -- 红线
        local lineSprite = ui.newSprite("jzsp_10.png")
        self.mEndNode:addChild(lineSprite)
        -- 终点
        local tempSprite = ui.newSprite("jzsp_3.png")
        tempSprite:setPosition(0, 90)
        self.mEndNode:addChild(tempSprite)
        local tempSprite = ui.newSprite("jzsp_9.png")
        tempSprite:setPosition(0, -90)
        self.mEndNode:addChild(tempSprite)

        -- 创建结束重置
        Utility.performWithDelay(self, function ()
            -- 清除终点
            self.mEndNode:removeFromParent()
            self.mEndNode = nil
        	-- 刷新状态
        	self:refreshStatus()
            -- 重置跑道
            self:createMoveBg()
            -- 重置速度
            self.mSpeed = 300
        end, remainderTime+1)

        -- 设置最后排名
        self:setZhuRank(true)
    end
end

function ActivityPigCompetitionLayer:resetDaiji()
    local posYList = {740, 560, 390, 220}
    -- 设置猪动作
    for i, zhuNode in ipairs(self.mPigNodeList) do
        zhuNode:stopAllActions()
        zhuNode:setAnimation(0, "daiji", true)
        zhuNode:setPosition(580, posYList[i])
    end
end

-- 开始跑初始化
function ActivityPigCompetitionLayer:startRun()
    -- 设置猪动作
    for _, zhuNode in ipairs(self.mPigNodeList) do
        zhuNode:setAnimation(0, "pao", true)
    end
    -- 设置当前名次
    self:setZhuRank()
    -- 开始移动背景
    self.mIsRun = true
end

-- 跑步中初始化
function ActivityPigCompetitionLayer:Running()
    local posXList = self.getPosXList()
    local rankList = {1, 2, 3, 4}
    rankList = Utility.shuffle(rankList)
    -- 设置猪动作
    for i, zhuNode in ipairs(self.mPigNodeList) do
        zhuNode:setAnimation(0, "pao", true)
        local x, y = zhuNode:getPosition()
        zhuNode:setPosition(posXList[rankList[i]], y)
    end
    -- 移动背景
    self.mIsRun = true
end

function ActivityPigCompetitionLayer.getPosXList()
    return {200, 300, 400, 500}
end

function ActivityPigCompetitionLayer.isSameRank(rankList1, rankList2)
    if #rankList1 ~= #rankList2 then return false end

    for i, rank in ipairs(rankList1) do
        if rankList2[i] ~= rank then return false end
    end

    return true
end

-- 调整猪的位置
function ActivityPigCompetitionLayer:setZhuRank(isLastRank)
    -- 调整猪的名次
    local runEndTime = self.mPigAllData.NowTurnStartTime + self.mPigAllData.TimedPigRunningConfig.QuizTime + self.mPigAllData.TimedPigRunningConfig.GameTime
    local useTime = self.mPigAllData.TimedPigRunningConfig.GameTime - (runEndTime - Player:getCurrentTime())
    local keySecond = math.ceil(useTime/5)*5
    local tempList = self.mRunRankData[tostring(keySecond)] or self.mRunRankData["5"]
    if isLastRank then
    	local keyList = table.keys(self.mRunRankData)
    	table.sort(keyList, function(key1, key2)
    		return tonumber(key1) < tonumber(key2)
		end)
		tempList = self.mRunRankData[keyList[#keyList]]
    end
    if not tempList then return end
    local rankList = {}
    for i = 1, 4 do
        table.insert(rankList, tempList[tostring(i)])
    end
    if not self.mRankList or (not self.isSameRank(self.mRankList, rankList)) then
        self:moveZhuPos(rankList)
        self.mRankList = rankList
    end
end

-- 播放猪的位置移动
function ActivityPigCompetitionLayer:moveZhuPos(rankList)
    -- 猪的名次X位置列表
    local posXList = self.getPosXList()
    for rank, zhuIndex in ipairs(rankList) do
    	zhuNode = self.mPigNodeList[zhuIndex]
        local needTime = math.random(40, 60)/10
        local oldX, y = zhuNode:getPosition()
        local newX = posXList[rank]
        zhuNode:stopAllActions()
        local moveAction = cc.MoveTo:create(needTime, cc.p(newX, y))
        zhuNode:runAction(moveAction)
    end
end

-- 随机一次猪的名次
function ActivityPigCompetitionLayer:randomRank()
    local rankList = {1, 2, 3, 4}
    rankList = Utility.shuffle(rankList)

    self:moveZhuPos(rankList)
end

-- 创建本期结束倒计时
function ActivityPigCompetitionLayer:createActivityTimeUpdate()
    if self.mActivityTimeLabel.timeUpdate then
        self.mActivityTimeLabel:stopAction(self.mActivityTimeLabel.timeUpdate)
        self.mActivityTimeLabel.timeUpdate = nil
    end

    self.mActivityTimeLabel.timeUpdate = Utility.schedule(self.mActivityTimeLabel, function ()
        local timeLeft = self.mPigAllData.EndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mActivityTimeLabel:setString(TR("本期结束倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mActivityTimeLabel:setString(TR("本期结束倒计时：#ffe74800:00:00"))
            self.mActivityTimeLabel:stopAction(self.mActivityTimeLabel.timeUpdate)
            self.mActivityTimeLabel.timeUpdate = nil
            LayerManager.removeLayer(self)
        end
    end, 1)
end

-- 创建下一轮倒计时
function ActivityPigCompetitionLayer:createNextTimeUpdate()
    if self.mTurnTimeLabel.timeUpdate then
        self.mTurnTimeLabel:stopAction(self.mTurnTimeLabel.timeUpdate)
        self.mTurnTimeLabel.timeUpdate = nil
    end

    self.mTurnTimeLabel.timeUpdate = Utility.schedule(self.mTurnTimeLabel, function ()
        local timeLeft = self.mPigAllData.NextTurnStartTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTurnTimeLabel:setString(TR("下一轮倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mTurnTimeLabel:stopAction(self.mTurnTimeLabel.timeUpdate)
            self.mTurnTimeLabel.timeUpdate = nil
            -- 超过一天则没有下一轮
            if timeLeft < -86400 then
                self.mTurnTimeLabel:setString(TR("今日没有下一轮了"))
            else
                -- 延时刷新数据
                Utility.performWithDelay(self, function ()
                    self:requestGetInfo(function ()
                    	-- 弹出排行榜
			            self:createRankLayer()
                    end)
                end, 1)
                -- self:requestGetInfo()
            end
        end
    end, 1)
end

-- 创建竞猜倒计时
function ActivityPigCompetitionLayer:createQuizTimeUpdate()
    if self.mQuizTimeLabel.timeUpdate then
        self.mQuizTimeLabel:stopAction(self.mQuizTimeLabel.timeUpdate)
        self.mQuizTimeLabel.timeUpdate = nil
    end

    self.mQuizTimeLabel.timeUpdate = Utility.schedule(self.mQuizTimeLabel, function ()
        local timeLeft = self.mPigAllData.NowTurnStartTime+self.mPigAllData.TimedPigRunningConfig.QuizTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mQuizTimeLabel:setString(TR("竞猜结束倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))

            if timeLeft <= 5 then
            	ui.newEffect({
            		parent = self.mParentLayer,
            		effectName = "effect_ui_jinzhudaojishi",
            		animation = tostring(timeLeft),
            		loop = false,
            		position = cc.p(320, 568),
        		})
            end
        else
            self.mQuizTimeLabel:stopAction(self.mQuizTimeLabel.timeUpdate)
            self.mQuizTimeLabel.timeUpdate = nil
            self.mQuizTimeLabel:setString("")
            -- 刷新状态
            self:refreshStatus()
        end
    end, 1)
end

function ActivityPigCompetitionLayer:refreshUI()
    -- 本期结束倒计时
    self:createActivityTimeUpdate()
    -- 下一轮倒计时
    self:createNextTimeUpdate()
    -- 当前竞猜积分
    self.mScoreLabel:setString(TR("当前竞猜积分：#ffe748%s", self.mPigAllData.TimedPigRunningInfo.TotalScore))

    self:refreshStatus()

    if not tolua.isnull(self.mCurScoreLabelPop) then
	    self.mCurScoreLabelPop:setString(TR("当前可用积分：#249029%s#46220d", self.mPigAllData.TimedPigRunningInfo.NowScore))
	end
end

-- 判断当前时间是否在比赛时间段内
function ActivityPigCompetitionLayer.isMatchTime(startTimeStr, endTimeStr)
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

function ActivityPigCompetitionLayer:refreshStatus()
    self.mQuizTimeLabel:setString("")
    self.mRunStatus = 0
    self.mIsRun = false
    -- 不在两段比赛时间段内
    if not self.isMatchTime(self.mPigAllData.TimedPigRunningConfig.StartTimeOne, self.mPigAllData.TimedPigRunningConfig.EndTimeOne) and not self.isMatchTime(self.mPigAllData.TimedPigRunningConfig.StartTimeTwo, self.mPigAllData.TimedPigRunningConfig.EndTimeTwo) then
        self:resetDaiji()
        self.mHintLabel:setString(TR("比赛时间段为%s~%s和%s~%s，请注意比赛时段", self.mPigAllData.TimedPigRunningConfig.StartTimeOne, self.mPigAllData.TimedPigRunningConfig.EndTimeOne, self.mPigAllData.TimedPigRunningConfig.StartTimeTwo, self.mPigAllData.TimedPigRunningConfig.EndTimeTwo))
        return
    end
    -- 竞猜结束时间
    local quizEndTime = self.mPigAllData.NowTurnStartTime + self.mPigAllData.TimedPigRunningConfig.QuizTime
    self.mRunStatus = 1
    -- 在竞猜时间内
    if Player:getCurrentTime() < quizEndTime then
        self:resetDaiji()
        self.mHintLabel:setString(TR("竞猜火热进行中。。。"))
        -- 竞猜倒计时
        self:createQuizTimeUpdate()
        return
    end
    -- 赛跑结束时间
    local runEndTime = self.mPigAllData.NowTurnStartTime + self.mPigAllData.TimedPigRunningConfig.QuizTime + self.mPigAllData.TimedPigRunningConfig.GameTime
    self.mRunStatus = 2
    -- 赛跑时间段内
    if Player:getCurrentTime() < runEndTime then
        self.mHintLabel:setString(TR("比赛火热进行中。。。"))
        -- 开始几秒了
        local useTime = self.mPigAllData.TimedPigRunningConfig.GameTime - (runEndTime - Player:getCurrentTime())
        if useTime < 3 then
            self:startRun()
        else
            self:Running()
        end
    end
end

--================================================网络请求=========================================
-- 请求服务器，获取活动的具体信息
function ActivityPigCompetitionLayer:requestGetInfo(callback)
    HttpClient:request({
        moduleName = "TimedPigRunning",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- dump(data.Value)
            self.mPigAllData = data.Value
            self.mRankList = nil
            -- 赛跑途中名次数据
            local runningInfo = self.mPigAllData.GlobalPigRunningInfo.RunningInfo
            self.mRunRankData = runningInfo and cjson.decode(runningInfo) or {}
            self:refreshUI()

            if callback then
            	callback()
            end
        end
    })
end

function ActivityPigCompetitionLayer:requestExchangeReward(num)
	HttpClient:request({
        moduleName = "TimedPigRunning",
        methodName = "Exchange",
        svrMethodData = {num, 1},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            self.mPigAllData.TimedPigRunningInfo = data.Value.TimedPigRunningInfo
            self.mCurScoreLabelPop:setString(TR("当前可用积分：#249029%s#46220d", self.mPigAllData.TimedPigRunningInfo.NowScore))
        end
    })
end

return ActivityPigCompetitionLayer