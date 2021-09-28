--[[
	文件名:NationalDiceLayer.lua
	描述：国庆活动-掷骰子游戏
	创建人：peiyaoqiang
	创建时间：2017.09.22
--]]


local NationalDiceLayer = class("NationalDiceLayer", function(params)
    return display.newLayer()
end)


--[[
--]]
function NationalDiceLayer:ctor()
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 读取配置
    self.diceConfig = DiceConfig.items[1]
    self.diceRewardConfig = DiceRewardModel.items

	-- 初始化页面控件
	self:initUI()

	-- 显示页面
	self:requestGetInfo()
end

-- 初始化页面控件
function NationalDiceLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("jrhd_013.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)
	self.bgSprite = bgSprite

	-- 顶部状态栏
	local topBgSize = cc.size(660, 100)
	local topBgSprite = ui.newScale9Sprite("bp_22.png", topBgSize)
	topBgSprite:setAnchorPoint(cc.p(0.5, 1))
	topBgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(topBgSprite)
	self.topBgSprite = topBgSprite
	self.topBgSize = topBgSize

	-- 添加按钮
	local btnConfigList = {
		{ 	-- 关闭按钮
			image = "c_29.png",
			pos = cc.p(590, 1086),
			action = function ()
				LayerManager.removeLayer(self)
			end
		},
		{ 	-- 规则按钮
			image = "c_72.png",
			pos = cc.p(30, 1086),
			action = function ()
				MsgBoxLayer.addRuleHintLayer(TR("规则"),
	                {
	                    TR("1.活动期间，每天初始拥有10次掷骰子的次数，次日0点重置；每小时自动恢复1次（达到10次上限后不再增加），也可以花费元宝来购买次数"),
	                    TR("2.掷骰子后，玩家将移动对应点数的步数；每个点数对应的奖励不同，完成指定步数后，更可以获得终极大奖"),
	                    TR("3.活动期间，终极大奖的领取次数不做限制，完成指定步数的次数越多，领取的终极大奖次数越多，多拿多得"),
	                    TR("4.遥控骰子可以通过随机宝箱以及充值活动获得，使用遥控骰子可以前进指定步数"),
	                })
			end
		},
		{ 	-- 遥控按钮
			image = "jrhd_01.png",
			pos = cc.p(60, 980),
			typeName = "btnRemoteCtrl",
			action = function ()
				self:btnControlAction()
			end
		},
		{ 	-- 日志按钮
			image = "jrhd_02.png",
			pos = cc.p(60, 880),
			action = function ()
				self:btnLogAction()
			end
		},
		{ 	-- 预览按钮
			image = "c_79.png",
			pos = cc.p(95, 1086),
			action = function ()
				self:createPreviewPop()
			end
		},
	}
	for _,v in ipairs(btnConfigList) do
		local button = ui.newButton({
			normalImage = v.image,
			clickAction = v.action
		})
		button:setPosition(v.pos)
		self.mParentLayer:addChild(button, 1)
		if (v.typeName ~= nil) then
			self[v.typeName] = button
		end
	end

	-- 活动结束时间
	local gameEndNode = ui.newScale9Sprite("c_25.png", cc.size(400, 60))
	gameEndNode:setPosition(320, 1000)
	self.mParentLayer:addChild(gameEndNode)

	local gameEndLabel = ui.newLabel({
		text = "",
		size = 22,
		color = cc.c3b(0xff, 0xfa, 0xda),
        outlineColor = cc.c3b(0x5c, 0x43, 0x40),
	})
	gameEndLabel:setPosition(200, 30)
	gameEndNode:addChild(gameEndLabel)
	self.gameEndLabel = gameEndLabel

	-- 剩余数量
	local remainNode = ui.newScale9Sprite("c_25.png", cc.size(300, 60))
	remainNode:setPosition(320, 940)
	self.mParentLayer:addChild(remainNode)
	self.remainNode = remainNode

	remainNode.refreshNum = function (target, newNum)
		target.remainLabel:setString(TR("剩余骰子数量:%s %d/%d", "#FFE492", newNum, self.diceConfig.numMax))
	end
	remainNode.refreshTime = function (target, lastTime)
		target.recoverLabel:setString(TR("恢复时间%s %s", "#B6FF36", MqTime.formatAsHour(lastTime)))
	end

	-- 剩余次数Label
	local remainLabel = ui.newLabel({
		text = "",
		size = 22,
		color = cc.c3b(0xff, 0xfa, 0xda),
        outlineColor = cc.c3b(0x5c, 0x43, 0x40),
	})
	remainLabel:setPosition(150, 30)
	remainNode:addChild(remainLabel)
	remainNode.remainLabel = remainLabel

	-- 恢复时间Label
	local recoverLabel = ui.newLabel({
		text = "",
		size = 22,
		color = cc.c3b(0xff, 0xfa, 0xda),
        outlineColor = cc.c3b(0x5c, 0x43, 0x40),
	})
	recoverLabel:setPosition(150, -20)
	remainNode:addChild(recoverLabel)
	remainNode.recoverLabel = recoverLabel

	-- 购买次数Button
	local btnAddNum = ui.newButton({
		normalImage = "c_21.png",
		clickAction = function ()
			self:btnBuynumAction()
		end
	})
	btnAddNum:setPosition(300, 30)
	remainNode:addChild(btnAddNum)

	-- 骰子按钮
	local btnSearch = ui.newButton({
		normalImage = "cdjh_1.png",
		clickAction = function ()
			self:btnDiceAction()
		end
	})
	btnSearch:setPosition(320, 380)
	self.mParentLayer:addChild(btnSearch)
	self.btnSearch = btnSearch

    --今日次数限制label
    local totalNumLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eRed,
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    totalNumLabel:setPosition(320, 160)
    self.mParentLayer:addChild(totalNumLabel)
    self.mTotalNumLabel = totalNumLabel
end

-- 创建预览框
function NationalDiceLayer:createPreviewPop()
	if not self.diceInfo then return end
	-- 项数据表
	local itemsData = {}
	-- 构造数据
	for _, info in pairs(self.diceInfo.activityInfo) do
		local item = {}
		item.Num = info.Num
		item.resourceList = Utility.analysisStrResList(info.ResourceList)
		item.title = info.Num..TR("步")

		table.insert(itemsData, item)
	end
	-- 排序
	table.sort(itemsData, function(item1, item2)
		return item1.Num < item2.Num
	end)

	LayerManager.addLayer({
			name = "festival.RewardPreviewPopLayer",
			data = {title = TR("寻宝预览"), itemsData = itemsData},
			cleanUp = false,
		})
end

-- 刷新页面
function NationalDiceLayer:refreshLayer(newDiceInfo, ignoreRewardChange)
	-- 关闭以前的倒计时
	local function stopRecoverAction()
		if (self.remainNode.recoverAction ~= nil) then
			self.remainNode:stopAction(self.remainNode.recoverAction)
			self.remainNode.recoverAction = nil
		end
		self.remainNode.recoverLabel:setString("")
	end
	stopRecoverAction()

	-- 保存新数据
	self.diceInfo = clone(newDiceInfo)

	-- 活动结束时间
	if (newDiceInfo.endDate ~= nil) then
		if (self.gameEndLabel.endAction ~= nil) then
			self.gameEndLabel:stopAction(self.gameEndLabel.endAction)
			self.gameEndLabel.endAction = nil
		end
		self.gameEndLabel.endAction = Utility.schedule(self.gameEndLabel, function()
	    	local lastTime = newDiceInfo.endDate - Player:getCurrentTime()
	        if (lastTime > 0) then
	        	self.gameEndLabel:setString(TR("活动将在%s%s%s后结束", "#B6FF36", MqTime.formatAsHour(lastTime), "#FFFADA"))
	        else
	        	-- 活动结束了关闭页面
	        	LayerManager.removeLayer(self)
	        	return
	        end
	    end, 0.5)
	end
	
	-- 刷新剩余次数
	local nowNum = newDiceInfo.NowNum or 0
	self.remainNode:refreshNum(nowNum)

	-- 刷新倒计时
	if (newDiceInfo.NextRecoverTime > Player:getCurrentTime()) then
		self.remainNode.recoverAction = Utility.schedule(self.remainNode, function()
	    	local lastTime = newDiceInfo.NextRecoverTime - Player:getCurrentTime()
	        if (lastTime > 0) then
	        	self.remainNode:refreshTime(lastTime)
	        else
	        	stopRecoverAction()
	        	self.diceInfo.NowNum = nowNum + 1
	        	self.remainNode:refreshNum(self.diceInfo.NowNum)
	        	return
	        end
	    end, 0.5)
	end

	-- 如果传了该参数，则忽略奖励变化（用于购买骰子数量后的刷新）
	if (ignoreRewardChange ~= nil) and (ignoreRewardChange == true) then
		return
	end

	-- 刷新顶部和底部的奖励显示
	self:refreshTopNode()
	self:refreshBottomNode(function ()
			-- 判断是否有终极奖励
			if (self.diceInfo.GetMaxNumRewardInfo ~= nil) and (self.diceInfo.GetMaxNumRewardInfo.Reward ~= nil) and (self.diceInfo.GetMaxNumRewardInfo.Reward ~= "") then
				LayerManager.addLayer({
					name = "festival.DlgDiceEndRewardLayer",
					data = {rewardStr = self.diceInfo.GetMaxNumRewardInfo.Reward, callback = function ()
							self:refreshMeetAction()
						end},
					cleanUp = false,
				})
			else
				self:refreshMeetAction()
			end
		end)

    self.mTotalNumLabel:setString(TR("今日剩余次数：%d/%d", newDiceInfo.LimitNum, newDiceInfo.TotalNumDaily))

end

-- 刷新顶部显示
function NationalDiceLayer:refreshTopNode()
	-- 大奖循环计算，超过配置的最大值后从头循环
	local currStep = self.diceInfo.TotalDiceNum
	local tempRewardList = clone(self.diceInfo.activityInfo)
	table.sort(tempRewardList, function (a, b)
			return a.Num < b.Num
		end)
	local maxRewardNum = tempRewardList[table.maxn(tempRewardList)].Num
	if (currStep >= maxRewardNum) then
		currStep = math.mod(currStep, maxRewardNum)
	end

	-- 读取下一个大奖
	local nextReward = nil
	for _,v in ipairs(tempRewardList) do
		if (currStep < v.Num) then
			nextReward = clone(v)
			break
		end
	end

	-- 显示大奖
	if (nextReward == nil) then
		return
	end

	-- 剩余步数
	if (self.topBgSprite.remainLabel == nil) then
		local remainLabel = ui.newLabel({
			text = "",
			size = 22,
			color = cc.c3b(0xff, 0xfa, 0xda),
	        outlineColor = cc.c3b(0x5c, 0x43, 0x40),
		})
		remainLabel:setAnchorPoint(cc.p(0, 0.5))
		remainLabel:setPosition(140, self.topBgSize.height * 0.5)
		self.topBgSprite:addChild(remainLabel)
		self.topBgSprite.remainLabel = remainLabel
	end
	local nextStep = tonumber(nextReward.Num or 0)
	self.topBgSprite.remainLabel:setString(TR("还剩%s%d%s步可获得:", "#B6FF36", (nextStep - currStep), "#FFFADA"))

	-- 如果和上次创建的一样，不再重复创建
	if (self.oldResourceList ~= nil) and (self.oldResourceList == nextReward.ResourceList) then
		return
	end
	self.oldResourceList = clone(nextReward.ResourceList)
	if (self.topBgSprite.cardList ~= nil) then
		self.topBgSprite.cardList:removeFromParent()
		self.topBgSprite.cardList = nil
	end

	-- 大奖礼包
 	local rewardList = Utility.analysisStrResList(nextReward.ResourceList)
 	for _, item in pairs(rewardList) do
        item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
    end
    local cardList = ui.createCardList({
        cardDataList = rewardList,
        allowClick = true,
        maxViewWidth = 310,
        viewHeight = self.topBgSize.height,
        space = 10,
    })
    cardList:setAnchorPoint(cc.p(0, 0))
    cardList:setPosition(310, 10)
    cardList:setScale(0.8)
    self.topBgSprite:addChild(cardList)
    self.topBgSprite.cardList = cardList
end

-- 刷新底部显示
function NationalDiceLayer:refreshBottomNode(callFunc)
	-- 创建奖励背景
	local tmpBgNode = self.rewardBgNode
	if (tmpBgNode == nil) then
		tmpBgNode = cc.Node:create()
		tmpBgNode:setContentSize(cc.size(640 - 140, 100))
		tmpBgNode:setAnchorPoint(cc.p(0, 0))
		tmpBgNode:setPosition(140, 20)
		self.mParentLayer:addChild(tmpBgNode)
		self.rewardBgNode = tmpBgNode
	end
	tmpBgNode:stopAllActions()

	-- 创建走动的Q版小人
	-- local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
	-- HeroQimageRelation.items[playerModelId].positivePic
	local positivePic, backPic = QFashionObj:getQFashionByDressType()
	if (self.playerEffect == nil) then
	    self.playerEffect = ui.newEffect({
	        parent = self.mParentLayer,
	        effectName = positivePic,
	        animation = "daiji",
	        scale = 0.6,
	        position = cc.p(50, 30),
	        loop = true,
	        endRelease = false,
	    })
	end

    -- 用来保存所有的奖励宝箱
    if (self.boxNodeList == nil) then
    	self.boxNodeList = {}
    end

    -- 添加一个宝箱奖励
    local function addOneReward(rewardId, posX)
    	-- 宝箱底座
    	local boxBgSprite = ui.newSprite("jrhd_34.png")
		local boxBgSize = boxBgSprite:getContentSize()
		boxBgSprite:setAnchorPoint(cc.p(0.5, 0))
		boxBgSprite:setPosition(posX, 0)
		boxBgSprite:setScale(0.75)
		tmpBgNode:addChild(boxBgSprite)

		-- 宝箱奖励
		local tmpReward = string.splitBySep(DiceRewardModel.items[rewardId].reward, ",")
		local tempCard = CardNode:create({allowClick = true,})
        tempCard:setCardData({resourceTypeSub = tonumber(tmpReward[1]), modelId = tonumber(tmpReward[2]), num = tonumber(tmpReward[3]), cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}})
        tempCard:setAnchorPoint(cc.p(0.5, 0))
        tempCard:setPosition(boxBgSize.width * 0.5, 30)
        boxBgSprite:addChild(tempCard)

        return boxBgSprite
    end

    -- 解析宝箱奖励数据
    local tmpBoxItemList = {}
    for k,v in pairs(self.diceInfo.DiceNumRewardStr) do
    	table.insert(tmpBoxItemList, {diceId = tonumber(k), rewardId = v})
    end
    table.sort(tmpBoxItemList, function (a, b)
    		return a.diceId < b.diceId
    	end)

    -- 重新加载宝箱奖励列表
    local function reloadBoxList()
    	-- 清空以前的所有宝箱
    	for _,v in pairs(self.boxNodeList) do
    		v:removeFromParent()
    	end
    	self.boxNodeList = {}

    	-- 重置背景node的位置（执行动画的时候会将其移动）
    	tmpBgNode:setPosition(140, 20)
    	tmpBgNode:removeAllChildren()

    	-- 重建宝箱预览列表
    	for _,v in ipairs(tmpBoxItemList) do
    		self.boxNodeList[v.diceId] = addOneReward(v.rewardId, (v.diceId - 1) * 90)
    	end
    end
    if (#self.boxNodeList == 0) then
    	reloadBoxList()
    	return callFunc()
    end

    -- 如果转了骰子，则需要把新的奖励和当前的拼接起来
    local getDiceNum = tonumber(self.diceInfo.GetDiceNum)
    local tmpPosX = 540
    for i,v in ipairs(tmpBoxItemList) do
    	if (i > (6 - getDiceNum)) then
    		addOneReward(v.rewardId, tmpPosX)
    		tmpPosX = tmpPosX + 90
    	end
    end

    -- 禁止点击骰子按钮
    self.btnSearch:setEnabled(false)
    self.btnRemoteCtrl:setEnabled(false)

    -- 生成动画
    local actionList = {}
    table.insert(actionList, cc.CallFunc:create(function ()
    		self.playerEffect:setToSetupPose()
    		self.playerEffect:setAnimation(0, "zou", true)
    	end))
    for i=1,getDiceNum do
    	table.insert(actionList, cc.MoveBy:create(0.5, cc.p(-90, 0)))
    	table.insert(actionList, cc.CallFunc:create(function ()
    			self.boxNodeList[i]:removeFromParent()
    			self.boxNodeList[i] = nil
    		end))
    end
    table.insert(actionList, cc.CallFunc:create(function ()
    		reloadBoxList() 	-- 重新reload宝箱，为下次刷新做准备
    		ui.ShowRewardGoods(self.diceInfo.GetRewardList)

    		-- 允许点击骰子按钮
    		self.btnSearch:setEnabled(true)
    		self.btnRemoteCtrl:setEnabled(true)
    		self.playerEffect:setAnimation(0, "daiji", true)
    		callFunc()
    	end))
    tmpBgNode:runAction(cc.Sequence:create(actionList))
end

-- 刷新奇遇显示
function NationalDiceLayer:refreshMeetAction()
	-- 删除以前的奇遇按钮
	if (self.btnMeet ~= nil) then
		self.btnMeet:removeFromParent()
		self.btnMeet = nil
	end
	self.btnSearch:setVisible(false)

	-- 修改一个奇遇的状态为完成
	local function doneOneMeetAction(meetId)
		for _,v in ipairs(self.diceInfo.meetInfo or {}) do
			if (v.Id == meetId) then
				v.IsDone = true
				break
			end
		end
	end

	-- 如果没有奇遇，就重新显示骰子按钮
	local tmpMeet = self:getValidMeet()
	if (tmpMeet == nil) then
		self.btnSearch:setVisible(true)
		return
	end

	-- 显示奇遇按钮
	local meetImgList = {[1] = "jrhd_03.png", [2] = "jrhd_04.png",}
	local btnMeet = ui.newButton({
		normalImage = meetImgList[tmpMeet.TypeId],
		clickAction = function ()
			LayerManager.addLayer({
				name = "festival.NationalSaiziSubLayer",
				data = {subLayerType = tmpMeet.TypeId, guid = tmpMeet.Id, callback = function ()
						doneOneMeetAction(tmpMeet.Id)
						self:refreshMeetAction()
					end},
				cleanUp = false,
			})
		end
	})
	btnMeet:setPosition(320, 380)
	self.mParentLayer:addChild(btnMeet)
	self.btnMeet = btnMeet
	ui.setWaveAnimation(self.btnMeet, 7.5, false, nil)
end

----------------------------------------------------------------------------------------------------

-- 获取可用的奇遇
function NationalDiceLayer:getValidMeet()
	-- 找到第一个可用的奇遇
	local retMeet = nil
	for _,v in ipairs(self.diceInfo.meetInfo or {}) do
		if not v.IsDone then
			retMeet = clone(v)
			break
		end
	end
	return retMeet
end

-- 旋转骰子
function NationalDiceLayer:rorateDice(newNum, callFunc)
	local diceImageList = {
		[1] = "cdjh_1.png", [2] = "cdjh_2.png", [3] = "cdjh_3.png",
		[4] = "cdjh_4.png", [5] = "cdjh_5.png", [6] = "cdjh_6.png",
	}
	local diceImage = diceImageList[newNum]

	-- 防止重复点击
	self.btnRemoteCtrl:setEnabled(false)
	self.btnSearch:setEnabled(false)
	self.btnSearch:setVisible(false)
	self.btnSearch:loadTextures(diceImage, diceImage)

    -- 播放动画，最后再把按钮显示出来
    ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_saizi",
        animation = tostring(newNum),
        position = cc.p(320, 380),
        scale = 0.8,
        loop = false,
        endRelease = true,
        endListener = function ()
        	self.btnSearch:setVisible(true)
		    self.btnSearch:setEnabled(true)
		    self.btnRemoteCtrl:setEnabled(true)
		    callFunc()
    	end
    })
