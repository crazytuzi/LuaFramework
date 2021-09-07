Monster = Monster or BaseClass(Character)

function Monster:__init(vo)
	self.obj_type = SceneObjType.Monster
	self.draw_obj:SetObjType(self.obj_type)
	self.is_boss = false
	self.res_id = 0
	self.head_id = 0
	self.general_resid = 0
	self.is_skill_reading = false
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.monster_id]
	if nil ~= cfg then
		self.vo.name = cfg.name
		self.res_id = cfg.resid
		self.general_resid = cfg.general_resid or 0
		self.head_id = cfg.headid
		self.is_boss = (cfg.type == MONSTER_TYPE.BOSS)
		self.obj_scale = cfg.scale
		self.dietype = cfg.dietype
	end
	self.totem_name = self.vo.name or ""
	self.draw_obj.is_boss = self.is_boss
	self.effect_param = 0
end

function Monster:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

local DecayMounstCount = 0
function Monster:DeleteDrawObj()
	if not self:IsRealDead() or DecayMounstCount > 10 then
		Character.DeleteDrawObj(self)
		return
	end

	if nil ~= self.draw_obj then
		local draw_obj = self.draw_obj
		self.draw_obj = nil
		if self.res_id ~= 3030001 then
			DecayMounstCount = DecayMounstCount + 1
			draw_obj:PlayDead(self.dietype, function()
				DecayMounstCount = DecayMounstCount - 1
				draw_obj:DeleteMe()
			end)
		else
			draw_obj:DeleteMe()
		end
	end
end

function Monster:InitInfo()
	Character.InitInfo(self)
	-- self.draw_obj:SetVisible(false)
	self:GetFollowUi()
	self.follow_ui:SetFollowTarget(self.draw_obj:GetRoot().transform)
	self.follow_ui:SetIsBoss(self:IsBoss())
	self:ReloadUIName()

	if self.vo.disappear_time then
		local time = self.vo.disappear_time - TimeCtrl.Instance:GetServerTime()
		if time > 0 and TotemMonsterId[self.vo.monster_id] then
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(self.FlushMonsterName, self), 1, time)
				self:FlushMonsterName()
			end
		end
	end
end

function Monster:ReloadSpecialImage()
	local scene_logic = Scene.Instance:GetSceneLogic()
	local is_show_special_image, asset, bundle = scene_logic:GetIsShowSpecialImage(self)

	self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
end

function Monster:AddBuff(buff_type)
	Character.AddBuff(self, buff_type)
	local scene_id = Scene.Instance:GetSceneId()
	if buff_type == 41 and BossData.IsWorldBossScene(scene_id) then
		local scale = BossData.Instance:GetBossHuDunScale(self.vo.monster_id)
		self.buff_effect_list[buff_type]:SetScale({scale, scale, scale})

		--个人塔防
		if Scene.Instance:GetSceneType() == SceneType.TowerDefend then
			local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").other[1]
			local life_tower_monster_id = other_cfg.life_tower_monster_id
			if self.vo.monster_id == life_tower_monster_id then
				self.buff_effect_list[buff_type]:SetScale({1.3, 1.3, 1.3})
			end
		end
	end
end

-- 重写CheckModleScale方法 避免放大缩小给限制了
function Monster:CheckModleScale()

end

