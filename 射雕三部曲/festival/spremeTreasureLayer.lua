--[[
    文件名: spremeTreasureLayer.lua
	描述: 至尊宝藏活动
	创建人: lengjiazhi
	创建时间: 2017.12.28
-- ]]
local spremeTreasureLayer = class("spremeTreasureLayer", function (params)
	return display.newLayer()
end)

function spremeTreasureLayer:ctor()

	self.mCurBoxIndex = 0
	self.mMaxLayerNum = 0
	self.mPageSelectIndex = 1

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    self.mTouchSwallowLayer = ui.newStdLayer()
    self:addChild(self.mTouchSwallowLayer)

    -- self.mTouchNode = ui.registerSwallowTouch({
    --     node = self.mTouchSwallowLayer,
    --     allowTouch = true,
    --     })

	self:initUI()
	self:requestGetInfo()
end

function spremeTreasureLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("jrhd_101.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1035),
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
        position = cc.p(40, 915),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.所有玩家都可以参与至尊宝典活动。"),
                [2] = TR("2.激活至尊宝典可以领取更多的奖励，不激活至尊宝典只能领取部分奖励。"),
                [3] = TR("3.完成修炼任务可以获得不同的修炼值，使用修炼值激活至尊宝典，修炼任务可获得修炼值有上限。"),
                [4] = TR("4.每日相同任务获取的修炼值可能不同，请注意合理分配资源。"),
                [5] = TR("5.充值一元宝可获得一点修炼值。"),
                [6] = TR("6.点击参悟可以领取相应层数的奖励，额外奖励需要点击奖励领取。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 奖励预览按钮
    local perViewBtn = ui.newButton({
        normalImage = "c_79.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(595, 910),
        clickAction = function()
            self:createPreviewPop()
        end})
    self.mParentLayer:addChild(perViewBtn, 1)

    --任务按钮
    local taskBtn = ui.newButton({
    	normalImage = "jrhd_103.png",
    	clickAction = function()
    		self:requestGetTaskDetail()
    	end
    	})
    taskBtn:setPosition(585, 825)
    self.mParentLayer:addChild(taskBtn)

    --激活背景
    local activeBgSprite = ui.newScale9Sprite("xsms_03.png", cc.size(380, 130))
    activeBgSprite:setAnchorPoint(cc.p(0, 0.5))
    activeBgSprite:setPosition(20, 175)
    self.mParentLayer:addChild(activeBgSprite)

    --激活按钮
    local activeBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("激活"),
    	clickAction = function()
    		self:requestActive()
    	end
    	})
    activeBtn:setPosition(190, 30)
    activeBgSprite:addChild(activeBtn)
    self.mActiveBtn = activeBtn

    --激活描述文字
    local activeIntro = ui.newLabel({
    	text = TR("单笔充值1000元宝激活秘籍，可以通过参与任务获得修炼值，修炼宝典可领取多种大奖（某些奖励需激活秘籍才能领取）"),
    	dimensions = cc.size(350, 0),
    	color = Enums.Color.eBlack,
    	size = 18,
    	})
    activeIntro:setAnchorPoint(0.5, 0)
    activeIntro:setPosition(190, 60)
    activeBgSprite:addChild(activeIntro)

    --层数
    local levelLabel = ui.newLabel({
    	text = TR("当前层：#249029-/-"),
    	color = Enums.Color.eBlack,
    	size = 22,
    	})
    levelLabel:setPosition(320, 910)
    self.mParentLayer:addChild(levelLabel)
    self.mLevelLabel = levelLabel

    -- 参悟按钮
    local studyBtn = ui.newButton({
        normalImage = "wgcw_02.png",
        position = cc.p(495, 205),
        clickAction = function()
        	self:requestActiveCurNode(self.mPlayerInfo.CurNodeId)
        end
    })
    self.mParentLayer:addChild(studyBtn)
    self.mStudyBtn = studyBtn

    --修炼值
    local scoreLabel = ui.newLabel({
    	text = TR("修炼值：%s", 0),
    	outlineColor = Enums.Color.eBlack,
    	size = 20,
    	})
    scoreLabel:setPosition(495, 130)
    self.mParentLayer:addChild(scoreLabel)
    self.mScoreLabel = scoreLabel

    --倒计时
	local timeLabel = ui.newLabel({
		text = TR("活动未开启"),
		size = 20,
		outlineColor = Enums.Color.eBlack,
		})
	timeLabel:setPosition(320, 880)
	self.mParentLayer:addChild(timeLabel)
	self.mTimeLable = timeLabel

     -- 左右箭头
    local rightButton = ui.newButton({
        normalImage = "c_43.png",
        position = cc.p(610, 570),
        clickAction = function(btnObj)

        	local tempIndex = self.mPageSelectIndex + 1

            if tempIndex > self.mMaxLayerNum then
                ui.showFlashView({text = TR("已经到最高层了")})
                return
            end
			self.mPageSelectIndex = tempIndex

            self:refreshTreasureView()
        end
    })
    local leftButton = ui.newButton({
        normalImage = "c_43.png",
        position = cc.p(30, 570),
        clickAction = function(btnObj)
        	local tempIndex = self.mPageSelectIndex - 1
            if (tempIndex < 1) then
                ui.showFlashView({text = TR("已经到第一层了")})
                return
            end
			self.mPageSelectIndex = tempIndex

            self:refreshTreasureView()
        end
    })

    rightButton:setRotation(270)
    leftButton:setRotation(90)
    self.mParentLayer:addChild(rightButton)
    self.mParentLayer:addChild(leftButton)


    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)
