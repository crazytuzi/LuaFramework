WorldBossInfoView = WorldBossInfoView or BaseClass(BaseRender)

function WorldBossInfoView:__init(instance)
	if instance == nil then
		return
	end

	-- self.scroller = self:FindObj("Scroller")
	self.slider1 = self:FindObj("Slider1"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.slider2 = self:FindObj("Slider2"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.icon = self:FindObj("Icon")
	self.item_list = {}
	for i=1,3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self:ListenEvent("OnClickPerson",
		BindTool.Bind(self.OnClickPerson, self))
	self:ListenEvent("ClickBoss",
		BindTool.Bind(self.ClickBoss, self))
	self:ListenEvent("ClickMap",
		BindTool.Bind(self.ClickMap, self))
	self:ListenEvent("OnClickRoll",
		function() self:OnClickRoll(1) end)
	self:ListenEvent("OnClickRoll1",
		function() self:OnClickRoll(2) end)
	self:ListenEvent("OnClickAbandon",
		function() self:OnClickAbandon(1) end)
	self:ListenEvent("OnClickAbandon1",
		function() self:OnClickAbandon(2) end)
	self:ListenEvent("OnClickRank",
		function() self:OnClickRank() end)
	self.scene_loaded = GlobalEventSystem:Bind(
		SceneEventType.SCENE_LOADING_STATE_QUIT,BindTool.Bind(self.OnSceneLoaded, self))
	-- self:InitScroller()

	self.rank_view = WorldBossRankView.New(self:FindObj("ScoreRank"))

	self.map_name = self:FindVariable("MapName")
	self.show_btn = self:FindVariable("ShowBtn")
	self.show_btn1 = self:FindVariable("ShowBtn1")
	self.xu_qiu = self:FindVariable("XuQiu")
	self.fang_qi = self:FindVariable("FangQi")
	self.sheng_yu_shi_jian = self:FindVariable("ShengYuShiJian")
	self.rest_time1 = self:FindVariable("RestTime1")
	self.rest_time2 = self:FindVariable("RestTime2")
	self.show_point1 = self:FindVariable("ShowPoint1")
	self.show_point2 = self:FindVariable("ShowPoint2")
	self.point1 = self:FindVariable("Point1")
	self.point2 = self:FindVariable("Point2")
	self.top_name1 = self:FindVariable("TopName1")
	self.top_name2 = self:FindVariable("TopName2")
	self.top_point1 = self:FindVariable("TopPoint1")
	self.top_point2 = self:FindVariable("TopPoint2")
	self.progress_value_1 = self:FindVariable("progress_value_1")
	self.progress_value_2 = self:FindVariable("progress_value_2")
	self.boss_name = self:FindVariable("boss_name")
	self.boss_icon = self:FindVariable("boss_icon")
	self.boss_level = self:FindVariable("boss_level")
	self.boss_hp = self:FindVariable("BossHpValue")
	self.boss_dun = self:FindVariable("BossDunValue")
	self.is_boss_dun = self:FindVariable("is_dun")
	self.is_boss_hp = self:FindVariable("is_hp")
	self.time_text = self:FindVariable("TimeText")

	-- 监听系统事件
	self:BindGlobalEvent(ObjectEventType.BE_SELECT,
		BindTool.Bind(self.OnSelectObjHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD,
		BindTool.Bind(self.OnObjDead, self))
	-- self:BindGlobalEvent(ObjectEventType.TARGET_HP_CHANGE,
	-- 	BindTool.Bind(self.OnTargetHpChangeHead, self))
	self:BindGlobalEvent(ObjectEventType.SPECIAL_SHIELD_CHANGE,
		BindTool.Bind(self.OnSpecialShieldChangeBlood, self))

	self.xu_qiu:SetValue(Language.Common.XuQiu)
	self.fang_qi:SetValue(Language.Common.FangQi)
	self.sheng_yu_shi_jian:SetValue(Language.Common.ShengYuShiJian)
	self.show_point1:SetValue(false)
	self.show_point2:SetValue(false)
	self.is_boss_hp:SetValue(false)

	-- self.info_list = {}
	-- for i = 1, 5 do
	-- 	self.info_list[i] = {}
	-- 	self.info_list[i].obj = self:FindObj("DamageInfo" .. i)
	-- 	local variable_table = self.info_list[i].obj:GetComponent("UIVariableTable")
	-- 	self.info_list[i].rank = variable_table:FindVariable("Rank")
	-- 	self.info_list[i].name = variable_table:FindVariable("Name")
	-- 	self.info_list[i].damage = variable_table:FindVariable("Damage")
	-- end

	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = {}
		self.item_cell_list[i].obj = self:FindObj("ItemCell" .. i)
		local variable_table = self.item_cell_list[i].obj:GetComponent(typeof(UIVariableTable))
		self.item_cell_list[i].Icon = variable_table:FindVariable("Icon")
		self.item_cell_list[i].Quality = variable_table:FindVariable("Quality")
		self.item_cell_list[i].ShowNumber = variable_table:FindVariable("ShowNumber")
		self.item_cell_list[i].ShowStrength = variable_table:FindVariable("ShowStrength")
		self.item_cell_list[i].ShowPropName = variable_table:FindVariable("ShowPropName")
		self.item_cell_list[i].Number = variable_table:FindVariable("Number")
		self.item_cell_list[i].Strength = variable_table:FindVariable("Strength")
		self.item_cell_list[i].PropName = variable_table:FindVariable("PropName")
		self.item_cell_list[i].Bind = variable_table:FindVariable("Bind")
		self.item_cell_list[i].CellLock = variable_table:FindVariable("CellLock")
		self.item_cell_list[i].ShowQuality = variable_table:FindVariable("ShowQuality")
		self.item_cell_list[i].ShowHighLight = variable_table:FindVariable("ShowHighLight")
		self.item_cell_list[i].name = self:FindVariable("RewardName" .. i)

		self.item_cell_list[i].ShowHighLight:SetValue(false)
		self.item_cell_list[i].ShowQuality:SetValue(true)
		self.item_cell_list[i].ShowNumber:SetValue(true)
	end

	self.roll_effective_time = 10
	local world_boss_other_config = BossData.Instance:GetBossOtherConfig()
	if world_boss_other_config then
		self.roll_effective_time = world_boss_other_config.roll_effective_time or 10
	end
	self.is_show_person = true
	self:OnSceneLoaded()

	self:OnSelectObjHead(nil, nil)
end

function WorldBossInfoView:__delete()
	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end
	if self.reward_timer then
		GlobalTimerQuest:CancelQuest(self.reward_timer)
		self.reward_timer = nil
	end
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end
	self:RemoveCountDown()
	self:PauseTweener()
end

function WorldBossInfoView:OnSceneLoaded()
	BossCtrl.Instance:SetBossHpInfo()
	self:RemoveCountDown()
	self.show_btn:SetValue(false)
	self.show_btn1:SetValue(false)
	local map_name = Scene.Instance:GetSceneName()
	self.map_name:SetValue(map_name)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			if boss_id then
				BossCtrl.Instance:SendWorldBossPersonalHurtInfoReq(boss_id)
				BossCtrl.Instance:SendWorldBossGuildHurtInfoReq(boss_id)
				local config = BossData.Instance:GetBossCfgById(boss_id)
				if config then
					local item_list = config.gift_item
					if item_list then
						local item_id = item_list.item_id
						for i = 1, 2 do
							self.item_cell_list[i].obj:GetComponent(typeof(UIEventTable)):ClearEvent("Click")
							self.item_cell_list[i].obj:GetComponent(typeof(UIEventTable)):ListenEvent("Click",
								function() TipsCtrl.Instance:OpenItem({item_id = item_id}) end)
							local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
							if item_cfg then
								local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
								self.item_cell_list[i].Icon:SetAsset(bundle, asset)
								bundle, asset = ResPath.GetQualityIcon(item_cfg.color)
								self.item_cell_list[i].Quality:SetAsset(bundle, asset)
								self.item_cell_list[i].name:SetValue(item_cfg.name)
							end
							self.item_cell_list[i].Number:SetValue(item_list.num)
							if item_list.is_bind == 0 then
								self.item_cell_list[i].Bind:SetValue(false)
							else
								self.item_cell_list[i].Bind:SetValue(true)
							end
						end
					end
				end
			end
		end
	end
end

function WorldBossInfoView:OnFlush()
	local data_list = {}
	local scene_id = Scene.Instance:GetSceneId()
	local item_data_list = BossData.Instance:GetWorldBossRewardItems(scene_id)
	for i=1,3 do
		self.item_list[i]:SetData(item_data_list[i])
	end
	local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[boss_id]
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		self.boss_level:SetValue(monster_cfg.level)
		local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
		self.boss_icon:SetAsset(bundle, asset)
	end
	if nil ~= BossData.Instance:GetBossHpInfo() then
		local boss_info = BossData.Instance:GetBossHpInfo()
		local max_hp = boss_info.max_hp
		local cur_hp = boss_info.cur_hp
		if boss_info.boss_id ~= 0 then
			self:SetHpPercent(cur_hp / max_hp)
		end
		if boss_info.boss_id == 0 then
			self:SetHpPercent(0)
		end
	end
	self:FlushNextTime()
	if self.reward_timer then
		GlobalTimerQuest:CancelQuest(self.reward_timer)
		self.reward_timer = nil
	end
	if self.reward_timer == nil then
		self.reward_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	self.rank_view:Flush()
end

function WorldBossInfoView:OnClickPerson(switch)
	self.is_show_person = switch
	self:Flush()
end

function WorldBossInfoView:ClickMap()
	ViewManager.Instance:Open(ViewName.Map)
end

function WorldBossInfoView:CountToString(count)
	if not count then return end
	if count > 9999 and count < 100000000 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count >= 100000000 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	return count
end

function WorldBossInfoView:OnSelectObjHead(target_obj, select_type)
	self.is_boss_dun:SetValue(false)
	self.is_boss_hp:SetValue(true)
	if nil == target_obj
		or target_obj:GetType() == SceneObjType.MainRole
		or target_obj:GetType() == SceneObjType.TruckObj
		or target_obj:GetType() == SceneObjType.EventObj
		or target_obj:GetType() == SceneObjType.Trigger
		or target_obj:GetType() == SceneObjType.MingRen
		or target_obj:IsNpc()
		or (target_obj.IsGather and target_obj:IsGather())
		or (target_obj:IsMonster() and not target_obj:IsBoss() and target_obj:GetMonsterId() ~= qizhi_id)
		or (target_obj:GetType() == SceneObjType.Monster and target_obj:GetMonsterId() == 1101 and Scene.Instance:GetSceneType() == SceneType.QunXianLuanDou) then
		self.target_obj = nil
		-- self.show_target:SetValue(false)
		return
	end

	self.target_obj = target_obj
	-- self.show_target:SetValue(self.target_obj ~= nil and self.is_show)
	if self.target_obj == nil then
		return
	end

	-- if target_obj:IsRole() then
	-- 	self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
	-- elseif target_obj:IsMonster() then
	-- 	self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
	-- else
	-- 	self:SetHpPercent(1)
	-- end
end

-- 取消
function WorldBossInfoView:OnObjDeleteHead(obj)
	if self.target_obj == obj then
		self.target_obj = nil
		-- self.show_target:SetValue(false)
	end
end

function WorldBossInfoView:OnObjDead(obj)
	self:SetHpPercent(0)
	if self.target_obj == obj then
		self.target_obj = nil
		-- self.show_target:SetValue(false)
	end
end

-- function WorldBossInfoView:OnTargetHpChangeHead(target_obj)
-- 	self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
-- end

function WorldBossInfoView:SetHpPercent(percent)
	self.boss_hp:SetValue(percent)
end

function WorldBossInfoView:OnSpecialShieldChangeBlood(info)
	if self.target_obj and self.target_obj:GetObjId() == info.obj_id then
		self.boss_dun:SetValue(info.left_times / info.max_times)
		self.is_boss_dun:SetValue(info.left_times / info.max_times > 0)
		if info.max_times <= 0 then
			self.is_boss_dun:SetValue(false)
			self.boss_dun:SetValue(0)
			if self.cal_time_quest then
				GlobalTimerQuest:CancelQuest(self.cal_time_quest)
				self.cal_time_quest = nil
			end
		end
	end
	if self.cal_time_quest == nil then
		self:CalTimeHideDun()
	end
end

function WorldBossInfoView:CalTimeHideDun()
	local timer_cal = 20
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0 then
			self.is_boss_dun:SetValue(false)
			self.boss_dun:SetValue(0)
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
			self.cal_time_quest = nil
		end
	end, 0)
end

function WorldBossInfoView:OnClickRoll(index)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			BossCtrl.Instance:SendWorldBossRollReq(boss_id, index)
		end
	end
end

function WorldBossInfoView:ClickBoss()
	local scene_id = Scene.Instance:GetSceneId()
	local a = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
	local data = BossData.Instance:GetWorldBossList()

	if data == nil then return end

	for k,v in pairs(data) do
		if v.bossID == a then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(scene_id, v.postion_x, v.postion_y, 0, 0)
			return
		end
	end
	return
end

function WorldBossInfoView:OnClickAbandon(index)
	if index == 1 then
		self.show_btn:SetValue(false)
	else
		self.show_btn1:SetValue(false)
	end
end

function WorldBossInfoView:OnClickRank()
	self.rank_view:Flush()
end

function WorldBossInfoView:SetCanRoll(index)
	local tweener = nil
	if index == 1 then
		self.show_btn:SetValue(true)
		self.show_point1:SetValue(false)
		self.slider1.value = 0
		tweener = self.slider1:DOValue(1, self.roll_effective_time, false)
		self.tweener1 = tweener
		if self.count_down1 then
			CountDown.Instance:RemoveCountDown(self.count_down1)
		end
		self.count_down1 = CountDown.Instance:AddCountDown(self.roll_effective_time, 0.1,
		 function(elapse_time, total_time) self.rest_time1:SetValue(string.format("%.1f", total_time - elapse_time))
		 self.progress_value_1:SetValue((total_time - elapse_time)/total_time)
		 if total_time - elapse_time <= 0 then
		 	self.show_btn:SetValue(false)
		 end end)
	else
		self.show_btn1:SetValue(true)
		self.show_point2:SetValue(false)
		self.slider2.value = 0
		tweener = self.slider2:DOValue(1, self.roll_effective_time, false)
		self.tweener2 = tweener
		if self.count_down2 then
			CountDown.Instance:RemoveCountDown(self.count_down2)
		end
		self.count_down2 = CountDown.Instance:AddCountDown(self.roll_effective_time, 0.1,
		 function(elapse_time, total_time) self.rest_time2:SetValue(string.format("%.1f", total_time - elapse_time))
		 self.progress_value_2:SetValue((total_time - elapse_time)/total_time)
		 if total_time - elapse_time <= 0 then
		 	self.show_btn1:SetValue(false)
		 end end)
	end
	if tweener then
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:OnComplete(function() self:OnClickAbandon(index) end)
	end
end

function WorldBossInfoView:SetRollResult(point, index)
	if index == 1 then
		self.show_point1:SetValue(true)
		self.point1:SetValue(point)
		if self.tweener1 then
			self.tweener1:Pause()
			self.tweener1 = nil
		end
		-- self.time_quest1 = GlobalTimerQuest:AddDelayTimer(function() self.show_btn:SetValue(false) end, 3)
	elseif index == 2 then
		self.show_point2:SetValue(true)
		self.point2:SetValue(point)
		if self.tweener2 then
			self.tweener2:Pause()
			self.tweener2 = nil
		end
		-- self.time_quest2 = GlobalTimerQuest:AddDelayTimer(function() self.show_btn1:SetValue(false) end, 3)
	end
end

function WorldBossInfoView:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			local this_boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			if this_boss_id == boss_id then
				if hudun_index == 1 then
					self.top_point1:SetValue(top_roll_point)
					self.top_name1:SetValue(top_roll_name)
				elseif hudun_index == 2 then
					self.top_point2:SetValue(top_roll_point)
					self.top_name2:SetValue(top_roll_name)
				end
			end
		end
	end
end

function WorldBossInfoView:RemoveCountDown()
	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end
	if self.time_quest2 then
		GlobalTimerQuest:CancelQuest(self.time_quest2)
		self.time_quest2 = nil
	end
	if self.count_down1 then
		CountDown.Instance:RemoveCountDown(self.count_down1)
		self.count_down1 = nil
	end
	if self.count_down2 then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
end

function WorldBossInfoView:PauseTweener()
	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end
	if self.tweener1 then
		self.tweener2:Pause()
		self.tweener2 = nil
	end
end

function WorldBossInfoView:MyLinearEase(time, duration, overshootOrAmplitude, period)
	return time / duration
end

function WorldBossInfoView:FlushNextTime()
	self.icon.grayscale.GrayScale = 0
	if nil ~= BossData.Instance:GetBossHpInfo() and nil ~= BossData.Instance:GetBossNextReFreshTime() then
		local hp = BossData.Instance:GetBossHpInfo().cur_hp
		local time = BossData.Instance:GetBossNextReFreshTime() - TimeCtrl.Instance:GetServerTime()
		if time > 0 and hp <= 0 then
			local string = Language.Boss.WorldRefreshTime
			self.is_boss_hp:SetValue(false)
			self.icon.grayscale.GrayScale = 225
			self.time_text:SetValue(string.format(string, ToColorStr(TimeUtil.FormatSecond2Str(time), TEXT_COLOR.GREEN_SPECIAL)))
		else
			self.is_boss_hp:SetValue(true)
			self.time_text:SetValue("")
			self.icon.grayscale.GrayScale = 0
			if self.reward_timer then
				GlobalTimerQuest:CancelQuest(self.reward_timer)
				self.reward_timer = nil
			end
		end
	end
end

----------------------排行View----------------------
WorldBossRankView = WorldBossRankView or BaseClass(BaseRender)
function WorldBossRankView:__init()
	-- 获取控件
	self.rank_data_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self.rank = self:FindVariable("rank")
	self.name = self:FindVariable("name")
	self.hurt = self:FindVariable("hurt")
	self:Flush()
end

function WorldBossRankView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function WorldBossRankView:BagGetNumberOfCells()
	return math.max(#self.rank_data_list, 5)
end

function WorldBossRankView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = WorldBossRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function WorldBossRankView:OnFlush()
	local info = BossData.Instance:GetBossPersonalHurtInfo()
	self.rank:SetValue(info.self_rank)
	self.name:SetValue(PlayerData.Instance.role_vo.name)
	self.hurt:SetValue(info.my_hurt)
	self.rank_data_list = info.rank_list
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

WorldBossRankItem = WorldBossRankItem or BaseClass(BaseRender)

function WorldBossRankItem:__init()
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.score = self:FindVariable("Score")
end

function WorldBossRankItem:SetIndex(index)
	self.rank:SetValue(index)
end

function WorldBossRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function WorldBossRankItem:Flush()
	if nil == self.data then
		return
	end
	self.name:SetValue(self.data.name)
	self.score:SetValue(self.data.hurt)
end