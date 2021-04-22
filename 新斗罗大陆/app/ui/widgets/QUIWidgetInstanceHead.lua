--
-- Author: wkwang
-- Date: 2014-05-08 16:07:32
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetInstanceHead = class("QUIWidgetInstanceHead", QUIWidget)
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QChatDialog = import("...utils.QChatDialog")

QUIWidgetInstanceHead.EVENT_CITY_CLICK = "EVENT_CITY_CLICK"
QUIWidgetInstanceHead.EVENT_BOX_CLICK = "EVENT_BOX_CLICK"

function QUIWidgetInstanceHead:ctor(ccbFile,options)
	local callBacks = {
			{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetInstanceHead._onTriggerClick)},
		}
	QUIWidgetInstanceHead.super.ctor(self,ccbFile,callBacks,options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetInstanceHead:setInfo(info, isBattle)
	self._info = info
	self._instanceType = info.dungeon_type
	self._ccbOwner.tf_number:setString(self._info.number)
	self._star = 0
	local isPassed = self._info.info and (self._info.info.lastPassAt or 0) or 0 -- 0 means this dungeon has not passed
	if self._info.info ~= nil and self._info.info.star ~= nil then
		self._star = self._info.info.star
	end
	if isBattle == true and isPassed > 0 then
		self:hideStar()
		local animationStar = QUIWidgetAnimationPlayer.new()
		animationStar:playAnimation("ccb/effects/EliteStar.ccbi", function (ccbOwner)
			for i=1,3 do
				ccbOwner["node"..i]:setVisible(false)
			end
			if ccbOwner["node"..self._star] ~= nil then
				ccbOwner["node"..self._star]:setVisible(true)
			end
		end, nil, false)
		self._ccbOwner.node_star:addChild(animationStar)
	else
		for i=1,3,1 do
			self._ccbOwner["star_bg"..i]:setVisible(self._star>0)
			if i > self._star then
				self._ccbOwner["star"..i]:setVisible(false)
			else
				self._ccbOwner["star"..i]:setVisible(true)
			end
		end
	end

	self._isPass = false
	if self._info.info ~= nil and self._info.info.lastPassAt ~= nil and self._info.info.lastPassAt > 0 then
		self._isPass = true
	end

	if self._info.dungeon_isboss == true and self._info.monster_id ~= nil then	
		self:avatarHandler(self._info.monster_id)
		self:addChestBox()
		if self._info.starsX ~= nil and self._ccbOwner.node_star ~= nil then
			local posX = self._ccbOwner.node_star:getPositionX()
			self._ccbOwner.node_star:setPositionX(posX + self._info.starsX)
		end
		if self._info.starsY ~= nil and self._ccbOwner.node_star ~= nil then
			local posY = self._ccbOwner.node_star:getPositionY()
			self._ccbOwner.node_star:setPositionY(posY + self._info.starsY)
		end
	end

	if self._info.isLock == false then
		makeNodeFromNormalToGray(self._ccbOwner.node_root)
		self._ccbOwner.btn_head:setEnabled(false)
		if self._avatar ~= nil then
			self._avatar:getActor():getSkeletonView():pauseAnimation()
			self._ccbOwner.node_name:setVisible(true)
		end
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_root)
		self._ccbOwner.btn_head:setEnabled(true)
		if self._info.dungeon_isboss == true and (self._info.info == nil or self._info.info.lastPassAt == nil or self._info.info.lastPassAt == 0)  then
			self:speak()
			self._ccbOwner.node_name:setVisible(false)
		end
	end
end

function QUIWidgetInstanceHead:hideStar()
	for i=1,3,1 do
		self._ccbOwner["star_bg"..i]:setVisible(false)
		self._ccbOwner["star"..i]:setVisible(false)
	end
end

function QUIWidgetInstanceHead:avatarHandler(actorId)
	local character = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	self._avatar = QUIWidgetActorDisplay.new(actorId)
	self._ccbOwner.node_avatar:addChild(self._avatar)
	if self._info.boss_size ~= nil then
		self._avatar:setScaleX(self._info.boss_size)
		self._avatar:setScaleY(self._info.boss_size)
	end
	if self._ccbOwner.tf_name then
		self._ccbOwner.tf_name:setString(character.name or "")
	end
end

