require("data.data_error_error")
local data_item_item = require("data.data_item_item")
local data_pet_pet = require("data.data_pet_pet")
local MAX_ZORDER = 999
local onePetCost = 300
local tenPetCost = 2800

local ChongwuChouKaLayer = class("ChongwuChouKaLayer", function()
	return display.newLayer("ChongwuChouKaLayer")
end)

function ChongwuChouKaLayer:getData(...)
	local function init(data)
		self.freeTimes = data.lastTimes
		self.startTime = data.startTime
		self.endTime = data.endTime
		self._rootnode.coinNumLbl1:setString(data.goldCost1)
		self._rootnode.coinNumLbl2:setString(data.goldCost10)
		self:refreshFreeTimes()
	end
	
	RequestHelper.chongwuChouKa.getBaseInfo({
	callback = function(data)
		dump(data)
		init(data)
	end
	})
end

function ChongwuChouKaLayer:ctor(param)
	self:setNodeEventEnabled(true)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param)
	local bgNode = CCBuilderReaderLoad("huodong/Petcard_ten.ccbi", self._proxy, self._rootnode)
	local bgSize = bgNode:getContentSize()
	local rewardPx, rewardPy = self._rootnode.reward_show:getPosition()
	local height = param.height + rewardPy - bgSize.height
	self._rootnode.reward_show:setPositionY(height)
	self._rootnode.act_desc:setPositionY(height)
	self:addChild(bgNode)
	self.freeTimes = nil
	self:getData()
	
	--奖励预览
	self._rootnode.reward_show:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1000) then
			CCDirector:sharedDirector():getRunningScene():addChild(require("game.nbactivity.WaBao.WaBaoGiftPopup").new(100), 999, 1000)
		end
	end,
	CCControlEventTouchUpInside)
	
	--活动详情
	self._rootnode.act_desc:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1000) then
			local layer = require("game.SplitStove.SplitDescLayer").new(9)
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.coinNumLbl1:setString(onePetCost)
	self._rootnode.coinNumLbl2:setString(tenPetCost)
	self:initData()
end

function ChongwuChouKaLayer:initData()
	
	--召唤一次
	local chongzhiBtn = self._rootnode.buyOneBtn
	chongzhiBtn:addHandleOfControlEvent(function(eventName, sender)
		self:chouka()
	end,
	CCControlEventTouchUpInside)
	
	--召唤十次
	local buyBtn = self._rootnode.buyTenBtn
	buyBtn:addHandleOfControlEvent(function(eventName, sender)
		self:chouka(10)
	end,
	CCControlEventTouchUpInside)
	
	self:refreshFreeTimes()
	
end

function ChongwuChouKaLayer:startShowRewards(isOneTime)
	if not isOneTime and self.rewardPetStep == #self.rewardPetData then
		return
	end
	local petId = self.rewardPetData[self.rewardPetStep + 1].id
	self.rewardPetStep = self.rewardPetStep + 1
	local showType = isOneTime and 1 or 2
	local param = {
	id = petId,
	showType = showType,
	leftTime = self.freeTimes,
	cost = showType == 1 and onePetCost,
	buyListener = function()
		self:chouka()
	end,
	removeListener = function()
		if not isOneTime then
			self:startShowRewards(false)
		end
	end
	}
	CCDirector:sharedDirector():getRunningScene():addChild(require("game.nbactivity.ChongwuChouKa.ChongwuShowLayer").new(param), MAX_ZORDER + 1)
end

function ChongwuChouKaLayer:showRewards(items)
	local itemData = {}
	local petData = {}
	local msg = common:getLanguageString("@Get")
	for k, v in ipairs(items) do
		local iconType = ResMgr.getResType(v.t) or ResMgr.ITEM
		if v.t == ITEM_TYPE.chongwu then
			local petInfo = ResMgr.getPetData(v.id)
			if petInfo.isItem == 1 then
				table.insert(itemData, {
				id = v.id,
				type = v.t,
				iconType = iconType,
				num = v.n or 0
				})
			else
				table.insert(petData, v)
			end
		else
			table.insert(itemData, {
			id = v.id,
			type = v.t,
			iconType = iconType,
			num = v.n or 0
			})
		end
	end
	local function showItemRewards()
		local title = common:getLanguageString("@GetRewards")
		local msgBox = require("game.Huodong.RewardMsgBox").new({
		title = title,
		cellDatas = itemData,
		isShowConfirmBtn = true
		})
		CCDirector:sharedDirector():getRunningScene():addChild(msgBox, MAX_ZORDER)
	end
	if #petData == 0 then
		local addEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "xiakejinjie_qishou",
		isRetain = false,
		frameFunc = function()
			showItemRewards()
		end,
		finishFunc = function()
		end
		})
		CCDirector:sharedDirector():getRunningScene():addChild(addEffect, 11)
		addEffect:setPosition(cc.p(display.width * 0.5, display.height * 0.5))
	else
		for key, pet in pairs(petData) do
			local petInfo = ResMgr.getPetData(pet.id)
			if petInfo.star >= 5 then
				game.broadcast:showPlayerGetPet(petInfo.name, petInfo.star)
			end
		end
		self.rewardPetData = petData
		self.rewardPetStep = 0
		self:startShowRewards(#items == 1)
		if #itemData > 0 then
			showItemRewards()
		end
	end
end

function ChongwuChouKaLayer:chouka(count)
	count = count or 1
	local needGold = 0
	if count == 1 and 0 >= self.freeTimes then
		needGold = onePetCost
	elseif count == 10 then
		needGold = tenPetCost
	end
	if needGold > game.player:getGold() then
		show_tip_label(common:getLanguageString("@PriceEnough"))
		return false
	end
	
	RequestHelper.chongwuChouKa.qifu({
	count = count,
	errback = function(data)
		self._rootnode.buyOneBtn:setEnabled(true)
		self._rootnode.buyTenBtn:setEnabled(true)
	end,
	callback = function(data)
		dump(data)
		game.player:setGold(data.lastMoney)
		self.freeTimes = data.lastFreeTimes
		self:refreshFreeTimes()
		self.rewardList = data.list
		self.point = data.addLuckValue
		if self.point and 0 < self.point then
			show_tip_label(common:getLanguageString("@LuckyPlus") .. tostring(self.point))
		end
		self:showRewards(data.list)
		self._rootnode.buyOneBtn:setEnabled(true)
		self._rootnode.buyTenBtn:setEnabled(true)
	end
	})
	self._rootnode.buyOneBtn:setEnabled(false)
	self._rootnode.buyTenBtn:setEnabled(false)
	return true
end

function ChongwuChouKaLayer:refreshFreeTimes()
	if self.freeTimes then
		if self.freeTimes > 0 then
			self._rootnode.goldOneLabel:setVisible(false)
			self._rootnode.free_times:setVisible(true)
			local tips = common:getLanguageString("@mianfei") .. self.freeTimes .. common:getLanguageString("@Next")
			self._rootnode.free_times:setString(tips)
		else
			self._rootnode.goldOneLabel:setVisible(true)
			self._rootnode.free_times:setVisible(false)
		end
	else
		self._rootnode.goldOneLabel:setVisible(false)
		self._rootnode.free_times:setVisible(false)
	end
end

function ChongwuChouKaLayer:onExit()
	ResMgr.ReleaseUIArmature("xiakejinjie_qishou")
end

return ChongwuChouKaLayer