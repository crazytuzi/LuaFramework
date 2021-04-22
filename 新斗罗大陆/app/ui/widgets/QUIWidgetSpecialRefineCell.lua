--
-- Author: Kumo.Wang
-- Date: 
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSpecialRefineCell = class("QUIWidgetSpecialRefineCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
-- local QUIWidgetSpecialRefineCellCell = import("..widgets.QUIWidgetSpecialRefineCellCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("..models.QActorProp")

QUIWidgetSpecialRefineCell.OPEN = "QUIWIDGETSPECIALREFINECELL.OPEN"
QUIWidgetSpecialRefineCell.SELECT = "QUIWIDGETSPECIALREFINECELL.SELECT"
QUIWidgetSpecialRefineCell.REPLACE_COMPLETE = "QUIWIDGETSPECIALREFINECELL.REPLACE_COMPLETE"

function QUIWidgetSpecialRefineCell:ctor(options)
	local ccbFile = "ccb/Widget_refine_zhufu.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
        {ccbCallbackName = "onTriggerOpen", callback = handler(self, self._onTriggerOpen)},
	}
	QUIWidgetSpecialRefineCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._actorId = options.actorId
	self._index = options.index
	self._isSelect = false
	self._isOpen = false
	self._delay = false

	self:_init()
end

function QUIWidgetSpecialRefineCell:onEnter()
end

function QUIWidgetSpecialRefineCell:onExit()

end

function QUIWidgetSpecialRefineCell:_onTriggerSelect()
	app.sound:playSound("common_small")
	self:dispatchEvent({ name = QUIWidgetSpecialRefineCell.SELECT, index = self._index })
end

function QUIWidgetSpecialRefineCell:_onTriggerOpen()
	app.sound:playSound("common_small")
	self:dispatchEvent({ name = QUIWidgetSpecialRefineCell.OPEN, index = self._index })
end

function QUIWidgetSpecialRefineCell:isOpen()
	return self._isOpen
end

function QUIWidgetSpecialRefineCell:setDaley( boo )
	self._delay = boo
end

function QUIWidgetSpecialRefineCell:showOpenEffect()
	local ccbFile = "ccb/effects/xilian_zhufu_1.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function()
    		self._ccbOwner.node_close:setVisible(false)
    	end, function()
    		self._delay = false
    		self:update()
    		self:_showOpenGridEffect()
    	end, true)
end

function QUIWidgetSpecialRefineCell:showReplaceEffect()
	if not self._isSelect or not self._isOpen then
		self._delay = false
		self:update()
		return
	end
	local ccbFile = "ccb/effects/xilian_zhufu_1.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function()
    		app.sound:playSound("map_fireworks")
    		self._ccbOwner.node_close:setVisible(false)
    	end, function()
    		self._delay = false
    		self:update()
    		self:dispatchEvent({ name = QUIWidgetSpecialRefineCell.REPLACE_COMPLETE })
    	end, true)
end

function QUIWidgetSpecialRefineCell:setSelect( selectId )
	self._isSelect = selectId == self._index
	self:_checkSelectState()
end

function QUIWidgetSpecialRefineCell:update()
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
	self:_checkSelectState()

	-- 设置属性的名字和值
	local buffConfig = QStaticDatabase.sharedDatabase():getRefineBuffConfig()
	local color = QIDEA_QUALITY_COLOR.GREEN
	if heroInfo.refineAttrs then
		for _, value in pairs( heroInfo.refineAttrs ) do
			if value.grid == self._index then
				local buffName = QActorProp._field[ value.attribute ].refineName or QActorProp._field[ value.attribute ].name
				buffName = string.gsub(buffName, "百分比", "")
				buffName = string.gsub(buffName, "玩家对战", "PVP")
				if not buffConfig[ value.attribute ] then
					self._ccbOwner.tf_buff:setString(value.attribute)
					return
				end
				local isPercentage = (buffConfig[ value.attribute ].show_model == "2" or buffConfig[ value.attribute ].show_model == 2)-- 1: 绝对值； 2： 百分比
				local buffValue = ""
				if isPercentage then
					buffValue = string.format("%.2f", (value.refineValue * 100)).."%"
				else
					buffValue = value.refineValue
				end

				local maxWord = ""
				if self:isMaxProp( value.attribute, value.refineValue ) then
					maxWord = "(满)"
				end
				color = self:_getColor( value.attribute, value.refineValue )
				self._ccbOwner.tf_buff:setString( buffName.." + "..buffValue.. maxWord)
				self._ccbOwner.tf_buff:setColor( color )
				break
			end
		end
	end
end

function QUIWidgetSpecialRefineCell:_init()
	self:update()
end

