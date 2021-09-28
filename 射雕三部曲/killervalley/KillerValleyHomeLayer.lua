--[[
    文件名：KillerValleyHomeLayer.lua
	描述：绝情谷匹配界面（也是主界面）
	创建人：yanghongsheng
	创建时间：2018.1.22
-- ]]
require("killervalley.KillerValleyHelper")
require("killervalley.KillerValleyUiHelper")

local KillerValleyHomeLayer = class("KillerValleyHomeLayer", function(params)
    return display.newLayer()
end)

function KillerValleyHomeLayer:ctor()
	-- 服务器数据
    self.mServerData = {}
    -- 当前过去时间
    self.mCurTime = 0

	-- 创建标准容器
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eLoveFlower, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    self:initUI()

    self:requestInfo()
end

function KillerValleyHomeLayer:onEnterTransitionFinish()
    -- 打完一场绝情谷后清缓存
    cc.Director:getInstance():purgeCachedData()
end

function KillerValleyHomeLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("jqg_5.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	-- 标题
	local titleSprite = ui.newSprite("jqg_3.png")
	titleSprite:setPosition(320, 1000)
	self.mParentLayer:addChild(titleSprite)
	-- 树枝
	local branchSprite = ui.newSprite("jqg_8.png")
	branchSprite:setAnchorPoint(cc.p(1, 0.5))
	branchSprite:setPosition(640, 180)
	self.mParentLayer:addChild(branchSprite)
	-- 树枝2
	local branchSprite2 = ui.newSprite("jqg_8.png")
	branchSprite2:setFlippedX(true)
	branchSprite2:setAnchorPoint(cc.p(0, 0.5))
	branchSprite2:setPosition(0, 180)
	self.mParentLayer:addChild(branchSprite2)
	-- 赛季结束倒计
	self.mCountDownLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        bgSize = cc.size(380, 45),
        labelStr = TR("本赛季倒计时:%s", MqTime.formatAsDay(0)),
        color = cc.c3b(0x20, 0xff, 0x09),
        outlineColor = cc.c3b(0x21, 0x46, 0x21),
        alignType = ui.TEXT_ALIGN_CENTER
    })
    self.mCountDownLabel:setPosition(320, 930)
    self.mParentLayer:addChild(self.mCountDownLabel)
	-- 按钮
	self:createBtnList()
	-- 选择的探子头像
	local retinueHead = CardNode:create({
            allowClick = true,
            onClickCallback = function(sender)
            	self:selectHero()
            end,
        })
    retinueHead:setEmpty({}, "c_04.png")
    retinueHead:showGlitterAddMark()
    retinueHead:setPosition(80, 230)
    retinueHead:setVisible(false)
    self.mParentLayer:addChild(retinueHead)
    self.mRetinueHeadCard = retinueHead
    -- 正在匹配显示
    self.mMatchLabel = ui.newLabel({
    		text = "",
    		color = Enums.Color.eWhite,
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    		size = 24,
    	})
    self.mMatchLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mMatchLabel:setPosition(240, 320)
    self.mParentLayer:addChild(self.mMatchLabel)
    -- 选择侠客按钮
    local selectHeroBtn = ui.newButton({
    		normalImage = "jqg_49.png",
    		clickAction = function ()
    			self:selectHero()
    		end,
    	})
    selectHeroBtn:setPosition(100, 230)
    self.mParentLayer:addChild(selectHeroBtn)
    self.mSelectHeroBtn = selectHeroBtn
	-- 开始匹配按钮
	local matchBtn = ui.newButton({
			normalImage = "jqg_20.png",
			clickAction = function ()
				if not self.mServerData.FormationInfo or not self.mServerData.FormationInfo.HeroModelId or self.mServerData.FormationInfo.HeroModelId == 0 then
					ui.showFlashView({text = TR("还未选择侠客，请先选择侠客")})
					return
				end
				self:requestMatch()
			end,
		})
	matchBtn:setPosition(550, 230)
	self.mParentLayer:addChild(matchBtn)
	self.mMatchBtn = matchBtn
	-- 取消匹配按钮
	local cancelMatchBtn = ui.newButton({
			normalImage = "jqg_56.png",
			clickAction = function ()
				local cancelRet = KillerValleyHelper:cancelMatch(function (retValue)
					if retValue.Code == 0 then
					    ui.showFlashView(TR("取消匹配!"))

					    -- 刷新界面
					    if self and not tolua.isnull(self) then
						    self:requestInfo()
						end
					end
				end)
                if not cancelRet then
                    KillerValleyUiHelper:exitGame(true)
                end
			end,
		})
	cancelMatchBtn:setPosition(550, 230)
	self.mParentLayer:addChild(cancelMatchBtn)
	self.mCancelMatchBtn = cancelMatchBtn

    -- 注册匹配成功的通知事件
    Notification:registerAutoObserver(self.mMatchBtn, function ()
        LayerManager.addLayer({name = "killervalley.KillerValleyMapLayer"})
    end, {KillerValleyHelper.Events.eEnterBattle})
