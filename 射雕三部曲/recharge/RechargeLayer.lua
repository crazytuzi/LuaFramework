--[[
	文件名：RechargeLayer.lua
	描述：充值页面
	创建人：lengjiazhi
	创建时间：2017.5.30
--]]
local RechargeLayer = class("RechargeLayer", function(params)
	return display.newLayer()
end)

function RechargeLayer:ctor(params)
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

	-- 初始化数据
    self.mCloseCallBack = params.closeCallBack      -- 本页面关闭时的回调
	self.mTabInfoList = {} 					        -- 顶部，充值类型信息列表
	self.mChargeInfoList = {}  				        -- 底部，充值信息列表，由服务器返回
	self.mCardInfoList = {}      			        -- 底部，月卡信息列表，由服务器返回

	-- 初始化UI
	self:initUI()
    -- 请求服务器，获取玩家充值信息
    self:requestGetChargeList()
end

-- 添加UI相关元素
function RechargeLayer:initUI()
	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 背景图片
    self.mBgSpr = ui.newSprite(PlayerAttrObj:getPlayerAttrByName("Vip") > Utility.getVipStep() and "cz_26.jpg" or "cz_02.jpg")
    self.mBgSpr:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSpr)
    -- 背景大小
    self.mBgSize = self.mBgSpr:getContentSize()
    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        --anchorPoint = cc.p(1, 1),
        position = cc.p(608, 1099),
        clickAction = function()
            if self.mCloseCallBack then
                self.mCloseCallBack()
            end

            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn, 10)

    -- 切换详情/充值按钮
    local isCharge = true
    self.mChangeBtn = ui.newButton({
    	normalImage = "c_83.png",
    	titleImage = "cz_09.png",
    	size = cc.size(125, 116),
        position = cc.p(572, 46),
        clickAction = function(pSender)
        	if isCharge then
        		pSender.titleSprite:setTexture("cz_10.png")
        		self:vipViewLayer()
        		isCharge = false
        	else
        		pSender.titleSprite:setTexture("cz_09.png")
        		self:requestGetChargeList()
        		isCharge = true
        	end
        end
    	})
    self.mParentLayer:addChild(self.mChangeBtn)

    -- 当前vip等级
    self.mVipLevel = ui.newLabel({
    	text = 19,
    	font = "c_49.png",
    	})
    self.mVipLevel:setPosition(102, 47)
    self.mParentLayer:addChild(self.mVipLevel)
    --进度条
	-- 现在拥有的vip等级与经验
	local currVip = PlayerAttrObj:getPlayerAttrByName("Vip")
	local currVipExp = PlayerAttrObj:getPlayerAttrByName("VipEXP")
	local currVipNeedExp = VipModel.items[currVip].expTotal

    self.mVipProgressBar = require("common.ProgressBar"):create({
        bgImage = "cz_11.png",
        barImage = "cz_12.png",
		currValue = 20,
 	   	maxValue = 100,
        needLabel = true,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x1f, 0x10, 0x10)
    })
    self.mVipProgressBar:setPosition(320, 30)
    self.mParentLayer:addChild(self.mVipProgressBar)
    --充值升级提示
    self.mVipNeedLabel = ui.newLabel({
    	text = TR("测试文字111111"),
    	color = cc.c3b(0xff, 0xf8, 0xac),
    	outlineColor = cc.c3b(0x64, 0x29, 0x28),
    	size = 20,
    	})
    self.mVipNeedLabel:setPosition(320, 60)
    self.mParentLayer:addChild(self.mVipNeedLabel)

    -- 提示“理性消费”
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
        local consumeLabel = ui.newLabel({
            text = TR("请适度娱乐，理性消费（赠送元宝不参与活动）"),
            color = Enums.Color.eBlack,
            size = 22,
            })
        consumeLabel:setPosition(320, 105)
        self.mParentLayer:addChild(consumeLabel)
    end

    --详情/充值子页面父节点
    self.mSubLayer = display.newLayer()
	self.mParentLayer:addChild(self.mSubLayer)
	self:refreshBottomView()
