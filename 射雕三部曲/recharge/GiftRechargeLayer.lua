--[[
	文件名: GiftRechargeLayer.lua
	描述: 充值礼包页面
	创建人: peiyaoqiang
	创建时间: 2017.12.08
--]]

local levelOptions = {
	{ -- 小手拈花
		eLevel = 1,
		backImg = "czlb_18.jpg", 		-- 背景图
		priceImg = "czlb_13.png", 		-- 价格图
		normalBtnImg = "czlb_11.png", 	-- 按钮正常
		selectBtnImg = "czlb_07.png", 	-- 按钮选中
		btnPos = cc.p(80, 1020), 		-- 按钮位置
		-- 这里还要配置一些和服务端相关的信息
	},
	{ -- 摘星揽月
		eLevel = 2,
		backImg = "czlb_20.jpg",
		priceImg = "czlb_14.png",
		normalBtnImg = "czlb_08.png",
		selectBtnImg = "czlb_03.png",
		btnPos = cc.p(185, 925),
	},
	{ -- 气冲斗牛
		eLevel = 3,
		backImg = "czlb_19.jpg",
		priceImg = "czlb_15.png",
		normalBtnImg = "czlb_09.png",
		selectBtnImg = "czlb_04.png",
		btnPos = cc.p(80, 860),
	},
	{ -- 豪气冲天
		eLevel = 4,
		backImg = "czlb_22.jpg",
		priceImg = "czlb_16.png",
		normalBtnImg = "czlb_10.png",
		selectBtnImg = "czlb_05.png",
		btnPos = cc.p(185, 765),
	},
	{ -- 曜世无双
		eLevel = 5,
		backImg = "czlb_21.jpg",
		priceImg = "czlb_17.png",
		normalBtnImg = "czlb_12.png",
		selectBtnImg = "czlb_06.png",
		btnPos = cc.p(80, 700),
	},
}


local GiftRechargeLayer = class("GiftRechargeLayer", function()
	return display.newLayer()
end)

-- 构造函数
function GiftRechargeLayer:ctor()
	self.giftInfo = {}
	self.currLevel = 0 	-- 当前充值级别

	-- 页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 初始化界面
	self:initUI()

	-- 获取数据
	self:requestGiftInfo()
end

