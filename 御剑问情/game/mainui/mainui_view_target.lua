MainUIViewTarget = MainUIViewTarget or BaseClass(BaseRender)

-- Boss血条运动一格的时间
local BOSS_HP_DURATION = 1
-- Boss血条最大的时间
local MAX_BOSS_HP_DURATION = 1.5

function MainUIViewTarget:__init()
	-- 找到要控制的变量
	self.show_target = self:FindVariable("ShowTarget")
	self.target_level = self:FindVariable("TargetLevel")
	self.target_name = self:FindVariable("TargetName")
	self.target_portrait = self:FindVariable("TargetPortrait")
	self.boss_hp = self:FindVariable("BossHp")
	self.boss_hp_bg = self:FindVariable("BossHpBg")
	self.show_boss_hp_bg = self:FindVariable("ShowBossHpBg")
	self.boss_hp_count = self:FindVariable("BossHpCount")
	self.boss_dark_hp = self:FindVariable("BossDarkHp")
	self.show_hp_black = self:FindVariable("ShowHpBlack")


	-- 监听系统事件
	self:BindGlobalEvent(ObjectEventType.BE_SELECT,
		BindTool.Bind(self.OnSelectObjHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD,
		BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.TARGET_HP_CHANGE,
		BindTool.Bind(self.OnTargetHpChangeHead, self))
	self:BindGlobalEvent(ObjectEventType.SPECIAL_SHIELD_CHANGE,
		BindTool.Bind(self.OnSpecialShieldChangeBlood, self))

	self.hp_slider_top = self:FindVariable("HpValue")

	-- self.boss_hp_slider_top = self:FindVariable("BossHpValue")
	self.boss_dun_slider = self:FindVariable("BossDunValue")
	self.boss_dun_text = self:FindVariable("BossDunText")
	self.dun_pro = self:FindObj("BossHpBar/DunPro")
	self.dun_pro:SetActive(false)

	self.portrait = self:FindObj("portrait")
	self.portrait_raw = self:FindObj("portrait_raw")

	self.boss_portrait = self:FindObj("Bossportrait")
	self.boss_portrait_raw = self:FindObj("Bossportrait_raw")

	self.is_boss = self:FindVariable("IsBoss")
	self.boss_hp_middle_slider = self:FindObj("BossHpMiddleSlider").slider
	self.boss_hp_top_slider = self:FindObj("BossHpTopSlider").slider
	self.is_boss:SetValue(false)
	self.shake_hp_slider = self:FindObj("ShakeBossHpSlider")
	self.show_first_hurt = self:FindVariable("Show_First_Hurt")
	self.first_hurt_player = self:FindVariable("First_Hurt_Player")

	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))

	-- 首次刷新数据
	self:OnSelectObjHead(nil, nil)
	self.is_show = true
	self.target_is_boss = false

	self.target_boss_hp_index = 0
	self.cur_boss_hp_index = 0
	self.total_duration = 0
	self.total_value = 0
	self.last_change_hp_time_stamp = Status.NowTime

	-- self.ui_shake = self.root_node:GetComponent(typeof(UIShake))

	-- self.rect = self.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- local x, y = self.rect.anchoredPosition.x, self.rect.anchoredPosition.y
	-- self.height_pos = Vector2(x, 0);
	-- self.pos = Vector2(x, y);
end

function MainUIViewTarget:__delete()

	self:RemoveTimerQuest()

	self:StopTweener()
	-- self:StopShakeTweener()
end