end
local boxInfo = {
	[1] = {
		pos = cc.p(130, 770),
		pic = "jrhd_106.png",
		color = Enums.Color.eGreen,
	},
	[2] = {
		pos = cc.p(530, 580),
		pic = "jrhd_105.png",
		color = Enums.Color.eBlue,
	},
	[3] = {
		pos = cc.p(155, 370),
		pic = "jrhd_104.png",
		color = Enums.Color.ePurple,
	},
}
--创建中间宝藏
function spremeTreasureLayer:refreshTreasureView()
	local curPageIndex = math.floor((self.mCurBoxIndex-1)/3) + 1
	local boxInfoInPage 
	if curPageIndex ~= self.mPageSelectIndex then
		boxInfoInPage = self.mBoxInfo[self.mPageSelectIndex]
	else
		boxInfoInPage = self.mBoxInfo[curPageIndex]
	end

    self.mTouchSwallowLayer:removeAllChildren()

    --连接线
    local lineSprite = ui.newSprite("jrhd_107.png")
    lineSprite:setPosition(330, 570)
    self.mTouchSwallowLayer:addChild(lineSprite)

 	self.mLevelLabel:setString(TR("当前层：#249029%s/%s", self.mPageSelectIndex, self.mMaxLayerNum))
 	self.mScoreLabel:setString(TR("修炼值：%s", self.mPlayerInfo.TotalIntegral))
    local boxNode = {}
    for i,v in ipairs(boxInfo) do
    	local boxInfo = boxInfoInPage[i]
    	if not boxInfo then
    		break
    	end

    	local tempNode = cc.Node:create()
    	tempNode:setPosition(v.pos)
    	self.mTouchSwallowLayer:addChild(tempNode)

    	local boxBtn = ui.newButton({
    		normalImage = v.pic,
    		clickAction = function()
    			self:rewardPopView(boxInfo)
    		end
    		})
    	boxBtn:setPosition(0, 0)
    	tempNode:addChild(boxBtn)

    	--额外奖励
    	if boxInfo.ExtraReward ~= "" then
            boxBtn:setPosition(0, -60)

    		local extraInfo = Utility.analysisStrResList(boxInfo.ExtraReward)
    		local extraRewardCard = CardNode.createCardNode({
    			 	resourceTypeSub = extraInfo[1].resourceTypeSub, 
			        modelId = extraInfo[1].modelId,
			        num = extraInfo[1].num,
			        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum},
    			})
    		extraRewardCard:setPosition(0, 60)

    		tempNode:addChild(extraRewardCard)
    		if self.mPlayerInfo.ExtraStatus == 2 and boxInfo.ExtraReceiveStatus == 1 then
		        ui.setWaveAnimation(extraRewardCard, nil, true)

    			extraRewardCard:setClickCallback(function(pSender)
    				self:requestReceiveReward(boxInfo.NodeId, pSender)
    			end)
    		end

    		if boxInfo.ExtraReceiveStatus == 2 then
	    		local hadGetSprite = ui.newSprite("jrhd_108.png")
	    		hadGetSprite:setPosition(45, 45)
	    		hadGetSprite:setRotation(-45)
	    		extraRewardCard:addChild(hadGetSprite, 1000)
    		end 
    	end

    	--需要修炼值文字
    	local needScore = ui.newLabel({
    		text = TR("需要修炼值%s", boxInfo.UnlockIntegral),
    		color = Enums.Color.eBlack,
    		size = 20,
    		})
    	needScore:setPosition(0, -110)
    	tempNode:addChild(needScore)

    	--可学习标识
    	if boxInfo.NodeId == self.mCurBoxIndex and boxInfo.UnlockIntegral <= self.mPlayerInfo.TotalIntegral then
    		local canStudySprite = ui.newSprite("wgcw_03.png")
    		canStudySprite:setPosition(i%2 == 0 and 60 or -60, 0)
    		tempNode:addChild(canStudySprite)
    	end

    	--锁
    	local redNodeSprite = ui.newSprite("wgcw_06.png")
    	local posx = i%2 == 0 and v.pos.x-60 or v.pos.x + 60
    	redNodeSprite:setPosition(i%2 == 0 and -60 or 60, 0)
    	tempNode:addChild(redNodeSprite)
    	tempNode.redNodeSprite = redNodeSprite
    	table.insert(boxNode, tempNode)

    	--已学习标识
    	if boxInfo.BasicReceiveStatus == 2 then
    		local hadGetSprite = ui.newSprite("jrhd_108.png")
    		hadGetSprite:setRotation(-45)
    		hadGetSprite:setPosition(45, 45)
    		boxBtn:addChild(hadGetSprite, 10)

    		redNodeSprite:setTexture("wgcw_05.png")
    	end

    	--宝箱名字
    	local nameLabel = ui.newLabel({
    		text = TR("%d级宝箱",boxInfo.NodeId),
    		color = v.color,
    		outlineColor = Enums.Color.eBlack,
    		size = 24,
    		})
    	nameLabel:setPosition(0, -80)
    	tempNode:addChild(nameLabel)
    end
