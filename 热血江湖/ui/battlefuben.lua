module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_battleFuben = i3k_class("wnd_battleFuben", ui.wnd_base)

local numberIcons = {8787, 8788, 8789, 8790, 8791, 8792, 8793, 8794, 8795, 8796}
local TarGetState = 1 --目标
local OutPutState = 2 --输出
local WidgetFbzxt = "ui/widgets/fbzxt"
local COLOR1 = "fffdb0b0"  --粉红色
local COLOR2 = "ffcdc4f1"  --紫色
local DamageBarBg1 = 3416
local DamageBarBg2 = 3417
local DAMAGEREFRESH = 1 --伤害刷新时间间隔

function wnd_battleFuben:ctor()
	self._fightCoolTime = nil
	self._totalTime = nil
	self._state = 1
	self._timeCounter = 0
	self._maxHp = 1
	self._lastDamage = 0
	self._curDamage = 0
	self._damageCounter = 0
	self._lastDamageInt = 0
end
function wnd_battleFuben:configure()
    local widget=self._layout.vars
    widget.exit:onClick(self, self.onExit)
    self._widgets = {}
    self._widgets.guideArrow =  self._layout.vars.guideArrow
	self._widgets.guideGo =  self._layout.vars.guideGo
	widget.guideArrow:hide()--指引箭头
	widget.guideGo:hide()--指引Go
    f_isPlay = false
	local mapType = i3k_game_get_map_type()
	local mapID = g_i3k_game_context:GetWorldMapID()
	if mapType==g_ARENA_SOLO then
		self._fightCoolTime = i3k_db_arena.arenaCfg.fightCoolTime
		self._totalTime = i3k_db_arena.arenaCfg.arenaMaxTime
	elseif mapType==g_TOURNAMENT then
		self._fightCoolTime = i3k_db_tournament_base.baseData.waitTime
		for i,v in ipairs(i3k_db_tournament) do
			if v.mapId==mapID then
				self._totalTime = v.maxTime
				break
			end
		end
	elseif mapType==g_TAOIST then
		self._fightCoolTime = i3k_db_taoist.waitTime
		self._totalTime = i3k_db_taoist.maxTime
	elseif mapType== g_FORCE_WAR then
		self._fightCoolTime = i3k_db_forcewar_base.otherData.waitTime
		self._totalTime = g_i3k_db.i3k_db_get_forcewar_max_time(mapID)
	elseif mapType== g_FACTION_WAR then
		self._fightCoolTime = i3k_db_faction_fight_cfg.other.waittime
		self._totalTime = i3k_db_factionFight_dungon[mapID].maxTime
	elseif mapType == g_QIECUO then
		self._fightCoolTime = i3k_db_common.qiecuo.startTime
		self._totalTime = i3k_db_qieCuo_dungon[mapID].maxTime
	elseif mapType == g_BUDO then
		self._fightCoolTime = i3k_db_forcewar_base.otherData.waitTime
		self._totalTime = i3k_db_fight_team_fb[mapID].maxTime
	elseif mapType == g_DEFENCE_WAR then
		self._fightCoolTime = i3k_db_forcewar_base.otherData.waitTime
		self._totalTime = i3k_db_defenceWar_cfg.fightTotalTime
	elseif mapType == g_DOOR_XIULIAN then
		self._fightCoolTime = i3k_db_practice_door_common.countDown
		self._totalTime = i3k_db_dungeon_practice_door[mapID].duration
	elseif mapType == g_AT_ANY_MOMENT_DUNGEON then
		self._totalTime = i3k_db_at_any_moment[mapID].lastTime
	elseif mapType == g_HOMELAND_GUARD then
		self._totalTime = i3k_db_homeland_guard_base[mapID].maxTime
		self._fightCoolTime = i3k_db_homeland_guard_cfg.countdownTime
	elseif mapType == g_FIVE_ELEMENTS then
		self._totalTime = g_i3k_db.i3k_db_get_five_element_time(mapID)
	end


	self.desc_root = self._layout.vars.desc_root
	self.desc_text = self._layout.vars.desc_text
	self.desc_root:hide()

	self.autoBtn = self._layout.vars.autoBtn
	self.autoBtn:onClick(self,self.onAuto)

	self.targetDesc = widget.targetDesc
	self.targetBtn = widget.targetBtn
	self.outputBtn = widget.outputBtn
	widget.targetBtn:onClick(self, self.onTarget)
	widget.outputBtn:onClick(self, self.onOutput)
	self.outputRoot = widget.outputRoot
	self.percentRoot = widget.percentRoot
	self.rankScroll = widget.rankScroll
	self.damageRoot = widget.damageRoot
