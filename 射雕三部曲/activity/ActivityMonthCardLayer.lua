--[[
    文件名: ActivityMonthCardLayer.lua
    描述: 月卡页面, 模块Id为：ModuleSub.eExtraActivityMonthCard
    创建人: yanghongsheng
    创建时间: 2017.4.8
--]]

--显示月卡类型
local ShowCradType = {
    eCard30 = 1, --30元月卡
    eCard50 = 2, --50元月卡
}

--[[
    params = {
        cardId      月卡类型
    }
]]

local ActivityMonthCardLayer = class("ActivityMonthCardLayer", function()
    return display.newLayer()
end)

function ActivityMonthCardLayer:ctor(params)
    self.mParentLayer = ui.newStdLayer()   -- 页面元素父节点
    self:addChild(self.mParentLayer)

    -- 当前月卡类型
    self.curCardID = params.cardId or ShowCradType.eCard30
    -- 初始化页面控件
    self:initUI()
    -- 获取网络数据
    self:requestGetCardInfo()
end

function ActivityMonthCardLayer:getRestoreData()
    local retData = {
        cardId = self.curCardID
    }
    return retData
end

-- 初始化页面控件
function ActivityMonthCardLayer:initUI()
     -- 背景
    local bgSprite = ui.newSprite("jchd_35.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)

    -- 提示
    local hintLabel = ui.newLabel({
        text = TR("购买周卡第七天可以领取额外奖励\n任选其中一种奖励"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        align = cc.TEXT_ALIGNMENT_CENTER,
        size = 20
    })
    hintLabel:setAnchorPoint(cc.p(0, 0))
    hintLabel:setPosition(260, 900)
    self.mParentLayer:addChild(hintLabel)

    -- 每日奖励按钮
    local dayRewardBtn = ui.newButton({
            normalImage = "tb_160.png",
            clickAction = function ()
                self:showCardReward(self.curCardID)
            end
        })
    dayRewardBtn:setPosition(cc.p(70, 800))
    self.mParentLayer:addChild(dayRewardBtn)

    -- 累计奖励按钮
    self.mAccumulationRewardBtn = ui.newButton({
            normalImage = "jchd_36.png",
            clickAction = function ()
                self:showAccumulationReward(self.curCardID)
            end
        })
    self.mAccumulationRewardBtn:setPosition(cc.p(170, 800))
    self.mParentLayer:addChild(self.mAccumulationRewardBtn)

    -- 30元月卡
    local monthCard30 = ui.newButton({
        normalImage = "jc_46.png",
        clickAction = function ()
            self:refreshUI(ShowCradType.eCard30)
        end})
    monthCard30:setPosition(70, 650)
    self.card30Btn = monthCard30
    self.mParentLayer:addChild(monthCard30)

    -- 50元月卡
    local monthCard50 = ui.newButton({
        normalImage = "jc_45.png",
        clickAction = function ()
            self:refreshUI(ShowCradType.eCard50)
        end})
    monthCard50:setPosition(200, 650)
    self.card50Btn = monthCard50
    self.mParentLayer:addChild(monthCard50)

    -- 奖励背景
    local rewardBg = ui.newScale9Sprite("c_94.png", cc.size(615, 305))
    rewardBg:setPosition(320, 440)
    self.mParentLayer:addChild(rewardBg)

    -- 奖励总计lable
    local allWorthSprite = ui.newSprite("jc_41.png")
    allWorthSprite:setAnchorPoint(cc.p(0.5, 0.5))
    allWorthSprite:setPosition(cc.p(270, 573))
    self.mParentLayer:addChild(allWorthSprite)

    local titleLabel = ui.newLabel({
            text = "0",
            font = "jc_42.png",
        })
    titleLabel:setAnchorPoint(cc.p(0, 0.5))
    titleLabel:setPosition(315, 573)
    self.mParentLayer:addChild(titleLabel)
    self.allWorthNum = titleLabel

    -- 累计充值过期倒计时
    self.mAccumTimeLabel = ui.newLabel({
    		text = "",
    		color = Enums.Color.eWhite,
	        outlineColor = cc.c3b(0x30, 0x30, 0x30),
	        size = 20,
	        dimensions = cc.size(150, 0),
    	})
    self.mAccumTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mAccumTimeLabel:setPosition(460, 190)
    self.mParentLayer:addChild(self.mAccumTimeLabel)

    -- 列表背景
    local listBg = ui.newScale9Sprite("c_97.png", cc.size(548, 214))
    listBg:setPosition(320, 450)
    self.mParentLayer:addChild(listBg)

    -- 奖励列表
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(548, 204))
    rewardListView:setItemsMargin(6)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0))
    rewardListView:setPosition(320, 350)
    self.mParentLayer:addChild(rewardListView)
    self.rewardListView = rewardListView

    -- 特权
    local addGoldNum, addExpNum = CardAddRelation.items[1][2201].goldAddR, CardAddRelation.items[2][2201].expAddR
    if addExpNum > 0 or addGoldNum > 0 then
        local numLabelBg = ui.newSprite("jc_47.png")
        numLabelBg:setAnchorPoint(cc.p(0, 0.5))
        numLabelBg:setPosition(cc.p(40, 320))
        self.mNumLabelBg = numLabelBg

        self.mParentLayer:addChild(numLabelBg)
        self.mTequanLabl = ui.newLabel({
                text = TR(""),
                size = 22,
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                outlineSize = 2,
            })
        self.mTequanLabl:setAnchorPoint(cc.p(0, 0.5))
        self.mTequanLabl:setPosition(cc.p(80, ui.getImageSize("jc_47.png").height / 2))
        numLabelBg:addChild(self.mTequanLabl)
    end


    -- 剩余天数背景
    local dayBgSize = cc.size(350, 54)
    local residueDayBg = ui.newScale9Sprite("c_25.png", dayBgSize)
    residueDayBg:setPosition(320, 265)
    self.mParentLayer:addChild(residueDayBg)
    -- 剩余天数label
    local residueDayLabel = ui.newLabel({
            text = TR("周卡剩余天数: %s%d天", "#b6ff36", 0),
            color = cc.c3b(0xff, 0xfa, 0xda),
            outlineColor = cc.c3b(0x5c, 0x43, 0x40),
            size = 20,
        })
    residueDayLabel:setAnchorPoint(cc.p(0.5, 0.5))
    residueDayLabel:setPosition(dayBgSize.width*0.5, dayBgSize.height*0.5)
    residueDayBg:addChild(residueDayLabel)
    self.residueDayLabel = residueDayLabel
    -- 购买按钮
    local buyBtn = ui.newButton({
        normalImage = "jc_39.png",
        clickAction = function ()
            LayerManager.showSubModule(ModuleSub.eCharge, {}, true)
        end
        })
    buyBtn:setPosition(320, 190)
    self.buyBtn = buyBtn
    self.mParentLayer:addChild(buyBtn)

    -- 购买就送
    local giveLabel = ui.newLabel({
            text = TR("购买即送%d元宝", 0),
            color = cc.c3b(0xff, 0xfa, 0xda),
            outlineColor = cc.c3b(0x0, 0x0, 0x0),
            size = 20,
        })
    giveLabel:setAnchorPoint(cc.p(0.5, 0.5))
    giveLabel:setPosition(310, 135)
    self.giveLabel = giveLabel
    self.mParentLayer:addChild(giveLabel)
    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)