end
--刷新下方的显示信息
function RechargeLayer:refreshBottomView()
	 -- Vip等级描述
    local maxVIP = VipModel.items_count - 1
    local descStr = nil
    local nextVIP = nil
    local nextVipEXP = nil

	local curVIP = PlayerAttrObj:getPlayerAttrByName("Vip")
	local curVipExp = PlayerAttrObj:getPlayerAttrByName("VipEXP")

    if curVIP < maxVIP then
        nextVIP = curVIP + 1
        nextVipEXP = VipModel.items[nextVIP].expTotal
        -- 下一级Vip所需的经验与当前经验的差值 / 10 = X(元人民币)，10为人民币与元宝的换算比例
        local needCoin = math.ceil(nextVipEXP - curVipExp) * 2
        descStr = TR("再充值%d元宝升至VIP%d", needCoin, nextVIP)
        if needCoin < 0 then
            descStr = TR("充值任意金额激活新的vip等级")
        end
    else
        nextVIP = maxVIP
        descStr = TR("已经到达VIP%d最高等级！", maxVIP)
		nextVipEXP = VipModel.items[maxVIP].expTotal
    end
	if curVIP >= maxVIP then
		self.mVipProgressBar:setVisible(false)
	end
	self.mVipProgressBar:setMaxValue((nextVipEXP - VipModel.items[curVIP].expTotal) * 2)
	self.mVipProgressBar:setCurrValue((curVipExp - VipModel.items[curVIP].expTotal) * 2)

    self.mBgSpr:setTexture(PlayerAttrObj:getPlayerAttrByName("Vip") > Utility.getVipStep() and "cz_26.jpg" or "cz_02.jpg")
    self.mVipLevel:setString(curVIP > Utility.getVipStep() and curVIP-Utility.getVipStep() or curVIP)
    self.mVipNeedLabel:setString(descStr)
