--
-- Author: Kumo.Wang
-- Date: 
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRefineCell = class("QUIWidgetRefineCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("..models.QActorProp")

QUIWidgetRefineCell.CHANGE_LOCK = "QUIWIDGETREFINECELL.CHANGE_LOCK"
QUIWidgetRefineCell.OPEN = "QUIWIDGETREFINECELL.OPEN"
QUIWidgetRefineCell.STOP = "QUIWIDGETREFINECELL.STOP"
QUIWidgetRefineCell.REPLACE_COMPLETE = "QUIWIDGETREFINECELL.REPLACE_COMPLETE"
QUIWidgetRefineCell.REFINE_COMPLETE = "QUIWIDGETREFINECELL.REFINE_COMPLETE"
function QUIWidgetRefineCell:ctor(options)
	local ccbFile = "ccb/Widget_refine_lock.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLock", callback = handler(self, self._onTriggerLock)},
        {ccbCallbackName = "onTriggerOpen", callback = handler(self, self._onTriggerOpen)},
	}
	QUIWidgetRefineCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._actorId = options.actorId
	self._index = options.index
	self._isLock = options.isLock ~= nil and true or false
	self._isOpen = false
	self._isEmpty = true -- 右边是否清除
	self._isLeftEmpty = true -- 左边是否为空
	self._delay = false

	self:_init()
end

function QUIWidgetRefineCell:onEnter()
end

function QUIWidgetRefineCell:_onUserProxyEvent( event )
end

function QUIWidgetRefineCell:onExit()

end

-- function QUIWidgetRefineCell:isEmpty()
-- 	if not self._isOpen or self._isLeftEmpty then return false end
-- 	if self._isLock then return false end
-- 	return self._isEmpty
-- end

function QUIWidgetRefineCell:getIndex()
	return self._index
end

function QUIWidgetRefineCell:_onTriggerLock()
	app.sound:playSound("common_small")
	local heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end

	if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.refineAttrsPre and #heroInfo.refineHeroInfo.refineAttrsPre > 0 then
		app:alert({content = "有预览属性，锁定或解锁操作会清空预览属性，是否继续操作？", title = "系统提示", 
	        callback = function(state)
	        	if state == ALERT_TYPE.CONFIRM then
	            	self:_checkLock()
	            end
	        end, isAnimation = false}, true, true)
	else
		self:_checkLock()
	end
end

function QUIWidgetRefineCell:_checkLock()
	self._isLock = not self._isLock
	self:_checkLockState()

	self:dispatchEvent({ name = QUIWidgetRefineCell.CHANGE_LOCK, index = self._index, isLock = self._isLock })
end

function QUIWidgetRefineCell:_onTriggerOpen()
	app.sound:playSound("common_small")
	self:dispatchEvent({ name = QUIWidgetRefineCell.OPEN, index = self._index })
end

function QUIWidgetRefineCell:isOpen()
	return self._isOpen
end

function QUIWidgetRefineCell:setDaley( boo )
	self._delay = boo
end

function QUIWidgetRefineCell:showOpenEffect()
	local ccbFile = "ccb/effects/xilian_zhufu_1.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:setScaleX(1.15)
    aniPlayer:setPosition(17, 0)
    aniPlayer:playAnimation(ccbFile, function()
    		app.sound:playSound("map_fireworks")
    		self._ccbOwner.node_close:setVisible(false)
    	end, function()
    		self._delay = false
    		self:update()
    		self:_showOpenGridEffect()
    	end, true)
end

function QUIWidgetRefineCell:showReplaceEffect()
	if self._isLock or not self._isOpen then
		self._delay = false
		self:update()
		return
	end
	self._isEmpty = true
	local ccbFile = "ccb/effects/xilian_2.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function()
    		app.sound:playSound("map_fireworks")
    	end, function()
    		self._delay = false
    		self:update()
    		self:dispatchEvent({ name = QUIWidgetRefineCell.REPLACE_COMPLETE })
    	end, true)
end

function QUIWidgetRefineCell:showRefineEffect()
	if self._isLock or not self._isOpen then
		self._delay = false
		self:update()
		return
	end
	local ccbFile = "ccb/effects/xilian_1.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function()
    	app.sound:playSound("hero_up")
    	end, function()
    		self:dispatchEvent({ name = QUIWidgetRefineCell.REFINE_COMPLETE })
    		self._delay = false
    		self:update()
    	end, true)
end