end

-- 刷新周卡周奖励
function ActivityMonthCardLayer:refreshWeekReward(cardId)
    if not self.mWeekParent then
        self.mWeekParent = cc.Node:create()
        self.mParentLayer:addChild(self.mWeekParent)
    end
    self.mWeekParent:removeAllChildren()

    local monthCardData = self.mCardInfoList[cardId]

    local function weekRewardCard(orderId, pos)
        local rewardData = nil
        for _, rewardInfo in pairs(self.mWeekRewardConfig) do
            if rewardInfo.CardId == cardId and rewardInfo.OrderId == orderId then
                rewardData = rewardInfo
                break
            end
        end

        if not rewardData then return end

        -- 卡牌背景
        local cardBg = ui.newSprite("jchd_33.png")
        cardBg:setPosition(pos)
        self.mWeekParent:addChild(cardBg)

        -- 奖励卡牌
        local cardBgSize = cardBg:getContentSize()
        local rewardInfo = Utility.analysisStrResList(rewardData.Reward)[1]
        rewardInfo.onClickCallback = function ()
            -- 可领取
            if monthCardData.data and monthCardData.data.CanDrawWeekReward then
                self:requestWeekReward(rewardData.CardId, rewardData.OrderId)
            else
                CardNode.defaultCardClick(rewardInfo)
            end
        end
        local rewardCard = CardNode.createCardNode(rewardInfo)
        rewardCard:setPosition(cardBgSize.width*0.5, 175)
        rewardCard:setScale(0.8)
        cardBg:addChild(rewardCard)

        -- 可领取标识
        if monthCardData.data and monthCardData.data.CanDrawWeekReward then
            local canReceiveSprite = ui.newSprite("jchd_34.png")
            canReceiveSprite:setPosition(cardBgSize.width*0.5, 215)
            cardBg:addChild(canReceiveSprite)
        end
    end

    -- 创建三个周奖励
    local rewardPosList = {
        cc.p(318, 700),
        cc.p(420, 725),
        cc.p(521, 700),
    }
    for i = 1, 3 do
        weekRewardCard(i, rewardPosList[i])
    end

    -- 累计领取天数背景
    local labelBg = ui.newSprite("c_25.png")
    labelBg:setPosition(417, 639)
    self.mWeekParent:addChild(labelBg)
    -- 已累计领取天数
    local receiveDay = monthCardData.data and monthCardData.data.ContinuousReceiveDays or 0
    local dayLabel = ui.newLabel({
            text = TR("已累计领取：%d天", receiveDay),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    dayLabel:setPosition(labelBg:getContentSize().width*0.5, labelBg:getContentSize().height*0.5)
    labelBg:addChild(dayLabel)
end

--[[
    描述：显示月卡奖励
    参数：月卡id
]]
function ActivityMonthCardLayer:showCardReward(cardId)
    -- 月卡数据
    local cardInfo = self.mCardInfoList[cardId]

    -- 获取月卡奖励列表
    local dailyRewardList = Utility.analysisStrResList(cardInfo.DailyReward)
    local weekRewardList = Utility.analysisStrResList(cardInfo.DailyReward)

    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 周奖励背景
        local weekRewardBg = ui.newSprite("jc_40.png")
        weekRewardBg:setPosition(bgSize.width*0.5, bgSize.height*0.77)
        bgSprite:addChild(weekRewardBg)
        -- -- 周奖励卡
        -- local weekBgSize = weekRewardBg:getContentSize()
        -- weekRewardList[1].cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        -- local weekRewardCard = CardNode.createCardNode(weekRewardList[1])
        -- weekRewardCard:setPosition(weekBgSize.width*0.8, weekBgSize.height*0.5)
        -- weekRewardBg:addChild(weekRewardCard)
        -- 列表背景
        local listBgSize = cc.size(454, 252)
        local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
        listBg:setPosition(bgSize.width*0.5, bgSize.height*0.4)
        bgSprite:addChild(listBg)
        -- 每日奖励列表
        local rewardListView = ccui.ListView:create()
        rewardListView:setDirection(ccui.ScrollViewDir.vertical)
        rewardListView:setBounceEnabled(true)
        rewardListView:setContentSize(listBgSize)
        rewardListView:setItemsMargin(6)
        rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
        rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
        rewardListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
        listBg:addChild(rewardListView)
        -- 刷新奖励列表
        self.refreshRewardList({
            listData = dailyRewardList,
            listViewObj = rewardListView,
            colNum = 4,
            itemWidth = listBgSize.width,
            itmeHeight = 107,
            isCellBg = false
        })
    end

    -- 弹窗
    local boxSize = cc.size(510, 542)
    LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            cleanUp = false,
            data = {
                notNeedBlack = true,
                bgSize = boxSize,
                title = TR("每日奖励"),
                DIYUiCallback = DIYfunc,
                closeBtnInfo = {},
            }
        })