end
--=============================充值部分=====================
--创建顶部广告
function RechargeLayer:topAdView()

	local imgList = {"cz_07.png", "cz_08.png"}
    local isOpenChristmasActivity = ActivityObj:haveMainActivity(ModuleSub.eChristmasActivity)
	local callbackList = {
		[1] = function()
                local activityInfo = ActivityObj:getActivityInfo()
                if activityInfo and next(activityInfo) then
    				LayerManager.addLayer({
    					name = "activity.ActivityMainLayer",
    					data = {moduleId = ModuleSub.eTimedActivity},
    				})
                else
                    ui.showFlashView(TR("活动暂未开启"))
                end
			end,
		[2] = function()
                local activityInfo = ActivityObj:getActivityInfo()
                if activityInfo and next(activityInfo) then
    				LayerManager.addLayer({
    					name = "activity.ActivityMainLayer",
    					data = {moduleId = isOpenChristmasActivity and ModuleSub.eChristmasActivity or ModuleSub.eTimedActivity},
    				})
                else
                    ui.showFlashView(TR("活动暂未开启"))
                end
			end,
		}

	local function addAdOneView(itemNode, index)
		local bgSprite = ui.newButton({
			normalImage = imgList[index + 1],
			clickAction = callbackList[index + 1]
			-- end
			})
		bgSprite:setPosition(320, 135)
		itemNode:addChild(bgSprite)
	end

	-- 创建分页滑动控件
    self.mTopSliderView = ui.newSliderTableView({
        width = 640,
        height = 270,
        isVertical = false,
        selectIndex = 0,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return #imgList
        end,
        itemSizeOfSlider = function(sliderView)
            return 640, 270
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index, isSelected)
            addAdOneView(itemNode, index)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    self.mTopSliderView:setPosition(320, self.mBgSize.height)
    self.mTopSliderView:setAnchorPoint(0.5, 1)
    self.mSubLayer:addChild(self.mTopSliderView)
    -- 不可通过左右滑动来翻页，只能通过点击左右按钮来翻页
    -- self.mTopSliderView:setTouchEnabled(false)
    self.mTopSliderView:setSelectItemIndex(0)

    local tempNum = 0
    local tempIndex = 0
	self:scheduleUpdate(function(dt)
		tempNum = tempNum + 1
		if tempNum >= 100 then
			tempNum = 0
			tempIndex = tempIndex + 1
			self.mTopSliderView:setSelectItemIndex(tempIndex, true)
			if tempIndex >= 3 then
				tempIndex = -1
			end
		end
	end)
end

-- 充值展示部分
function RechargeLayer:chargeViewLayer()
	self.mSubLayer:removeAllChildren()
	--创建顶部广告
	self:topAdView()

	--提示文字
	local tipLabel = ui.newLabel({
		text = TR("周卡参与所有充值活动"),
		color = cc.c3b(0x46, 0x22, 0x0d),
		size = 24,
		})
	tipLabel:setPosition(320, 842)
	self.mSubLayer:addChild(tipLabel)

    local function mouthCardRechargeFunc(cardInfo, index)
        -- mqkk 开启内部充值
        local channelName = IPlatform:getInstance():getConfigItem("Channel")
        if channelName == "MQKK" then
            self:requestActivityCard(index)
            return
        end
        -- 判断充值是否可用
        -- if not IPlatform:getInstance():isRechargeSupported() then
        --     ui.showFlashView({
        --         text = TR("暂未开放充值")
        --     })
        --     return
        -- end
        self.mIsMonthCard = true
        self:requestGenerateOrderID("CardInfo",
            "GenerateOrderID",
            {monthCardId = cardInfo.CardId, ChargePoint = cardInfo.price}
        )
    end

	local function monthCardCallfunc(index)
		local cardInfo = self.mCardInfoList[index]
		if cardInfo.data then
            local remanTime = cardInfo.data.ExpireTime - Player:getCurrentTime()
            if remanTime > 0 then
                ui.showFlashView({
                    text = TR("周卡还在有效期内")
                })
                return
            end
        end

        if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
            MsgBoxLayer.addOKCancelLayer(
                TR("是否花费NT$%d购买%s？", cardInfo.price, cardInfo.name),
                TR("提示"),
                {
                    text = TR("确定"),
                    clickAction = function(layerObj)
                        mouthCardRechargeFunc(cardInfo, index)
                        LayerManager.removeLayer(layerObj)
                    end
                })
        else
            mouthCardRechargeFunc(cardInfo, index)
        end
	end

	--30月卡
	local monthCardS = ui.newButton({
		normalImage = "cz_06.png",
		clickAction = function ()
			monthCardCallfunc(1)
		end

		})
	monthCardS:setPosition(161, 734)
	self.mSubLayer:addChild(monthCardS)
	self.mMonthCardS = monthCardS

	--经验加成
	local addGoldNum, addExpNum = CardAddRelation.items[1][2201].goldAddR, CardAddRelation.items[2][2201].expAddR
	-- if addGoldNum > 0 then
	-- 	local expLabel = ui.newLabel({
	-- 		text =  addGoldNum / 100,
	-- 		font = "cz_20.png",
	-- 		size = 22,
	-- 	})
	-- 	expLabel:setPosition(ui.getImageSize("cz_06.png").width / 2 - 20, ui.getImageSize("cz_06.png").height / 2 - 2)
	-- 	monthCardS:addChild(expLabel)
	-- end

	--50月卡
	local monthCardB = ui.newButton({
		normalImage = "cz_05.png",
		clickAction = function ()
			monthCardCallfunc(2)
		end
		})
	monthCardB:setPosition(479, 734)
	self.mSubLayer:addChild(monthCardB)
	self.mMonthCardB = monthCardB

	-- --金币加成
	-- if addExpNum > 0 then
	-- 	local goldLabel = ui.newLabel({
	-- 		text = addExpNum / 100,
	-- 		font = "cz_20.png",
	-- 		size = 22,
	-- 	})
	-- 	goldLabel:setPosition(ui.getImageSize("cz_05.png").width / 2 - 30, ui.getImageSize("cz_05.png").height / 2 - 2)
	-- 	monthCardB:addChild(goldLabel)
	-- end

	self.mBuySpriteS = ui.newSprite("cz_16.png")
	self.mBuySpriteS:setPosition(159, 25)
	self.mMonthCardS:addChild(self.mBuySpriteS)

	self.mBuySpriteB = ui.newSprite("cz_16.png")
	self.mBuySpriteB:setPosition(159, 25)
	self.mMonthCardB:addChild(self.mBuySpriteB)

	--充值部分背景
	local bgSprite = ui.newScale9Sprite("c_97.png", cc.size(626, 514))
	bgSprite:setPosition(320, 378)
	self.mSubLayer:addChild(bgSprite)

	self.mChargeListView = ccui.ListView:create()
    self.mChargeListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mChargeListView:setBounceEnabled(true)
    self.mChargeListView:setContentSize(cc.size(626, 514))
    self.mChargeListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mChargeListView:setAnchorPoint(cc.p(0.5, 1))
    self.mChargeListView:setPosition(320, 635)
    self.mSubLayer:addChild(self.mChargeListView)

end

function RechargeLayer:refreshMonthCard()

    local function createTimeShow(cardIndx, parent, visibleNode)
        if self.mCardInfoList[cardIndx].data then
            visibleNode:setVisible(false)
            local timeLeft = MqTime.toHour(self.mCardInfoList[cardIndx].data.ExpireTime - Player:getCurrentTime())
            local hourTime = MqTime.formatAsDay(self.mCardInfoList[cardIndx].data.ExpireTime - Player:getCurrentTime())
            local timeLabel = ui.newLabel({
                text = TR("剩余时间: #9dff77%s", timeLeft > 0 and timeLeft..TR("天") or hourTime),
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x52, 0x52, 0x52),
                size = 22,
                })
            timeLabel:setPosition(159, 25)
            parent:addChild(timeLabel)

            return timeLabel
        end
    end

    local timeLabelList = {}
    timeLabelList[1] = createTimeShow(1, self.mMonthCardS, self.mBuySpriteS)
    timeLabelList[2] = createTimeShow(2, self.mMonthCardB, self.mBuySpriteB)

    local function refreshTimeLabel(cardIndx)
        if self.mCardInfoList[cardIndx].data and not tolua.isnull(timeLabelList[cardIndx]) then
            local timeLeft = self.mCardInfoList[cardIndx].data.ExpireTime - Player:getCurrentTime()
            if timeLeft < 0 then
                timeLabelList[cardIndx]:setString(TR("剩余时间: #9dff7700:00:00"))
            else
                local day = MqTime.toHour(timeLeft)
                local hourTime = MqTime.formatAsDay(timeLeft)
                timeLabelList[cardIndx]:setString(TR("剩余时间: #9dff77%s", day > 0 and day..TR("天") or hourTime))
            end
        end
    end

    if self.cardTimeUpdate then
        self:stopAction(self.cardTimeUpdate)
        self.cardTimeUpdate = nil
    end

    self.cardTimeUpdate = Utility.schedule(self, function ()
        refreshTimeLabel(1)
        refreshTimeLabel(2)
    end, 1)