end

-- 更新倒计时
function KillerValleyHomeLayer:updateCountDown()
	local function refreshCountDown()
	    local lastTime = self.mServerData.EndTime - Player:getCurrentTime()
	    if lastTime <= 0 or self.mServerData.SeasonState == 0 then
	        local str = TR("每日%s到%s开放", KillervalleyConfig.items[1].startTime, KillervalleyConfig.items[1].endTime)
	        self.mCountDownLabel:setString(str)
	        self.mCountDownLabel:stopAllActions()
	        self.mCountDownSche = nil
	    else
	        self.mCountDownLabel:setString(TR("本赛季倒计时:%s", MqTime.formatAsDay(lastTime)))
	    end
	end

    -- 赛季倒计时
    if self.mServerData.EndTime and self.mServerData.EndTime - Player:getCurrentTime() > 0 and self.mServerData.SeasonState == 1 then
        -- 刷新倒计时
        if self.mCountDownSche then
            self.mCountDownLabel:stopAllActions()
            self.mCountDownSche = nil
        end
        self.mCountDownSche = Utility.schedule(self.mCountDownLabel, function()
                refreshCountDown()
            end, 1)
    else
        self.mCountDownLabel:setString(TR("每日%s到%s开放", KillervalleyConfig.items[1].startTime, KillervalleyConfig.items[1].endTime))
    end
end

-- 跳转选择侠客界面
function KillerValleyHomeLayer:selectHero()
	if self.mServerData.IsMatch then
		return 
	end

	if self.mServerData and self.mServerData.EndTime then
	    if self.mServerData.EndTime - Player:getCurrentTime() <= 0 then
	        ui.showFlashView({text = TR("不在战斗时间，不能选将")})
			return 
	    end
	end

	LayerManager.addLayer({
		name = "killervalley.KillerValleySelectLayer",
		data = {
			formation = self.mServerData.FormationInfo or {},
			callback = function (formationInfo)
				self.mServerData.FormationInfo = clone(formationInfo)
				self:refreshUI()
			end,
		},
		cleanUp = false,
	})
end 

function KillerValleyHomeLayer:createBtnList()
	local btnList = {
		-- 排行榜
		{
			normalImage = "jqg_18.png",
			position = cc.p(320, 820),
			clickAction = function ()
				LayerManager.addLayer({
						name = "killervalley.KillerValleyRankLayer",
						cleanUp = false,
					})
			end,
		},
		-- 战绩
		{
			normalImage = "jqg_16.png",
			position = cc.p(160, 640),
			clickAction = function ()
				self:requestReport()
			end,
		},
		-- 每日奖励
		{
			normalImage = "jqg_19.png",
			position = cc.p(480, 640),
			checkRedDotFunc = function()  -- 显示小红点判断函数
                return RedDotInfoObj:isValid(ModuleSub.eKillerValley)
            end,
			clickAction = function ()
				self.rewardBox = self:showRewardBox()
			end,
		},
		-- 商店
		{
			normalImage = "jqg_17.png",
			position = cc.p(320, 460),
			clickAction = function ()
				LayerManager.addLayer({
						name = "killervalley.KillerValleyShopLayer",
						cleanUp = false,
					})
			end,
		},
		-- 规则
		{
			normalImage = "c_72.png",
			position = cc.p(45, 1035),
            isGuide = true,
			clickAction = function ()
				LayerManager.addLayer({
						name = "killervalley.KillerValleyRuleLayer",
						cleanUp = false,
					})

                -- 结束引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10034 then
                    Guide.manager:nextStep(eventID, true)
                    Guide.manager:removeGuideLayer()
                end
			end,
		},
		-- 返回
		{
			normalImage = "c_29.png",
			position = cc.p(595, 1035),
			clickAction = function ()
				LayerManager.removeLayer(self)
			end,
		},
	}

	for _, btnInfo in pairs(btnList) do
		local tempBtn = ui.newButton(btnInfo)
		self.mParentLayer:addChild(tempBtn)
        -- 保存引导使用
        if btnInfo.isGuide then
            self.mRuleBtn = tempBtn
        end

		-- 小红点逻辑
        if btnInfo.checkRedDotFunc then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(btnInfo.checkRedDotFunc())
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = {EventsName.eRedDotPrefix..ModuleSub.eKillerValley}, parent = tempBtn})
        end
	end