end

-- 创建预览框
function spremeTreasureLayer:createPreviewPop()
	local perViewData = {}

	for i,v in ipairs(self.mNodeList) do
		local tempRewrad = v.BasicReward .. "||"..v.ExtraReward
		table.insert(perViewData, tempRewrad)
	end

    -- 项数据表
    local itemsData = {}
    -- 构造数据
    for i, resoureStr in pairs(perViewData) do
        local item = {}
        item.resourceList = Utility.analysisStrResList(resoureStr)
        item.title = i..TR("级宝箱")

        table.insert(itemsData, item)
    end

    LayerManager.addLayer({
            name = "festival.RewardPreviewPopLayer",
            data = {title = TR("奖励预览"), itemsData = itemsData},
            cleanUp = false,
        })
end


--创建任务弹窗
function spremeTreasureLayer:createTaskPopView()
	--黑底板
	local blackBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	blackBg:setContentSize(640, 1136)
	blackBg:setPosition(0, 0)
	self.mTouchSwallowLayer:addChild(blackBg)

	--背景图
	local bgSprite = ui.newSprite("jrhd_102.png")
	bgSprite:setPosition(320, 568)
	blackBg:addChild(bgSprite)
	self.mBgSprite = bgSprite

	-- 注册屏蔽下层页面事件
    ui.registerSwallowTouch({
        node = blackBg,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
        	if not ui.touchInNode(touch, self.mBgSprite) then
        		blackBg:removeFromParent()
        		blackBg = nil
            end
        end,
    })

	--上下箭头
	local tipArrowUp = ui.newSprite("c_43.png")
	tipArrowUp:setPosition(350, 950)
	blackBg:addChild(tipArrowUp)
	tipArrowUp:setRotation(180)

	local tipArrowDown = ui.newSprite("c_43.png")
	tipArrowDown:setPosition(350, 220)
	blackBg:addChild(tipArrowDown)

	--目录图标
	local listSprite = ui.newSprite("wgcw_25.png")
	listSprite:setPosition(100, 835)
	blackBg:addChild(listSprite)

	--任务修炼值上限
	local taskScoreLimit = ui.newLabel({
		text = TR("修炼任务修炼值：%s/%s", self.mPlayerInfo.TodayTaskIntegral, self.mActivityInfo.BasicInfo.DailyMaxTaskIntegral),
		size = 22,
		})
	taskScoreLimit:setPosition(330, 185)
	taskScoreLimit:setAnchorPoint(0, 0.5)
	blackBg:addChild(taskScoreLimit)

	--任务列表
	local taskListView = ccui.ListView:create()
    taskListView:setDirection(ccui.ScrollViewDir.vertical)
    taskListView:setBounceEnabled(true)
    taskListView:setContentSize(cc.size(520, 640))
    taskListView:setItemsMargin(2)
    taskListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    taskListView:setAnchorPoint(cc.p(0.5, 1))
    taskListView:setPosition(350, 900)
    blackBg:addChild(taskListView)

    for i,v in ipairs(self.mTaskInfo) do
   		local layout = ccui.Layout:create()
   		layout:setContentSize(520, 60)

   		local taksSprite = ui.createLabelWithBg({
		 	bgFilename = "wgcw_24.png", 
	        labelStr = TR("任 务"),
	        offset = -15,
	        alignType = ui.TEXT_ALIGN_CENTER,   
   			})
   		taksSprite:setPosition(130, 30)
   		layout:addChild(taksSprite)

   		local ModelName = ModuleSubModel.items[v.ModuleId].name
   		local taskLabel = ui.newLabel({
   			text = TR("完成%s%s次   +%s修炼值", ModelName, v.Num, v.IntegralNum),
   			dimensions = cc.size(300, 0),
   			size = 22,
   			color = cc.c3b(0x7b, 0x17, 0x1d)
   			})
   		taskLabel:setAnchorPoint(0, 0.5)
   		taskLabel:setPosition(200, 30)
   		layout:addChild(taskLabel)

   		taskListView:pushBackCustomItem(layout)
   	end
