--
-- Author: Kumo.Wang
-- 大富翁仙品管理Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonopolyPickFlower = class("QUIWidgetMonopolyPickFlower", QUIWidget)

function QUIWidgetMonopolyPickFlower:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_collection.ccbi"
	local callBacks = {}
	QUIWidgetMonopolyPickFlower.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMonopolyPickFlower:onEnter()
end

function QUIWidgetMonopolyPickFlower:onExit()
end

function QUIWidgetMonopolyPickFlower:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetMonopolyPickFlower:setInfo(info)
	-- QPrintTable(info)
	-- if not info or #info == 0 then
	-- 	self._ccbOwner.node_no:setVisible(true)
	-- 	self._ccbOwner.node_have:setVisible(false)
	-- 	return
	-- end

	self._ccbOwner.node_noStatus:setVisible(false)
	self._ccbOwner.sp_noFlower_mask:setVisible(false)
	self._flowerId = info[1].id
	self._curConfig = remote.monopoly:getFlowerCurAndNextConfigById(self._flowerId)

	-- if not self._curConfig or self._curConfig.level == 0 then
	-- 	self._ccbOwner.node_no:setVisible(true)
	-- 	self._ccbOwner.node_have:setVisible(false)
	-- 	return
	-- end

	self._ccbOwner.tf_level:setString(self._curConfig.level)
	self._ccbOwner.tf_flowerName:setString(self._curConfig.name)

	local path = self._curConfig.picture
	local sp = self._ccbOwner.sp_plants
	if path and sp then
		local frame = QSpriteFrameByPath(path)
		sp:setDisplayFrame(frame)
	end

	q.cutSprite(self._ccbOwner.node_mask_plants, self._ccbOwner.sp_plants, self._ccbOwner.node_plants)

	self._curLuckyDrawConfig = remote.monopoly:getLuckyDrawByKey(self._curConfig.good)
	self:setSpriteIcon(self._ccbOwner.sp_icon, self._curLuckyDrawConfig)
	self:setSpriteIcon(self._ccbOwner.sp_iconForTotal, self._curLuckyDrawConfig)
	self:setSpriteIcon(self._ccbOwner.sp_iconForMax, self._curLuckyDrawConfig)
	-- self._ccbOwner.tf_output:setString(self._curLuckyDrawConfig.num_1 * self._curConfig.num)
	self._ccbOwner.tf_output:setString(string.format("%0.1f",(self._curLuckyDrawConfig.num_1 * self._curConfig.num * 60.0 + 0.0000001)))
	self._ccbOwner.tf_maxOutput:setString(math.floor(self._curLuckyDrawConfig.num_1 * self._curConfig.num * 60 * 24 + 0.0000001))
	self:_updateTotalOutput()

	if not self._curConfig or self._curConfig.level == 0 then
		self._ccbOwner.node_button:setVisible(false)
		self._ccbOwner.node_haveStatus:setVisible(false)
		self._ccbOwner.node_noStatus:setVisible(true)
		self._ccbOwner.sp_noFlower_mask:setVisible(true)
		makeNodeFromNormalToGray(self._ccbOwner.node_have)
		if self._curConfig.unlock and not app.unlock:checkLock(self._curConfig.unlock,false) then
			local unlockLevel = app.unlock:getConfigByKey(self._curConfig.unlock).team_level
			self._ccbOwner.tf_unlockTips:setString("开启等级"..(unlockLevel or 70).."级")
		else
			self._ccbOwner.tf_unlockTips:setString("仙品未培养")
		end
	end
end

function QUIWidgetMonopolyPickFlower:_updateTotalOutput()
	local timeSpanForMin, _, redTips = remote.monopoly:getPickFlowerTimeSpan(self._flowerId)
	self._timeSpanForMin = timeSpanForMin 
	print(self._timeSpanForMin)
	self._ccbOwner.tf_totalOutput:setString(math.floor(self._curLuckyDrawConfig.num_1 * self._curConfig.num * timeSpanForMin))
	self._ccbOwner.flower_tips:setVisible(redTips)
end

function QUIWidgetMonopolyPickFlower:setSpriteIcon(sp, config)
	local setIcon = function( path)
		local frame = QSpriteFrameByPath(path)
		if frame then
			sp:setDisplayFrame(frame)
		end
	end

	local resourceConfig = remote.items:getWalletByType(config.type_1)
	if q.isEmpty(resourceConfig) == false then
		setIcon(resourceConfig.alphaIcon)
	else
		local itemInfo = db:getItemByID(config.id_1)
		if itemInfo then
			setIcon(itemInfo.icon_1)
		end
		
	end
end

function QUIWidgetMonopolyPickFlower:_onTriggerOK()
	if self._timeSpanForMin < 1 then
		app.tip:floatTip("还没有可以采集的奖励，请稍后再试")
	else
		remote.monopoly:monopolyGetImmortalRewardRequest({self._flowerId}, function(data)
			remote.monopoly:showRewardForTips(data.prizes)
			if self._updateTotalOutput then
				self:_updateTotalOutput()
			end
		end)
	end
end


return QUIWidgetMonopolyPickFlower