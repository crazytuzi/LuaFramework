--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderCave = class("QUIWidgetPlunderCave", QUIWidget)

local QUIWidgetPlunderCaveIcon = import("..widgets.QUIWidgetPlunderCaveIcon")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetPlunderCave.EVENT_OK = "QUIWIDGETPLUNDERCAVE_EVENT_OK"
QUIWidgetPlunderCave.EVENT_INFO = "QUIWIDGETPLUNDERCAVE_EVENT_INFO"

function QUIWidgetPlunderCave:ctor(options)
	local ccbFile = "ccb/Widget_plunder_cave.ccbi"
	local callBacks = {}
	QUIWidgetPlunderCave.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self._caveId = options.cave_id
    self._quality = options.cave_quality
	self._name = options.cave_name
	self._caveCount = options.cave_count
	self._caveRegion = options.cave_region

	self:_init()
end

function QUIWidgetPlunderCave:onEnter()

end

function QUIWidgetPlunderCave:onExit()

end

function QUIWidgetPlunderCave:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetPlunderCave:update()
	self:_update()
end

function QUIWidgetPlunderCave:_onEvent(event)
	if event.name == QUIWidgetPlunderCaveIcon.EVENT_OK then
		self:dispatchEvent( {name = QUIWidgetPlunderCave.EVENT_OK, caveId = self._caveId, caveRegion = self._caveRegion, caveName = self._name} )
	end
end

function QUIWidgetPlunderCave:_onTriggerAssistOK( ... )
	self:dispatchEvent( {name = QUIWidgetPlunderCave.EVENT_OK, caveId = self._caveId, caveRegion = self._caveRegion, caveName = self._name} )
end

function QUIWidgetPlunderCave:_init()
	local icon = QUIWidgetPlunderCaveIcon.new(self._quality)
	icon:addEventListener(QUIWidgetPlunderCaveIcon.EVENT_OK, handler(self, self._onEvent))
	self._ccbOwner.node_icon:addChild(icon)

	self:_update()
end

function QUIWidgetPlunderCave:_update()
	self._ccbOwner.s9s_name_bg_our:setVisible(false)
	self._ccbOwner.s9s_name_bg_other:setVisible(true)
	self._ccbOwner.node_buff:setVisible(false)
	self._ccbOwner.sp_buff_3:setVisible(false)
	self._ccbOwner.sp_buff_4:setVisible(false)
	self._ccbOwner.sp_buff_5:setVisible(false)

	local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	local mineIdList = string.split(caveConfig.mine_ids, ";")
	local mineId = mineIdList[1]
	local maxMineId = remote.plunder:getMaxMineId()
	if tonumber(mineId) > tonumber(maxMineId) then
		self._ccbOwner.tf_cave_info:setString(self._name.."（0/0）")
		self._ccbOwner.tf_society_name:setString("尚未开放")
	else
		if caveConfig and table.nums(caveConfig) > 0 and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
			local index = 1
			while true do
				if index > 1 then
					mineId = remote.plunder:addMineId(mineId, caveConfig.cave_id)
					if tonumber(mineId) > tonumber(maxMineId) then
						break
					end
					mineIdList[index] = mineId
				end
				index = index + 1
			end
			self._ccbOwner.tf_cave_info:setString(self._name.."（"..(index - 1).."/"..(index - 1).."）")
		else
			local caveInfo = remote.plunder:getCaveInfoByCaveId( self._caveId )
			if caveInfo and caveInfo.occupies then
				self._ccbOwner.tf_cave_info:setString(self._name.."（"..table.nums(caveInfo.occupies).."/"..self._caveCount.."）")
			else
				self._ccbOwner.tf_cave_info:setString(self._name.."（0/"..self._caveCount.."）")
			end
		end
	end

	local isBuff, member, consortiaId, consortiaName = remote.plunder:getSocietyBuffInfoByCaveId( self._caveId )
	-- print(isBuff, consortiaName)
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
		-- self._ccbOwner.node_buff:setPositionX( x + width/2 + 40 )
	else
		local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
		if caveConfig and caveConfig.cave_bonus == 1 then
			self._ccbOwner.tf_society_name:setString("暂无宗门加成")
		else
			self._ccbOwner.tf_society_name:setString("无宗门加成")
		end
		self._ccbOwner.tf_society_name:setColor( COLORS.a )
		self._ccbOwner.tf_society_name:disableOutline()
	end
	
	self:_updateMyCaveCCB()
end

function QUIWidgetPlunderCave:_updateMyCaveCCB()
	local myMineId = remote.plunder:getMyMineId()
	if myMineId then
		local caveId = remote.plunder:getCaveIdByMineId( myMineId )
		if caveId == self._caveId then
			local pos, ccbFile = remote.plunder:getGuang()
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

return QUIWidgetPlunderCave