end

-- 充值列表
function RechargeLayer:refreshChargeList()
	self.mChargeListView:removeAllChildren()


    for i = 1, #self.mChargeInfoList do
    	self.mChargeListView:pushBackCustomItem(self:lineList(i))
    end
end

function RechargeLayer:lineList(index)
	local layout = ccui.Layout:create()
	layout:setContentSize(618, 228)

	local underSprite = ui.newScale9Sprite("c_96.png", cc.size(618, 35))
	underSprite:setPosition(309, 20)
	layout:addChild(underSprite)

	local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    listView:setTouchEnabled(false)
    listView:setContentSize(cc.size(618, 228))
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(309, 122)
    layout:addChild(listView)

    for i = 1, #self.mChargeInfoList[index] do
    	local info = self.mChargeInfoList[index][i]
    	local oneCell = ccui.Layout:create()
    	oneCell:setContentSize(198, 213)

        if info.isPointCard then        -- 点卡
            local buyBtn = ui.newButton({
                    normalImage = "fl_7.png",
                    position = cc.p(115, 106),
                    clickAction = function ()
                        local payData = {
                            level = tostring(PlayerAttrObj:getPlayerAttrByName("Lv")),
                        }

                        local jstr = json.encode(payData)

                        IPlatform:getInstance():invoke("OpenGDPay",jstr, function(jsonStr) 
                            local data = cjson.decode(jsonStr)
                            if data["ret"] == "0" then
                                ui.showFlashView(TR("点卡充值成功"))
                            else
                                --失败
                                ui.showFlashView(TR("点卡充值失败"))
                            end
                        end)
                    end
                })
            oneCell:addChild(buyBtn)
        else
        	--背景板
        	local bgSprite = ui.newSprite("cz_03.png")
        	bgSprite:setPosition(115, 106)
        	oneCell:addChild(bgSprite)

        	--顶部元宝数
        	local priceTag = ui.newLabel({
        		text = TR("%s元宝", info.GamePoint),
        		color = cc.c3b(0xff, 0xf4, 0xc1),
        		size = 22,
        		})
        	priceTag:setPosition(115, 180)
        	oneCell:addChild(priceTag)

            local function rechargeBtnAction(info)
                -- mqkk 开启内部充值
                local channelName = IPlatform:getInstance():getConfigItem("Channel")
                if channelName == "MQKK" then
                    self:requestTestRecharge(info.ChargePoint)
                    return
                end
                -- 判断充值是否可用
                -- if not IPlatform:getInstance():isRechargeSupported() then
                --     ui.showFlashView({
                --         text = TR("暂未开放充值")
                --     })
                --     return
                -- end

                self.mIsMonthCard = false
                IPlatform:getInstance():rechargeBegin()
                -- 获取订单ID
                self:requestGenerateOrderID("PlayerCharge", "GenerateOrderID", info)
            end

        	--购买按钮
        	local buyBtn = ui.newButton({
        		text = string.format("%s%d", "NT$",info.ChargePoint),
        		fontsize = 10,
        		normalImage = "c_59.png",
        		clickAction = function()
                    local localInfo = info
                    if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
                        local totalReceived = localInfo.GamePoint + localInfo.GiveGamePoint
                        MsgBoxLayer.addOKCancelLayer(
                            TR("是否充值NT$%d获得%d元宝？\nVIP6以上尊享买一送一超值优惠！", localInfo.ChargePoint, totalReceived),
                            TR("提示"),
                            {
                                text = TR("确定"),
                                clickAction = function(layerObj)
                                    rechargeBtnAction(localInfo)
                                    LayerManager.removeLayer(layerObj)
                                end
                            })
                    else
                        rechargeBtnAction(localInfo)
                    end
                end
        		})
        	buyBtn:setPosition(115, 35)
        	oneCell:addChild(buyBtn)

            local normalImageName = (i > 1 or index > 1) and "cz_25.png" or "cz_19.png"
        	--首冲送礼
        	if info.IsFirst then
        		local giftBg = ui.newSprite("cz_04.png")
        		giftBg:setPosition(57, 130)
        		oneCell:addChild(giftBg)

    	    	local firstGift = ui.newLabel({
    	    		text = info.GiveGamePoint,
    	    		font = "c_49.png",
    	    		})
    	    	firstGift:setRotation(-25)
    	    	firstGift:setPosition(57, 113)
    	    	oneCell:addChild(firstGift)

                -- 首充显示4倍
                normalImageName = (i > 1 or index > 1) and "cz_24.png" or "cz_23.png"
    	    end

            --充值20倍图标
            local tempSpriteCharge = ui.newSprite(normalImageName)
            tempSpriteCharge:setPosition(170, 140)
            oneCell:addChild(tempSpriteCharge)
        end

    	listView:pushBackCustomItem(oneCell)
    end
 	return layout
