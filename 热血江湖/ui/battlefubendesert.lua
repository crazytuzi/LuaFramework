module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_battleFubenDesert = i3k_class("wnd_battleFubenDesert", ui.wnd_base)

local SCORE_TAB = 1
local TEAM_TAB = 2

local TEAM_MEMBER_WIDGET = "ui/widgets/zdjuezhanhuangmot2"
local ROLE_RANK_WIDGET = "ui/widgets/zdjuezhanhuangmot1"

local REFRESH_RANK_TIME = 1--多少秒刷新一次排行榜

function wnd_battleFubenDesert:ctor()
	self._tabIndex = TEAM_TAB
	self._timer = 0
	self._isOutStateChange = false --淘汰倒计时状态改变
	self._drugsData = self:getDrugsData()
end

function wnd_battleFubenDesert:configure()
	local widget = self._layout.vars
	widget.openBtn:onClick(self, self.onShowBtnClick, true)
	widget.closeBtn:onClick(self, self.onShowBtnClick, false)
	widget.goSafeBtn:onClick(self, self.onGoSafeBtnClick)
	widget.bagBtn:onClick(self, self.onBagBtnClick)
	widget.scoreBtn:onClick(self, self.onTabBtnClick, SCORE_TAB)
	widget.teamBtn:onClick(self, self.onTabBtnClick, TEAM_TAB)
	widget.promptTips:setText(i3k_get_string(17661))
	self.drugUI = {}
	for i = 1, 3 do
		self.drugUI[i] = {
			timer		= widget["timer"..i],
			medicine	= widget["medicine"..i],
			grade_icon	= widget["grade_icon"..i],
			item_icon	= widget["item_icon"..i],
			item_count	= widget["item_count"..i],
		}
		widget["medicine"..i]:onClick(self, self.onMedicineBtnClick, self._drugsData[i].id)
	end
end

function wnd_battleFubenDesert:refresh()
	local widget = self._layout.vars
	self:onTabBtnClick(widget.scoreBtn, TEAM_TAB)
	self:initTeamMemberInfo()
	self:updateQuickUseMedicine()
end

function wnd_battleFubenDesert:initTeamMemberInfo()
	local widgets = self._layout.vars
	local teamInfo = g_i3k_game_context:GetTeamOtherMembersProfile()
	self._teamWidgets = {}
	self._teamNames = {}
	widgets.teamScroll:removeAllChildren()
	for i, v in ipairs(teamInfo) do
		local widget = require(TEAM_MEMBER_WIDGET)()
		local isConnect = g_i3k_game_context:GetTeamMemberState(v.overview.id)
		self._teamNames[v.overview.id] = v.overview.name
		widget.vars.name:setText(v.overview.name..(isConnect and '' or i3k_get_string(17618)))
		widget.vars.hpBar:setPercent(v.curHp/v.maxHp*100)
		self._teamWidgets[v.overview.id] = widget.vars
		widgets.teamScroll:addItem(widget)
	end
end

function wnd_battleFubenDesert:onShowBtnClick(sender, state)
	local widget = self._layout.vars
	widget.openBtn:setVisible(not state)
	widget.closeBtn:setVisible(state)
	widget.tabRoot:setVisible(state)
end

function wnd_battleFubenDesert:onGoSafeBtnClick(sender)
	g_i3k_db.i3k_db_is_safety_zone() --前往安全区
end

function wnd_battleFubenDesert:onBagBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleDesertBag)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleDesertBag)
end

function wnd_battleFubenDesert:onTabBtnClick(sender, index)
	local widget = self._layout.vars
	if index == SCORE_TAB then
		widget.outParticle:hide()
	end
	widget.teamTab:setVisible(index == TEAM_TAB)
	widget.scoreTab:setVisible(index == SCORE_TAB)
end

--队伍剩余变化
function wnd_battleFubenDesert:updateLeftPersonCount(count)
	self._layout.vars.leftTeamCount:setText(i3k_get_string(17614,count))
end

function wnd_battleFubenDesert:formatTime(time)
	local tm = time;
	local h = i3k_integer(tm / (60 * 60));
	tm = tm - h * 60 * 60;
	local m = i3k_integer(tm / 60);
	tm = tm - m * 60;
	local s = tm;
	if m ~= 0 then
		return i3k_get_string(17649, h * 60 + m, s)
	else
		return i3k_get_string(17650, s)
	end