end

-- 每日奖励弹窗
function KillerValleyHomeLayer:showRewardBox()
	local bgSize = cc.size(587, 669)
	local rewardLayer = require("commonLayer.PopBgLayer").new({
			title = TR("每日奖励"),
			bgSize = bgSize,
		})
	self:addChild(rewardLayer)
	-- 背景
	local bgSprite = rewardLayer.mBgSprite
	-- 奖励数据列表
	local rewardData = {}
	for _, rewardInfo in pairs(KillervalleyAttackRewardRelation.items) do
		table.insert(rewardData, rewardInfo)
	end
	table.sort(rewardData, function (item1, item2)
		return item1.needPoint < item2.needPoint
	end)
	-- 当前分数
	local fightScore = self.mServerData.FightScore or 0
	-- 已获得积分
	local scoreLabel = ui.createSpriteAndLabel({
			imgName = "c_63.png",
			labelStr = TR("今日已获得积分#d17b00%d", fightScore),
			fontColor = cc.c3b(0x46, 0x22, 0x0d),
			fontSize = 25,
			alignType = ui.TEXT_ALIGN_RIGHT,
		})
	scoreLabel:setAnchorPoint(cc.p(0, 0.5))
	scoreLabel:setPosition(40, 580)
	bgSprite:addChild(scoreLabel)
	-- 列表背景
	local listBgSize = cc.size(518, 517)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setPosition(bgSize.width*0.5, bgSize.height*0.5-40)
	bgSprite:addChild(listBg)
	-- 列表控件
	local listView = ccui.ListView:create()
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-10))
	listView:setAnchorPoint(cc.p(0.5, 0.5))
	listView:setPosition(listBgSize.width * 0.5, listBgSize.height*0.5)
	listView:setItemsMargin(15)
	listBg:addChild(listView)
	-- 创建奖励项
	local function createItem(rewardInfo, rewardStateList)
		local cellSize = cc.size(502, 159)
		local cellItem = ccui.Layout:create()
		cellItem:setContentSize(cellSize)

		-- 条目背景
		local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
		bgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
		cellItem:addChild(bgSprite)

		-- 描述
		local labelStr = TR("每日获得#d17b00%d#46220d积分，可获得以下奖励", rewardInfo.needPoint)
		local descLabel = ui.newLabel({
			text = labelStr,
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		descLabel:setAnchorPoint(cc.p(0.5, 1))
		descLabel:setPosition(cellSize.width * 0.5, cellSize.height * 0.95)
		cellItem:addChild(descLabel)

		-- 奖励
		local rewardList = Utility.analysisStrResList(rewardInfo.reward)
		local reward = ui.createCardList({
			maxViewWidth = 340,
			cardDataList = rewardList,
		})
		reward:setAnchorPoint(cc.p(0, 0.5))
		reward:setPosition(10, cellSize.height * 0.4)
		cellItem:addChild(reward)

		-- 领取按钮
		-- 已领取
		if fightScore >= rewardInfo.needPoint and not rewardStateList[tostring(rewardInfo.needPoint)] then
			local hadGet = ui.createSpriteAndLabel({
                imgName = "c_156.png",
                labelStr = TR("已领取"),
                fontSize = 24,
	        })
	        hadGet:setPosition(cellSize.width * 0.85, cellSize.height * 0.5)
	        cellItem:addChild(hadGet)
		else
			local getBtn = ui.newButton({
				normalImage = "c_28.png",
				text = TR("领取"),
				clickAction = function()
					self:requestReward(rewardInfo.needPoint)
				end
			})
			getBtn:setPosition(cellSize.width * 0.85, cellSize.height * 0.5)
			cellItem:addChild(getBtn)

			getBtn:setEnabled(rewardStateList[tostring(rewardInfo.needPoint)] and true or false)
		end

		return cellItem
	end

	rewardLayer.refreshList = function()
		listView:removeAllChildren()
		-- 领取状态
		local stateList = string.splitBySep(self.mServerData.RewardState or "", ",")
		local tempList = {}
		for key, value in pairs(stateList) do
			tempList[value] = key
		end
		stateList = tempList
		-- 填充列表
		for i, rewardInfo in ipairs(rewardData) do
			local cellItem = createItem(rewardInfo, stateList)
			listView:pushBackCustomItem(cellItem)
		end
	end

	rewardLayer.refreshList()

	return rewardLayer
end

-- 战绩弹窗
function KillerValleyHomeLayer:showRecordBox(recordDataList)
	local bgSize = cc.size(587, 669)
	local recordLayer = require("commonLayer.PopBgLayer").new({
			title = TR("战绩"),
			bgSize = bgSize,
		})
	self:addChild(recordLayer)
	-- 背景
	local bgSprite = recordLayer.mBgSprite

	-- 创建列表
	if recordDataList and next(recordDataList) then
		-- 列表背景
		local listBgSize = cc.size(518, 557)
		local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
		listBg:setPosition(bgSize.width*0.5, bgSize.height*0.5-15)
		bgSprite:addChild(listBg)
		-- 列表控件
		local listView = ccui.ListView:create()
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-10))
		listView:setAnchorPoint(cc.p(0.5, 0.5))
		listView:setPosition(listBgSize.width * 0.5, listBgSize.height*0.5)
		listView:setItemsMargin(5)
		listBg:addChild(listView)
		-- 填充列表
		for _, recordInfo in ipairs(recordDataList) do
			-- 项大小
			local cellSize = cc.size(listView:getContentSize().width, 130)
			-- 创建项
			local cellItem = ccui.Layout:create()
			cellItem:setContentSize(cellSize)
			listView:pushBackCustomItem(cellItem)
			-- 背景
			local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
			bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
			cellItem:addChild(bgSprite)
			-- 单人匹配
			local tagLabel = ui.newLabel({
					text = TR("单人匹配"),
					color = cc.c3b(0x46, 0x22, 0x0d),
					size = 24,
				})
			tagLabel:setAnchorPoint(cc.p(0, 0.5))
			tagLabel:setPosition(20, cellSize.height*0.5)
			cellItem:addChild(tagLabel)
			-- 排名
			local rankLabel = ui.newLabel({
					text = TR("排名: #ffdd80%d", recordInfo.Rank),
					color = Enums.Color.eWhite,
					outlineColor = Enums.Color.eOutlineColor,
					size = 22,
				})
			rankLabel:setAnchorPoint(cc.p(0, 0.5))
			rankLabel:setPosition(cellSize.width*0.35, cellSize.height*0.75)
			cellItem:addChild(rankLabel)
			-- 击杀数
			local killNumLabel = ui.newLabel({
					text = TR("击杀数: #ffb380%d", recordInfo.KillNum),
					color = Enums.Color.eWhite,
					outlineColor = Enums.Color.eOutlineColor,
					size = 22,
				})
			killNumLabel:setAnchorPoint(cc.p(0, 0.5))
			killNumLabel:setPosition(cellSize.width*0.35, cellSize.height*0.5)
			cellItem:addChild(killNumLabel)
			-- 获得积分
			local getScoreLabel = ui.newLabel({
					text = TR("获得积分: #96e5ff%d", recordInfo.FightScore),
					color = Enums.Color.eWhite,
					outlineColor = Enums.Color.eOutlineColor,
					size = 22,
				})
			getScoreLabel:setAnchorPoint(cc.p(0, 0.5))
			getScoreLabel:setPosition(cellSize.width*0.35, cellSize.height*0.25)
			cellItem:addChild(getScoreLabel)
			-- 玩家头像
			local headCard = CardNode.createCardNode({
		 			resourceTypeSub = ResourcetypeSub.eHero,
		 	        modelId = PlayerAttrObj:getPlayerAttrByName("HeadImageId"),
		 	        fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
		 	        cardShowAttrs = {CardShowAttr.eBorder},
		 	        allowClick = false,
		 		})
		 	headCard:setPosition(cellSize.width*0.85, cellSize.height*0.6)
		 	cellItem:addChild(headCard)
		 	-- 玩家名
		 	local colorLv = Utility.getColorLvByModelId(PlayerAttrObj:getPlayerAttrByName("HeadImageId"), ResourcetypeSub.eHero)
		 	local playeName = ui.newLabel({
		 			text = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
		 			color = Utility.getColorValue(colorLv, 1),
		 			outlineColor = Enums.Color.eOutlineColor,
		 			size = 22,
		 		})
		 	playeName:setPosition(cellSize.width*0.85, cellSize.height*0.15)
		 	cellItem:addChild(playeName)
		end
	else
		-- 空提示
		local emptyHint = ui.createEmptyHint(TR("暂无战绩"))
		emptyHint:setPosition(bgSize.width*0.5, bgSize.height*0.5)
		bgSprite:addChild(emptyHint)
	end