end
--==========================vip详情部分==============================
--创建vip界面
function RechargeLayer:vipViewLayer()
	self.mSubLayer:removeAllChildren()
	self:unscheduleUpdate()

	-- 创建分页滑动控件
    self.mSliderView = ui.newSliderTableView({
        width = self.mBgSize.width,
        height = self.mBgSize.height - 100,
        isVertical = false,
        selectIndex = 0,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return VipLvIntroRelation.items_count
        end,
        itemSizeOfSlider = function(sliderView)
            return self.mBgSize.width, self.mBgSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index, isSelected)
            self:addVipDescAndRewardView(itemNode, index)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    self.mSliderView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height)
    self.mSliderView:setAnchorPoint(0.5, 1)
    self.mSubLayer:addChild(self.mSliderView)
    -- 不可通过左右滑动来翻页，只能通过点击左右按钮来翻页
    -- self.mSliderView:setTouchEnabled(false)
    self.mSliderView:setSelectItemIndex(PlayerAttrObj:getPlayerAttrByName("Vip") + 1)
end

function RechargeLayer:addVipDescAndRewardView(itemNode, itemIndex)
	--背景图
  	local bg = ui.newSprite(itemIndex > Utility.getVipStep() and "cz_27.jpg" or "cz_14.jpg")
	bg:setAnchorPoint(0.5, 1)
	bg:setPosition(320, 1086)
	itemNode:addChild(bg)

    -- Vip标题
    local vipLvTitle = ui.newLabel({
        text = itemIndex > Utility.getVipStep() and itemIndex-Utility.getVipStep() or itemIndex,
        font = "cz_15.png",
        x = 315,
        y = 965,
        align = ui.TEXT_ALIGN_CENTER
    })
    itemNode:addChild(vipLvTitle)

    -- VIP会员内容列表
    local vipIntroItem = VipLvIntroRelation.items[itemIndex]
    local lvSize = cc.size(535, 490)
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.vertical)
    tempListView:setBounceEnabled(true)
    tempListView:setContentSize(lvSize)
    tempListView:setItemsMargin(20)
    tempListView:setPosition(320, 900)
    tempListView:setAnchorPoint(cc.p(0.5, 1.0))
    tempListView:setChildrenActionType(0)
    itemNode:addChild(tempListView)

    for index = 1, #vipIntroItem do
        -- 创建cell
        local cell = ccui.Layout:create()
        cell:setAnchorPoint(cc.p(0, 1))
        cell:setContentSize(cc.size(535, 0))

        local newIntro = nil
        if itemIndex > Utility.getVipStep() then
            -- 替换“会员”为尊享
            local subStr = string.match(vipIntroItem[index].intro, TR("会员(#%w+)"))
            if subStr then
                local colorStr = string.sub(subStr, 1, 7)
                newIntro = string.gsub(vipIntroItem[index].intro, TR("会员#%w+"), TR("尊享")..colorStr..(itemIndex - Utility.getVipStep()))
            end
        end
        -- 文字描述标签
        local introLabel = ui.newLabel({
            text = newIntro or vipIntroItem[index].intro,
            dimensions = cc.size(520, 0),
            size = 24,
            outlineColor = Enums.Color.eBlack,
        })
        local cellHeight = introLabel:getContentSize().height
        cell:setContentSize(cc.size(535, cellHeight))

        introLabel:setAnchorPoint(cc.p(0.5, 1))
        introLabel:setPosition(cell:getContentSize().width * 0.5, cellHeight)
        cell:addChild(introLabel)
        tempListView:pushBackCustomItem(cell)
    end

    -- 奖励展示背景
    local dailyBg = ui.newScale9Sprite("c_97.png", cc.size(628, 234))
    dailyBg:setPosition(320, 200)
    itemNode:addChild(dailyBg)

    -- "每日领取"标签
    local centerLabel = ui.newSprite("cz_13.png")
    centerLabel:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.28)
    itemNode:addChild(centerLabel)

    -- 奖品滑动窗体
    local function handleRewardData(rewardList)
    	local tempList = {}
    	local lineList = {}
	    for i = 1, #rewardList do
	    	table.insert(lineList, rewardList[i])
	    	if i % 5 == 0 then
	    		table.insert(tempList, lineList)
	    		lineList = {}
	    	end
    	end
    	if #lineList ~= 0 then
    		table.insert(tempList, lineList)
    	end
    	return tempList
    end
    local rewardList = handleRewardData(Utility.analysisStrResList(VipWelfareModel.items[itemIndex].resourceList))

    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(626, 232))
    rewardListView:setGravity(ccui.ListViewGravity.centerVertical)
    rewardListView:setAnchorPoint(cc.p(0.5, 1))
    rewardListView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.25)
    itemNode:addChild(rewardListView)

    for i = 1, #rewardList do
    	local layout = ccui.Layout:create()
    	layout:setContentSize(610, 144)

    	local underSprite = ui.newScale9Sprite("c_96.png", cc.size(610, 25))
	    underSprite:setPosition(305, 20)
	    layout:addChild(underSprite)

    	local cardListView = ui.createCardList({
	        maxViewWidth = 640,
	        space = 5,
	        cardDataList = rewardList[i],
	    })
	    cardListView:setAnchorPoint(cc.p(0.5, 0.5))
	    cardListView:setScale(0.85)
	    cardListView:setPosition(305, 72)
	    layout:addChild(cardListView)

    	rewardListView:pushBackCustomItem(layout)
    end