end

--[[
    描述：显示累计奖励
]]
function ActivityMonthCardLayer:showAccumulationReward(cardId)
	-- 周档位
	local weekAddList = table.keys(self.mCardRewardAddConfig[cardId])
	table.sort(weekAddList, function (week1, week2)
		return week1 < week2
	end)
	-- 提示还需充值周数列表
	local hintList = {}
	for _, rewardInfo in ipairs(self.mCardTotalRewardConfig[cardId]) do
		if rewardInfo.WeekNum > self.mCardTotalInfo[cardId].TotalWeekNum then
			table.insert(hintList, rewardInfo)
		end
	end
	-- 当前达到的最大档位
	local curMaxWeek = 0
	for _, rewardInfo in ipairs(self.mCardTotalRewardConfig[cardId]) do
		if rewardInfo.WeekNum <= self.mCardTotalInfo[cardId].TotalWeekNum then
    		curMaxWeek = rewardInfo.WeekNum
    	else
    		break
    	end
	end

    local function DIYfunc(boxRoot, bgSprite, bgSize)
    	local addRNum = self.mCardRewardAddConfig[cardId][self.mCardTotalInfo[cardId].TotalWeekNum] or 0
    	if self.mCardTotalInfo[cardId].TotalWeekNum >= weekAddList[#weekAddList] then
    		addRNum = self.mCardRewardAddConfig[cardId][weekAddList[#weekAddList]]
    	end
    	-- 玩家累计充值多少周
    	local addRLabel = ui.newLabel({
    			text = TR("玩家累计充值%s周，每日额外获取%s%%奖励！", self.mCardTotalInfo[cardId].TotalWeekNum, addRNum),
    			color = cc.c3b(0x46, 0x22, 0x0d),
    		})
    	addRLabel:setPosition(bgSize.width*0.5, bgSize.height-80)
    	bgSprite:addChild(addRLabel)
    	-- 补充说明
    	local tempLabel = ui.newLabel({
    			text = TR("（额外三选一奖励不享受加成）"),
    			color = cc.c3b(0x46, 0x22, 0x0d),
    		})
    	tempLabel:setPosition(bgSize.width*0.5, bgSize.height-105)
    	bgSprite:addChild(tempLabel)
    	-- 还需充值周数
    	for i, rewardInfo in ipairs(hintList) do
    		local needHintLabel = ui.newLabel({
    			text = TR("还需连续充值%s周，获得连续%s周累计充值大礼", rewardInfo.WeekNum - self.mCardTotalInfo[cardId].TotalWeekNum, rewardInfo.WeekNum),
    			color = cc.c3b(0x46, 0x22, 0x0d),
    			size = 20,
    		})
	    	needHintLabel:setPosition(bgSize.width*0.5, bgSize.height-105-i*22)
	    	bgSprite:addChild(needHintLabel)
    	end
        -- 列表背景
        local listBgSize = cc.size(532, 354)
        local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
        listBg:setPosition(bgSize.width*0.5, 277)
        bgSprite:addChild(listBg)
        -- 累计奖励列表
        local rewardListView = ccui.ListView:create()
        rewardListView:setDirection(ccui.ScrollViewDir.vertical)
        rewardListView:setBounceEnabled(true)
        rewardListView:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-10))
        rewardListView:setItemsMargin(6)
        rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
        rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
        rewardListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
        listBg:addChild(rewardListView)

        local itemSize = cc.size(rewardListView:getContentSize().width, 170)

        boxRoot.refreshList = function ( ... )
        	rewardListView:removeAllItems()
        	-- 筛选列表
        	local tempList = {}
        	for _, rewardInfo in ipairs(self.mCardTotalRewardConfig[cardId]) do
        		if rewardInfo.WeekNum >= curMaxWeek then
        			table.insert(tempList, rewardInfo)
        		end
        	end

        	for i, rewardInfo in ipairs(tempList) do
        		local rewardItem = ccui.Layout:create()
        		rewardItem:setContentSize(itemSize)
        		rewardListView:pushBackCustomItem(rewardItem)
        		-- 背景
        		local itemBgSprite = ui.newScale9Sprite("c_54.png", cc.size(itemSize.width, 165))
        		itemBgSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
        		rewardItem:addChild(itemBgSprite)
        		-- 题目
        		local nextWeekNum = tempList[i+1] and tempList[i+1].WeekNum or nil
        		local titleLabel = ui.newLabel({
        				text = nextWeekNum and TR("连续充值%s-%s周，每周续费获得", rewardInfo.WeekNum, nextWeekNum-1) or TR("连续充值%s周后，每周续费获得", rewardInfo.WeekNum),
        				color = Enums.Color.eWhite,
        				outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        			})
        		titleLabel:setPosition(itemSize.width*0.5, itemSize.height-25)
        		rewardItem:addChild(titleLabel)
        		-- 奖励列表
        		local rewardList = Utility.analysisStrResList(rewardInfo.Reward)
        		local cardList = ui.createCardList({
        				maxViewWidth = 500,
        				cardDataList = rewardList,
        			})
        		cardList:setAnchorPoint(cc.p(0.5, 0.5))
        		cardList:setPosition(itemSize.width*0.5, itemSize.height-105)
        		rewardItem:addChild(cardList)
        		-- 若已领取
        		if self.mReceivedTotalList[cardId][rewardInfo.WeekNum] then
        			for _, cardNode in pairs(cardList:getCardNodeList()) do
        				local tagSprite = ui.newSprite("jc_21.png")
        				tagSprite:setPosition(cardNode:getContentSize().width*0.5, cardNode:getContentSize().height*0.5)
        				cardNode:addChild(tagSprite)
        			end
        		end
        	end

		    local canGetWeekNum = nil  -- 能领取奖励
		    for _, rewardInfo in ipairs(self.mCardTotalRewardConfig[cardId]) do
		    	if rewardInfo.WeekNum <= self.mCardTotalInfo[cardId].TotalWeekNum and rewardInfo.WeekNum >= curMaxWeek
			    	and not self.mReceivedTotalList[cardId][rewardInfo.WeekNum] then
		    		canGetWeekNum = rewardInfo.WeekNum
		    	end
		    end
        	-- 领取按钮
        	if boxRoot.getBtn then
        		boxRoot.getBtn:removeFromParent()
        		boxRoot.getBtn = nil
        	end
        	local getBtn = ui.newButton({
        			text = canGetWeekNum and TR("领取") or TR("确定"),
        			normalImage = "c_28.png",
            		clickAction = function ()
            			if canGetWeekNum then
            				self:requestAccumReward(cardId, canGetWeekNum)
            			else
                			LayerManager.removeLayer(boxRoot)
                		end
            		end
        		})
        	getBtn:setPosition(bgSize.width*0.5, 60)
        	bgSprite:addChild(getBtn)
        	boxRoot.getBtn = getBtn
        end

        boxRoot.refreshList()
    end
    -- 弹窗
    local boxSize = cc.size(589, 575+#hintList*22)
    self.mAccumBox = LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            cleanUp = false,
            data = {
                notNeedBlack = true,
                bgSize = boxSize,
                title = TR("累计奖励"),
                DIYUiCallback = DIYfunc,
                closeBtnInfo = {},
                btnInfos = {},
            }
        })
