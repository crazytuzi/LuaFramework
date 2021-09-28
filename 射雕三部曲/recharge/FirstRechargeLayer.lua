--[[
	文件名: FirstRechargeLayer.lua
	描述: 首冲页面
	创建人: xuchen
	修改人：chenqiang
	创建时间: 2016.06.30
--]]

local layerType = {
	eBAQI = 1,  	-- 精打细算
	eXIAOQIAN = 2, 	-- 不计小钱
	eKUOCHUO = 3, 	-- 出手阔绰
	eZHIZUN = 4, 	-- 一掷千金
	eTIANZUN = 5, 	-- 豪情万丈
}

local chargeState = {
	eNeedCharge = 1, -- 需要充值
	eNeedDraw = 2,	-- 需要领取
	eHaveDraw = 3,	-- 已经领取
}

local FirstRechargeLayer = class("FirstRechargeLayer", function()
	return display.newLayer()
end)

-- 构造函数
function FirstRechargeLayer:ctor()
	-- 玩家充值数量
	self.mChargeNum = 0
	-- 3档充值的状态，初始都为未充值
	self.mChargeSwitch = {
		{level = 1, state = chargeState.eNeedCharge},
		{level = 2, state = chargeState.eNeedCharge},
		{level = 3, state = chargeState.eNeedCharge},
		{level = 4, state = chargeState.eNeedCharge},
		{level = 5, state = chargeState.eNeedCharge},
	}
	-- 当前显示的充值档次和状态, 初始化为一档
	self.mCurrChargeState = self.mChargeSwitch[1]
	-- 当前奖励
	self.mCurrReward = {}

	-- 页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()

	-- 玩家充值信息
	self:requestChargeInfo()
end

-- 初始化界面
function FirstRechargeLayer:initUI()
	-- 背景
	self.mBgSprite = ui.newSprite("shouc_10.jpg")
	self.mBgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(self.mBgSprite)

	-- self.mChargePosition = {}
	-- 精打细算
	self.mBaqiSprite = ui.newButton({
		normalImage = "shouc_04.png",
		position = cc.p(550, 1050),
		clickAction = function()
			-- 切换到精打细算
			if self.mCurrChargeState.level == layerType.eBAQI then
				return
			end
			self.mCurrChargeState = self.mChargeSwitch[layerType.eBAQI]
			self:refreshUI()
		end
	})
	self.mBaqiSprite:setPressedActionEnabled(false)
	self.mParentLayer:addChild(self.mBaqiSprite)
	--table.insert(self.mChargePosition, cc.p(550, 865))
	-- 一掷千金
	self.mZhizunSprite = ui.newButton({
		normalImage = "shouc_05.png",
		position = cc.p(450, 820),
		clickAction = function()
			-- 切换到一掷千金
			if self.mCurrChargeState.level == layerType.eZHIZUN then
				return
			end
			self.mCurrChargeState = self.mChargeSwitch[layerType.eZHIZUN]
			self:refreshUI()
		end
	})
	self.mZhizunSprite:setPressedActionEnabled(false)
	self.mParentLayer:addChild(self.mZhizunSprite)
	--table.insert(self.mChargePosition, cc.p(467, 990))
	-- 豪情万丈
	self.mTianzunSprite = ui.newButton({
		normalImage = "shouc_06.png",
		position = cc.p(550, 740),
		-- scale = 0.8,
		clickAction = function()
			-- 切换到豪情万丈
			if self.mCurrChargeState.level == layerType.eTIANZUN then
				return
			end
			self.mCurrChargeState = self.mChargeSwitch[layerType.eTIANZUN]
			self:refreshUI()
		end
	})
	self.mTianzunSprite:setPressedActionEnabled(false)
	-- self.mTianzunSprite:setPosition(486, 720)
	self.mParentLayer:addChild(self.mTianzunSprite)
	--table.insert(self.mChargePosition, cc.p(486, 720))

	-- 出手阔绰
	self.mCSKCSprite = ui.newButton({
		normalImage = "shouc_17.png",
		position = cc.p(550, 900),
		clickAction = function()
			-- 切换到出手阔绰
			if self.mCurrChargeState.level == layerType.eKUOCHUO then
				return
			end
			self.mCurrChargeState = self.mChargeSwitch[layerType.eKUOCHUO]
			self:refreshUI()
		end
	})
	self.mCSKCSprite:setPressedActionEnabled(false)
	self.mParentLayer:addChild(self.mCSKCSprite)


	-- 不计小钱
	self.mBJXQSprite = ui.newButton({
		normalImage = "shouc_18.png",
		position = cc.p(450, 980),
		clickAction = function()
			-- 切换到不计小钱
			if self.mCurrChargeState.level == layerType.eXIAOQIAN then
				return
			end
			self.mCurrChargeState = self.mChargeSwitch[layerType.eXIAOQIAN]
			self:refreshUI()
		end
	})
	self.mBJXQSprite:setPressedActionEnabled(false)
	self.mParentLayer:addChild(self.mBJXQSprite)

	-- 奖励
	local listViewSize = cc.size(640, 250)
	self.mRewardListView = ccui.ListView:create()
	self.mRewardListView:setContentSize(listViewSize)
	self.mRewardListView:setItemsMargin(10)
	self.mRewardListView:setDirection(ccui.ListViewDirection.vertical)
	self.mRewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
 	self.mRewardListView:setBounceEnabled(true)
    self.mRewardListView:setAnchorPoint(0.5, 0.5)
    self.mRewardListView:setPosition(320, 240)
    self.mParentLayer:addChild(self.mRewardListView)
    -- 条目大小
    self.mCellSize = cc.size(640, 115)

	-- 返回按钮
	local backBtn = ui.newButton({
		normalImage = "shouc_12.png",
		titleImage = "shouc_07.png",
	  	-- text = TR("返 回"),
        fontSize = 30,
        textColor = cc.c3b(170,255,245),
        titlePosRateY = 0.5,
		clickAction = function()
			-- 返回首页
		  	LayerManager.removeLayer(self)
		end
	})
	backBtn:setPosition(175, 55)
	self.mParentLayer:addChild(backBtn)

	-- 立即充值
	self.mRechargeBtn = ui.newButton({
		titleImage = "shouc_08.png",
		normalImage = "shouc_12.png",
		-- disabledImage = "shouc_12.png",
        titlePosRateY = 0.5,
		clickAction = function(pSender)
			-- 立即充值
			if self.mCurrChargeState.state == chargeState.eNeedCharge then
				LayerManager.showSubModule(ModuleSub.eCharge)
			elseif self.mCurrChargeState.state == chargeState.eNeedDraw then
				self:requestDrawReward()
			elseif self.mCurrChargeState.state == chargeState.eHaveDraw then
			 	ui.showFlashView(TR("提示：已经领取！"))
			end
		end
	})
	self.mRechargeBtn:setPosition(470, 55)
	self.mParentLayer:addChild(self.mRechargeBtn)
	-- 溜边特效
	self.mLiubianEffect = ui.newEffect({
			parent = self.mParentLayer,
			effectName = "effect_ui_jianghushouchong",
			position = cc.p(470, 55),
			loop = true,
		})