-- 初始化界面
function GiftRechargeLayer:initUI()
	-- 规则按钮
	local btnClose = ui.newButton({
		normalImage = "c_72.png",
		position = cc.p(590, 1000),
		clickAction = function()
			MsgBoxLayer.addRuleHintLayer(
		        TR("规则"),
		        {
		            TR("1.充值不同档位可以领取不同档位的礼包。"),
		            TR("2.每个档位的礼包可以通过多次充值进行多次领取。"),
		            TR("3.高档位的礼包领取完后，可以领取低一档位的礼包。"),
		            TR("4.充值一次只能领取一次礼包。"),
		            TR("5.每种礼包的领取次数都有上限，请大家注意自己领取的上限。"),
		        }
		    )
		end
	})
	self.mParentLayer:addChild(btnClose, 1)

	-- 返回按钮
	local btnClose = ui.newButton({
		normalImage = "shouc_12.png",
		titleImage = "shouc_07.png",
		position = cc.p(180, 130),
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mParentLayer:addChild(btnClose, 1)

	-- 领取按钮
	local btnReward = ui.newButton({
		normalImage = "shouc_12.png",
		titleImage = "c_83.png",
		position = cc.p(460, 130),
		clickAction = function()
			local currInfo = self:getCurrInfo()
			if (currInfo == nil) then
				return
			end

			if (currInfo.LimitNum == currInfo.TotalNum) then
				ui.showFlashView(TR("该档位的礼包已被全部领取，去看看其他档位吧"))
				return
			end
			
			-- 判断可领取次数
			if (currInfo.RewardNum == 0) then
				ui.showFlashView(TR("可领取次数已用完，继续充值还可以再次领取"))
				return
			end

			-- 请求接口
			self:requestDrawReward(currInfo.OrderId)
		end
	})
	self.mParentLayer:addChild(btnReward, 1)
	self.btnReward = btnReward

	-- 溜边特效
	self.mLiubianEffect = ui.newEffect({
		parent = self.mParentLayer,
		effectName = "effect_ui_jianghushouchong",
		position = cc.p(460, 130),
		loop = true,
		zorder = 1,
	})

	-- 折扣价值的百分号
	local discountSprite = ui.newSprite("czlb_02.png")
	discountSprite:setAnchorPoint(cc.p(0, 0.5))
	discountSprite:setPosition(570, 545)
	discountSprite:setRotation(350)
	self.mParentLayer:addChild(discountSprite, 1)

	-- 切换按钮
	self.tabBtnList = {}
	for _,v in ipairs(levelOptions) do
		local button = ui.newButton({
			normalImage = v.normalBtnImg,
			position = v.btnPos,
			clickAction = function()
				self:refreshUI(v.eLevel)
			end
		})
		button:setTag(v.eLevel)
		self.mParentLayer:addChild(button, 1)
		table.insert(self.tabBtnList, button)
	end
	self:refreshUI(1)
end

-- 刷新界面
function GiftRechargeLayer:refreshUI(nLevel)
	-- 读取配置
	local function readOption(tmpLevel)
		for _,v in ipairs(levelOptions) do
			if (v.eLevel == tmpLevel) then
				return clone(v)
			end
		end
		return nil
	end

	-- 刷新界面，如果档位没发生变化就不刷新
	if (self.currLevel ~= nLevel) then
		-- 读取配置
		local oldOption = readOption(self.currLevel)
		local newOption = readOption(nLevel)

		-- 背景图
		if (self.mBgSprite == nil) then
			self.mBgSprite = ui.newSprite(newOption.backImg)
			self.mBgSprite:setPosition(320, 568)
			self.mParentLayer:addChild(self.mBgSprite)
		else
			self.mBgSprite:setTexture(newOption.backImg)
		end

		-- 价格
		self.btnReward:setTitleImage(newOption.priceImg)

		-- 删除以前的小红点
		for _,v in ipairs(self.tabBtnList) do
			if (v.redDotSprite ~= nil) then
				v.redDotSprite:removeFromParent()
				v.redDotSprite = nil
			end
		end
		
		-- 按钮状态
		for _,v in ipairs(self.tabBtnList) do
			local nTag = v:getTag()
			if (nTag == self.currLevel) then
				v:loadTextures(oldOption.normalBtnImg, oldOption.normalBtnImg)
			elseif (nTag == nLevel) then
				v:loadTextures(newOption.selectBtnImg, newOption.selectBtnImg)
			end
		end

		-- 重新创建小红点
		for _,v in ipairs(self.tabBtnList) do
			local eventId = "Order"..v:getTag()
			local function dealRedDotVisible(redDotSprite)
	            redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eCommonHoliday15, eventId))
	        end
	        v.redDotSprite = ui.createAutoBubble({parent = v, eventName = RedDotInfoObj:getEvents(ModuleSub.eCommonHoliday15, eventId), refreshFunc = dealRedDotVisible})
		end
	end
	self.currLevel = nLevel

	-- 清除以前的数据
	local function removeOldNode(nodeNameList)
		for _,v in pairs(nodeNameList) do
			if (self[v] ~= nil) then
				self[v]:removeFromParent()
				self[v] = nil
			end
		end
	end
	removeOldNode({"cardList", "timerLabel", "countLabel", "diamondLabel", "discountLabel"})
	self.mLiubianEffect:setVisible(false)
	
	-- 读取数据
	local currInfo = self:getCurrInfo()
	if (currInfo == nil) then
		return
	end
	self.mLiubianEffect:setVisible(currInfo.RewardNum > 0)
	
	-- 刷新奖品列表
	local rewardData = Utility.analysisStrResList(currInfo.Reward)
	local cardList = ui.createCardList({
        maxViewWidth = 640,
        viewHeight = 120,
        space = 10,
        cardDataList = rewardData,
        })
	local realWidth = cardList:getContentSize().width 	-- 实际宽度会根据奖品数量变化，但最多不超过 maxViewWidth
    cardList:setPosition((640 - realWidth) / 2, 290)
    self.mParentLayer:addChild(cardList)
    self.cardList = cardList

	-- 倒计时
	if (self.giftInfo.EndTime ~= nil) then
		local timerLabel = ui.newLabel({
			text = "",
			size = 22,
			color = cc.c3b(0xff, 0xfa, 0xda),
	        outlineColor = cc.c3b(0x5c, 0x43, 0x40),
		})
		timerLabel:setPosition(180, 60)
		self.mParentLayer:addChild(timerLabel)
		self.timerLabel = timerLabel

		-- 定时器
		Utility.schedule(self.timerLabel, function()
	    	local lastTime = self.giftInfo.EndTime - Player:getCurrentTime()
	        if (lastTime > 0) then
	        	self.timerLabel:setString(TR("倒计时%s %s", "#63E24A", MqTime.formatAsDay(lastTime)))
	        else
	        	ui.showFlashView(TR("本次活动已结束"))
	        	LayerManager.removeLayer(self)
	        end
	    end, 0.5)
	end

	-- 可领取次数
	local countLabel = ui.newLabel({
		text = TR("可领取次数:%s %s/%s", ((currInfo.RewardNum > 0) and "#63E24A" or Enums.Color.eRedH), currInfo.RewardNum, (currInfo.LimitNum - currInfo.TotalNum)),
		size = 22,
		color = cc.c3b(0xff, 0xfa, 0xda),
        outlineColor = cc.c3b(0x5c, 0x43, 0x40),
	})
	countLabel:setPosition(460, 60)
	self.mParentLayer:addChild(countLabel)
	self.countLabel = countLabel

	-- 总价值
	local diamondLabel = ui.newNumberLabel{
		imgFile = "cz_15.png",
		text = currInfo.NeedDiamond,
	}
	diamondLabel:setPosition(330, 242)
	diamondLabel:setScale(0.8)
	self.mParentLayer:addChild(diamondLabel)
	self.diamondLabel = diamondLabel

	-- 折扣价值
	local discountLabel = ui.newNumberLabel({
		imgFile = "czlb_01.png",
		text = currInfo.DiscountDesc,
	})
	discountLabel:setAnchorPoint(cc.p(1, 0.5))
	discountLabel:setPosition(565, 545)
	discountLabel:setRotation(350)
	self.mParentLayer:addChild(discountLabel)
	self.discountLabel = discountLabel