-- openGrid 已经用神炼石开始格子的数量
function QUIWidgetSpecialRefineCell:_checkLevel( level, openGrid )
	if not openGrid then openGrid = 0 end

	local config = QStaticDatabase:sharedDatabase():getUnlock()
	local key = "UNLOCK_XILIAN_"..self._index
	self._ccbOwner.tf_buff:setString("")
	self._ccbOwner.tf_close:setString("")
	self._ccbOwner.btn_select:setEnabled(false)
	self._ccbOwner.btn_open:setEnabled(false)
	self._ccbOwner.sp_close:setVisible(false)
	self._ccbOwner.sp_no_select:setVisible(false)
	self._ccbOwner.sp_select:setVisible(false)
	self._ccbOwner.node_open:setVisible(false)
	self._ccbOwner.node_close:setVisible(false)

	if openGrid == 0 then
		if config[key] then
			if config[key].hero_level <= level then
				-- 等级达到
				self._ccbOwner.node_open:setVisible(true)
				self._ccbOwner.tf_buff:setString("未洗炼")
				self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
				self._ccbOwner.btn_select:setEnabled(true)
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
				self._ccbOwner.tf_buff:setString("未洗炼")
				self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
				self._ccbOwner.btn_select:setEnabled(true)
				self._isOpen = true
			else
				key = "UNLOCK_XILIAN_"..(self._index - 1)
				if config[key] then
					if config[key].hero_level <= level then
						-- 等级达到
						self._ccbOwner.node_open:setVisible(true)
						self._ccbOwner.tf_buff:setString("未洗炼")
						self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
						self._ccbOwner.btn_select:setEnabled(true)
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
					self._ccbOwner.tf_buff:setString("未洗炼")
					self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
					self._ccbOwner.btn_select:setEnabled(true)
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
					self._ccbOwner.tf_buff:setString("未洗炼")
					self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
					self._ccbOwner.btn_select:setEnabled(true)
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
				self._ccbOwner.tf_buff:setString("未洗炼")
				self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
				self._ccbOwner.btn_select:setEnabled(true)
				self._isOpen = true
			else
				key = "UNLOCK_XILIAN_"..(self._index - 1)
				if config[key].hero_level <= level then
					-- 显示开启的第一个神炼石格子
					self._ccbOwner.node_open:setVisible(true)
					self._ccbOwner.tf_buff:setString("未洗炼")
					self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
					self._ccbOwner.btn_select:setEnabled(true)
					self._isOpen = true
				else
					key = "UNLOCK_XILIAN_"..(self._index - 2)
					if config[key].hero_level <= level then
						-- 显示开启的第二个神炼石格子
						self._ccbOwner.node_open:setVisible(true)
						self._ccbOwner.tf_buff:setString("未洗炼")
						self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
						self._ccbOwner.btn_select:setEnabled(true)
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
					self._ccbOwner.tf_buff:setString("未洗炼")
					self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
					self._ccbOwner.btn_select:setEnabled(true)
					self._isOpen = true
				else
					key = "UNLOCK_XILIAN_"..(self._index - 2)
					if config[key].hero_level <= level then
						-- 显示开启的第二个神炼石格子
						self._ccbOwner.node_open:setVisible(true)
						self._ccbOwner.tf_buff:setString("未洗炼")
						self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
						self._ccbOwner.btn_select:setEnabled(true)
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
					self._ccbOwner.tf_buff:setString("未洗炼")
					self._ccbOwner.tf_buff:setColor(UNITY_COLOR_LIGHT.gray)
					self._ccbOwner.btn_select:setEnabled(true)
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

function QUIWidgetSpecialRefineCell:_checkSelectState()
	if not self._isSelect then
		self._ccbOwner.sp_no_select:setVisible(true)
		self._ccbOwner.sp_select:setVisible(false)
	else
		self._ccbOwner.sp_no_select:setVisible(false)
		self._ccbOwner.sp_select:setVisible(true)
	end
end

function QUIWidgetSpecialRefineCell:_getColor( attribute, value )
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
function QUIWidgetSpecialRefineCell:_analysisScope( str )
	if not str or str == "" then return {} end

	local tbl = string.split( str, "," ) or {}
	-- QPrintTable( tbl )
	table.sort( tbl, function( a, b )
			return tonumber(a) < tonumber(b)
		end)

	return tbl
end

function QUIWidgetSpecialRefineCell:_showOpenGridEffect()
    local ccbFile = "ccb/effects/kaiqixilian.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    local page = app:getNavigationManager():getController(app.middleLayer):getTopPage()
    local x = UI_DESIGN_HEIGHT * display.width / display.height / 2
    local y = UI_DESIGN_WIDTH * display.height / display.width / 2
    aniPlayer:setPosition(ccp(x, y))
    page:getView():addChild(aniPlayer)

    aniPlayer:playAnimation(ccbFile, nil, nil, true)
end

function QUIWidgetSpecialRefineCell:isMaxProp( attribute, value )
	value = (math.floor(value * 100000 + 0.5))/100000
	local buffConfig = QStaticDatabase.sharedDatabase():getRefineBuffConfig()
	local config = buffConfig[ attribute ]
	local multiple = tonumber( config.multiple )
	if config then
		local data = string.split( config.value_red_info, ";")
		local tbl = {}
		for _, value in pairs(data) do
			tbl[#tbl+1] = string.split( value, ",")
		end
		if value == tonumber(tbl[#tbl][1])/multiple then
			return true
		end
	end

	return false
end

return QUIWidgetSpecialRefineCell