end

-- 刷新界面, 参数state表示充值状态
function FirstRechargeLayer:refreshUI()
	-- 设置当前奖励
	self:setReward()
	-- 刷新奖励
	self:refreshListView()

	if self.mCurrChargeState.level == layerType.eBAQI then
		-- 如果是霸气充值
		self.mBgSprite:setTexture("shouc_10.jpg")
		self.mBaqiSprite:loadTextureNormal("shouc_01.png")
		self.mZhizunSprite:loadTextureNormal("shouc_05.png")
		self.mTianzunSprite:loadTextureNormal("shouc_06.png")
		self.mCSKCSprite:loadTextureNormal("shouc_17.png")
		self.mBJXQSprite:loadTextureNormal("shouc_18.png")

	elseif self.mCurrChargeState.level == layerType.eZHIZUN then
		self.mBgSprite:setTexture("shouc_23.jpg")
		self.mZhizunSprite:loadTextureNormal("shouc_02.png")
		self.mBaqiSprite:loadTextureNormal("shouc_04.png")
		self.mTianzunSprite:loadTextureNormal("shouc_06.png")
		self.mCSKCSprite:loadTextureNormal("shouc_17.png")
		self.mBJXQSprite:loadTextureNormal("shouc_18.png")

	elseif self.mCurrChargeState.level == layerType.eTIANZUN then
		self.mBgSprite:setTexture("shouc_21.jpg")
		self.mTianzunSprite:loadTextureNormal("shouc_03.png")
		self.mBaqiSprite:loadTextureNormal("shouc_04.png")
		self.mZhizunSprite:loadTextureNormal("shouc_05.png")
		self.mCSKCSprite:loadTextureNormal("shouc_17.png")
		self.mBJXQSprite:loadTextureNormal("shouc_18.png")

	elseif self.mCurrChargeState.level == layerType.eKUOCHUO then
		self.mBgSprite:setTexture("shouc_20.jpg")
		self.mTianzunSprite:loadTextureNormal("shouc_06.png")
		self.mBaqiSprite:loadTextureNormal("shouc_04.png")
		self.mZhizunSprite:loadTextureNormal("shouc_05.png")
		self.mCSKCSprite:loadTextureNormal("shouc_15.png")
		self.mBJXQSprite:loadTextureNormal("shouc_18.png")

	elseif self.mCurrChargeState.level == layerType.eXIAOQIAN then
		self.mBgSprite:setTexture("shouc_19.jpg")
		self.mTianzunSprite:loadTextureNormal("shouc_06.png")
		self.mBaqiSprite:loadTextureNormal("shouc_04.png")
		self.mZhizunSprite:loadTextureNormal("shouc_05.png")
		self.mCSKCSprite:loadTextureNormal("shouc_17.png")
		self.mBJXQSprite:loadTextureNormal("shouc_16.png")
	end

	if self.mCurrChargeState.state == chargeState.eNeedDraw then
		self.mRechargeBtn:setEnabled(true)
		self.mLiubianEffect:setVisible(true)
		self.mRechargeBtn.setTitleImage(self.mRechargeBtn,"shouc_13.png")
	elseif self.mCurrChargeState.state == chargeState.eNeedCharge then
		self.mRechargeBtn:setEnabled(true)
		self.mLiubianEffect:setVisible(true)
		self.mRechargeBtn.setTitleImage(self.mRechargeBtn,"shouc_08.png")
	elseif self.mCurrChargeState.state == chargeState.eHaveDraw then
		self.mRechargeBtn.setTitleImage(self.mRechargeBtn,"shouc_14.png")
		self.mRechargeBtn:setEnabled(false)
		self.mLiubianEffect:setVisible(false)
	end