-- 选择对象显示头像
function MainUIViewTarget:OnSelectObjHead(target_obj, select_type)
	self.show_hp_black:SetValue(false)
	-- 攻城战旗帜
	local qizhi_id = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_id or 0
	--隐藏护盾
	self.dun_pro:SetActive(false)
	self:StopTweener()
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
		self.show_target:SetValue(false)
		return
	end
	self.target_obj = target_obj
	self.show_target:SetValue(self.target_obj ~= nil and self.is_show)
	local is_gongcheng_zhan = CityCombatData:GetCurSceneIsGongChengZhan()
	if is_gongcheng_zhan then
		CityCombatCtrl.Instance:SetCityCombatFBTimeValue(self.target_obj ~= nil and self.is_show)
	end
	if self.target_obj == nil then
		return
	end

	local scene_type = Scene.Instance:GetSceneType()
    if scene_type == SceneType.Kf_OneVOne or scene_type == SceneType.Field1v1 or scene_type == SceneType.Mining then
    	self.show_target:SetValue(false)
    	return
    end
    self.is_boss:SetValue(false)
    self.target_is_boss = false
	local vo = target_obj:GetVo()
	if target_obj:IsRole() then
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		self.target_name:SetValue(target_obj:GetName())
		local lv, zhuan = PlayerData.GetLevelAndRebirth(target_obj:GetAttr("level"))
		self.target_level:SetValue(string.format(Language.Mainui.Level2, lv, zhuan))
		self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
		self:OnHeadChange(vo)
		if self.show_first_hurt then
			self.show_first_hurt:SetValue(false)
		end
	elseif target_obj:IsMonster() then
		self.is_boss:SetValue(true)
		self.target_is_boss = true
		self.target_boss_hp_index = target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp") * 100
		self.cur_boss_hp_index = self.target_boss_hp_index
		self.boss_hp_middle_slider.value = self.cur_boss_hp_index % 1 > 0 and self.cur_boss_hp_index % 1 or 1
		self.boss_hp_top_slider.value = self.boss_hp_middle_slider.value
		self:UpdateBossHp()
		self.boss_portrait_raw.gameObject:SetActive(false)
		self.boss_portrait.gameObject:SetActive(true)
		self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"), true)
		local monster_id = vo.monster_id
		local config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
		if config then
			if config[monster_id] then
				local level = config[monster_id].level or 0
				self.target_name:SetValue(string.format("<color=#07cc72>" .. Language.Mainui.Level3 .. level .. "</color>" .. target_obj:GetName()))
				self.target_level:SetValue("")
			end
		end
	else
		self:SetHpPercent(1)
	end
	if Scene.Instance:GetSceneType() == SceneType.ClashTerritory then
		self.target_name:SetValue(ClashTerritoryData.Instance:GetMonsterName(target_obj.vo))
	end

	if target_obj:IsMonster() then
		if target_obj:GetMonsterHead() > 0 then
			local bundle, asset = ResPath.GetlingxingBossIcon(target_obj:GetMonsterHead())
			local is_gongchengzhan_scene = CityCombatData:GetCurSceneIsGongChengZhan()
			if is_gongchengzhan_scene then
				if qizhi_id == vo.monster_id then
					local lv = CityCombatData.Instance:GetShouGuildTotemLevel()
					local qizhi_res_id = CityCombatData.Instance:GetGongChengZhanFaltCfg(lv)
					bundle, asset = ResPath.GetlingxingBossIcon(qizhi_res_id.head_id)
				end
			end
			self.target_portrait:SetAsset(bundle, asset)
		else
			self.boss_portrait:SetActive(false)
		end
		if target_obj:GetMonsterGuiShu() then
			self:OnBossFirstHurtChange(target_obj:GetObjId(), target_obj:GetMonsterGuiShu())
		end
	end
end

-- 取消
function MainUIViewTarget:OnObjDeleteHead(obj)
	if self.target_obj == obj then
		local hp = obj:GetAttr("hp")
		if self.target_is_boss and hp == 0 then
			self:SetHpPercent(0)
		else
			self.target_obj = nil
			self.show_target:SetValue(false)
			local is_gongcheng_zhan = CityCombatData:GetCurSceneIsGongChengZhan()
			if is_gongcheng_zhan then
				CityCombatCtrl.Instance:SetCityCombatFBTimeValue(false)
			end
			self:StopTweener()
		end
	end
end

-- 目标血量改变
function MainUIViewTarget:OnTargetHpChangeHead(target_obj)
	self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
end

function MainUIViewTarget:OnSpecialShieldChangeBlood(info)
	if self.target_obj and self.target_obj:GetObjId() == info.obj_id then
		self.boss_dun_slider:SetValue(info.left_times / info.max_times)
		self.boss_dun_text:SetValue(math.ceil(info.left_times) .."/".. info.max_times)
		self.dun_pro:SetActive(info.left_times / info.max_times > 0)
		if info.max_times <= 0 then
			self.dun_pro:SetActive(false)
			self.boss_dun_text:SetValue("")
			self.boss_dun_slider:SetValue(0)
			self:RemoveTimerQuest()
		end
	end
	if self.cal_time_quest == nil then
		self:CalTimeHideDun()

	end