function QUIWidgetRefineCell:update()
	if self._delay then return end

	local heroInfo = remote.herosUtil:getHeroByID( self._actorId ) 
	local heroLevel = heroInfo.level
	local openGrid = 0
	if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.openGrid then
		openGrid = heroInfo.refineHeroInfo.openGrid
	else
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID( self._actorId ) 
		if refineHeroInfo then
			openGrid = refineHeroInfo.openGrid
		end
	end

	self:_checkLevel( heroLevel, openGrid )

	-- 设置属性的名字和值
	local buffConfig = QStaticDatabase.sharedDatabase():getRefineBuffConfig()
	local color = QIDEA_QUALITY_COLOR.GREEN
	local isRed = nil
	if self._isLock then
		self._isEmpty = true
		if heroInfo.refineAttrs then
			-- 左边的属性, 右边同左边的属性
			for _, value in pairs( heroInfo.refineAttrs ) do
				if value.grid == self._index then
					self._isLeftEmpty = false
					local buffName = QActorProp._field[ value.attribute ].refineName or QActorProp._field[ value.attribute ].name
					buffName = string.gsub(buffName, "百分比", "")
					buffName = string.gsub(buffName, "玩家对战", "PVP")
					if not buffConfig[ value.attribute ] then
						self._ccbOwner.tf_buff_now:setString(value.attribute)
						self._ccbOwner.tf_buff_will:setString(value.attribute)
						return
					end
					local isPercentage = (buffConfig[ value.attribute ].show_model == "2" or buffConfig[ value.attribute ].show_model == 2)-- 1: 绝对值； 2： 百分比
					local buffValue = ""
					if isPercentage then
						buffValue = string.format("%.2f", (value.refineValue * 100)).."%"
					else
						buffValue = value.refineValue
					end
					color = self:_getColor( value.attribute, value.refineValue )
					self._ccbOwner.tf_buff_now:setString( buffName.." + "..buffValue )
					self._ccbOwner.tf_buff_will:setString( buffName.." + "..buffValue )
					self._ccbOwner.tf_buff_now:setColor( color )
					self._ccbOwner.tf_buff_will:setColor( color )
					self._ccbOwner.btn_lock:setEnabled(true)
					self:_checkLockState()
					break
				end
			end
		end
	else
		self._isEmpty = true
		if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.refineAttrsPre then
			-- 右边的属性
			for _, value in pairs( heroInfo.refineHeroInfo.refineAttrsPre ) do
				if value.grid == self._index then
					self._isEmpty = false
					local buffName = QActorProp._field[ value.attribute ].refineName or QActorProp._field[ value.attribute ].name
					buffName = string.gsub(buffName, "百分比", "")
					buffName = string.gsub(buffName, "玩家对战", "PVP")
					if not buffConfig[ value.attribute ] then
						self._ccbOwner.tf_buff_will:setString(value.attribute)
						return
					end
					local isPercentage = (buffConfig[ value.attribute ].show_model == "2" or buffConfig[ value.attribute ].show_model == 2)-- 1: 绝对值； 2： 百分比
					local buffValue = ""
					if isPercentage then
						buffValue = string.format("%.2f", (value.refineValue * 100)).."%"
					else
						buffValue = value.refineValue
					end
					color, isRed = self:_getColor( value.attribute, value.refineValue )
					if isRed then
						self:dispatchEvent({ name = QUIWidgetRefineCell.STOP })
					end
					self._ccbOwner.tf_buff_will:setString( buffName.." + "..buffValue )
					self._ccbOwner.tf_buff_will:setColor( color )
					break
				end
			end
		end

		if heroInfo.refineAttrs then
			-- 左边的属性
			for _, value in pairs( heroInfo.refineAttrs ) do
				if value.grid == self._index then
					self._isLeftEmpty = false
					local buffName = QActorProp._field[ value.attribute ].refineName or QActorProp._field[ value.attribute ].name
					buffName = string.gsub(buffName, "百分比", "")
					buffName = string.gsub(buffName, "玩家对战", "PVP")
					if not buffConfig[ value.attribute ] then
						self._ccbOwner.tf_buff_now:setString(value.attribute)
						return
					end
					local isPercentage = (buffConfig[ value.attribute ].show_model == "2" or buffConfig[ value.attribute ].show_model == 2)-- 1: 绝对值； 2： 百分比
					local buffValue = ""
					if isPercentage then
						buffValue = string.format("%.2f", (value.refineValue * 100)).."%"
					else
						buffValue = value.refineValue
					end
					color = self:_getColor( value.attribute, value.refineValue )
					self._ccbOwner.tf_buff_now:setString( buffName.." + "..buffValue )
					self._ccbOwner.tf_buff_now:setColor( color )
					self._ccbOwner.btn_lock:setEnabled(true)
					self:_checkLockState()
					break
				end
			end
		end
	end
