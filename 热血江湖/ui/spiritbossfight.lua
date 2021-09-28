module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battleSpiritBoss = i3k_class("wnd_battleSpiritBoss", ui.wnd_base)

local RANKWIDGET = "ui/widgets/zdjlgct"

function wnd_battleSpiritBoss:ctor()
	self._bossId = 0
	self._nextBuffTime = 0
	self._buffCo = nil
	self._co = {}
	self._timeCounter = 0
	self._rewards = {} -- 抽奖记录
	self._bloodPersent = 1
	self._rankRefresh = 2 -- 记录排行榜刷新间隔，初始化成2秒是为了首次打开时刷新
	self._curBossBlood = 0 -- 记录进入时boss的血量
	self._maxValue = 1 -- boss最大血量
	self._isShowBuff = false -- buff是否正在显示
	self._curBossIndex = 0
end

function wnd_battleSpiritBoss:configure()
	self._layout.vars.buffIcon:onClick(self, self.getBuff)
end

function wnd_battleSpiritBoss:refresh()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local spiritBoss = g_i3k_game_context:getSpiritBossData()
	self._nextBuffTime = spiritBoss.nextBuffTime
	self._rewards = spiritBoss.rewards
	self._bossId = spiritBoss.bossId
	self._curBossBlood = spiritBoss.bossBlood
	self._curBossIndex = spiritBoss.curBossIndex
	self._bloodPersent = 1
	if self._bossId and self._bossId > 0 then
		self._layout.vars.bossHead:setImage(g_i3k_db.i3k_db_get_monster_head_icon_path(self._bossId))
		self._layout.vars.bloodBar:setPercent(self._curBossBlood / i3k_db_monsters[self._bossId].hpOrg * 100)
	end
	if self._nextBuffTime ~= 0 and i3k_game_get_time() >= self._nextBuffTime then
		if not self._isShowBuff then
			self._isShowBuff = true
			self:showBuff()
		end
	else
		self._layout.vars.buffBg:hide()
		self._layout.vars.buffIcon:disableWithChildren()
		self._isShowBuff = false
	end
	self:setLottoPosition()
	self:setLottoRewards()
	if mapId > 0 then
		self._layout.vars.endTips:setVisible(self._curBossIndex > #i3k_db_dungeon_base[mapId].areas)
		self._layout.vars.bossCount:setText(string.format("(%s/%s)", self._curBossIndex, #i3k_db_dungeon_base[mapId].areas))
		if self._curBossIndex > #i3k_db_dungeon_base[mapId].areas then
			self._layout.vars.bossCount:setText(string.format("(%s/%s)", #i3k_db_dungeon_base[mapId].areas, #i3k_db_dungeon_base[mapId].areas))
			self:setBossVisible(false)
		end
	end
end

function wnd_battleSpiritBoss:updateDamageRank(ranks, selfDamage)
	self._layout.vars.scroll:removeAllChildren()
	for k, v in ipairs(ranks) do
		local layer = require(RANKWIDGET)()
		layer.vars.rankLabel:setText(k)
		layer.vars.nameLabel:setText(v.roleName)
		layer.vars.damageLabel:setText(v.damage)
		self._layout.vars.scroll:addItem(layer)
	end
	self._layout.vars.selfDamage:setText(selfDamage or 0)
end

function wnd_battleSpiritBoss:updateBossBlood(bossId, curValue, maxValue)
	self:setBossVisible(true)
	self._bossId = bossId
	self._layout.vars.bossHead:setImage(g_i3k_db.i3k_db_get_monster_head_icon_path(bossId))
	self._layout.vars.bloodBar:setPercent(curValue / maxValue * 100)
	self._bloodPersent = curValue / maxValue
	self._maxValue = maxValue
	self:setLottoRewards()
end

function wnd_battleSpiritBoss:setLottoPosition()
	--local blood = self._layout.vars.bloodIcon:getSize()
	--local posX = self._layout.vars.bloodIcon:getPositionX()
	if self._bossId and self._bossId > 0 then
		--self._layout.vars["lotto"..i]:setPosition(blood.width * i3k_db_spirit_boss.common.bossBloodAward[i] / 10000 + posX - blood.width / 2, self._layout.vars.bloodIcon:getPositionY())
		for i = 1, 3 do
			self._layout.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_spirit_boss.lotto[self._bossId].rewardId))
			self._layout.vars["count"..i]:setText("x"..i3k_db_spirit_boss.lotto[self._bossId].coefficient[i])
		end
	end
end

function wnd_battleSpiritBoss:setLottoRewards()
	for i = 1, 3 do
		self._layout.vars["icon"..i]:enable()
		if not self._rewards[i] then
			local percent = i3k_db_spirit_boss.common.bossBloodAward[i] / 10000
			if self._bloodPersent <= percent and self._curBossBlood / self._maxValue >= percent then
				self._rewards[i] = 0
				i3k_sbean.gaintboss_reward(i, self._bossId)
			else
				self._layout.vars["icon"..i]:disable()
				self._layout.vars["number"..i]:setText("?")
			end
		elseif self._rewards[i] > 0 then
			self._layout.vars["number"..i]:setText(self._rewards[i])
		else
			i3k_sbean.gaintboss_reward(i, self._bossId)
		end
	end
end

function wnd_battleSpiritBoss:updateLottoReward(index, rate)
	if rate > 0 then
		self._rewards[index] = rate
		self._co[index] = g_i3k_coroutine_mgr:StartCoroutine(function()
			local count = 0
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.1)
				count = count + 1
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateLottoNumber", index, count % 10)
				if count > 10 then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "showLottoMessage", index, rate)
					g_i3k_coroutine_mgr:StopCoroutine(self._co[index])
					self._co[index] = nil
				end
			end
		end)
	else
		self._layout.vars["number"..index]:setText("?")
		if rate == -1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17335))
		elseif rate == -2 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17336))
		elseif rate == -3 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17337))
		end
	end
