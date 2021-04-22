


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroBorrowOperation = class("QUIWidgetHeroBorrowOperation", QUIWidget)
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("..QUIViewController")

QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_IN = 1
QUIWidgetHeroBorrowOperation.INFO_TYPE_APPLY = 2
QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_OUT = 3
QUIWidgetHeroBorrowOperation.INFO_TYPE_APPLY_FOR = 4



function QUIWidgetHeroBorrowOperation:ctor(options)
	local ccbFile = "ccb/Widget_HeroBorrow_Operation.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerBorrow", callback = handler(self, self._onTriggerBorrow)},
		{ccbCallbackName = "onTriggerReturn", callback = handler(self, self._onTriggerReturn)},
		{ccbCallbackName = "onTriggerClickHead", callback = handler(self, self._onTriggerClickHead)},
    }
	QUIWidgetHeroBorrowOperation.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.btn_return)
    q.setButtonEnableShadow(self._ccbOwner.btn_borrow)

end

function QUIWidgetHeroBorrowOperation:resetData()
    self._ccbOwner.tf_level:setString("")
    self._ccbOwner.tf_name:setString("")
    self._ccbOwner.tf_vip:setString("")
    self._ccbOwner.tf_force_value:setString("")
    self._ccbOwner.tf_value1:setString("")
    self._ccbOwner.tf_applyfor_num:setString("")


    self._ccbOwner.node_return:setVisible(false)
    self._ccbOwner.node_borrow:setVisible(false)
    self._ccbOwner.node_info:setVisible(false)

    self._ccbOwner.node_power:setVisible(false)
    self._ccbOwner.node_state:setVisible(false)
    self._ccbOwner.node_select:setVisible(false)

end


function QUIWidgetHeroBorrowOperation:setInfo(info ,_type ,actorId)

	self:resetData()

	self._info = info
	local level = 99
	local soulTrial = nil
	local name = ""
	local target_name = ""
	local vip = 0
	local force = 0
	local isBorrow = false
	local isApply = false
	local isBorrowFull = false
	local borrow_count = 0
	local avatar = 0

	local heroInfo = nil
	if _type == QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_IN then
		soulTrial = info.borrowFighter.soulTrial
		name  = info.borrowFighter.name
		level = info.borrowFighter.level
		vip = info.borrowFighter.vip or 0
		force = info.borrowFighter.heros[1].force or 0
		heroInfo= info.borrowFighter.heros[1]
		self._actorId = heroInfo.actorId
    	self._ccbOwner.node_power:setVisible(true)
    	self._ccbOwner.node_power:setPositionY(-50)
    	self._ccbOwner.node_return:setVisible(true)
	elseif _type == QUIWidgetHeroBorrowOperation.INFO_TYPE_APPLY then
		soulTrial = info.borrowFighter.soulTrial
		name  = info.borrowFighter.name
		level = info.borrowFighter.level
		vip = info.borrowFighter.vip or 0
		force = info.ownFighter.heros[1].force or 0
		heroInfo= info.ownFighter.heros[1]
		self._actorId = info.actorId
    	self._ccbOwner.node_power:setVisible(true)
    	self._ccbOwner.node_power:setPositionY(-50)
    	self._ccbOwner.node_borrow:setVisible(true)
	elseif _type == QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_OUT then
		soulTrial = info.soulTrial
		level = remote.user.level
		name = remote.user.nickname
		vip = app.vipUtil:VIPLevel() or 0
		target_name  = info.borrowFighter.name
		heroInfo= info.ownFighter.heros[1]
		force = info.ownFighter.heros[1].force or 0

		self._actorId = heroInfo.actorId

    	self._ccbOwner.node_power:setVisible(true)
    	self._ccbOwner.node_state:setVisible(true)
    	self._ccbOwner.node_power:setPositionY(-37)

	elseif _type == QUIWidgetHeroBorrowOperation.INFO_TYPE_APPLY_FOR then
		soulTrial = info.soulTrial
		name  = info.name
		level = info.level
		vip = info.vip or 0
		isBorrow = info.isBorrow
		isApply = info.isApply

		borrow_count = info.applyCount
		isBorrowFull = borrow_count >= 5
		-- avatar = info.avatar
		heroInfo= info.heros[1]
		force = info.heros[1].force or 0


    	self._ccbOwner.node_info:setVisible(true)
		self._actorId = actorId
		self._info.selected = self._info.selected or false
		self:setSelect(self._info.selected)
    	self._ccbOwner.node_select:setVisible(not isBorrow and not isApply and not isBorrowFull)
    	self._ccbOwner.node_power:setVisible(true)
    	self._ccbOwner.node_power:setPositionY(-50)
	end


    self._ccbOwner.tf_level:setString("LV."..level)
    self._ccbOwner.tf_name:setString(name)
	self._ccbOwner.tf_vip:setString( "VIP"..vip)

	local num, unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_force_value:setString(num..(unit or ""))

	-- self:setAvatar(avatar)
	self:setHeroHead(heroInfo)
	self:setSoulTrial(soulTrial)

    self._ccbOwner.tf_value1:setString(target_name)
    self._ccbOwner.tf_value1:setPositionX(self._ccbOwner.tf_value0:getPositionX() + self._ccbOwner.tf_value0:getContentSize().width + 10)
    self._ccbOwner.tf_value2:setPositionX(self._ccbOwner.tf_value0:getPositionX() + self._ccbOwner.tf_value0:getContentSize().width  + 10  + 10 + self._ccbOwner.tf_value1:getContentSize().width )

    if self._ccbOwner.sp_soulTrial:isVisible() then
    	self._ccbOwner.tf_level:setPositionX(self._ccbOwner.sp_soulTrial:getPositionX() + self._ccbOwner.sp_soulTrial:getContentSize().width )
	else
    	self._ccbOwner.tf_level:setPositionX(-200)
	end

    self._ccbOwner.tf_name:setPositionX(self._ccbOwner.tf_level:getPositionX() + self._ccbOwner.tf_level:getContentSize().width )
    self._ccbOwner.tf_vip:setPositionX(self._ccbOwner.tf_name:getPositionX() + self._ccbOwner.tf_name:getContentSize().width )

	self._ccbOwner.tf_applyfor_num:setString(borrow_count.."人申请")
	self._ccbOwner.tf_applyfor_num:setVisible(not isBorrow and not isApply and not isBorrowFull)

	self._ccbOwner.tf_borrowed:setVisible(isBorrow or isApply or isBorrowFull)
	if isBorrowFull then
		self._ccbOwner.tf_borrowed:setString("申请已满")
	elseif isBorrow then
		self._ccbOwner.tf_borrowed:setString("已借出")
	else
		self._ccbOwner.tf_borrowed:setString("已申请")
	end	

