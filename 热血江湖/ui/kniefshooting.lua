module(..., package.seeall)

local ui = require("ui/base");

wnd_kniefShooting = i3k_class("wnd_kniefShooting", ui.wnd_base)

function wnd_kniefShooting:ctor()
	self._id = 0
	self._finishTimes = 0
	self._kniefList = {}
	self._occupyList = {}
	self._startPosition = nil
	self._endPosition = nil
	self._startRotate = nil
	self._kniefTarget = 1
end

function wnd_kniefShooting:configure()
	local widgets = self._layout.vars
	self.succeed_img = widgets.succeed_img
	self.failed_img = widgets.failed_img
	self.commend_text = widgets.commend_text
	self.joinTimes_text = widgets.joinTimes_text
	self.knief = widgets.knief
	self.ball = widgets.ball
	self.knief_cnt_text = widgets.knief_cnt_text
	self.pos_img = widgets.pos_img
	local knief_num = #i3k_db_knief_shooting_cfg - self._kniefTarget
	self.knief_cnt_text:setText("x" .. knief_num)
	for i = 1, 10 do
		self._kniefList[i] = widgets['knief' .. i]
	end
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	self.shoot_btn = widgets.shoot_btn
	self.shoot_btn:onClick(self, self.onShootBtnClick)
	self.return_btn = widgets.return_btn
	self.return_btn:onClick(self, self.onCloseUI)
	self.try_again_btn = widgets.try_again_btn
	self.try_again_btn:onClick(self, self.onTryAgainBtnClick)
	local anis = self._layout.anis
	self.succeed_anis = anis.c_cg
	self.failed_anis = anis.c_sb
	self.zhongbiao_anis = anis.c_zhongbiao
	self.luobiao_anis = anis.c_luobiao
end

function wnd_kniefShooting:refresh(info)
	self._id = info.id
	self._finishTimes = info.useTimes
end

function wnd_kniefShooting:onUpdate(dTime)
	if not self._startPosition then
		self._startPosition = self.knief:getPosition()
	end
	if not self._endPosition then
		self._endPosition = self.pos_img:getParent():convertToWorldSpace(self.pos_img:getPosition())
	end
	if not self._startRotate then
		self._startRotate = self.knief:getRotation() % 360
	end
	if self._isFail then
		return
	end
	local rad_offset = self:calculateOffset(dTime)
	local rad_current = self.ball:getRotation() % 360
	self.ball:setRotation(rad_current + rad_offset)
end

function wnd_kniefShooting:onShootBtnClick(sender)
	self.shoot_btn:disable()
	local currentAngle = self.ball:getRotation() % 360
	local angle = currentAngle + self:calculateOffset(i3k_db_knief_shooting_fly_time)
	local isSucceed = self:testOccupied(angle)
	local seq = cc.Sequence:create(
		cc.CallFunc:create(function ()
			self:playFlyAnis(isSucceed)
		end), 
		cc.DelayTime:create(i3k_db_knief_shooting_fly_time),
		cc.CallFunc:create(function ()
			self:kniefArrived(isSucceed)
		end)
	)
	self:runAction(seq)
end

function wnd_kniefShooting:onTryAgainBtnClick(sender)
	self:gameStart()
end

function wnd_kniefShooting:kniefArrived(isSucceed)
	self.shoot_btn:enable()
	self.zhongbiao_anis.stop()
	self.luobiao_anis.stop()
	self.knief:setPosition(self._startPosition)
	self.knief:setRotation(self._startRotate)
	self._kniefTarget = self._kniefTarget + 1
	if isSucceed then
		self:showCurrentKnief()
		if self._kniefTarget == #i3k_db_knief_shooting_cfg then
			self:gameOver(true)
			i3k_sbean.findMooncake_getItems(self._id)
		end
	else
		self:gameOver(false)
	end
end

function wnd_kniefShooting:showCurrentKnief()
	local currKnief = self._kniefList[self._kniefTarget]
	local rotation = self.ball:getRotation() % 360 * -1
	local pos = self.ball:convertToNodeSpace(self._endPosition)
	local knief_num = #i3k_db_knief_shooting_cfg - self._kniefTarget
	self.knief_cnt_text:setText("x" .. knief_num)
	currKnief:setPosition(pos)
	currKnief:setRotation(rotation)
	currKnief:setVisible(true)
end

function wnd_kniefShooting:calculateOffset(time)
	local cfg = i3k_db_knief_shooting_cfg[self._kniefTarget]
	return cfg and cfg.rotateSpeed * cfg.rotateFlag * time or 0
end

function wnd_kniefShooting:testOccupied(angle)
	local realAngle = angle % 360
	for _, v in ipairs(self._occupyList) do
		local abs = math.abs(realAngle - v)
		if abs <= i3k_db_knief_width or abs + i3k_db_knief_width >= 360 then
			return false
		end
	end
	table.insert(self._occupyList, realAngle)
	return true
end

function wnd_kniefShooting:gameStart()
	self._isFail = false
	if self._finishTimes == i3k_db_findMooncake[self._id].dayTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16391))
		return
	end
	self.ball:setVisible(true)
	self.return_btn:setVisible(false)
	self.try_again_btn:setVisible(false)
	self.shoot_btn:setVisible(true)
	self.succeed_img:setVisible(false)
	self.failed_img:setVisible(false)
	self.commend_text:setText(i3k_get_string(50069))
	local joinTimes = i3k_db_findMooncake[self._id].dayTimes - self._finishTimes
	self.joinTimes_text:setText(i3k_get_string(50071, joinTimes))
	for i = 1, self._kniefTarget do
		self._kniefList[i]:setVisible(false)
	end
	self._kniefTarget = 1
	local knief_num = #i3k_db_knief_shooting_cfg - self._kniefTarget
	self.knief_cnt_text:setText("x" .. knief_num)
	self._occupyList = {}
end

function wnd_kniefShooting:gameOver(isSucceed)
	self._isFail = true
	if isSucceed then
		self._finishTimes = self._finishTimes + 1
		self.commend_text:setText("")
		local joinTimes = i3k_db_findMooncake[self._id].dayTimes - self._finishTimes
		self.joinTimes_text:setText(i3k_get_string(50071, joinTimes))
	else
		self.commend_text:setText(i3k_get_string(50070))
	end
	self.return_btn:setVisible(true)
	self.try_again_btn:setVisible(true)
	self.shoot_btn:setVisible(false)
	local seq = cc.Sequence:create(
		cc.CallFunc:create(function ()
			self:playGameOverAnis(isSucceed)
		end), 
		cc.CallFunc:create(function ()
			self:showGameOverImage(isSucceed)
		end)
	)
	self:runAction(seq)
end

function wnd_kniefShooting:playFlyAnis(isSucceed)
	if isSucceed then
		self.zhongbiao_anis.play()
	else
		self.luobiao_anis.play()
	end
end

function wnd_kniefShooting:playGameOverAnis(isSucceed)
	if isSucceed then
		self.succeed_anis.play()
	else
		self.failed_anis.play()
	end
end

function wnd_kniefShooting:showGameOverImage(isSucceed)
	self.succeed_img:setVisible(isSucceed)
	self.failed_img:setVisible(not isSucceed)
end

function wnd_create(layout)
	local wnd = wnd_kniefShooting.new();
	wnd:create(layout);
	return wnd;
end