end

function FirstRechargeLayer:refreshListView()
	self.mRewardListView:removeAllItems()

	for index = 1, math.ceil(#self.mCurrReward / 5) do
		local item = ccui.Layout:create()
		item:setContentSize(self.mCellSize)
		self.mRewardListView:pushBackCustomItem(item)

		-- 刷新指定项
		self:refreshListItem(index)
	end
end

function FirstRechargeLayer:refreshListItem(index)
	local lvItem = self.mRewardListView:getItem(index - 1)
	if lvItem == nil then
		lvItem = ccui.Layout:create()
		lvItem:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
	end
	lvItem:removeAllChildren()

	local posX = 25
	for idx = (5 * index - 4), (5 * index) do
		if idx > #self.mCurrReward then
			return
		end

		local info = self.mCurrReward[idx]

		-- 奖励
		local goodsSprite =  require("common.CardNode").new({nameColor = Enums.Color.eWhite})
		local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
		goodsSprite:setCardData({resourceTypeSub = info.resourceTypeSub, modelId = info.modelId,
			num = info.num, cardShowAttrs = showAttrs})
		goodsSprite:setAnchorPoint(cc.p(0, 0.5))
		goodsSprite:setPosition(posX, self.mCellSize.height * 0.5 + 5)

		posX = posX + goodsSprite:getContentSize().width + 30
		lvItem:addChild(goodsSprite)
	end
end

-- 获取当前显示状态
function FirstRechargeLayer:setChargeState()
	for i, obj in ipairs(self.mChargeSwitch) do
		if obj.state ~= chargeState.eHaveDraw then
			self.mCurrChargeState = self.mChargeSwitch[i]
			break
		end
	end

	-- 更新充值类型按钮的显示位置
	-- if self.mCurrChargeState.level == layerType.eZHIZUN then
	-- 	self.mZhizunSprite:setPosition(self.mChargePosition[1])
	-- 	self.mBaqiSprite:setPosition(self.mChargePosition[2])
	-- elseif self.mCurrChargeState.level == layerType.eTIANZUN then
	-- 	self.mTianzunSprite:setPosition(self.mChargePosition[1])
	-- 	self.mBaqiSprite:setPosition(self.mChargePosition[3])
	-- end
end

-- 设置当前的奖励
function FirstRechargeLayer:setReward()
	local rewardResouceList = ChargeFirstModel.items[self.mCurrChargeState.level].rewardResouceList
	self.mCurrReward = Utility.analysisStrResList(rewardResouceList)
end

--------------------------网络相关--------------------------
-- 充值信息
function FirstRechargeLayer:requestChargeInfo()
	HttpClient:request({
		moduleName = "PlayerCharge",
		methodName = "ChargeInfo",
		callback = function(response)
			self.mChargeNum = response.Value.ChargeNum
			-- 更新每一档充值的状态
			for i, obj in ipairs(self.mChargeSwitch) do
				if self.mChargeNum >= ChargeFirstModel.items[i].num then
					-- 如果充值金额大于该档金额
					local flag = true
					for _, k in ipairs(response.Value.DrawNums) do
						if k == ChargeFirstModel.items[i].num then
							-- 如果领取的id等于充值的金额
							self.mChargeSwitch[i].state = chargeState.eHaveDraw
							flag = false
							break
						end
					end
					if flag then
						self.mChargeSwitch[i].state = chargeState.eNeedDraw
					end
				end
			end

			-- 设置当前状态
			self:setChargeState()
			-- 刷新UI
			self:refreshUI()
		end,
	})
end

-- 领取奖励
function FirstRechargeLayer:requestDrawReward()
	HttpClient:request({
		moduleName = "PlayerCharge",
		methodName = "DrawChargeBox",
		svrMethodData = {ChargeFirstModel.items[self.mCurrChargeState.level].num},
		callback = function(response)
			if response.Status == 0 then
				ui.showFlashView(TR("领取首充礼包成功！"))
				-- 更新状态
				self.mCurrChargeState.state = chargeState.eHaveDraw
				self.mChargeSwitch[self.mCurrChargeState.level].state = chargeState.eHaveDraw
				self.mRechargeBtn.setTitleImage(self.mRechargeBtn, "shouc_14.png")
				ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
				self.mRechargeBtn:setEnabled(false)
				self.mLiubianEffect:setVisible(false)
			end
		end,
	})
end

return FirstRechargeLayer
