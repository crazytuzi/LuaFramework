
local QUIDialog = import(".QUIDialog")
local QUIDialogRewardInfo = class("QUIDialogRewardInfo", QUIDialog)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QMockBattle = import("..network.models.QMockBattle")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogRewardInfo:ctor(options)
	local ccbFile = "ccb/Dialog_RewardInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
	}
	QUIDialogRewardInfo.super.ctor(self, ccbFile, callBacks, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
	self.isAnimation = true

	self._showCancel = options.showCancel
	self._notGiveUp = options.notGiveUp or false
	self._exit_callback = nil
	self.ok_callback = nil
	self._rewardType = options.rewardType
	if options.exit_callback then
		self._exit_callback = options.exit_callback
	end

	if options.ok_callback then
		self._ok_callback = options.ok_callback
	end

	self:setSelfInfo()
end 


function QUIDialogRewardInfo:setSelfInfo()
	if self._rewardType == "MOCK_BATTLE" then
		self:setMockBattleAwardInfo()
	elseif self._rewardType == "METAL_ABYSS" then
		self:setMetalAbyssAwardInfo()
	else

	end
	self:updateBtnState()
end

function QUIDialogRewardInfo:updateBtnState()
	if not self._showCancel  then
		self._ccbOwner.node_btn_cancel:setVisible(false)
		self._ccbOwner.node_btn_ok:setPositionX(0)
	else
		self._ccbOwner.node_btn_cancel:setVisible(true)
		self._ccbOwner.node_btn_ok:setPositionX(90)
	end

end


function QUIDialogRewardInfo:setMockBattleAwardInfo()
    self._ccbOwner.frame_tf_title:setString("参赛奖励" or "")

	self._seasonType = remote.mockbattle:getMockBattleSeasonType()
    local reward_  ={}

	local win_num =  remote.mockbattle:getMockBattleRoundInfo().winCount or 0
	self._ccbOwner.tf_desc_empty:setVisible( win_num == 0 )
	self._ccbOwner.tf_desc:setVisible( win_num ~= 0 )


	if self._notGiveUp then
		self._ccbOwner.tf_desc_empty:setString( "本轮暂未获得奖励")
	end

	local score_item_num = 0
	if win_num > 0 then
		for i=1,win_num do
	   		local num_ = db:getMockBattleScoreRewardById(i , self._seasonType) or 0
			score_item_num =  score_item_num + num_
			print("QUIDialogRewardInfo:setMockBattleAwardInfo.    "..num_)
		end
	end

	if score_item_num > 0 then
		table.insert(reward_,{ type_ = "mock_battle_integral" , value_ = score_item_num })
	end

	local rewardInfo = remote.mockbattle:getMockBattleReward() or {}
	local item_table1 = string.split(rewardInfo, ";")
	for i,v in ipairs(item_table1) do
		local item_table = string.split(v, "^")
		local num = math.floor(#item_table / 2)

		for i=1,num do
			table.insert(reward_,{ type_ = item_table[2 * i - 1] , value_ =item_table[2 * i]})
		end
	end
	self:handlerRewardItem(reward_)
end

function QUIDialogRewardInfo:handlerRewardItem(item_table)
	if next(item_table) ~= nil then
		local num =  #item_table
		if num == 1 then
			local  item = self:createRewardItemBox(item_table[1].type_,item_table[1].value_)
			self._ccbOwner.node_reward_father:addChild(item)
		elseif num == 2 then
			for i=1,num do
				local  item = self:createRewardItemBox(item_table[i].type_,item_table[i].value_)
				item:setPositionX( 80 * (2 * i - 3 ))
				self._ccbOwner.node_reward_father:addChild(item)
			end
		elseif num == 3 then
			for i=1,num do
				local  item = self:createRewardItemBox(item_table[i].type_,item_table[i].value_)
				item:setPositionX( 120 * ( i - 2 ))
				self._ccbOwner.node_reward_father:addChild(item)
			end			
		elseif num > 3 then
			--需要列表没实现
		end
	end
end

function QUIDialogRewardInfo:createRewardItemBox(type_,value_)
	local itemBox = QUIWidgetItemsBox.new()
    itemBox:setPromptIsOpen(true)
    itemBox:setGoodsInfo(nil, type_,tonumber(value_))
    itemBox:setScale(0.8)
    return itemBox
end


function QUIDialogRewardInfo:_OkCallBack()
	if self._ok_callback then
		self._ok_callback()
	end
end

function QUIDialogRewardInfo:_ExitCallBack()
	if self._exit_callback then
		self._exit_callback()
	end
end

function QUIDialogRewardInfo:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogRewardInfo:_onTriggerOk()
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_small")
	self:_OkCallBack()
	self:_ExitCallBack()
    self:playEffectOut()
end

function QUIDialogRewardInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:_ExitCallBack()
    self:playEffectOut()
end

function QUIDialogRewardInfo:_onTriggerCancel(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
	app.sound:playSound("common_cancel")
	self:_ExitCallBack()
    self:playEffectOut()
end

return QUIDialogRewardInfo