end

local hideMapType = {
	[g_FIELD] = true,
	[g_FACTION_GARRISON] = true,
	[g_GOLD_COAST] = true,
}
function wnd_battleFuben:refresh()
	----------------------------副本倒计时和退出界面
	local mapType = i3k_game_get_map_type()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local exitbtn = self._layout.vars.exit
	local TimeElapse = self._layout.vars.timeElapsePanel
	if hideMapType[mapType] then
		exitbtn:hide()
		TimeElapse:hide()
	elseif mapType == g_Life or mapType == g_OUT_CAST or mapType == g_HOME_LAND or mapType == g_CATCH_SPIRIT or mapType == g_BIOGIAPHY_CAREER then
		exitbtn:show()
		TimeElapse:hide()
	elseif mapType == g_ANNUNCIATE then
		exitbtn:show()
		self._layout.vars.autoBtn:hide()
		self:updateAnnunciateInfo()
	else
		exitbtn:show()
		TimeElapse:show()
	end
	if mapType == g_FACTION_DUNGEON then
		self._layout.vars.damagePercent:show()
		self:setFactionDungeonDamage(0)
		local bigBossPos = i3k_db_faction_dungeon[mapId].monsterID1
		local bigBossID = i3k_db_spawn_point[bigBossPos].monsters[1]
		self._maxHp = i3k_db_monsters[bigBossID].hpOrg
	else
		self._layout.vars.damagePercent:hide()
	end
	local cfg = i3k_db_activity_cfg[mapId]
	if cfg and cfg.groupId == 8 then
		self:UpdateMiBaoKuangDong(cfg)
	end
	self:updateLeftState()
	self:refreshKillTipsUI()
end

function wnd_battleFuben:onShow()
	self:syncMapCoypDamageRank()
end

--秘宝矿洞特殊逻辑
function wnd_battleFuben:UpdateMiBaoKuangDong(cfg)
	local specialCfg = cfg.specialWinCondition5
	local _mibaokuangdong = {
		maxTime = cfg.maxTime,
		initCount = specialCfg.initCount,
		whenReduce = specialCfg.whenReduce,
		masterDownCD = specialCfg.masterDownCD,
		minCount = specialCfg.minCount,
		isStopReduceMaster = false,
	}
	function _mibaokuangdong:onUpdate(elapse)
		local time = self.maxTime - elapse
		if time == 3 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17459))
		elseif time > self.whenReduce then
			local t1,t2 = math.modf((time - self.whenReduce)/self.masterDownCD)
			if t2 == 0 then
				local leftCount = self.initCount - t1
				if leftCount >= self.minCount and not self.isStopReduceMaster then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17455, leftCount))
				end
			end
		end
	end
	function _mibaokuangdong:stopReduceMaster()--停止减少怪物
		self.isStopReduceMaster = true
	end
	self._mibaokuangdong = _mibaokuangdong
end

function wnd_battleFuben:updateSingleChallengeLeftState(mapId)
	if g_i3k_db.i3k_db_single_challenge_dungeon(mapId) then
		self.damageRoot:show()
		self.outputBtn:hide()
		self._state = TarGetState
	end
end

function wnd_battleFuben:updateDefenceWarLeftState(mapType)
	if mapType == g_DEFENCE_WAR then
		self.desc_root:hide()
		self.percentRoot:hide()
		self._state = TarGetState
	end
end

function wnd_battleFuben:updateLeftState()
	self:updateTargetData()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local mapType = i3k_game_get_map_type()
	
	if (mapType == g_BASE_DUNGEON and i3k_db_new_dungeon[mapId].openType == 0) or (mapType == g_ACTIVITY or mapType == g_FACTION_DUNGEON or mapType == g_AT_ANY_MOMENT_DUNGEON) then
		self.damageRoot:show()
	else
		self.damageRoot:hide()
	end

	if (mapType == g_BASE_DUNGEON and i3k_db_new_dungeon[mapId].openType == 0) or mapType == g_FACTION_DUNGEON then
		local isShowSingleDesc = g_i3k_db.i3k_db_get_is_show_dungeon_desc()
		if not isShowSingleDesc then
			self._state = OutPutState
			self.targetDesc:setText("输出")
			self.outputBtn:hide()
			self:updateOutPutData()
		else
			self.desc_root:show()
		end
	end
	if mapType == g_AT_ANY_MOMENT_DUNGEON then
		self.outputBtn:hide()
	end

	self:updateSingleChallengeLeftState(mapId)
	self:updateDefenceWarLeftState(mapType)