end

--宝箱奖励弹窗
function spremeTreasureLayer:rewardPopView(info)
	local function DIYFuncion(layer, layerBgSprite, layerSize)
		local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(420, 175))
		grayBgSprite:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.5 - 15)
		layerBgSprite:addChild(grayBgSprite)

		local rewardInfo = Utility.analysisStrResList(info.BasicReward)

		--奖励列表
		local rewardList = ui.createCardList({
			maxViewWidth = 370,
	        viewHeight = 120,
	        space = 10,
	        cardDataList = rewardInfo,
	        allowClick = false, 
	        needArrows = true, 
		})
		rewardList:setAnchorPoint(cc.p(0.5, 0.5))
		rewardList:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.5 - 15)
		layerBgSprite:addChild(rewardList)

	end

	MsgBoxLayer.addDIYLayer({
	 	title = TR("%s级宝箱", info.NodeId),
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        btnInfos = {},
        notNeedBlack = true,
        bgSize = cc.size(490, 309)
	})
end

--处理宝箱数据
function spremeTreasureLayer:handleBoxInfo(info, needRefresh)
	local boxInfo = {}
	local tempList = {}	
	for i,v in ipairs(info) do
		table.insert(tempList, v)
		if i%3 == 0 then
			table.insert(boxInfo, tempList)
			tempList = {}
		end
	end 
	if next(tempList) ~= nil then
		table.insert(boxInfo, tempList)
	end
	self.mBoxInfo = boxInfo
	self.mMaxLayerNum = math.ceil(#info/3)

	if needRefresh then
		self.mPageSelectIndex = math.floor((self.mCurBoxIndex-1)/3) + 1
		if self.mPageSelectIndex >= self.mMaxLayerNum then
			self.mPageSelectIndex = self.mMaxLayerNum
		end
		self:refreshTreasureView()
	end
end

-- 活动倒计时
function spremeTreasureLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLable:setString(TR("活动剩余时间：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLable:setString(TR("00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        ui.showFlashView(TR("活动已经结束"))
        LayerManager.removeLayer(self)
    end
end
--=======================================网络请求=============================================
--请求信息
function spremeTreasureLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedValuableBook", 
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data.Value)
            self.mActivityInfo = data.Value.ActivityInfo
            self.mEndTime = data.Value.ActivityInfo.EndTime
            self.mPlayerInfo = data.Value.PlayerInfo
            self.mNodeList = data.Value.ActivityInfo.NodeList
            self.mCurBoxIndex = self.mPlayerInfo.CurNodeId

            self:handleBoxInfo(self.mNodeList, true)

        	self:updateTime()
			self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

            if self.mPlayerInfo.ExtraStatus == 0 then
            	self.mActiveBtn:setEnabled(false)
        	elseif self.mPlayerInfo.ExtraStatus == 2 then
            	self.mActiveBtn:setEnabled(false)
        		self.mActiveBtn:setTitleText(TR("已激活"))
            end
        end
    })
