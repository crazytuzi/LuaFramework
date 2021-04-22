--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineCave = class("QUIWidgetSilverMineCave", QUIWidget)

local QUIWidgetSilverMineCaveIcon = import("..widgets.QUIWidgetSilverMineCaveIcon")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetSilverMineCave.EVENT_OK = "QUIWIDGETSILVERMINECAVE_EVENT_OK"
QUIWidgetSilverMineCave.EVENT_ASSIST = "QUIWIDGETSILVERMINECAVE_EVENT_ASSIST"

function QUIWidgetSilverMineCave:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Cave.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetSilverMineCave._onTriggerOK)},
		{ccbCallbackName = "onTriggerAssistOK", callback = handler(self, QUIWidgetSilverMineCave._onTriggerAssistOK)}
	}
	QUIWidgetSilverMineCave.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self._caveId = options.cave_id
    self._quality = options.cave_quality
	self._name = options.cave_name
	self._caveCount = options.cave_count
	self._caveRegion = options.cave_region
	self._index = 1
	self._mapIndex = 1
	
	self:_init()
end

function QUIWidgetSilverMineCave:onEnter()

end

function QUIWidgetSilverMineCave:onExit()

end

function QUIWidgetSilverMineCave:setIndex(mapIndex, index)
	self._mapIndex = mapIndex
	self._index = index
end

function QUIWidgetSilverMineCave:getIndex()
	return self._mapIndex, self._index
end

function QUIWidgetSilverMineCave:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetSilverMineCave:update()
	self:_update()
end

function QUIWidgetSilverMineCave:_onEvent(event)
	if event.name == QUIWidgetSilverMineCaveIcon.EVENT_OK then
		self:dispatchEvent( {name = QUIWidgetSilverMineCave.EVENT_OK, caveId = self._caveId, caveRegion = self._caveRegion, caveName = self._name} )
	end
end

function QUIWidgetSilverMineCave:_onTriggerAssistOK()
	self:dispatchEvent( {name = QUIWidgetSilverMineCave.EVENT_ASSIST, caveId = self._caveId, caveRegion = self._caveRegion, caveName = self._name, isAssist = true} )
end

function QUIWidgetSilverMineCave:_init()
	local icon = QUIWidgetSilverMineCaveIcon.new(self._quality)
	icon:addEventListener(QUIWidgetSilverMineCaveIcon.EVENT_OK, handler(self, self._onEvent))
	self._ccbOwner.node_icon:addChild(icon)

	self:_update()
end

function QUIWidgetSilverMineCave:_update()
	self._ccbOwner.s9s_name_bg_our:setVisible(false)
	self._ccbOwner.s9s_name_bg_other:setVisible(true)
	self._ccbOwner.node_buff:setVisible(false)
	self._ccbOwner.sp_buff_3:setVisible(false)
	self._ccbOwner.sp_buff_4:setVisible(false)
	self._ccbOwner.sp_buff_5:setVisible(false)
	
	local caveInfo = remote.silverMine:getCaveInfoByCaveId( self._caveId )
	if caveInfo and caveInfo.occupies then
		self._ccbOwner.tf_cave_info:setString(self._name.."（"..table.nums(caveInfo.occupies).."/"..self._caveCount.."）")
	else
		self._ccbOwner.tf_cave_info:setString(self._name.."（0/"..self._caveCount.."）")
	end

	local assistCount = remote.silverMine.assistCount or 0
	self._ccbOwner.node_assist:setVisible(false)
	if caveInfo and assistCount > 0 then
		if caveInfo.isInvite then 
			self._ccbOwner.node_assist:setVisible(true)
		end
	end

	local isBuff, member, consortiaId, consortiaName = remote.silverMine:getSocietyBuffInfoByCaveId( self._caveId )
	if isBuff then
		if consortiaId == remote.plunder:getMyConsortiaId() then
			self._ccbOwner.s9s_name_bg_our:setVisible(true)
			self._ccbOwner.s9s_name_bg_other:setVisible(false)
			self._ccbOwner.tf_society_name:setColor( COLORS.F )
			setShadowByFontColor(self._ccbOwner.tf_society_name, COLORS.F)
			self._ccbOwner.tf_society_name:enableOutline()
		else
			self._ccbOwner.tf_society_name:setColor( COLORS.a )
			self._ccbOwner.tf_society_name:disableOutline()
		end
		self._ccbOwner.tf_society_name:setString(consortiaName)
		self._ccbOwner.tf_buff_num:setString(member.."人")
		self._ccbOwner.node_buff:setVisible(true)
		self._ccbOwner["sp_buff_"..member]:setVisible(true)
		-- local width = self._ccbOwner.tf_society_name:getContentSize().width
		-- local x = self._ccbOwner.tf_society_name:getPositionX()
		-- self._ccbOwner.node_buff:setPositionX( x + width/2 + 20 )
	else
		local caveConfig = remote.silverMine:getCaveConfigByCaveId( self._caveId )
		if caveConfig and caveConfig.cave_bonus == 1 then
			self._ccbOwner.tf_society_name:setString("暂无宗门狩猎")
		else
			self._ccbOwner.tf_society_name:setString("无宗门加成")
		end
		self._ccbOwner.tf_society_name:setColor( COLORS.a )
		self._ccbOwner.tf_society_name:disableOutline()
	end
	
	self:_updateMyCaveCCB()
end

function QUIWidgetSilverMineCave:_updateMyCaveCCB()
	local myOccupy = remote.silverMine:getMyOccupy()
	if myOccupy and table.nums(myOccupy) > 0 then
		local caveId = remote.silverMine:getCaveIdByMineId( myOccupy.mineId )
		if caveId == self._caveId then
			local pos, ccbFile = remote.silverMine:getGuang()
		    local aniPlayer = QUIWidgetAnimationPlayer.new()
		    self._ccbOwner.node_my_cave:removeAllChildren()
		    self._ccbOwner.node_my_cave:addChild(aniPlayer)
		    aniPlayer:setPosition(pos.x, pos.y)
			aniPlayer:playAnimation(ccbFile, nil, nil, false)
		else
			self._ccbOwner.node_my_cave:removeAllChildren()
		end
	else
		self._ccbOwner.node_my_cave:removeAllChildren()
	end
end

return QUIWidgetSilverMineCave