end

-- 刷新界面
function KillerValleyHomeLayer:refreshUI()
	-- 匹配显示
	self:beginMatch()

	-- 挂机惩罚计时
	local timeLeft = 0
	if self.mServerData.HangUpResetTime then
		timeLeft = self.mServerData.HangUpResetTime - Player:getCurrentTime()
	end
	if timeLeft > 0 and not self.punishTimeSchedule then
		local punishLabel = ui.newLabel({
				text = "",
				color = Enums.Color.eRed,
				outlineColor = Enums.Color.eOutlineColor,
			})
		punishLabel:setAnchorPoint(cc.p(1, 0))
		punishLabel:setPosition(620, 200)
		self.mParentLayer:addChild(punishLabel)

		self.punishTimeSchedule = Utility.schedule(self, function ()
			local timeLeft = self.mServerData.HangUpResetTime - Player:getCurrentTime()
			if timeLeft > 0 then
				punishLabel:setString(TR("挂机惩罚: %s", MqTime.formatAsHour(timeLeft)))
			else
				if self.punishTimeSchedule then
					self:stopAction(self.punishTimeSchedule)
					self.punishTimeSchedule = nil
				end
			end
		end, 1)
	end

	-- 随从头像
	if self.mServerData.FormationInfo and self.mServerData.FormationInfo.HeroModelId and self.mServerData.FormationInfo.HeroModelId ~= 0 then
		self.mRetinueHeadCard:setHero({ModelId = self.mServerData.FormationInfo.HeroModelId})

		self.mRetinueHeadCard:setVisible(true)
		self.mSelectHeroBtn:setVisible(false)
	else
		self.mRetinueHeadCard:setVisible(false)
		self.mSelectHeroBtn:setVisible(true)
	end

	-- 开始匹配按钮
	if self.mServerData.IsMatch then
		self.mMatchBtn:setVisible(false)
		self.mCancelMatchBtn:setVisible(true)
	else
		self.mMatchBtn:setVisible(true)
		self.mCancelMatchBtn:setVisible(false)
	end

	-- 更新赛季到计时
	self:updateCountDown()
