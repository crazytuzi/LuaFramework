
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_woodMan = i3k_class("wnd_woodMan",ui.wnd_base)

function wnd_woodMan:ctor()
	self._showTick = 0
	self.closeTime = 0
	self.closeTick = 0
	self.monsterId = 0
	self.damageCnt = 0
	self.damage = 0
	self.timeTick = 0
	self.canShareTime = 0
	self.isBreak = false
	--self.isFinishAttack = false
end

function wnd_woodMan:configure()
	self._widget = self._layout.vars
	self._widget.shareBtn:onClick(self, self.shareDamage)
	self._widget.shareBtn:disable()
	self._widget.findRoot:setTouchEnabled(true)
	self._widget.findRoot:setSwallowTouches(true)
	self.closeTime = i3k_db_common.woodMan.finishTime
	self._widget.dmg:setText(self.damage)
	self._widget.time:setText(self.timeTick)
end

function wnd_woodMan:refresh(damageCnt, monsterId, isNew)
	-- self.isFinishAttack = false
	if self.isBreak then
		return
	end
	if isNew then
		self.timeTick = 0
		self._widget.time:setText(self.timeTick)
	end

	self.closeTick = 0
	self.damageCnt = damageCnt
	self._widget.dmgCnt:setText(self.damageCnt)
	if self.monsterId ~= monsterId then
		self.monsterId = monsterId
		self._widget.name:setText(g_i3k_db.i3k_db_get_monster_name(monsterId))
	end
end

function wnd_woodMan:InitTimeStart(timeTick)
	self.timeTick = timeTick
	local shareTime = i3k_db_common.woodMan.canShareTime - 1
	self.canShareTime = timeTick > shareTime and shareTime or timeTick
	self._widget.time:setText(self.timeTick)
	self.damage = math.floor(self.damageCnt/self.timeTick)
	self._widget.dmg:setText(self.damage)
end

function wnd_woodMan:onUpdate(dTime)
	self._showTick = self._showTick + dTime
	if self._showTick >= 1 then
		self._showTick = 0
		self.closeTick = self.closeTick + 1
		if not self.isBreak then
			self.timeTick = self.timeTick + 1
			self.damage = math.floor(self.damageCnt/self.timeTick)
			self._widget.dmg:setText(self.damage)
			self._widget.time:setText(self.timeTick)
		end

		local pet = i3k_game_get_mercenary_entity(g_i3k_game_context:getFieldPetID())
		if pet and #pet:GetEnmities() > 0 and pet._hoster and not pet._hoster:IsInFightTime() and #pet._hoster:GetEnmities() == 0 then
			pet:ClsEnmities()
			pet:SetTarget(nil)
			--self.isFinishAttack = true
			self:onCloseUI()
			return
		end
		self.canShareTime = self.canShareTime + 1
		if self.canShareTime == i3k_db_common.woodMan.canShareTime then
			self._widget.shareBtn:enable()
		end

		if self.closeTick >= self.closeTime then
			g_i3k_game_context:clearWoodManDamage()
			self:onCloseUI()
		end
	end
end

function wnd_woodMan:shareDamage()
	if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_common.chat.worldNeedId) <= 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(i3k_db_common.chat.worldNeedId)))
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		self.isBreak = true
		--self.isFinishAttack = true
		self.damage = math.floor(self.damageCnt/self.timeTick)
		self._widget.dmg:setText(self.damage)
		hero:ClsEnmities()
		if hero:IsAutoFight() then
			g_i3k_game_context:SetAutoFight(false)
		else
			hero:SetTarget(nil)
			hero._PreCommand = -1
		end
	end
	g_i3k_ui_mgr:OpenUI(eUIID_woodManShare)
	g_i3k_ui_mgr:RefreshUI(eUIID_woodManShare, self.timeTick, self.damageCnt, self.damage, self.monsterId)
	g_i3k_game_context:clearWoodManDamage()
end

function wnd_woodMan:ResetBreakState( )
	self.isBreak = false
	self.damageCnt = 0
	self.damage = 0
	self.timeTick = 0
	self._widget.dmg:setText(0)
	self._widget.time:setText(0)
	self._widget.dmgCnt:setText(0)
end

function wnd_create(layout, ...)
	local wnd = wnd_woodMan.new()
	wnd:create(layout, ...)
	return wnd;
end