end

--- 充值完成的SDK回调
function RechargeLayer:onPurchaseFinish(result)
    -- 服务器数据可能没修改，延时1s刷新试一下
    Utility.performWithDelay(self, function ()
        -- dump("recharge callback")
        IPlatform:getInstance():rechargeEnd()
        -- 策划要求充值月卡跳转到精彩活动月卡页面
        if self.mIsMonthCard then
            LayerManager.addLayer({
                name = "activity.ActivityMainLayer",
                data = {
                    moduleId = ModuleSub.eExtraActivity,
                    showSubModelId = ModuleSub.eExtraActivityMonthCard,
                }
            })
        else
            self:requestGetChargeList()
            self:refreshBottomView()
        end

        -- if result == "FAIL" then
        --     ui.showFlashView({text = TR("您当前为游客账号不能充值，请升级为正式账号后进行充值\n如果正式账号无法充值 请联系客服QQ：1769035216"), duration = 3.0})
        -- end
    end, 1)
end
--==========================数据处理=================================
-- 处理数据
function RechargeLayer:handleData(dataList)
	local totalList = {}
	local lineList = {}

    -- 如果是渠道
    if IPlatform:getInstance():getConfigItem("PartnerID") == "9902" or IPlatform:getInstance():getConfigItem("PartnerID") == "9903" then
        table.insert(dataList, 1, {isPointCard = true})
    end

	for i = 1, #dataList do
		table.insert(lineList, dataList[i])
		if i % 3 == 0 then
			table.insert(totalList, lineList)
			lineList = {}
		end
	end
	if #lineList ~= 0 then
		table.insert(totalList, lineList)
	end
	return totalList