end

function wnd_battleFuben:updateTargetData()
	self.outputRoot:hide()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local mapType = i3k_game_get_map_type()
	if i3k_db_activity_cfg[mapId] then
		local gruop_id = i3k_db_activity_cfg[mapId].groupId
		local leftDescId = i3k_db_activity[gruop_id].leftDescTextId
		self:updateDesc(leftDescId)
	end

	if i3k_db_rightHeart2[mapId] then
		local leftDescId = i3k_db_rightHeart2[mapId].challengeTargetDesc
		self:updateDesc(leftDescId)
	end

	if mapType == g_BASE_DUNGEON and i3k_db_new_dungeon[mapId].openType == 0 then
		local isShowSingleDesc = g_i3k_db.i3k_db_get_is_show_dungeon_desc()
		if isShowSingleDesc then
			local world = i3k_game_get_world()
			local descId = world:GetSingleDungeonTagDesc()
			self:updateDesc(descId)
		end
	end

	self._layout.vars.percent_root:hide()
	local mapId = g_i3k_game_context:GetWorldMapID()
	if i3k_db_activity_cfg[mapId] then
		local actId = i3k_db_activity_cfg[mapId].groupId
		if mapType == g_ACTIVITY and actId ~= 1 and  actId ~= 2 then
			self._layout.vars.percent_root:show()
			local record = g_i3k_game_context:getActMapRecord(actId, mapId)
			local percent = g_i3k_game_context:GetActivityPercent() / 100
			self._layout.vars.nowPercent:setPercent(percent)
			self._layout.vars.percentLabel:setText(percent.."%")
			self._layout.vars.percentLabel:show()
			self._layout.vars.oldPercent:setPercent(record and record/10000*100 or 0)
			self.percentRoot:show()
			if percent == 100 and self._mibaokuangdong then
				self._mibaokuangdong:stopReduceMaster()
			end
		else
			self.percentRoot:hide()
		end
	end
end

function wnd_battleFuben:updateOutPutData()
	self.desc_root:hide()
	self.percentRoot:hide()
	self.outputRoot:show()
	self.rankScroll:removeAllChildren()
	local roleID = g_i3k_game_context:GetRoleId()
	local damageRank = self:sortDamgeRank(g_i3k_game_context:GetMapCopyDamageRank())
	local maxDamage = 0
	if #damageRank > 0 then
		maxDamage = damageRank[1].damage
	end
	for i, e in ipairs(damageRank) do
		local widget = require(WidgetFbzxt)()
		local name
		if e.attackName ~= "" then
			name = roleID == e.attackId and "主角" or e.attackName
		else -- 名字为空则为自己带的随从
			name = i3k_db_mercenaries[e.attackId] and i3k_db_mercenaries[e.attackId].name or "随从"
		end
		local iconId = roleID == e.attackId and DamageBarBg1 or DamageBarBg2
		widget.vars.name:setText(name)
		widget.vars.damageNum:setText(e.damage)
		widget.vars.name:setTextColor(roleID == e.attackId and COLOR1 or COLOR2)
		widget.vars.damageBar:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		widget.vars.damageBar:setPercent(e.damage / maxDamage * 100)
		self.rankScroll:addItem(widget)
	end
end

function wnd_battleFuben:sortDamgeRank(damageRank)
	local data = {}
	for k, v in pairs(damageRank) do
		table.insert(data, {attackId = k, attackName = v.attackName, damage = v.damage})
	end
	table.sort(data, function (a,b)
		return a.damage > b.damage
	end)
	return data
end

function wnd_battleFuben:onTarget(sender)
	local mapId = g_i3k_game_context:GetWorldMapID()
	if (i3k_db_new_dungeon[mapId] and i3k_db_new_dungeon[mapId].openType == 0) or i3k_game_get_map_type() == g_FACTION_DUNGEON  then
		local isShowSingleDesc = g_i3k_db.i3k_db_get_is_show_dungeon_desc()
		if not isShowSingleDesc then
			return
		end
	end
	if i3k_db_rightHeart2[mapId] then
		return false
	end
	self._state = TarGetState
	self:updateTargetData()