end

-- 读取当前的充值信息
function GiftRechargeLayer:getCurrInfo()
	local currInfo = nil
	for _,v in pairs(self.giftInfo.RewardList or {}) do
		if (v.OrderId == self.currLevel) then
			currInfo = clone(v)
			break
		end
	end
	return currInfo
end

--------------------------网络相关--------------------------

-- 获取礼包信息
function GiftRechargeLayer:requestGiftInfo()
	HttpClient:request({
		moduleName = "TimedDiscount",
		methodName = "GetInfo",
		callback = function(response)
			if (response.Status == 0) then
				self.giftInfo = clone(response.Value)
				self:refreshUI(self.currLevel)
			end
		end,
	})
end

-- 领取礼包奖励
function GiftRechargeLayer:requestDrawReward(orderId)
	HttpClient:request({
		moduleName = "TimedDiscount",
		methodName = "Reward",
		svrMethodData = {orderId},
		callback = function(response)
			if (response.Status == 0) then
				-- 修改当前档位信息的缓存
				local function resetOrderInfo(oldInfo, newInfo)
					for k,v in pairs(oldInfo) do
						oldInfo[k] = newInfo[k]
					end
				end
				for _,v in pairs(self.giftInfo.RewardList or {}) do
					if (v.OrderId == orderId) then
						resetOrderInfo(v, response.Value)
						break
					end
				end

				-- 弹出奖励并刷新界面
				ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
				self:refreshUI(self.currLevel)
			end
		end,
	})
end

return GiftRechargeLayer