end

function wnd_battleSpiritBoss:showLottoMessage(index, rate)
	if self._bossId and self._bossId > 0 then
		self._layout.vars.baozha:setPosition(self._layout.vars["lotto"..index]:getPosition())
		self._layout.anis.c_bao1.play()
		local lottoCfg = i3k_db_spirit_boss.lotto[self._bossId]
		self._layout.vars["number"..index]:setText(rate)
		local name = g_i3k_db.i3k_db_get_common_item_name(lottoCfg.rewardId)
		if lottoCfg.rewardId > 0 then
			name = "绑定"..name
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17328, name, lottoCfg.coefficient[index] * rate))
	end
end

function wnd_battleSpiritBoss:updateLottoNumber(index, count)
	self._layout.vars["number"..index]:setText(count)
end

function wnd_battleSpiritBoss:showBuff()
	self._layout.vars.buffBg:show()
	self._layout.vars.buffIcon:setImage(i3k_db_icons[7132].path)
	self._layout.vars.buffIcon:enableWithChildren()
	self._layout.anis.c_ss.play()
end

function wnd_battleSpiritBoss:getBuff(sender)
	self._layout.anis.c_ss.stop()
	self._layout.vars.buffIcon:disableWithChildren()
	self._layout.anis.c_tu.play()
	self._buffCo = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(2)
		i3k_sbean.gaintboss_takebuff()
		g_i3k_coroutine_mgr:StopCoroutine(self._buffCo)
		self._buffCo = nil
	end)
end

function wnd_battleSpiritBoss:updateBuffInfo(buffId, nextTime)
	if buffId > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_db_spirit_boss.buff[buffId])
		self._layout.vars.buffIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_buff[buffId].iconID))
	end
	self._nextBuffTime = nextTime
	g_i3k_game_context:setSpiritBossBuffTime(nextTime)
end

function wnd_battleSpiritBoss:setBossVisible(isShow)
	self._layout.vars.bossRoot:setVisible(isShow)
end

function wnd_battleSpiritBoss:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	self._rankRefresh = self._rankRefresh + dTime
	if self._timeCounter >= 1 then
		if self._nextBuffTime ~= 0 and i3k_game_get_time() >= self._nextBuffTime then
			if not self._isShowBuff then
				self._isShowBuff = true
				self:showBuff()
			end
		else
			self._layout.vars.buffBg:hide()
			self._layout.vars.buffIcon:disableWithChildren()
			self._isShowBuff = false
		end
		self._timeCounter = 0
	end
	if self._rankRefresh >= 2 then
		i3k_sbean.gaintboss_rank_query_handler()
		self._rankRefresh = 0
	end
end

function wnd_battleSpiritBoss:onHide()
	for i = 1, 3 do
		if self._co[i] then
			g_i3k_coroutine_mgr:StopCoroutine(self._co[i])
		end
	end
	g_i3k_coroutine_mgr:StopCoroutine(self._buffCo)
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleSpiritBoss.new();
		wnd:create(layout);
	return wnd;
end