end

function QUIWidgetRefineCell:_init()
	self:update()
end

-- openGrid 已经用神炼石开始格子的数量
function QUIWidgetRefineCell:_checkLevel( level, openGrid )
	if not openGrid then openGrid = 0 end

	local config = QStaticDatabase:sharedDatabase():getUnlock()
	local key = "UNLOCK_XILIAN_"..self._index
	self._ccbOwner.tf_buff_now:setString("")
	self._ccbOwner.tf_buff_will:setString("")
	self._ccbOwner.tf_close:setString("")
	self._ccbOwner.btn_lock:setEnabled(false)
	self._ccbOwner.btn_open:setEnabled(false)
	self._ccbOwner.sp_lock:setVisible(false)
	self._ccbOwner.sp_unlock:setVisible(false)
	self._ccbOwner.sp_lock_effect:setVisible(false)
	self._ccbOwner.node_open:setVisible(false)
	self._ccbOwner.node_close:setVisible(false)

	if openGrid == 0 then
		if config[key] then
			if config[key].hero_level <= level then
				-- 等级达到
				self._ccbOwner.node_open:setVisible(true)
				self._ccbOwner.tf_buff_now:setString("未洗炼")
				self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
				self._isOpen = true
			else
				-- 等级未达到，显示开启等级提示
				self._ccbOwner.node_close:setVisible(true)
				self._ccbOwner.sp_close:setVisible(false)
				self._ccbOwner.tf_close:setString("魂师等级"..config[key].hero_level.."级后开启")
			end
		else
			-- 显示需要神炼石开启的提示
			self._ccbOwner.node_close:setVisible(true)
			self._ccbOwner.sp_close:setVisible(true)
			self._ccbOwner.btn_open:setEnabled(true)
		end
	elseif openGrid == 1 then
		if config[key] then
			if config[key].hero_level <= level then
				-- 等级达到
				self._ccbOwner.node_open:setVisible(true)
				self._ccbOwner.tf_buff_now:setString("未洗炼")
				self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
				self._isOpen = true
			else
				key = "UNLOCK_XILIAN_"..(self._index - 1)
				if config[key] then
					if config[key].hero_level <= level then
						-- 等级达到
						self._ccbOwner.node_open:setVisible(true)
						self._ccbOwner.tf_buff_now:setString("未洗炼")
						self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
						self._isOpen = true
					else
						-- 前面一个格子已经显示了开启的神炼石格子了，当前格子显示等级提示
						self._ccbOwner.node_close:setVisible(true)
						self._ccbOwner.sp_close:setVisible(false)
						self._ccbOwner.tf_close:setString("魂师等级"..config[key].hero_level.."级后开启")
					end
				else
					-- 显示开启的神炼石格子
					self._ccbOwner.node_open:setVisible(true)
					self._ccbOwner.tf_buff_now:setString("未洗炼")
					self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
					self._isOpen = true
				end
			end
		else
			-- 显示需要神炼石开启的提示
			key = "UNLOCK_XILIAN_"..(self._index - 1)
			if config[key] then
				if config[key].hero_level <= level then
					-- 显示开启的神炼石格子
					self._ccbOwner.node_open:setVisible(true)
					self._ccbOwner.tf_buff_now:setString("未洗炼")
					self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
					self._isOpen = true
				else
					-- 前面一个格子已经显示了开启的神炼石格子了，当前格子显示等级提示
					self._ccbOwner.node_close:setVisible(true)
					self._ccbOwner.sp_close:setVisible(false)
					self._ccbOwner.tf_close:setString("魂师等级"..config[key].hero_level.."级后开启")
				end
			else
				-- 显示需要神炼石开启的提示
				self._ccbOwner.node_close:setVisible(true)
				self._ccbOwner.sp_close:setVisible(true)
				self._ccbOwner.btn_open:setEnabled(true)
			end
		end
	elseif openGrid == 2 then
		if config[key] then
			if config[key].hero_level <= level then
				-- 等级达到
				self._ccbOwner.node_open:setVisible(true)
				self._ccbOwner.tf_buff_now:setString("未洗炼")
				self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
				self._isOpen = true
			else
				key = "UNLOCK_XILIAN_"..(self._index - 1)
				if config[key].hero_level <= level then
					-- 显示开启的第一个神炼石格子
					self._ccbOwner.node_open:setVisible(true)
					self._ccbOwner.tf_buff_now:setString("未洗炼")
					self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
					self._isOpen = true
				else
					key = "UNLOCK_XILIAN_"..(self._index - 2)
					if config[key].hero_level <= level then
						-- 显示开启的第二个神炼石格子
						self._ccbOwner.node_open:setVisible(true)
						self._ccbOwner.tf_buff_now:setString("未洗炼")
						self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
						self._isOpen = true
					else
						-- 前面2个格子已经显示了开启的神炼石格子了，当前格子显示等级提示
						self._ccbOwner.node_close:setVisible(true)
						self._ccbOwner.sp_close:setVisible(false)
						self._ccbOwner.tf_close:setString("魂师等级"..config[key].hero_level.."级后开启")
					end
				end
			end
		else
			-- 显示需要神炼石开启的提示
			key = "UNLOCK_XILIAN_"..(self._index - 1)
			if config[key] then
				if config[key].hero_level <= level then
					-- 显示开启的神炼石格子
					self._ccbOwner.node_open:setVisible(true)
					self._ccbOwner.tf_buff_now:setString("未洗炼")
					self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
					self._isOpen = true
				else
					key = "UNLOCK_XILIAN_"..(self._index - 2)
					if config[key].hero_level <= level then
						-- 显示开启的第二个神炼石格子
						self._ccbOwner.node_open:setVisible(true)
						self._ccbOwner.tf_buff_now:setString("未洗炼")
						self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
						self._isOpen = true
					else
						-- 前面2个格子已经显示了开启的神炼石格子了，当前格子显示等级提示
						self._ccbOwner.node_close:setVisible(true)
						self._ccbOwner.sp_close:setVisible(false)
						self._ccbOwner.tf_close:setString("魂师等级"..config[key].hero_level.."级后开启")
					end
				end
			else
				key = "UNLOCK_XILIAN_"..(self._index - 2)
				if config[key].hero_level <= level then
					-- 当前是最后一个格子，如果最后一个等级已经解锁，那么全部解锁
					self._ccbOwner.node_open:setVisible(true)
					self._ccbOwner.tf_buff_now:setString("未洗炼")
					self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
					self._isOpen = true
				else
					-- 当前是最后一个格子，如果最后一个等级未解锁，那么最后一个格子就显示最后一个等级提示
					self._ccbOwner.node_close:setVisible(true)
					self._ccbOwner.sp_close:setVisible(false)
					self._ccbOwner.tf_close:setString("魂师等级"..config[key].hero_level.."级后开启")
				end
			end
		end
	end