end

-- 创建倒计时
function ActivityMonthCardLayer:createTimeUpdate(cardId)
    if self.timeUpdate then
        self.mAccumTimeLabel:stopAction(self.timeUpdate)
        self.timeUpdate = nil
    end

    self.timeUpdate = Utility.schedule(self.mAccumTimeLabel, function ()
        local timeLeft = self.mCardTotalInfo[cardId].NextCalcEndDate - Player:getCurrentTime()
    	if Player:getCurrentTime() < self.mCardTotalInfo[cardId].NextCalcDate then
    		timeLeft = 0
    	end
        if timeLeft > 0 then
            self.mAccumTimeLabel:setString(TR("累计周卡过期倒计时:  #ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mAccumTimeLabel:stopAction(self.timeUpdate)
            self.timeUpdate = nil
            self.mAccumTimeLabel:setString("")
        end
    end, 1.0)
end

--[[
    params = {
        listData        -- 列表数据(必要)
        listViewObj     -- 列表对象(必要)
        colNum          -- 列数(默认 4)
        itemWidth       -- 项宽度(默认 536)
        itmeHeight      -- 项高度(默认 107)
        isCellBg        -- 是否有项背景(默认 false)
    }
]]
-- 刷新奖励列表
function ActivityMonthCardLayer.refreshRewardList(params)
    -- 清除原来数据
    params.listViewObj:removeAllItems()
    -- 判断存在
    if params.listData == nil then return end
    -- 判断有序
    if table.maxn(params.listData) > #params.listData then
        local tempList = {}
        for i, v in pairs(params.listData) do
            tempList[i] = v
        end
        params.listData = tempList
    end
    -- 列数
    local colNum = params.colNum or 4
    -- 行数
    local rowNum = math.ceil(#params.listData / colNum)
    -- 一项宽度
    local itemWidth = params.itemWidth or 536
    -- 一项高度
    local itmeHeight = params.itmeHeight or 107
    -- 间隔
    local interval = itemWidth/colNum
    -- 遍历列表
    for i = 0, rowNum - 1 do
        -- 创建项
        local cellItem = ccui.Layout:create()
        cellItem:setContentSize(cc.size(itemWidth, itmeHeight))
        params.listViewObj:pushBackCustomItem(cellItem)
        -- 背景
        if params.isCellBg then
            local cellBg = ui.newScale9Sprite("c_96.png", cc.size(itemWidth, 80))
            cellBg:setPosition(itemWidth*0.5, -20)
            cellItem:addChild(cellBg)
        end
        -- 道具
        for j = 1, colNum do
            -- 边界检查
            local index = i*colNum + j
            if index > #params.listData then break end
            -- 生成卡片
            local cardData = params.listData[index]
            cardData.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
            local cardObj = CardNode.createCardNode(cardData)
            cardObj:setPosition(interval*j-60, itmeHeight*0.5)
            cellItem:addChild(cardObj)
        end
    end
end

-- 刷新界面
function ActivityMonthCardLayer:refreshUI(cardId)
    -- dump(self.mCardInfoList)
    -- 月卡数据
    local monthCardData = self.mCardInfoList[cardId]
    -- 刷新当前月卡类型
    self.curCardID = cardId
    -- 刷新列表
    local totalRewardList = Utility.analysisStrResList(monthCardData.DailyReward)
    -- 奖励*7为总奖励
    for _, rewardInfo in ipairs(totalRewardList) do
        rewardInfo.num = rewardInfo.num*monthCardData.ContinueTime
    end
    self.refreshRewardList({
        listData = totalRewardList,
        listViewObj = self.rewardListView,
        colNum = 4,
        itemWidth = 536,
        itmeHeight = 107,
        isCellBg = true
    })
    -- 刷新按钮
    local addGoldNum, addExpNum = CardAddRelation.items[1][2201].goldAddR, CardAddRelation.items[2][2201].expAddR

    if cardId == ShowCradType.eCard30 then
        self.card30Btn:loadTextureNormal("jc_44.png")
        self.card50Btn:loadTextureNormal("jc_45.png")
        if self.mNumLabelBg and self.mTequanLabl then
            self.mTequanLabl:setString(TR("所有系统金币获取增加%d%%", addGoldNum / 100))
            self.mNumLabelBg:setVisible(addExpNum > 0)
        end

    elseif cardId == ShowCradType.eCard50 then
        self.card30Btn:loadTextureNormal("jc_46.png")
        self.card50Btn:loadTextureNormal("jc_43.png")
        if self.mNumLabelBg and self.mTequanLabl then
            self.mTequanLabl:setString(TR("所有系统经验获取增加%d%%", addExpNum / 100))
            self.mNumLabelBg:setVisible(addGoldNum > 0)
        end
    end
    -- 刷新购买按钮状态
    self:refreshBtn(monthCardData)
    -- 刷新总价值
    self.allWorthNum:setString(tostring(monthCardData.totalPrice))
    -- 刷新剩余天数
    local remainTime = (monthCardData.data) and (monthCardData.data.ExpireTime - Player:getCurrentTime()) or 0
    remainTime = math.max(remainTime, 0)
    self.residueDayLabel:setString(TR("周卡剩余天数: %s%d天", "#b6ff36", MqTime.toHour(remainTime)))
    -- 刷新购买送的元宝数
    local giveNum = Utility.analysisStrResList(monthCardData.BuyReward)[1]
    self.giveLabel:setString(TR("购买即送%d元宝", giveNum.num))

    -- 创建小红点
    local cardBtnList = {self.card30Btn, self.card50Btn}
    local cardIdList = {ShowCradType.eCard30, ShowCradType.eCard50}
    for i,btn in ipairs(cardBtnList) do
        local cardData = self.mCardInfoList[cardIdList[i]].data
        if not btn.redDotSprite then
            -- 小红点不存在时创建新的
            local btnSize = btn:getContentSize()
            btn.redDotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.8, btnSize.height * 0.8)})
            btn:addChild(btn.redDotSprite)
        end
        -- 当日可领或激活奖励存在
        btn.redDotSprite:setVisible(cardData and (cardData.CanDrawBuyReward or cardData.CanDrawTodayReward))
    end
    -- 累计奖励小红点
    if not self.mAccumulationRewardBtn.redDotSprite then
    	local btnSize = self.mAccumulationRewardBtn:getContentSize()
        self.mAccumulationRewardBtn.redDotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.8, btnSize.height * 0.8)})
        self.mAccumulationRewardBtn:addChild(self.mAccumulationRewardBtn.redDotSprite)
    end
    -- 是否存在累计奖励
    for i,btn in ipairs(cardBtnList) do
		-- 当前达到的最大档位
		local curMaxWeek = 0
		for _, rewardInfo in ipairs(self.mCardTotalRewardConfig[i]) do
			if rewardInfo.WeekNum <= self.mCardTotalInfo[i].TotalWeekNum then
	    		curMaxWeek = rewardInfo.WeekNum
	    	else
	    		break
	    	end
		end

	    -- 能领取奖励
	    local canGetWeekNum = nil
	    for _, rewardInfo in ipairs(self.mCardTotalRewardConfig[i]) do
	    	if rewardInfo.WeekNum <= self.mCardTotalInfo[i].TotalWeekNum and rewardInfo.WeekNum >= curMaxWeek
		    	and not self.mReceivedTotalList[i][rewardInfo.WeekNum] then
	    		canGetWeekNum = rewardInfo.WeekNum
	    	end
	    end
	    -- 两个档位按钮小红点
	    local oldIsVisible = btn.redDotSprite:isVisible()
	    local newIsVisible = canGetWeekNum and true or false
	    btn.redDotSprite:setVisible(oldIsVisible or newIsVisible)
	    -- 累计奖励按钮小红点
	    if self.curCardID == i then
	    	self.mAccumulationRewardBtn.redDotSprite:setVisible(newIsVisible)
	    end
    end

    -- 刷新周卡奖励
    self:refreshWeekReward(cardId)
    -- 累计周卡奖励过期倒计时
    self:createTimeUpdate(cardId)
