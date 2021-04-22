--
-- Author: Kumo.Wang
-- 宗门红包成就cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetRedpacketAchievementCell = class("QUIWidgetRedpacketAchievementCell", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIWidgetRedpacketAchievementCell:ctor(options)
	local ccbFile = "ccb/Widget_Society_Redpacket_Achievement_Cell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetRedpacketAchievementCell.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetRedpacketAchievementCell:onEnter()
end

function QUIWidgetRedpacketAchievementCell:onExit()
end

function QUIWidgetRedpacketAchievementCell:setInfo(param)
	self:_resetAll()
	if not param then return end
	-- QPrintTable(param)
	self._param = param
	self._selectedAchieveTab = param.selectedAchieveTab or remote.redpacket.ITEM_REDPACKET
	self._itemData = clone(param.itemData) or {}
	-- print(next(self._itemData))
	self._isCurTarget = false
	local id = remote.redpacket:getRedpacketCurAchievementConfigIdByTab(self._selectedAchieveTab)
	if id > 0 then
	    if self._itemData.id ~= id then
	    	self._isCurTarge = false
	    else
	    	self._isCurTarge = true
	    end
	else
		return 
	end
   	self._state = remote.redpacket:getRedpacketAchievementStateByConfig(self._itemData)

	self:_setRedpacketImg()
	self:_setReward()
	self:_setInfo()
	self:_showEffect()
end

function QUIWidgetRedpacketAchievementCell:_showEffect()
	if self._isCurTarge and self._state == remote.redpacket.REDPACKET_ACHIEVEMENT_COMPLETE_STATE then
		-- if not self._fcaAnimation then
		-- 	self._fcaAnimation = QUIWidgetFcaAnimation.new("fudai_guangxiao", "res")
		-- end
		-- if self._fcaAnimation then
		-- 	self._ccbOwner.node_effect:addChild(self._fcaAnimation)
		-- 	self._fcaAnimation:playAnimation("animation", true)
		-- end
		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/fudai_guangxiao", "res")
		self._ccbOwner.node_effect:addChild(fcaAnimation)
		fcaAnimation:playAnimation("animation", true)
	else
		self._ccbOwner.node_effect:removeAllChildren()
	end
	
end

function QUIWidgetRedpacketAchievementCell:update(itemData)
	self._itemData = clone(itemData)
	-- if self._selectedTab == remote.redpacket.GAIN then
	-- 	if next(self._itemData) then
	-- 		self._ccbOwner.node_have:setVisible(true)
	-- 		self:_setRedpacketImg()
	-- 		self:_setInfo()
	-- 	else
	-- 		self._ccbOwner.node_no:setVisible(true)
	-- 	end
 --    end
end

function QUIWidgetRedpacketAchievementCell:_setReward()
	-- print("QUIWidgetRedpacketAchievementCell:_setReward() ")
	if self._itemData.head_default and self._state ~= remote.redpacket.REDPACKET_ACHIEVEMENT_DONE_STATE then
		-- print("QUIWidgetRedpacketAchievementCell:_setReward(1) ")
		local path = remote.redpacket:getHeadTitlePathById(self._itemData.head_default)
		if path then
			-- print("QUIWidgetRedpacketAchievementCell:_setReward(1-1) ")
	    	local sprite = CCSprite:create(path)
	    	if sprite then
	    		-- print("QUIWidgetRedpacketAchievementCell:_setReward(1-2) ")
	    		self._ccbOwner.node_title:addChild(sprite)
	    	end
		end
		self._ccbOwner.node_title_reward:setVisible(true)
	elseif self._itemData.lucky_draw and self._isCurTarge then
		-- print("QUIWidgetRedpacketAchievementCell:_setReward(2) ", self._itemData.lucky_draw)
		local id, typeName, count = remote.redpacket:getLuckyDrawItemInfoById(self._itemData.lucky_draw)
		-- print(id, typeName, count)
		id = tonumber(id)
		local path
		if id then
			path = remote.items:getURLForId(id)
		else
			path = remote.items:getURLForItem(typeName, "alphaIcon")
		end
		if path then
			-- print("QUIWidgetRedpacketAchievementCell:_setReward(2-1) ")
	    	local sprite = CCSprite:create(path)
	    	if sprite then
	    		-- print("QUIWidgetRedpacketAchievementCell:_setReward(2-2) ")
	    		self._ccbOwner.node_icon:addChild(sprite)
	    	end
		end
		self._ccbOwner.tf_reward_num:setString("x"..count)
		self._ccbOwner.tf_reward_num:setVisible(true)
		self._ccbOwner.node_token_reward:setVisible(true)
	end
end

function QUIWidgetRedpacketAchievementCell:_setInfo()
	self._ccbOwner.tf_num:setString(self._itemData.condition)
	self._ccbOwner.tf_num:setVisible(true)
end

function QUIWidgetRedpacketAchievementCell:_setRedpacketImg()
	local state = self._state
	if state == remote.redpacket.REDPACKET_ACHIEVEMENT_COMPLETE_STATE and not self._isCurTarge then
		state = remote.redpacket.REDPACKET_ACHIEVEMENT_NOT_COMPLETE_STATE
	end
	local path = remote.redpacket:getRedPacketAchievementPathByTypeAndState(self._selectedAchieveTab, state)
	-- print("QUIWidgetRedpacketAchievementCell:_setRedpacketImg() ", path, state)
    if path then
    	-- print("QUIWidgetRedpacketAchievementCell:_setRedpacketImg(1) ")
    	local sprite = CCSprite:create(path)
    	if sprite then
    		-- print("QUIWidgetRedpacketAchievementCell:_setRedpacketImg(1-1) ")
    		sprite:setScale(0.8)
    		self._ccbOwner.node_redpacket:addChild(sprite)
    	end
	end
	local isNeedGray = self._state == remote.redpacket.REDPACKET_ACHIEVEMENT_DONE_STATE
	-- print("isNeedGray = ", isNeedGray)
	if isNeedGray then
		makeNodeFromNormalToGray(self._ccbOwner.node_redpacket)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_redpacket)
	end
	self._ccbOwner.node_redpacket:setVisible(true)
end

function QUIWidgetRedpacketAchievementCell:_resetAll()
	self._ccbOwner.node_token_reward:setVisible(false)
	self._ccbOwner.node_title_reward:setVisible(false)
	self._ccbOwner.tf_num:setVisible(false)
	self._ccbOwner.tf_reward_num:setVisible(false)

	self._ccbOwner.node_title:removeAllChildren()
	self._ccbOwner.node_redpacket:removeAllChildren()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_effect:removeAllChildren()
end

function QUIWidgetRedpacketAchievementCell:getName()
	return "QUIWidgetRedpacketAchievementCell"
end

function QUIWidgetRedpacketAchievementCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetRedpacketAchievementCell
