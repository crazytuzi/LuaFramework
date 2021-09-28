module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_springRollMain = i3k_class("wnd_springRollMain", ui.wnd_base)

function wnd_springRollMain:ctor()
	self._lampList = {}
	self._positionList = {}
	self._offset = 6000
	self._lampCnt = 0
	self._currentLampIndex = 0
	self._isShowAnimation = false
end

function wnd_springRollMain:configure()
	local widgets = self._layout.vars
	
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.lamp_btn = widgets.lamp_btn
	self.lamp_btn:onTouchEvent(self, self.onLampBtnTouch)
	self.finish_image = widgets.finish_image
	self.lamp_cnt = widgets.lamp_cnt
	self.desc = widgets.desc
	self.icon = widgets.icon
	self.lamp_move = widgets.lamp_move
	self.lamp_move:setVisible(false)
	self.c_zu = self._layout.anis.c_zu
	self.c_gc = self._layout.anis.c_gc
	
	for i = 1, i3k_db_spring_roll.rollConfig.totalLamp do
		self['pos' .. i] = widgets['pos' .. i]
		self['lamp' .. i] = widgets['lamp' .. i]
		self['c_dl' .. i] = self._layout.anis['c_dl' .. i]
	end
end

function wnd_springRollMain:refresh()
	local info = g_i3k_game_context:getSpringRollInfo()
	self._lampCnt = info.lantern
	self._lampList = info.dayNeedIndex
	for i = 1, i3k_db_spring_roll.rollConfig.totalLamp do
		table.insert(self._positionList, self['pos' .. i]:getParent():convertToWorldSpace(self['pos' .. i]:getPosition()))
	end
	for i = 1, i3k_db_spring_roll.rollConfig.totalLamp do
		self['lamp' .. i]:setVisible(self._lampList[i - 1] == nil)
	end
	self.lamp_cnt:setText(string.format("x%s", self._lampCnt))
	local str = i3k_get_string(19033)
	if self._lampCnt == 0 then
		local groupID = g_i3k_game_context:getSpringRollGroupID()
		local mapCfg = i3k_db_spring_roll.mapConfig[groupID]
		str = i3k_get_string(19032, i3k_db_dungeon_base[mapCfg[1]].desc, i3k_db_dungeon_base[mapCfg[2]].desc)
	end
	if table.nums(self._lampList) == 0 then
		str = i3k_get_string(19034, i3k_db_spring_roll.rollConfig.finishTime)
	else
		self.finish_image:setPercent(0)
	end
	self.desc:setText(str)
	local userCfg = g_i3k_game_context:GetUserCfg()
	local isShowGuide = userCfg:GetSpringRollShowGuide()
	if isShowGuide and info.lantern > 0 then
		self.c_zu.play(function ()
			userCfg:UpdateSpringRollShowGuide()
		end)
	end
end

function wnd_springRollMain:onUpdate(dTime)
	if self._isShowAnimation and self.finish_image:getPercent() >= 100 then
		self._isShowAnimation = false
		self.c_gc.stop()
		g_i3k_game_context:setSpringRollDropAwards(nil, true)
	elseif self._isShowAnimation then
		local current = self.finish_image:getPercent()
		local addition = dTime * 1000 / i3k_db_spring_roll.rollConfig.transTime * 100
		self.finish_image:setPercent(current + addition)
	end
end

function wnd_springRollMain:onLampBtnTouch(sender, eventType)
	local isSpringRollOpen = g_i3k_game_context:checkSpringRollOpen()
	if not isSpringRollOpen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19167))
		g_i3k_ui_mgr:CloseUI(eUIID_SpringRollMain)
		return
	end
	if self._lampCnt == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19035))
		return
	end
	if table.nums(self._lampList) == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19036))
		return
	end
	local isEnough = g_i3k_game_context:IsBagEnoughForList(i3k_db_spring_roll.awardConfig)
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19037))
		return
	end
	local parent = self.lamp_btn:getParent()
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
	if eventType == ccui.TouchEventType.began then
		self.lamp_move:setVisible(true)
		self.lamp_btn:stateToPressed()
		self.lamp_move:setPosition(pos)
	elseif eventType == ccui.TouchEventType.moved then
		self.lamp_move:setPosition(pos)
	else
		self.lamp_move:setVisible(false)
		self.lamp_btn:stateToNormal()
		local filledLampID = self:isLampFillIn(self.lamp_move:getParent():convertToWorldSpace(self.lamp_move:getPosition()))
		if filledLampID then
			self._currentLampIndex = filledLampID
			self['c_dl' .. (filledLampID + 1)].play(function ()
			i3k_sbean.spring_lantern_use(filledLampID)
			end)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19038))
		end
	end
end

function wnd_springRollMain:filledLampCallback()
	g_i3k_game_context:refreshSpringRollLameFilled(self._currentLampIndex)
	self:refresh()
	g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_spring_roll.awardConfig, function ()
		if table.nums(self._lampList) == 0 then
			self._isShowAnimation = true
			self.c_gc.play()
		end
	end)
end

function wnd_springRollMain:isLampFillIn(position)
	for i = 0, i3k_db_spring_roll.rollConfig.totalLamp - 1 do
		if self._lampList[i] then
			local xDiff = self._positionList[i + 1].x - position.x
			local yDiff = self._positionList[i + 1].y - position.y
			local diff = xDiff * xDiff + yDiff * yDiff
			if diff <= self._offset then
				return i
			end
		end
	end
	return nil
end

function wnd_create(layout, ...)
	local wnd = wnd_springRollMain.new()
	wnd:create(layout, ...)
	return wnd
end