end

-- 更新按钮状态
function ActivityMonthCardLayer:refreshBtn(cardData)
    -- 检查按钮存在
    if self.buyBtn ~= nil then
        self.buyBtn:removeFromParent()
    end
    -- 获取按钮坐标
    local btnPos = cc.p(320, 190)
    -- 按钮大小
    local btnSize = cc.size(160, 65)
    -- 没有购买该月卡
    local remainTime = (cardData.data) and (cardData.data.ExpireTime - Player:getCurrentTime()) or 0
    if cardData.data == nil or remainTime < 0 then
        local buyBtn = ui.newButton({
                normalImage = "jc_39.png",
                clickAction = function ()
                    LayerManager.showSubModule(ModuleSub.eCharge, {}, true)
                end
                })
        buyBtn:setPosition(btnPos)
        self.mParentLayer:addChild(buyBtn)
        self.buyBtn = buyBtn
    -- 未领取激活奖励
    elseif cardData.data.CanDrawBuyReward then
        local buyBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取激活奖励"),
                size = btnSize,
                clickAction = function ()
                    self:requestBuyReward(cardData.CardId)
                end
                })
        buyBtn:setPosition(btnPos)
        self.mParentLayer:addChild(buyBtn)
        self.buyBtn = buyBtn
    -- 未领取每日奖励
    elseif cardData.data.CanDrawTodayReward then
        local buyBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取每日奖励"),
                size = btnSize,
                clickAction = function ()
                    self:requestDayReward(cardData.CardId)
                end
                })
        buyBtn:setPosition(btnPos)
        self.mParentLayer:addChild(buyBtn)
        self.buyBtn = buyBtn
    -- 已领取
    else
        local buyBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("已领取"),
                size = btnSize,
                clickAction = function ()
                end
                })
        buyBtn:setPosition(btnPos)
        buyBtn:setEnabled(false)
        self.mParentLayer:addChild(buyBtn)
        self.buyBtn = buyBtn
    end