function Monster:InitShow()
	Character.InitShow(self)

	local scene_type = Scene.Instance:GetSceneType()
	local scene_id = Scene.Instance:GetSceneId() or 0
	self.load_priority = 3
	if self.obj_scale ~= nil then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.obj_scale, self.obj_scale, self.obj_scale)
	end
	local bundle, asset = "", ""
	if scene_type == SceneType.DailyTaskFb and self.res_id == 3030001 then --领土战防御塔
		self.draw_obj:Rotate(0, 52, 0)
		bundle, asset = ResPath.GetMonsterModel(self.res_id)
		-- self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif math.floor(self.res_id / 1000) == 2038 then --领土战防御塔
		if scene_type == SceneType.QunXianLuanDou then
			local qxld_cfg = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").other[1]
			self.draw_obj:Rotate(0, math.deg(math.atan2(qxld_cfg.town_direction_x - self.logic_pos.x, qxld_cfg.town_direction_y - self.logic_pos.y)) - 90, 0)
		elseif scene_type == SceneType.ClashTerritory then
			local size = ClashTerritoryData.Instance:GetTerritoryMonsterSide(self.vo.monster_id)
			if size then
				self.draw_obj:Rotate(0, size == 0 and 180 or 0, 0)
			end
			self.draw_obj:SetOffset(Vector3(0, -2, 0))
		end
		-- self:InitModel(ResPath.GetMonsterModel(self.res_id))
		bundle, asset = ResPath.GetMonsterModel(self.res_id)

	elseif scene_type == SceneType.GongChengZhan then
		if self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_id then
			--or self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_1_id or self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_2_id or self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_3_id 
			local lv = CityCombatData.Instance:GetShouGuildTotemLevel()
			local qizhi_res_id = GuildData.Instance:GetQiZhiResId(lv)
			self.head_id = GuildData.Instance:GetQiZhiHeadId(lv)
			self:InitModel(ResPath.GetQiZhiModel(qizhi_res_id))
			-- self.draw_obj.root.transform.rotation = Quaternion.identity
			self.draw_obj:Rotate(0, 270, 0)
		elseif self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss1_id then
			self.draw_obj:Rotate(0, 90, 0)
			-- self:InitModel(ResPath.GetMonsterModel(self.res_id))
			bundle, asset = ResPath.GetMonsterModel(self.res_id)
		else
			--self.draw_obj:Rotate(0, math.random(0, 360), 0)
			self.draw_obj:Rotate(0, 275, 0)
			-- self:InitModel(ResPath.GetMonsterModel(self.res_id))
			bundle, asset = ResPath.GetMonsterModel(self.res_id)
		end

	elseif scene_type == SceneType.GuideFb or
			scene_type == SceneType.MountStoryFb or
			scene_type == SceneType.WingStoryFb or
			scene_type == SceneType.XianNvStoryFb then

		if self.vo.monster_id == 7501 then
			local qizhi_res_id = GuildData.Instance:GetQiZhiResId(14)
			-- self:InitModel(ResPath.GetQiZhiModel(qizhi_res_id))
			bundle, asset = ResPath.GetQiZhiModel(qizhi_res_id)
		else
			bundle, asset = ResPath.GetMonsterModel(self.res_id)
			-- self:InitModel(ResPath.GetMonsterModel(self.res_id))
		end

	elseif scene_type == SceneType.TowerDefend then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
		local life_tower_monster_id = other_cfg.life_tower_monster_id
		if self.vo.monster_id == life_tower_monster_id then
			self.draw_obj:Rotate(0, 220, 0)
		end
		bundle, asset = ResPath.GetMonsterModel(self.res_id)
		-- self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif FaceToCameraSceneType[scene_type] and self.is_boss then
		self.draw_obj:Rotate(0, FaceToCameraSceneType[scene_type], 0)
		bundle, asset = ResPath.GetMonsterModel(self.res_id)
	elseif scene_type == SceneType.MonsterSiegeFb and self.vo.monster_id == 50268 then
		self.draw_obj:Rotate(0, 0, 0)
		bundle, asset = ResPath.GetMonsterModel(self.res_id)
	elseif scene_type ==  SceneType.CrossGuildBattle then
		local rotate_to_angle = nil
		local scene_info = CommonSceneIdDirection[scene_id]
		if scene_info then
			rotate_to_angle = scene_info[self.vo.monster_id]
		end
		self.draw_obj:Rotate(0, rotate_to_angle and rotate_to_angle or math.random(0, 360), 0)
		bundle, asset = ResPath.GetMonsterModel(self.res_id)
	else
		local rotate_to_angle = CommonSceneTypeDirection[self.vo.monster_id]
		self.draw_obj:Rotate(0, rotate_to_angle and rotate_to_angle or math.random(0, 360), 0)
		bundle, asset = ResPath.GetMonsterModel(self.res_id)
	end

	if self.general_resid > 0 then
		bundle, asset = ResPath.GetMingJiangRes(self.general_resid)
	end
	self:InitModel(bundle, asset)