end

---------------------------网络相关-------------------------------
-- 请求服务器，获取玩家充值信息
function RechargeLayer:requestGetChargeList()
    HttpClient:request({
        moduleName = "PlayerCharge",
        methodName = "GetChargeList",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- dump(data)
            -- 保存数据
            self.mChargeInfoList = self:handleData(data.Value)


            -- 没有开通月卡的情况下直接刷新
            if not ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eExtraActivityMonthCard) then
                self:chargeViewLayer()
         		self:refreshChargeList()
            else
	         	self:chargeViewLayer()
         		self:refreshChargeList()
                self:requestGetCardInfo()
            end
        end
    })
end

-- 请求服务器，获取月卡信息
function RechargeLayer:requestGetCardInfo()
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
                card.name = CardModel.items[card.CardId].name
                card.price = CardModel.items[card.CardId].price
                self.mCardInfoList[card.CardId] = card
            end

            -- 获取月卡信息后，刷新底部视图
            self:refreshMonthCard()
        end
    })
end

-- 请求服务器，进行充值
--[[
    params:
    module                  -- 模块名称
    method                  -- 方法名称
    productInfo             -- 充值产品信息
--]]
function RechargeLayer:requestGenerateOrderID(module, method, productInfo)
    local product = {
        productInfo.ProductId or productInfo.monthCardId,
        IPlatform:getInstance():getDeviceMAC(),
        IPlatform:getInstance():getDeviceUUID(),
        IPlatform:getInstance():getDeviceIMEI()
    }
    HttpClient:request({
        moduleName = module,
        methodName = method,
        svrMethodData = product,
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            local info = {}
            local isMothCard = (productInfo.ProductId == nil)
            info.MothCard = isMothCard and 1 or 0                                           -- 是否月卡(int)
            info.ProductName = isMothCard and TR("周卡") or TR("元宝")                       -- 购买产品名称(元宝、月卡)
            info.ProductID = productInfo.ProductId or data.Value.ProductId                  -- 充值档位ID(string)
            info.OrderID = isMothCard and data.Value.OrderId or data.Value                  -- 订单ID(string)
            info.CurNum = PlayerAttrObj:getPlayerAttrByName("Diamond")                      -- 当前(元宝)数目(int)
            info.BuyNum = productInfo.GamePoint or 0                                        -- 购买(元宝)数目(int)
            info.PresentNum = productInfo.GiveGamePoint or 0                                -- 赠送(元宝)数目(int)
            info.Price = productInfo.ChargePoint                                            -- 价格(元)(int)
            info.ServerID = Player:getSelectServer().ServerID                               -- 当前服务器ID(int)
            info.ServerName = Player:getSelectServer().ServerName                           -- 当前服务器名称(string)
            info.PlayerLevel = PlayerAttrObj:getPlayerAttrByName("Lv")                      -- 玩家等级(int)
            info.PlayerID = Player:getUserLoginInfo().UserID or "null"                      -- ManageCenter 返回的UserId (以后会废弃这个字段)
            info.UserID = Player:getUserLoginInfo().UserID or "null"                        -- ManageCenter 返回的UserId
            info.RoleID = PlayerAttrObj:getPlayerAttrByName("PlayerId") or "null"           -- 玩家在游戏服务器中的角色Id            info.PlayerLevel = PlayerAttrObj:getPlayerAttrByName("Lv")                      -- 玩家等级(int)
            info.PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName")               -- 玩家名称(string)
            info.PlayerVipLevel = PlayerAttrObj:getPlayerAttrByName("Vip")                  -- 玩家VIP等级(int)
            info.ExtData = Player:getUserLoginInfo().ExtraData or "null"                            -- 登录服务器时返回的额外信息
            info.NotifyUrl = Player:getSelectServer().ChargeServerUrl                       -- 充值回调地址

            local value = json.encode(info)
            IPlatform:getInstance():recharge(value, handler(self, self.onPurchaseFinish))
        end
    })