end


---------------------------网络相关-------------------------------
-- 请求服务器，获取月卡信息
function ActivityMonthCardLayer:requestGetCardInfo()
    HttpClient:request({
        moduleName = "CardInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- dump(data.Value)

            self.mWeekRewardConfig = data.Value.CardRewardConfig or {}
            -- 根据配置表中的月卡id获取服务器返回的相应月卡信息
            local function getCardData(cardId)
                for i = 1, table.maxn(data.Value.CardInfo) do
                    if data.Value.CardInfo[i].CardId == cardId then
                        return data.Value.CardInfo[i]
                    end
                end

                return nil
            end

            self.mCardInfoList = {}
            for _, card in pairs(data.Value.CardConfig) do
                card.data = getCardData(card.CardId)
                card.totalPrice = CardModel.items[card.CardId].totalPrice
                self.mCardInfoList[card.CardId] = card
            end

            -- 累计奖励配置
            self.mCardTotalRewardConfig = {}
            self.mCardTotalRewardConfig[ShowCradType.eCard30] = {}
            self.mCardTotalRewardConfig[ShowCradType.eCard50] = {}
            for _, rewardInfo in pairs(data.Value.CardTotalRewardConfig) do
            	self.mCardTotalRewardConfig[rewardInfo.CardId] = self.mCardTotalRewardConfig[rewardInfo.CardId] or {}
            	table.insert(self.mCardTotalRewardConfig[rewardInfo.CardId], rewardInfo)
            end
            for _, totalRewardConfig in pairs(self.mCardTotalRewardConfig) do
	            -- 排序
	            table.sort(totalRewardConfig, function (rewardInfo1, rewardInfo2)
	            	return rewardInfo1.WeekNum < rewardInfo2.WeekNum
	        	end)
            end
            -- 累计奖励加成
            self.mCardRewardAddConfig = {}
            self.mCardRewardAddConfig[ShowCradType.eCard30] = {}
            self.mCardRewardAddConfig[ShowCradType.eCard50] = {}
            for _, addInfo in pairs(data.Value.CardRewardAddConfig) do
            	self.mCardRewardAddConfig[addInfo.CardId][addInfo.WeekNum] = addInfo.AddRatio
            end
            -- 当前累计奖励数据
            self.mCardTotalInfo = {}
            self.mCardTotalInfo[ShowCradType.eCard30] = {}
            self.mCardTotalInfo[ShowCradType.eCard50] = {}
            for cardId, totalInfo in pairs(data.Value.CardTotalInfo) do
            	self.mCardTotalInfo[cardId] = totalInfo
            end

            -- 已领取累计奖励
            self.mReceivedTotalList = {}
            self.mReceivedTotalList[ShowCradType.eCard30] = {}
            self.mReceivedTotalList[ShowCradType.eCard50] = {}
            for cardId, totalInfo in pairs(self.mCardTotalInfo) do
	            local tempList = string.splitBySep(totalInfo.DrawTotalRewardStr or "", ",")
	            for _, weekNum in pairs(tempList) do
	            	self.mReceivedTotalList[cardId][tonumber(weekNum)] = true
	            end
            end

            self:refreshUI(self.curCardID)

            -- 创建累计周卡充值过期时间
            self:createTimeUpdate(self.curCardID)
        end
    })