end

-- 购买骰子次数
function NationalDiceLayer:btnBuynumAction()
	-- 判断今日购买次数是否已用完
	if (self.diceInfo.BuyCount >= self.diceConfig.buyNum) then
		ui.showFlashView(TR("今日的购买次数已用完"))
		return
	end

	-- 弹出购买提示框
	LayerManager.addLayer({
		name = "festival.DlgDiceBuyNumLayer",
		data = {
			nowBuyCount = self.diceInfo.BuyCount,
			callback = function (needBuyNum)
				self:requestBuyNum(needBuyNum)
			end
		},
		cleanUp = false,
	})
end

-- 掷骰子按钮
function NationalDiceLayer:btnDiceAction()
	-- 判断是否还有奇遇
	if (self:getValidMeet() ~= nil) then
		ui.showFlashView(TR("请先完成所有的奇遇"))
		return
	end

	-- 判断次数是否用完
	if (self.diceInfo.NowNum == 0) then
		if (self.diceInfo.BuyCount >= self.diceConfig.buyNum) then
			ui.showFlashView(TR("今日的骰子数量已用完"))
		else
			self:btnBuynumAction()
		end
		return
	end

	-- 发送请求
	self:requestSearch()
end

-- 遥控骰子按钮
function NationalDiceLayer:btnControlAction()
	-- 判断是否还有奇遇
	if (self:getValidMeet() ~= nil) then
		ui.showFlashView(TR("请先完成所有的奇遇"))
		return
	end

	-- 弹出选择对话框
	LayerManager.addLayer({
		name = "festival.DlgDiceRemoteCtrlLayer",
		data = {
			callback = function (selectNum)
				self:requestSearch(selectNum, true)
			end
		},
		cleanUp = false,
	})