end

--请求激活奖励
function spremeTreasureLayer:requestActive()
    HttpClient:request({
        moduleName = "TimedValuableBook", 
        methodName = "ActiveExtra",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data.Value)
            self.mPlayerInfo = data.Value.PlayerInfo
            self.mNodeList = data.Value.NodeList
            self:handleBoxInfo(self.mNodeList, true)

            if self.mPlayerInfo.ExtraStatus == 0 then
            	self.mActiveBtn:setEnabled(false)
        	elseif self.mPlayerInfo.ExtraStatus == 2 then
            	self.mActiveBtn:setEnabled(false)
        		self.mActiveBtn:setTitleText(TR("已激活"))
            end

            if data.Value.BaseGetGameResourceList then
	        	ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
	        end
        end
    })
end

--激活当前节点
function spremeTreasureLayer:requestActiveCurNode(NodeId)
	HttpClient:request({
        moduleName = "TimedValuableBook", 
        methodName = "ActiveCurNode",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data.Value)
            self.mPlayerInfo = data.Value.PlayerInfo
            self.mCurBoxIndex = self.mPlayerInfo.CurNodeId
            self.mNodeList[NodeId] = data.Value.NodeInfo
            self:handleBoxInfo(self.mNodeList, true)

	        ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

        end
    })
end

--领取额外奖励
function spremeTreasureLayer:requestReceiveReward(NodeId, cardNode)
	HttpClient:request({
        moduleName = "TimedValuableBook", 
        methodName = "ReceiveReward",
        svrMethodData = {NodeId, 1},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data.Value)
            self.mPlayerInfo = data.Value.PlayerInfo
            self.mCurBoxIndex = self.mPlayerInfo.CurNodeId
            self.mNodeList[NodeId] = data.Value.NodeInfo
            self:handleBoxInfo(self.mNodeList)

		    if cardNode.flashNode then
		        cardNode:stopAllActions()
		        cardNode.flashNode:removeFromParent()
		        cardNode.flashNode = nil
		        cardNode:setRotation(0)
		    end
			cardNode:setClickCallback(nil)

    		local hadGetSprite = ui.newSprite("jrhd_108.png")
    		hadGetSprite:setPosition(45, 45)
    		hadGetSprite:setRotation(-45)
    		cardNode:addChild(hadGetSprite, 1000)

	        ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

        end
    })
end

--请求任务信息
function spremeTreasureLayer:requestGetTaskDetail()
    HttpClient:request({
        moduleName = "TimedValuableBook", 
        methodName = "GetTaskDetail",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end

            self.mTaskInfo = data.Value
    		self:createTaskPopView()
        end
    })
end
return spremeTreasureLayer