end

function QUIWidgetHeroBorrowOperation:getSelectState()
	if self._info.selected == nil then
		return false
	else
		return self._info.selected
	end
end



function QUIWidgetHeroBorrowOperation:_onTriggerSelect()
 	self._info.selected = not self._info.selected
	self:setSelect(self._info.selected == true)
end



function QUIWidgetHeroBorrowOperation:_onTriggerBorrow(func)

	local  success = function ( )
		-- body
		-- remote.offerreward:clearBorrowInfoByActorId(self._info.actorId)
		app.tip:floatTip("魂师借出成功~")
		if func then func() end 
	end
	remote.offerreward:offerRewardPromissRequest({self._info.borrowId},success)
end


function QUIWidgetHeroBorrowOperation:_onTriggerReturn(func)

	if not remote.offerreward:checkBorrowIdCanReturn(self._info.borrowId) then
		app.tip:floatTip("该魂师正在执行派遣任务，无法归还~")
		return
	end

	local  success = function ( )
		-- body
		-- remote.offerreward:clearBorrowInInfoByBorrowId(self._info.borrowId)
		app.tip:floatTip("魂师归还成功~")
		if func then func() end 
	end
	print(" _onTriggerReturn   "..self._info.borrowId)
	remote.offerreward:offerRewardReturnHeroRequest({self._info.borrowId},success)
end

function QUIWidgetHeroBorrowOperation:setSelect(b)
	self._ccbOwner.sp_select:setVisible(b)
	self._ccbOwner.btn_select:setHighlighted(b)
end


function QUIWidgetHeroBorrowOperation:_onTriggerClickHead()
	local level = self._info.level or 1

    remote.handBook:requestHandBookRankHeroInfo(self._info.userId, self._actorId, function(data)
		local heroInfo = data.handBookGetTargetUserHeroInfoResponse.targetHero
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroInfo", 
            options = {hero = {heroInfo.actorId}, pos = 1, fighter = {level = level, ["heros"] = {heroInfo}} } })


    end)
end


function QUIWidgetHeroBorrowOperation:setSoulTrial(soulTrial)
	local sp = self._ccbOwner.sp_soulTrial
	if not sp then return end

	local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(soulTrial)
	
    if frame then
        sp:setDisplayFrame(frame)
        sp:setVisible(true)
    else
        sp:setVisible(false)
    end
end


function QUIWidgetHeroBorrowOperation:setHeroHead(heroInfo)
	self._ccbOwner.node_avatar:removeAllChildren()
	if heroInfo then
		local heroHead = QUIWidgetHeroHead.new()
	    heroHead:setHeroInfo(heroInfo)
	    heroHead:showSabc()
	    heroHead:setScale(1)
	    self._ccbOwner.node_avatar:addChild(heroHead)
	end

end

function QUIWidgetHeroBorrowOperation:setAvatar(avatar)
	if avatar == 0 then  return end

	if self._avatarWidget == nil then
		if self._ccbOwner.node_avatar ~= nil then
			self._ccbOwner.node_avatar:removeAllChildren()
			self._avatarWidget = QUIWidgetAvatar.new()
			self._ccbOwner.node_avatar:addChild(self._avatarWidget)
		end
	end
	if self._avatarWidget ~= nil then
		self._avatarWidget:setInfo(avatar)
	end
end


function QUIWidgetHeroBorrowOperation:getContentSize()
	local size = self._ccbOwner.normal_banner:getContentSize()
	return CCSize(size.width + 8, size.height+6)
end

return QUIWidgetHeroBorrowOperation