end

--淘汰倒计时
function wnd_battleFubenDesert:updateOutCountTime(time)
	local beginTime = i3k_db_desert_battle_base.maxLife - time
	if beginTime <= 2 and not self._isBeginFight then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaSwallow)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFight)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleFight)
		self._isBeginFight = true
	else
		self._isBeginFight = true
	end
	local widget = self._layout.vars
	local nextChangeCfg
	for i,v in ipairs(i3k_db_desert_battle_out_cfg) do
		if beginTime < v.beginOutTime then
			nextChangeCfg = v
			break
		end
	end
	if nextChangeCfg then
		local beginShowTime = nextChangeCfg.beginOutTime - nextChangeCfg.preShowTime
		local isShow = beginTime >= beginShowTime and beginTime <= nextChangeCfg.beginOutTime
		widget.outDes:setVisible(isShow)
		if self._isOutStateChange ~= isShow and isShow == true then
			widget.outParticle:setVisible(isShow)
		end
		self._isOutStateChange = isShow
		if isShow then
			widget.outDes:setText(i3k_get_string(17640, i3k_get_show_rest_time(nextChangeCfg.beginOutTime - beginTime), nextChangeCfg.outNum))
		end
	else
		widget.outDes:hide()
	end
 
	--更新毒圈倒计时
	local poisonTime = self._layout.vars.poisonTime
	for i, v in ipairs(i3k_db_desert_battle_poisonCircle.poisonCircle) do
		if beginTime >= v.safeTime and beginTime <= v.startTime then
			poisonTime:show()
			poisonTime:setText(i3k_get_string(17616, i3k_get_show_rest_time(v.startTime- beginTime)))
			break
		elseif beginTime >= v.startTime and beginTime <= v.endTime then
			poisonTime:setText(i3k_get_string(17617))
			poisonTime:show()
			break
		else
			poisonTime:hide()
		end
	end
	widget.hint:hide()
	for i,v in ipairs(i3k_db_desert_battle_ui_up_chat_show_cfg) do
		if beginTime >= v.beginTime and beginTime <= v.endTime then
			widget.hint:show()
			widget.hint1:setVisible(v.type == 2)
			widget.hint2:setVisible(v.type == 1)
			break
		end
	end
	self:onUpdateDesertPoison()
end

function wnd_battleFubenDesert:onUpdateDesertPoison()
	local world = i3k_game_get_world();
	if world and world._mapType == g_DESERT_BATTLE then
		local cfg = i3k_db_desert_battle_base
		local poisonEntity = world:GetEntity(eET_Common, cfg.poisonModelID)
		local pos, radius = world:GetDesertPoisonInfo()
		if poisonEntity and pos then
			local hero = i3k_game_get_player_hero()
			local heroPos = hero:GetCurPos()
			local distance  = i3k_vec3_dist(i3k_logic_pos_to_world_pos(heroPos), pos)
			-- i3k_log("~~~~~~~~~~~~~~dis: ".. distance)
			if distance >= radius then
				if not self._isPlayingPrompt then
					self:PlayPromptAni(true)
				end
			else
				if self._isPlayingPrompt then
					self:PlayPromptAni(false)
				end
			end
		end
	end 
end

function wnd_battleFubenDesert:PlayPromptAni(isPlay)
	self._isPlayingPrompt = isPlay
	if isPlay then
		self._layout.anis.c_ts.play()
		self._layout.anis.c_zhongdu.play()
	else
		self._layout.anis.c_ts.stop()
		self._layout.anis.c_zhongdu.stop()
	end
end

--个人积分变化
function wnd_battleFubenDesert:updatePersonScore(score)
	self._layout.vars.personScore:setText(i3k_get_string(17638,score))
end

--更新排行变化
function wnd_battleFubenDesert:updateRank(data)
	local widgets = self._layout.vars
	widgets.personRank:setText(i3k_get_string(17639, data.selfRank == 0 and i3k_get_string(17659) or data.selfRank))
	widgets.personRank1:setText(i3k_get_string(17639, data.selfRank == 0 and i3k_get_string(17659) or data.selfRank))
	widgets.scoreScroll:removeAllChildren()
	for i, v in ipairs(data.ranks) do
		local widget = require(ROLE_RANK_WIDGET)()
		widget.vars.index:setText(i)
		widget.vars.name:setText(v.roleName)
		widget.vars.score:setText(v.rankKey)
		widgets.scoreScroll:addItem(widget)
	end