end

-- 奖励记录按钮
function NationalDiceLayer:btnLogAction()
	LayerManager.addLayer({
		name = "festival.DlgDiceRewardLogLayer",
		data = {rewardStr = self.diceInfo.RewardString},
		cleanUp = false,
	})
end

----------------------------------------------------------------------------------------------------

-- 请求获取信息
function NationalDiceLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedDiceInfo",
        methodName = "GetDiceInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
        	-- dump(data, "GetDiceInfo")
        	-- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 刷新页面
            local tmpInfo = clone(data.Value.TimedDiceInfo)
            tmpInfo.meetInfo = data.Value.DiceMeetInfo
            tmpInfo.activityInfo = data.Value.DiceActivityInfo
            tmpInfo.endDate = data.Value.EndDate
            tmpInfo.TotalNumDaily = data.Value.TotalNum
            tmpInfo.LimitNum = data.Value.LimitNum
            self:refreshLayer(tmpInfo)
        end
    })
end

-- 请求掷骰子
--[[
	useNum : 		指定点数，随机的话可以不传
	isUseGoods : 	是否使用道具，随机的话不用
--]]
function NationalDiceLayer:requestSearch(useNum, isUseGoods)
	local requestParams = {0, 0}
	if (useNum ~= nil) and (useNum >= 1) and (useNum <= 6) then
		local tmpUseGoods = 0
		if (isUseGoods ~= nil) and (isUseGoods == true) then
			tmpUseGoods = 1
		end
		requestParams = {useNum, tmpUseGoods}
	end
	HttpClient:request({
        moduleName = "TimedDiceInfo",
        methodName = "Search",
        svrMethodData = requestParams,
        callbackNode = self,
        callback = function(data)
        	-- dump(data, "Search")
        	-- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 旋转骰子
            self:rorateDice(data.Value.DiceNum, function ()
            		-- 刷新页面
            		local tmpInfo = clone(data.Value.TimedDiceInfo)
		            tmpInfo.meetInfo = data.Value.DiceMeetInfo
		            tmpInfo.activityInfo = data.Value.DiceActivityInfo
		            tmpInfo.GetDiceNum = data.Value.DiceNum 						-- 摇到了几点
		            tmpInfo.GetRewardList = data.Value.BaseGetGameResourceList 		-- 获取的奖励
		            tmpInfo.GetMaxNumRewardInfo = data.Value.GetMaxNumRewardInfo 	-- 终极大奖
                    tmpInfo.LimitNum = data.Value.LimitNum
            		tmpInfo.TotalNumDaily = data.Value.TotalNum
		            self:refreshLayer(tmpInfo)
            	end)
        end
    })
end

-- 请求购买次数
function NationalDiceLayer:requestBuyNum(buyNum)
	HttpClient:request({
        moduleName = "TimedDiceInfo",
        methodName = "BuyDiceCount",
        svrMethodData = {buyNum},
        callbackNode = self,
        callback = function(data)
        	--dump(data, "BuyDiceCount")
        	-- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 刷新次数
            local tmpInfo = clone(self.diceInfo)
            tmpInfo.NowNum = tmpInfo.NowNum + buyNum
            tmpInfo.BuyCount = data.Value.BuyDiceCount
            tmpInfo.NextRecoverTime = data.Value.LastRecoveTime
            self:refreshLayer(tmpInfo, true)
            ui.showFlashView(TR("购买成功"))
        end
    })
end

----------------------------------------------------------------------------------------------------


return NationalDiceLayer