end

function MainUIViewTarget:CalTimeHideDun()
	local timer_cal = 20
	self:RemoveTimerQuest()
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0 then
			self.dun_pro:SetActive(false)
			self.boss_dun_slider:SetValue(0)
			self.boss_dun_text:SetValue("")
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
			self.cal_time_quest = nil
		end
	end, 0)
end

function MainUIViewTarget:RemoveTimerQuest()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

-- 设置目标血条(is_select为了防止第一次选择的时候出现抖动效果)
function MainUIViewTarget:SetHpPercent(percent, is_select)
	self.hp_slider_top:SetValue(percent)
	if self.target_is_boss then
		self.target_boss_hp_index = percent * 100
		if self.cur_boss_hp_index >= self.target_boss_hp_index then
			self.total_value = self.cur_boss_hp_index - self.target_boss_hp_index
			self.total_duration = math.min(self.total_value * BOSS_HP_DURATION, MAX_BOSS_HP_DURATION)
			self.last_change_hp_time_stamp = Status.NowTime
		else
			self.cur_boss_hp_index = self.target_boss_hp_index
			self.boss_hp_top_slider.value = self.target_boss_hp_index % 1
			self.boss_hp_middle_slider.value = self.target_boss_hp_index % 1
		end
		self:UpdateBossHp()

		if not is_select then
			self:HpSliderShakeTweener()
		end
	end
end

function MainUIViewTarget:SetState(switch)
	self.is_show = switch or false
	if self.target_obj then
		if self.is_show then
			self.show_target:SetValue(true)
		else
			self.show_target:SetValue(false)
		end
	end
end

function MainUIViewTarget:OnClick()
	if self.target_obj then
		if self.target_obj:GetType() == SceneObjType.Role then
			local name = self.target_obj:GetName()
			if name then
				ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
			end
		end
	end
end

-- 头像更换
function MainUIViewTarget:OnHeadChange(vo)
	if not vo then return end
	local avatar_path_big = AvatarManager.Instance:GetAvatarKey(vo.role_id, false)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(vo.role_id)

	if IS_ON_CROSSSERVER then
		--温泉场景使用默认头像
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(vo.prof), false, vo.sex)
		self.target_portrait:SetAsset(bundle, asset)
		return
	end

	CommonDataManager.SetAvatar(vo.role_id, self.portrait_raw, self.portrait, self.target_portrait, vo.sex, vo.prof, true)
end

function MainUIViewTarget:ChangeToHigh(value)
	-- if self.rect then
	-- 	self.rect.anchoredPosition = value and self.pos or self.height_pos
	-- end
end

--------------------------------------------------------Boss血条------------------------------------------------------------
function MainUIViewTarget:ChangeBossHpColor(index)
	local res_index = index % 5
	self.boss_hp:SetAsset(ResPath.GetBossHp(5 - res_index))
	self.boss_dark_hp:SetAsset(ResPath.GetBossDarkHp(5 - res_index))
	self.show_boss_hp_bg:SetValue(index > 0)
	if index > 0 then
		self.boss_hp_bg:SetAsset(ResPath.GetBossHp(6 - res_index > 5 and 1 or 6 - res_index))
	end
end