end

function Monster:InitModel(bundle, asset)
	if AssetManager.Manifest ~= nil and not AssetManager.IsVersionCached(bundle) then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(2127001))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Monster:ChangeAppearance(effect_param)
	self.effect_param = effect_param
	if effect_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_CROSS_XYCITY_CAPTIVE_BAG then
		bundle, asset = ResPath.GetMonsterModel(1002001)
		self:ChangeModel(SceneObjPart.Main, bundle, asset)

		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		if nil ~= part then
			part:SetInteger("status", ActionStatus.Die)
		end
	end
end

function Monster:InitEnd()
	Character.InitEnd(self)

	if MAGIC_SPECIAL_STATUS_TYPE.READING == self.vo.status_type then
		self:StartSkillReading(0)
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= main_part then
		main_part:PlayAttachEffect()
	end
end

function Monster:SetDirectionByXY(x, y)
	if self.vo and math.floor(self.res_id / 1000) == 2038 then--and ClashTerritoryData.Instance:GetTerritoryMonsterSide(self.vo.monster_id) then
		return
	end
	Character.SetDirectionByXY(self, x, y)
end

function Monster:OnEnterScene()
	Character.OnEnterScene(self)
	self:GetFollowUi()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic:AlwaysShowMonsterName() or TotemMonsterId[self.vo.monster_id] then
		self:ShowName()
	end
	if self:IsBoss() and not TotemMonsterId[self.vo.monster_id] then
		self:GetFollowUi()
		if self:CanHideFollowUi() then
			self:HideFollowUi()
		end
	end
	self:ReloadSpecialImage()
end

function Monster:OnClick()
	local need_load_select = self.select_effect == nil
	Character.OnClick(self)
	if not self:IsBoss() then
		self:ShowName()
		if need_load_select and self.select_effect then
			self.select_effect:Load(ResPath.GetSelectObjEffect2("red"))
			self.select_effect:SetLocalScale(Vector3(1.5, 1.5, 1.5))
		end
	end
end

function Monster:CancelSelect()
	Character.CancelSelect(self)
	local scene_logic = Scene.Instance:GetSceneLogic()
	if not self:IsBoss() and not scene_logic:AlwaysShowMonsterName() then
		self:HideName()
	end
end

function Monster:EnterStateDead()
	Character.EnterStateDead(self)
	if self.vo.monster_id == 10000 then
		if self.audio_config == nil then
			self.audio_config = AudioData.Instance:GetAudioConfig()
		end
		local audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].MonsterKill)
		AudioManager.PlayAndForget(audio_id)
	end
	if self.res_id == 3030001 and nil ~= self.draw_obj then
		self.draw_obj:PlayDead(self.dietype, function()
			if nil ~= self.draw_obj then
				self.draw_obj:SetVisible(false)
			end
		end, 1)
	end
end

function Monster:IsMonster()
	return true
end

function Monster:IsBoss()
	return self.is_boss
end

function Monster:GetMonsterId()
	return self.vo.monster_id
end

function Monster:GetMonsterHead()
	return self.head_id
end

function Monster:IsSkillReading()
	return self.is_skill_reading
end

function Monster:StartSkillReading(skill_id)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return false
	end

	local anim_name = "magic1_1"

	local skill_cfg = SkillData.GetMonsterSkillConfig(skill_id)
	if nil ~= skill_cfg then
		anim_name = skill_cfg.skill_action .. "_1"
	end

	self.is_skill_reading = true
	part_obj.animator:SetTrigger(anim_name)

	return true
end