end

function wnd_battleFuben:onOutput(sender)
	self._state = OutPutState
	self:updateOutPutData()
end

function wnd_battleFuben:onAuto(sender)
	local mapType = i3k_game_get_map_type()
	local mapList = i3k_db_common.autoFightMapList
	local canClick = false
	for i, e in ipairs(i3k_db_common.autoFightMapList) do
		if mapType == e then
			canClick = true
			break
		end
	end
	if canClick then
		g_i3k_game_context:SetAutoFight(true)
	end
end

function wnd_battleFuben:updateDesc(id)
	if self._state == TarGetState then
		if id == 0 then
			self.desc_root:hide()
		else
			self.desc_root:show()
			self.desc_text:setText(i3k_get_string(id))
		end
	end
end

function wnd_battleFuben:updateSceneGuideDir(dir) -- InvokeUIFunction
	self._widgets.guideArrow:show();
	self._widgets.guideGo:show();
	self._widgets.guideArrow:setRotation(math.deg(dir))
end

function wnd_battleFuben:updateSceneGuideShow(visible) -- InvokeUIFunction
	self._widgets.guideArrow:setVisible(visible)
	self._widgets.guideGo:setVisible(visible)
end

function wnd_battleFuben:updateActivityPercent(percent)
	if self._state == TarGetState then
		local mapId = g_i3k_game_context:GetWorldMapID()
		local actCfg = i3k_db_activity_cfg[mapId]
		if actCfg and actCfg.groupId~=1 and actCfg.groupId~=2 then
			local per = percent/100
			self._layout.vars.nowPercent:setPercent(per)
			self._layout.vars.percentLabel:show()
			self._layout.vars.percentLabel:setText(per.."%")
		end
		if percent == 10000 and self._mibaokuangdong then--如果秘宝矿洞进度100了 不再出现盗矿者减少的提示
			self._mibaokuangdong:stopReduceMaster()
		end
	end
end