end

----------------------内部测试接口-------------------------
-- 请求服务器，模拟充值(仅debug下支持)
--[[
    params:
    chargePoint                     -- 充值金额
--]]
function RechargeLayer:requestTestRecharge(chargePoint)
    HttpClient:request({
        moduleName = "PlayerCharge",
        methodName = "ConfirmOrder",
        svrMethodData = {chargePoint},
        callbackNode = self,
        callback = function(data)
        	-- dump(data, "ccccharge")

            -- 刷新底部列表视图
            self:requestGetChargeList()
            self:refreshBottomView()
        end
    })
 end

 --- 购买月卡测试接口
 --[[
    params:
    cardId                          -- 月卡Id
 --]]
function RechargeLayer:requestActivityCard(cardId)
    HttpClient:request({
        moduleName = "CardInfo",
        methodName = "Activity",
        svrMethodData = {cardId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 成功提示
            ui.showFlashView({
                text = TR("成功激活周卡")
            })
            dump(data, "monthCard")
            -- 根据配置表中的月卡id获取服务器返回的相应月卡信息
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
                card.name = CardModel.items[card.CardId].name
                card.price = CardModel.items[card.CardId].price
                self.mCardInfoList[card.CardId] = card
            end

            -- 获取月卡信息后，刷新底部视图
            self:chargeViewLayer()
            self:refreshChargeList()
            self:refreshMonthCard()
        end
    })
end



return RechargeLayer