end

-- 领取每日奖励
function ActivityMonthCardLayer:requestDayReward(cardId)
    local monthCardData = self.mCardInfoList[cardId]
    if monthCardData.data and monthCardData.data.ContinuousReceiveDays >= 6 and monthCardData.data.CanDrawWeekReward then
        ui.showFlashView(TR("请先选择您的三选一大奖"))
        return
    end

    HttpClient:request({
        moduleName = "CardInfo",
        methodName = "DrawDailyReward",
        svrMethodData = {cardId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self:requestGetCardInfo()
        end
    })
end

-- 领取激活奖励
function ActivityMonthCardLayer:requestBuyReward(cardId)
    HttpClient:request({
        moduleName = "CardInfo",
        methodName = "DrawBuyReward",
        svrMethodData = {cardId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self:requestGetCardInfo()
        end
    })
end

-- 领取周奖励
function ActivityMonthCardLayer:requestWeekReward(cardId, orderId)
    HttpClient:request({
        moduleName = "CardInfo",
        methodName = "DrawExtraReward",
        svrMethodData = {cardId, orderId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self:requestGetCardInfo()
        end
    })
end

-- 领取累计奖励
function ActivityMonthCardLayer:requestAccumReward(cardId, weekNum)
    HttpClient:request({
        moduleName = "CardInfo",
        methodName = "DrawTotalReward",
        svrMethodData = {cardId, weekNum},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 当前累计奖励数据
            self.mCardTotalInfo = {}
            self.mCardTotalInfo[ShowCradType.eCard30] = {}
            self.mCardTotalInfo[ShowCradType.eCard50] = {}
            for cardId, totalInfo in pairs(data.Value.CardTotalInfo) do
            	self.mCardTotalInfo[cardId] = totalInfo
            end

            -- 已领取累计奖励
            self.mReceivedTotalList = {}
            self.mReceivedTotalList[ShowCradType.eCard30] = {}
            self.mReceivedTotalList[ShowCradType.eCard50] = {}
            for cardId, totalInfo in pairs(self.mCardTotalInfo) do
	            local tempList = string.splitBySep(totalInfo.DrawTotalRewardStr or "", ",")
	            for _, weekNum in pairs(tempList) do
	            	self.mReceivedTotalList[cardId][tonumber(weekNum)] = true
	            end
            end

            if not tolua.isnull(self.mAccumBox) then
	            self.mAccumBox.refreshList()
	        end

	        self:refreshUI(self.curCardID)
        end
    })
end

return ActivityMonthCardLayer