end

--进入地图同步信息  队友命数包括自己  积分
function wnd_battleFubenDesert:updateMapInfo()
	local info = g_i3k_game_context:getDesertBattleMapInfo()
	self:updatePersonScore(info.score)
	self:updateLeftPersonCount(info.leftRoles)
	for k, v in pairs(info.lifes) do
		self:setMembersLife(k, v)
	end
end

--设置自己/队友命数 id life
function wnd_battleFubenDesert:setMembersLife(id, life)
	if id == g_i3k_game_context:GetRoleId() then
		for i = 1,3 do
			self._layout.vars['heart'..i]:setVisible(i<=life)
		end
	else
		local widget = self._teamWidgets[id]
		if widget then
			for i=1,3 do
				widget['life'..i]:setVisible(i<=life)
			end
		end
	end
end

--同步队友状态 离线还是在线
function wnd_battleFubenDesert:updateTeamMemberState(roleId, isConnect)
	local name = self._teamNames[roleId]
	if self._teamWidgets[roleId] then
		self._teamWidgets[roleId].name:setText(name..(isConnect and '' or i3k_get_string(17618)))
	end
end

--同步队友血量
function wnd_battleFubenDesert:updateTeamMemberHp(roleId, curHp, maxHp)
	if self._teamWidgets[roleId] then
		self._teamWidgets[roleId].hpBar:setPercent(curHp/maxHp*100)
	end
end

function wnd_battleFubenDesert:getDrugsData()
	local allDrugs = {}

	for k, v in pairs(i3k_db_desert_battle_items) do
		if g_i3k_db.i3k_db_get_desert_item_cfg(k).type == UseItemHp then
			table.insert(allDrugs, {id = k, addHp = v.args1})
			end
		end
	table.sort(allDrugs, function(a, b)
		return a.addHp < b.addHp
	end)
	return allDrugs
	end
--更新可以使用的药品
function wnd_battleFubenDesert:updateQuickUseMedicine()
	local allDrugs = self._drugsData
	for i, v in ipairs(self.drugUI) do
		local id = allDrugs[i].id
		local count = g_i3k_game_context:GetDesertBagDrugsCountByID(id)
		if count > 0 then
			v.medicine:show()
			v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			v.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
			v.item_count:setText(count)
	else
			v.medicine:hide()
		end
	end
end

function wnd_battleFubenDesert:onMedicineBtnClick(sender, id)
	local curHp, maxHP = g_i3k_game_context:GetRoleHp()
	if curHp == maxHP then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17647))
	elseif i3k_game_get_time() - g_i3k_game_context:GetDesertLastUseDrugTime() < i3k_db_common.drug.drugTime.cTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17648))
	else
		i3k_sbean.survive_usedrug(id)
	end
end

function wnd_battleFubenDesert:onUpdate(dTime)
	self._timer = self._timer + dTime
	if self._timer > REFRESH_RANK_TIME then
		self._timer = 0
		local bean = i3k_sbean.survive_score_rank_query.new()
		i3k_game_send_str_cmd(bean)
		self:onUpdateDrugTimer(dTime)
		if self._layout.vars.teamScroll:getChildrenCount() == 0 then--重登的时候
			local teamInfo = g_i3k_game_context:GetTeamOtherMembersProfile()
			if next(teamInfo) then
				self:initTeamMemberInfo()
			end
		end
	end
end
function wnd_battleFubenDesert:onUpdateDrugTimer(dTime)
		local cd = i3k_game_get_time() - (g_i3k_game_context:GetDesertLastUseDrugTime() or 0 )
	for i, v in ipairs(self.drugUI) do
		if cd <= i3k_db_common.drug.drugTime.cTime then
			v.timer:show()
			v.timer:setPercent(100 - cd / i3k_db_common.drug.drugTime.cTime * 100)
		else
			v.timer:hide()
		end
	end
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleFubenDesert.new();
		wnd:create(layout);
	return wnd;
end