function wnd_battleFuben:updateSingleChallengePercent(targetIndex, value)
	if self._state == TarGetState then
		local mapId = g_i3k_game_context:GetWorldMapID()
		if g_i3k_db.i3k_db_single_challenge_dungeon(mapId) then
			local progressType = i3k_db_rightHeart2[mapId].progressType
			local curStage = progressType[targetIndex + 1] and progressType[targetIndex + 1] or progressType[#progressType]

			local targetCfg = i3k_db_rightHeart_target_info[curStage]
			if targetCfg then
				local percent = 0
				if targetIndex == #progressType then
					percent = 100
				else
					percent = math.floor((targetIndex/#progressType + value/targetCfg.args2) * 100)
				end

				self.percentRoot:show()
				self._layout.vars.percent_root:show()
				self._layout.vars.oldPercent:hide()
				self._layout.vars.nowPercent:setPercent(percent)
				self._layout.vars.percentLabel:show()
				self._layout.vars.percentLabel:setText(percent.."%")
			end
		else
			self.percentRoot:hide()
		end
	end
end

function wnd_battleFuben:updateOutPut()
	if self._state == OutPutState then
		self:updateOutPutData()
	end
end

function wnd_battleFuben:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 2 then
		self:syncMapCoypDamageRank()
		self._timeCounter = 0
	end
	if g_i3k_game_context:GetWorldMapType() == g_FACTION_DUNGEON and not g_i3k_game_context:isSpecialFacionDungeon(g_i3k_game_context:GetWorldMapID()) then
		self._damageCounter = self._damageCounter + dTime
		if self._damageCounter > DAMAGEREFRESH then
			self._damageCounter = 0
			self:syncFactionDungeonDamage()
		end
		local num = math.ceil((self._lastDamage + (self._curDamage - self._lastDamage)/DAMAGEREFRESH * self._damageCounter) * 100/self._maxHp)
		if num > self._lastDamageInt then
			self:setFactionDungeonDamage(num)
			self._lastDamageInt = num
		end
	end
end

function wnd_battleFuben:syncMapCoypDamageRank()
	local world = i3k_game_get_world()
	local flag = g_i3k_db.i3k_db_check_sync_mapcopy()
	if world and world._syncRpc and flag then
		i3k_sbean.queryMapCopyDamageRank()
	end
end

function wnd_battleFuben:updateSwallowUI()
	------------------------竞技场开场倒计时提示
	local mapType = i3k_game_get_map_type()
	local mapTp = 
	{
		[g_ARENA_SOLO] = true,
		[g_TOURNAMENT] = true,
		[g_TAOIST] = true,
		[g_DEFENCE_WAR] = true,
		[g_DOOR_XIULIAN] = true,
	}
	
	if mapTp[mapType] then
		if self._fightCoolTime>0 then
			g_i3k_ui_mgr:OpenUI(eUIID_ArenaSwallow)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_ArenaSwallow)
		end
	end
end

function wnd_battleFuben:setTimeElapseText(text)
	self._layout.vars.timeElapse:setText(text);
end

function wnd_battleFuben:updateTimeElapse(time, color) -- InvokeUIFunction
	self:updateSwallowUI()
	local surplusTime
	local formatTime = function(time)
		local tm = time;
		local h = i3k_integer(tm / (60 * 60));
		tm = tm - h * 60 * 60;

		local m = i3k_integer(tm / 60);
		tm = tm - m * 60;

		local s = tm;
		surplusTime = h*60*60 + m*60 + s
		return string.format("%02d:%02d:%02d", h, m, s);
	end
	if self._totalTime and self._fightCoolTime and self._totalTime-time >= self._fightCoolTime then
		g_i3k_ui_mgr:CloseUI(eUIID_ArenaSwallow)
	end

	self._layout.vars.timeElapse:setText(formatTime(time));
	self._layout.vars.timeElapse:setTextColor(color);

	if self._totalTime and self._fightCoolTime then
		local mapType = i3k_game_get_map_type()
		if mapType == g_ARENA_SOLO or  mapType == g_TAOIST or mapType == g_QIECUO or mapType == g_HOMELAND_GUARD then
			if self._totalTime - time <= (self._fightCoolTime - 3) then --等待时间到三秒倒计时打开
				if not g_i3k_ui_mgr:GetUI(eUIID_BattleReadFight) then
					g_i3k_ui_mgr:OpenUI(eUIID_BattleReadFight)
					g_i3k_ui_mgr:RefreshUI(eUIID_BattleReadFight)
				end
			end
		end
		if self._fightCoolTime-(self._totalTime-surplusTime)<=0 then
			self._fightCoolTime = -1
		elseif self._fightCoolTime-(self._totalTime-surplusTime)<=3 and not f_isPlay then
			if g_i3k_ui_mgr:GetUI(eUIID_BattleFight) then
				g_i3k_ui_mgr:CloseUI(eUIID_BattleFight)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_BattleReadFight)
			g_i3k_ui_mgr:OpenUI(eUIID_BattleFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleFight)
			f_isPlay = true
		end
	end

	--幻境副本计时
	if g_i3k_ui_mgr:GetUI(eUIID_BattleIllusory) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleIllusory, "updateIllusoryTime", time)
	end

	if self._mibaokuangdong then
		self._mibaokuangdong:onUpdate(time)
	end
end

function wnd_battleFuben:updateAnnunciateInfo(hide)
	if hide then
		self.desc_root:hide()
	else
		self.desc_root:show()
		local data = g_i3k_game_context:GetAnnunciateData()
		local mapId = g_i3k_game_context:GetWorldMapID()
		local actId = nil
		for i,v in ipairs(i3k_db_annunciate.activity) do
			if v.actMapId == mapId then
				actId = i
			end
		end
		if actId then
			self._layout.vars.rwTitle:setText("["..i3k_db_annunciate.activity[actId].monsterName.."]")
		end
		self:updateAnnunciatePrestige(data.prestige)
	end
end

function wnd_battleFuben:updateAnnunciatePrestige(prestige)
	self._layout.vars.desc_text:setText(i3k_get_string(15342).."\n"..i3k_get_string(909,prestige))
end

function wnd_battleFuben:enableTimeElapse(value) -- InvokeUIFunction
	local ui = self._layout.vars.time;
	if ui then
		if value then
			ui:show();
		else
			ui:hide();
		end
	end
end