function Monster:EndSkillReading(skill_id)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return false
	end

	local skill_cfg = SkillData.GetMonsterSkillConfig(skill_id)
	if nil ~= skill_cfg then
		local is_magic = ("magic1" == skill_cfg.skill_action or "magic2" == skill_cfg.skill_action)
		if is_magic then
			self.is_skill_reading = false
			part_obj.animator:SetTrigger("boss_end")
		end
	end
end

function Monster:EnterStateAttack()
	local anim_name = SceneObjAnimator.Atk1
	local skill_cfg = SkillData.GetMonsterSkillConfig(self.attack_skill_id)

	if nil ~= skill_cfg then
		local is_magic = ("magic1" == skill_cfg.skill_action or "magic2" == skill_cfg.skill_action)

		if self.is_skill_reading and is_magic then -- 正在读条中且是魔法技能，则是一个完整的（读条-聚气-释放）
			self.is_skill_reading = false
			anim_name = skill_cfg.skill_action .. "_3"

			-- 播放聚气特效
			if "" ~= skill_cfg.effect_prefab_name and "none" ~= skill_cfg.effect_prefab_name then

				local position = self.attack_target_obj and self.attack_target_obj:GetRoot().transform.position or self.draw_obj:GetRoot().transform.position
				if skill_cfg.is_aoe == 1 and self.attack_target_pos_x and self.attack_target_pos_y then
					local position_1 = position
					local x, z =  GameMapHelper.LogicToWorld(self.attack_target_pos_x, self.attack_target_pos_y)
					position = {x = x, y = position_1.y, z = z}
				end
				local bundle_name, prefab_name = ResPath.GetEffect(skill_cfg.effect_prefab_name)

				EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, position)
			end

		elseif not self.is_skill_reading and is_magic then -- 没在读条但收到魔法技能id，则处理成普攻
			anim_name = SceneObjAnimator.Atk1

		else
			anim_name = skill_cfg.skill_action
		end
	end

	Character.EnterStateAttack(self, anim_name)
end

function Monster:CreateFollowUi()
	self.follow_ui = MonsterFollow.New()
	self.follow_ui:SetIsBoss(self:IsBoss())
	self.follow_ui:Create(SceneObjType.Monster)
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform)
	end
	self.follow_ui:SetHpPercent(self.vo.hp / self.vo.max_hp)
end

function Monster:ShowName()
	self:GetFollowUi():ShowName()
end

function Monster:HideName()
	self:GetFollowUi():HideName()
end

function Monster:OnDie()
	Character.OnDie(self)

	local part_obj = self.draw_obj:GetPart(SceneObjPart.Main):GetObj()
	if nil ~= part_obj and nil ~= part_obj.actor_attach_effect then
		part_obj.actor_attach_effect:StopEffect()
	end

	if self.is_skill_reading then
		self.is_skill_reading = false
		if nil ~= part_obj and nil ~= part_obj.actor_ctrl then
			part_obj.actor_ctrl:StopEffects()
		end
	end
end

function Monster:PlayHurtAnimation(skill_id)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return
	end
	
	local index = SkillData.Instance:GetRealSkillIndex(skill_id)
	if index == 1 or index == 0 or index == 3 then
		part_obj.animator:SetTrigger(SceneObjAnimator.Hurt)
	end
end

function Monster:SetBubble(text)
	if nil ~= self.follow_ui and text then
		self.follow_ui:ChangeBubble(text)
	end
	if text then
		self.follow_ui:ShowBubble()
	else
		self.follow_ui:HideBubble()
	end
end

function Monster:FlushMonsterName()
	local time = math.max(0, self.vo.disappear_time - TimeCtrl.Instance:GetServerTime())
	local totem_name = ToColorStr((Language.RankTogle.StrCamp[self.vo.monster_camp_type or 0] .. self.totem_name), CAMP_COLOR[self.vo.monster_camp_type or 0])
	self.vo.name = TotemMonsterId[self.vo.monster_id] and (totem_name .. ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED)) or self.totem_name

	self:ReloadUIName()
end