function MainUIViewTarget:UpdateBossHp()
	self:StopTweener()
	-- 假血条整数部分
	local integer_cur = math.floor(self.cur_boss_hp_index)
	-- 目标血条整数部分
	local integer_target = math.floor(self.target_boss_hp_index)

	local title_index = math.ceil(self.cur_boss_hp_index) - 1
	self.boss_hp_count:SetValue(title_index <= 0 and "" or ("x " .. title_index))
	self:ChangeBossHpColor(title_index)
	if title_index >= integer_target then
		--超过2条血的伤害就加个遮罩
		if title_index - integer_target > 2 then
			self.show_hp_black:SetValue(true)
		else
			self.show_hp_black:SetValue(false)
		end
		local next_boss_hp_index = self.target_boss_hp_index
		if title_index > integer_target then
			if self.cur_boss_hp_index % 1 == 0 then
				next_boss_hp_index = self.cur_boss_hp_index - 1
			else
				next_boss_hp_index = integer_cur
			end
		end
		local value = 0
		if title_index == integer_target then
			value = self.target_boss_hp_index % 1
		end
		self.boss_hp_top_slider.value = value
		local duration = 0
		if self.total_value > 0 then
			local diff = self.boss_hp_middle_slider.value - value
			-- 把函数调用消耗时间也计算进去，只有这样才能保证在任何情况下都能在限制的时间之内跑完
			self.total_duration = math.max(0, self.total_duration - (Status.NowTime - self.last_change_hp_time_stamp))
			self.last_change_hp_time_stamp = Status.NowTime

			duration = diff / self.total_value * self.total_duration
			self.total_value = self.total_value - diff
			duration = math.max(0, duration)
			if title_index == integer_target then
				duration = diff * BOSS_HP_DURATION * 0.5
			end
		end
		self.tweener = self.boss_hp_middle_slider:DOValue(value, duration)
		self.tweener:SetEase(DG.Tweening.Ease.Linear)
		self.tweener:OnComplete(function ()
			if title_index == 0 and self.target_boss_hp_index == 0 then
				self.target_obj = nil
				self.show_target:SetValue(false)
				local is_gongcheng_zhan = CityCombatData:GetCurSceneIsGongChengZhan()
				if is_gongcheng_zhan then
					CityCombatCtrl.Instance:SetCityCombatFBTimeValue(false)
				end
				self:StopTweener()
				return
			end
			self.tweener = nil
			self.cur_boss_hp_index = next_boss_hp_index
			if next_boss_hp_index % 1 == 0 and next_boss_hp_index > 1 then
				self.boss_hp_top_slider.value = value == 0 and 1 or value
				self.boss_hp_middle_slider.value = 1
			end
			if next_boss_hp_index ~= self.target_boss_hp_index then
				self:UpdateBossHp()
			end
		end)
	end
end

function MainUIViewTarget:StopTweener()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
		self.cur_boss_hp_index = math.ceil(self.cur_boss_hp_index) - 1 + self.boss_hp_middle_slider.value
	end
end

--血条震动
function MainUIViewTarget:HpSliderShakeTweener()
	-- self:StopShakeTweener()
	-- -- self.shake_tweener = self.shake_hp_slider.transform:DOShakePosition(0.1, Vector3(8, 10, 0))
	-- self.shake_tweener = self.shake_hp_slider.transform:DOBlendableMoveBy(Vector3(5, 5, 0), 0.05)
	-- self.shake_tweener:SetEase(DG.Tweening.Ease.Linear)
	-- self.shake_tweener:OnComplete(function ()
	-- 	self.shake_tweener = self.shake_hp_slider.transform:DOBlendableMoveBy(Vector3(-5, -5, 0), 0.05)
	-- 	self:StopShakeTweener()
	-- end)
	-- self.ui_shake:Shake(0.3)
end

function MainUIViewTarget:StopShakeTweener()
	-- if self.shake_tweener then
	-- 	self.shake_hp_slider.transform.localPosition = Vector3(16, 384, 0)
	-- 	self.shake_tweener:Pause()
	-- 	self.shake_tweener = nil
	-- end
end

function MainUIViewTarget:OnFirstHurtChange(flag, role_obj_id, boss_obj_id)
	if self.target_obj and self.target_obj:GetObjId() == boss_obj_id then
		if role_obj_id and flag then
			self.show_first_hurt:SetValue(flag > 0)
			local role_obj = Scene.Instance:GetObjectByObjId(role_obj_id)
			local name = Language.Common.ZanWu
			if role_obj then
				name = role_obj:GetName()
			end
			self.first_hurt_player:SetValue(name)
		end
	end
end

-- 进入视野BOSS归属
function MainUIViewTarget:OnBossFirstHurtChange(obj_id, role_name)
	if self.target_obj and self.target_obj:GetObjId() == obj_id then
		self.show_first_hurt:SetValue("" ~= role_name)
		if "" ~= role_name then
			self.first_hurt_player:SetValue(role_name or Language.Common.ZanWu)
		end
	end
end