end

-- 显示正在匹配
function KillerValleyHomeLayer:beginMatch()
	-- 显示字符串
	self.mMatchLabel:setVisible(self.mServerData.IsMatch)

	if self.mServerData.IsMatch then
		-- 匹配字符串
		local matchTextList = {
			TR("正在匹配中"),
			TR("正在匹配中 ."),
			TR("正在匹配中 . ."),
			TR("正在匹配中 . . ."),
		}

		-- 循环播放
		local count = 0
		if not self.timeSchedule or tolua.isnull(self.timeSchedule) then
			self.timeSchedule = Utility.schedule(self, function ()
				count = (count % #matchTextList)
				
				self.mMatchLabel:setString(matchTextList[count+1])
				
				count = count + 1
			end, 1)
		end
	else
		if self.timeSchedule and not tolua.isnull(self.timeSchedule) then
			self:stopAction(self.timeSchedule)
			self.timeSchedul = nil
		end
	end
end

-- 根据状态刷新页面
function KillerValleyHomeLayer:dealWithState()
    -- 判断当前状态
    if self.mServerData.GameModuleId == ModuleSub.eKillerValley  and (self.mServerData.State == 3 or self.mServerData.State == 2) then
        -- 已经连接了匹配战斗
        KillerValleyHelper:setUrl(self.mServerData.IP)
        KillerValleyHelper:connect(function(retValue)
            if retValue == nil and self.mServerData.State == 3 then
                -- 手动通知进入战场页面
                Notification:postNotification(KillerValleyHelper.Events.eEnterBattle)
            end
        end)
    end
end


--=======================网络相关=====================
-- 请求初始信息
function KillerValleyHomeLayer:requestInfo()
	HttpClient:request({
		moduleName = "KillerValley",
		methodName = "GetData",
		svrMethodData = {},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			self.mServerData = response.Value
			-- 当前匹配状态
			self.mServerData.IsMatch = self.mServerData.State == 2 and self.mServerData.GameModuleId == ModuleSub.eKillerValley
			-- 当前匹配计时
			self.mCurTime = 0

			-- 刷新界面
			self:refreshUI()

			-- 已经连接了匹配战斗
			self:dealWithState()
		end
	})
end

-- 开始匹配
function KillerValleyHomeLayer:requestMatch()
	if self.mServerData and self.mServerData.EndTime then
	    if self.mServerData.EndTime - Player:getCurrentTime() <= 0 then
	        ui.showFlashView(TR("不在战斗时间内，请稍后重试！"))
	        return
	    end
	end

	if self.mServerData and self.mServerData.HangUpResetTime then
	    if self.mServerData.HangUpResetTime - Player:getCurrentTime() > 0 then
	        ui.showFlashView(TR("挂机惩罚中，请稍后重试！"))
	        return
	    end
	end

	if self.mServerData and self.mServerData.GameModuleId and self.mServerData.GameModuleId > 0 and self.mServerData.GameModuleId ~= ModuleSub.eKillerValley and self.mServerData.State == 2 then
	    ui.showFlashView(TR("%s正在匹配中，请取消后重试！", ModuleSubModel.items[self.mServerData.GameModuleId].name))
	    return
	end

	-- 断开桃花岛连接
	require("shengyuan.ShengyuanWarsHelper")
	ShengyuanWarsHelper:leave()

	HttpClient:request({
		moduleName = "KillerValley",
		methodName = "StartMatch",
		svrMethodData = {},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			self.mServerData.IP = response.Value.SocketServerIP
			self.mServerData.State = 2

			self.mServerData.IsMatch = true
			self:refreshUI()

			-- 已经连接了匹配战斗
            self:dealWithState()
		end
	})
end

-- 领取每日奖励
function KillerValleyHomeLayer:requestReward(score)
	HttpClient:request({
		moduleName = "KillerValley",
		methodName = "DrawChallengeReward",
		svrMethodData = {score},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			-- 刷新奖励领取
			self.mServerData.RewardState = response.Value.RewardState
			-- 显示奖励
			ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
			-- 刷新领取界面
			if self.rewardBox and not tolua.isnull(self.rewardBox) then
				self.rewardBox.refreshList()
			end
		end
	})
end

-- 获取战报数据
function KillerValleyHomeLayer:requestReport()
	HttpClient:request({
		moduleName = "KillerValley",
		methodName = "GetReportData",
		svrMethodData = {},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			-- 因为服务器按时间排序，这里将其逆序(最新一场在最上面)
			local reportList = {}
			for i = 1, #response.Value do
				local reportInfo = table.remove(response.Value, #response.Value)
				table.insert(reportList, reportInfo)
			end

			self:showRecordBox(reportList)
		end
	})
end

----------------- 新手引导 -------------------
function KillerValleyHomeLayer:onEnterTransitionFinish()
    self:executeGuide()
end
-- 执行新手引导
function KillerValleyHomeLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向规则
        [10034] = {clickNode = self.mRuleBtn},
    })
end

return KillerValleyHomeLayer