function wnd_battleFuben:onExit(sender, isFinished)
	local world = i3k_game_get_world()
	local petId = g_i3k_game_context:GetLifeTaskRecorkPetID()
	if world._mapType == g_Life and petId ~= 0 then
		local id, value = g_i3k_game_context:getPetTskIdAndValueById(petId)
		local num = (id == 0 or not id) and 512 or 513
		local fun = (function(ok)
			if ok then
				f_isPlay = false
				if g_i3k_game_context:getIsCompletePetLifeTaskFromID(petId) then
					g_i3k_game_context:RefreshMercenaryRelationProps()
				end
				g_i3k_game_context:SetLifeTaskRecordPetID(0)
				i3k_sbean.mapcopy_leave()
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(num, i3k_db_mercenaries[petId].name), fun)
	elseif world._mapType == g_FACTION_TEAM_DUNGEON then
		local fun = (function(ok)
			if ok then
				f_isPlay = false
				local function mulHorseCB()
					i3k_sbean.mapcopy_leave()
				end
				g_i3k_game_context:CheckMulHorse(mulHorseCB)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2("确定离开", fun)
	elseif world._mapType == g_BUDO then
		if g_i3k_game_context:GetIsGuard() then
			i3k_sbean.mapcopy_leave()
		else
			g_i3k_ui_mgr:PopupTipMessage("武道荣誉至上，不得离开")
		end
	elseif world._mapType == g_GLOBAL_PVE then
		local mapID = g_i3k_game_context:GetWorldMapID()
		local desc = i3k_db_crossRealmPVE_fb[mapID].mapType ==  g_FIELD_SAFE_AREA and i3k_get_string(1322) or i3k_get_string(1323)
		local fun = (function(ok)
			if ok then
				f_isPlay = false
				i3k_sbean.mapcopy_leave()
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	elseif  world._mapType == g_HOME_LAND then 
		local desc = i3k_get_string(5375)
		local fun = (function(ok)
			if ok then
				f_isPlay = false
				i3k_sbean.mapcopy_leave()
			end
		end)
		local func = function()
			g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
		end
		g_i3k_game_context:CheckMulHorse(func)
	elseif  world._mapType == g_FIVE_ELEMENTS then 
		local desc = i3k_get_string(66)
		local fun = (function(ok)
			local cb = function ()
				g_i3k_logic:OpenFiveElementsUI()
			end
			if ok then
				f_isPlay = false
				i3k_sbean.mapcopy_leave(eUIID_FiveElements, cb)
			end
		end)
		local func = function()
			g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
		end
		g_i3k_game_context:CheckMulHorse(func)
	elseif world._mapType == g_CATCH_SPIRIT then 
		local desc = i3k_get_string(18700)
		local fun = (function(ok)
			if ok then
				f_isPlay = false
				i3k_sbean.mapcopy_leave()
			end
		end)
		local func = function()
			g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
		end
		g_i3k_game_context:CheckMulHorse(func)
	else
		local desc = i3k_get_string(66)
		if world._mapType == g_ANNUNCIATE then
			desc = i3k_get_string(15337)
		elseif world._mapType == g_FACTION_WAR then
			desc = i3k_get_string(3118)
		elseif world._mapType == g_Pet_Waken then
			desc = i3k_get_string(16825)
		elseif world._mapType == g_DEFENCE_WAR then
			if g_i3k_game_context:IsInFightTime() then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1310))
				return
			end
			
			desc = "城战尚未结束，确定离开？"
		elseif world._mapType == g_OUT_CAST then 
			if isFinished then 
				desc = "外传已完成，确定离开？"
			else 
				desc = "外传未完成，确定离开？"
			end
		elseif world._mapType == g_SPIRIT_BOSS then
			desc = i3k_get_string(17343)
		elseif world._mapType == g_PET_ACTIVITY_DUNGEON then
			desc = i3k_get_string(1514)
		elseif world._mapType == g_DESERT_BATTLE then
			desc = i3k_get_string(17619)
		elseif world._mapType == g_MAZE_BATTLE then
			desc = i3k_get_string(17756)
		elseif world._mapType == g_PRINCESS_MARRY then
			desc = i3k_get_string(18044)
		elseif world._mapType == g_MAGIC_MACHINE then
			if g_i3k_game_context:IsInFightTime() then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1310))
				return
			end
			desc = i3k_get_string(18142)
		elseif world._mapType == g_LONGEVITY_PAVILION then
			desc = i3k_get_string(18560)
		elseif world._mapType == g_BIOGIAPHY_CAREER then
			desc = i3k_get_string(18517)
		elseif world._mapType == g_SPY_STORY then
			desc = i3k_get_string(18658)
		end
		local fun = (function(ok)
			if ok then
				f_isPlay = false
				i3k_sbean.mapcopy_leave()
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	end

end

function wnd_battleFuben:refreshKillTipsUI()
	local widget = self._layout.vars
	local mapType = i3k_game_get_map_type()
	
	if g_i3k_game_context:isCanKillTipes() and mapType ~= g_ARENA_SOLO and mapType ~= g_TAOIST then 
		widget.killTips:show()
		
		if g_i3k_game_context:GetUserCfg():getIsShowKillTips() == 0 then
			widget.killTips:stateToNormal()
		else
			widget.killTips:stateToPressed()
		end
		
		widget.killTips:onClick(self, self.onKillTipsBt)
	else
		widget.killTips:hide()
	end
end

function wnd_battleFuben:onKillTipsBt()
	local widget = self._layout.vars
	local value = g_i3k_game_context:GetUserCfg():getIsShowKillTips() == 0 and 1 or 0
	g_i3k_game_context:GetUserCfg():setIsShowKillTips(value)
	
	if value == 0 then
		widget.killTips:stateToNormal()
	else
		widget.killTips:stateToPressed()
	end
end
function wnd_battleFuben:updateAtAnyMomentState()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local mapType = g_i3k_game_context:GetWorldMapType()
	if mapType == g_AT_ANY_MOMENT_DUNGEON then
		local monsterArea = g_i3k_game_context:GetDungeonSpawnID()
		local index = 1
		for k, v in ipairs(i3k_db_dungeon_base[mapId].areas) do
			if math.abs(monsterArea) == v then
				index = k
				break
			end
		end
		self._layout.vars.desc_root:show()
		self._layout.vars.targetBtn:show()
		self._layout.vars.desc_text:setText(i3k_get_string(i3k_db_at_any_moment[mapId].target[index]))
		--self._layout.vars.rwTitle:setText(i3k_db_at_any_moment[mapId].dungeonTips[index])
		if not g_i3k_game_context:getDialogueFinish(index) then
			g_i3k_game_context:addDialogueFinish(index)
			g_i3k_game_context:OpenAtAnyMomentDialogue()
		end
	end
end
function wnd_battleFuben:syncFactionDungeonDamage()
	i3k_sbean.sectmap_damage(g_i3k_game_context:GetWorldMapID())
end
function wnd_battleFuben:showFactionDamage(damage)
	self._lastDamage = self._curDamage
	self._curDamage = damage
end
function wnd_battleFuben:setFactionDungeonDamage(num)
	self._layout.vars.singleIcon:hide()
	self._layout.vars.doubleIcon1:hide()
	self._layout.vars.trebleIcon1:hide()
	self._layout.anis.c_mao3.stop()
	self._layout.anis.c_mao2.stop()
	self._layout.anis.c_mao1.stop()
	if num >= 100 then
		self._layout.vars.trebleIcon1:show()
		self._layout.vars.trebleIcon1:setImage(g_i3k_db.i3k_db_get_icon_path(numberIcons[math.floor(num / 100) + 1]))
		self._layout.vars.trebleIcon2:setImage(g_i3k_db.i3k_db_get_icon_path(numberIcons[math.floor(num % 100 / 10) + 1]))
		self._layout.vars.trebleIcon3:setImage(g_i3k_db.i3k_db_get_icon_path(numberIcons[(num % 10) + 1]))
		self._layout.anis.c_mao3.play()
	elseif num >= 10 then
		self._layout.vars.doubleIcon1:show()
		self._layout.vars.doubleIcon1:setImage(g_i3k_db.i3k_db_get_icon_path(numberIcons[math.floor(num / 10) + 1]))
		self._layout.vars.doubleIcon2:setImage(g_i3k_db.i3k_db_get_icon_path(numberIcons[(num % 10) + 1]))
		self._layout.anis.c_mao2.play()
	else
		self._layout.vars.singleIcon:show()
		self._layout.vars.singleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(numberIcons[num + 1]))
		self._layout.anis.c_mao1.play()
	end
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleFuben.new();
		wnd:create(layout);
	return wnd;
end