function QUIWidgetInstanceHead:addChestBox()
	if self._chest == nil then
		local callBacks = {
				{ccbCallbackName = "onTriggerBoxGold", callback = handler(self, QUIWidgetInstanceHead._onTriggerBoxGold)},
			}
		self._chest = QUIWidget.new("ccb/Widget_Elite_Baoxiang.ccbi",callBacks)
		self._chest._ccbOwner.node_gold_close:setVisible(false)
		self._chest._ccbOwner.node_gold_open:setVisible(false)
		self._chest:setScale(1.1)
		self._ccbOwner.node_chest:addChild(self._chest)
	end
	if self._animationPlayer == nil then
		self._animationPlayer = QUIWidgetAnimationPlayer.new()
		self._chest._ccbOwner.node_gold_close:getParent():addChild(self._animationPlayer)
	end
	self._isOpen = false
	if self._instanceType and self._instanceType == DUNGEON_TYPE.WELFARE then
		if remote.welfareInstance:isBossBoxOpened( self._info.int_dungeon_id) then
			self._isOpen = true
			self._animationPlayer:playAnimation("ccb/effects/fubenbaoxiang_yilingqu.ccbi",nil,nil,false)
		else
			if self._isPass == true then
				self._animationPlayer:playAnimation("ccb/effects/fubenbaoxiang_kelingqu.ccbi",nil,nil,false)
			else
				self._animationPlayer:playAnimation("ccb/effects/fubenbaoxiang_jingzhi.ccbi",nil,nil,false)
			end
		end
	else
		if self._info.info ~= nil and self._info.info.bossBoxOpened == true then
			self._isOpen = true
			self._animationPlayer:playAnimation("ccb/effects/fubenbaoxiang_yilingqu.ccbi",nil,nil,false)
		else
			if self._isPass == true then
				self._animationPlayer:playAnimation("ccb/effects/fubenbaoxiang_kelingqu.ccbi",nil,nil,false)
			else
				self._animationPlayer:playAnimation("ccb/effects/fubenbaoxiang_jingzhi.ccbi",nil,nil,false)
			end
		end
	end
	if self._info.box_coordinate ~= nil then
		local pos = string.split(self._info.box_coordinate, ",")
		local posX = tonumber(pos[1])
		local posY = tonumber(pos[2])
		self._chest:setPositionX(posX)
		self._chest:setPositionY(posY)
	end
end

function QUIWidgetInstanceHead:speak()
	if self._word == nil then
		self._word = QChatDialog.new()
		local contain = self:getParent():getParent()
		contain:addChild(self._word)
		local pos = self:convertToWorldSpaceAR(ccp(0,0))
		pos = contain:convertToNodeSpaceAR(pos)
		local offsetX = self._info.word_x or 0
		local offsetY = self._info.word_y or 0
		self._word:setPositionY(pos.y + 70 + offsetY)
		self._word:setPositionX(pos.x - 50 + offsetX)
	end
	local dungeonConfig = db:getDungeonConfigByID(self._info.dungeon_id)
	self._word:setString(dungeonConfig.description or " ")
	self._word:setScaleX(-1)
end

function QUIWidgetInstanceHead:getBg()
	return self._ccbOwner.node_bg
end

function QUIWidgetInstanceHead:getRoot( )
	return self._ccbOwner.node_root
end

function QUIWidgetInstanceHead:getStarNode()
	return self._ccbOwner.node_star
end

function QUIWidgetInstanceHead:getDungeonId()
	return self._info.dungeon_id
end

function QUIWidgetInstanceHead:setTempData(data)
	self.tempData = data
end

function QUIWidgetInstanceHead:getTempData()
	return self.tempData
end

function QUIWidgetInstanceHead:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetInstanceHead.EVENT_CITY_CLICK, info = self._info})
end

function QUIWidgetInstanceHead:_onTriggerBoxGold( ... )
	local args = { ... }
	-- print("===========")
 --  	for k, v in pairs(args) do
 --  		print(k, v, "@")
 --  	end
  	if args[1] == "1" then return end 
	self:dispatchEvent({name = QUIWidgetInstanceHead.EVENT_BOX_CLICK, info = self._info, isOpen = self._isOpen, isPass = self._isPass, box = self})
end

return QUIWidgetInstanceHead