end

function QUIWidgetRefineCell:_checkLockState()
	self._ccbOwner.sp_lock_effect:setVisible( self._isLock )
	self._ccbOwner.sp_lock:setVisible( self._isLock )
	self._ccbOwner.sp_unlock:setVisible( not self._isLock )
end

function QUIWidgetRefineCell:_getColor( attribute, value )
	value = (math.floor(value * 100000 + 0.5))/100000
	local buffConfig = QStaticDatabase.sharedDatabase():getRefineBuffConfig()
	local config = buffConfig[ attribute ]
	local multiple = tonumber( config.multiple )
	if config then
		local tbl = self:_analysisScope( config.value_green )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.GREEN
		end

		tbl = self:_analysisScope( config.value_blue )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.BLUE
		end

		tbl = self:_analysisScope( config.value_purple )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.PURPLE
		end

		tbl = self:_analysisScope( config.value_orange )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.ORANGE
		end

		tbl = self:_analysisScope( config.value_red )
		if value >= tonumber(tbl[1])/multiple --[[and value <= tonumber(tbl[2])/multiple ]]then
			return QIDEA_QUALITY_COLOR.RED, true
		end
	end

	return QIDEA_QUALITY_COLOR.GREEN
end

-- str = "1,15",
function QUIWidgetRefineCell:_analysisScope( str )
	if not str or str == "" then return {} end

	local tbl = string.split( str, "," ) or {}
	-- QPrintTable( tbl )
	table.sort( tbl, function( a, b )
			return tonumber(a) < tonumber(b)
		end)

	return tbl
end

function QUIWidgetRefineCell:_showOpenGridEffect()
    local ccbFile = "ccb/effects/kaiqixilian.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    local page = app:getNavigationManager():getController(app.middleLayer):getTopPage()
    local x = UI_DESIGN_HEIGHT * display.width / display.height / 2
    local y = UI_DESIGN_WIDTH * display.height / display.width / 2
    aniPlayer:setPosition(ccp(x, y))
    page:getView():addChild(aniPlayer)

    aniPlayer:playAnimation(ccbFile, nil, nil, true)
end

return QUIWidgetRefineCell