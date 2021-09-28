Monster = Monster or BaseClass(Character)

local SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer").transform

function Monster:__init(vo)
	self.obj_type = SceneObjType.Monster
	self.draw_obj:SetObjType(self.obj_type)
	self.is_boss = false
	self.res_id = 0
	self.head_id = 0
	self.is_skill_reading = false
	self.is_main_target = false		-- 是否是玩家攻击的主目标
	self.can_shield = 1 			-- 是否可以屏蔽
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.monster_id]
	if nil ~= cfg then
		self.vo.name = cfg.name
		self.res_id = cfg.resid
		self.head_id = cfg.headid
		self.is_boss = (cfg.type == MONSTER_TYPE.BOSS)
		self.obj_scale = cfg.scale
		self.dietype = cfg.dietype
		self.can_shield = cfg.can_shield or 1
	end
	self.draw_obj.is_boss = self.is_boss
	self.special_param = vo.special_param
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LingyuFb then
		local guild_name = GuildFightData.Instance:GetGuildNameByPos(self.vo.monster_id, self.vo.pos_x, self.vo.pos_y)
		if guild_name ~= "" then
			self.vo.name = guild_name
		end
	end
end

function Monster:__delete()
	if self.effect_fz then
		GameObjectPool.Instance:Free(self.effect_fz)
		self.effect_fz = nil
	end
end

local DecayMounstCount = 0
function Monster:DeleteDrawObj()
	if self.effect_fz then
		GameObjectPool.Instance:Free(self.effect_fz)
		self.effect_fz = nil
	end

	if not self:IsRealDead() or DecayMounstCount > 10 then
		Character.DeleteDrawObj(self)
		return
	end

	if nil ~= self.draw_obj then
		local draw_obj = self.draw_obj
		self.draw_obj = nil
		if self.res_id ~= 3030001 and self.res_id ~= 3031001 and self.res_id ~= 3032001 then
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
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LingyuFb then
		self.follow_ui:Show()
	end
end

function Monster:ReloadSpecialImage()
	local scene_logic = Scene.Instance:GetSceneLogic()
	local is_show_special_image, asset, bundle = scene_logic:GetIsShowSpecialImage(self)
	if ActivityData.Instance:IsInHuangChengAcitvity() then
		if self.special_param == 1 then
			is_show_special_image, asset, bundle = ActivityData.Instance:GetHuangChengMonsterIcon()
		end
		self.follow_ui:GetNameTextObj():SetActive(true)
	end
	self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)

	if self.special_param == 1 then
		self.follow_ui:SetImageScale(0.5,0.5)
	end
end

function Monster:AddBuff(buff_type)
	Character.AddBuff(self, buff_type)
	local scene_id = Scene.Instance:GetSceneId()
	if DRAW_PART_LAYER_BUFF_LIST[buff_type] == 1 and self.buff_effect_list[buff_type] then
		-- if BossData.IsWorldBossScene(scene_id) then
		-- 	local scale = BossData.Instance:GetBossHuDunScale(self.vo.monster_id)
		-- 	self.buff_effect_list[buff_type]:SetScale({scale, scale, scale})
		-- elseif Scene.Instance:GetSceneType() == SceneType.TowerDefend then
		-- 	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
		-- 	local life_tower_monster_id = other_cfg.life_tower_monster_id
		-- 	if self.vo.monster_id == life_tower_monster_id then
		-- 		self.buff_effect_list[buff_type]:SetScale({1.3, 1.3, 1.3})
		-- 	end
		-- elseif Scene.Instance:GetSceneType() == SceneType.DailyTaskFb then
		-- 	local scale = DailyTaskFbData.Instance:GetFbHudunScale(self.vo.monster_id)
		-- 	self.buff_effect_list[buff_type]:SetScale({scale, scale, scale})
		-- end
		if self.draw_obj and self.draw_obj:GetRoot() then
			local parent_scale = self.draw_obj:GetRoot().transform.localScale
			self.buff_effect_list[buff_type]:SetScale({1/parent_scale.x, 1/parent_scale.y, 1/parent_scale.z})
		end
	end
end

function Monster:InitShow()
	Character.InitShow(self)

	local scene_type = Scene.Instance:GetSceneType()
	self.load_priority = 3
	if self.obj_scale ~= nil then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.obj_scale, self.obj_scale, self.obj_scale)
	end
	if scene_type == SceneType.DailyTaskFb and self.res_id == 3042001 then --领土战防御塔
		self.draw_obj:Rotate(0, 115, 0)
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
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
		self:InitModel(ResPath.GetMonsterModel(self.res_id))

	elseif scene_type == SceneType.GongChengZhan then
		if self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_id then
			local lv = CityCombatData.Instance:GetShouGuildTotemLevel()
			local qizhi_res_id = GuildData.Instance:GetQiZhiResId(lv)
			self.head_id = GuildData.Instance:GetQiZhiHeadId(lv)
			self:InitModel(ResPath.GetQiZhiModel(qizhi_res_id))
			-- self.draw_obj.root.transform.rotation = Quaternion.identity
			self.draw_obj:Rotate(0, 0, 0)
		elseif self.vo.monster_id == ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss1_id then
			self.draw_obj:Rotate(0, 70, 0)
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		else
			self.draw_obj:Rotate(0, math.random(0, 360), 0)
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		end

	elseif scene_type == SceneType.GuideFb or
			scene_type == SceneType.MountStoryFb or
			scene_type == SceneType.WingStoryFb or
			scene_type == SceneType.XianNvStoryFb then

		if self.vo.monster_id == 7501 then
			local qizhi_res_id = GuildData.Instance:GetQiZhiResId(14)
			self:InitModel(ResPath.GetQiZhiModel(qizhi_res_id))
		else
			self:InitModel(ResPath.GetMonsterModel(self.res_id))
		end
	elseif scene_type == SceneType.LingyuFb then
		self.draw_obj:Rotate(0, -320, 0)
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	elseif scene_type == SceneType.TowerDefend then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
		local life_tower_monster_id = other_cfg.life_tower_monster_id
		if self.vo.monster_id == life_tower_monster_id then
			self.draw_obj:Rotate(0, 90, 0)
		end
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	else
		self.draw_obj:Rotate(0, self.rotate_to_angle and self.rotate_to_angle or math.random(0, 360), 0)
		self:InitModel(ResPath.GetMonsterModel(self.res_id))
	end
end

function Monster:InitModel(bundle, asset)
	local function loadModelComple()
		if self.is_boss then
			--添加特效底座
			local effect_bundle, effect_asset = ResPath.GetMiscEffect("BOSS_fz_T")
			GameObjectPool.Instance:SpawnAsset(effect_bundle, effect_asset, function(obj)
				self.effect_fz = obj
				if nil == self.effect_fz then
					print_warning("obj not exist", effect_bundle, effect_asset)
					return
				end

				if self.draw_obj == nil or self.draw_obj:GetRoot() == nil then
					GameObjectPool.Instance:Free(self.effect_fz)
					self.effect_fz = nil
					return
				end

				self.effect_fz.transform:SetParent(self.draw_obj:GetRoot().transform, false)
				local parent_scale = self.draw_obj:GetRoot().transform.localScale
				self.effect_fz.transform.localScale = Vector3(1 / parent_scale.x, 1 / parent_scale.y, 1 / parent_scale.z)
				-- self.effect_fz:GetComponent(typeof(FollowTarget)):FollowImmediate(self.draw_obj:GetRoot().transform)

			end)
		end
	end
	if nil == bundle then
		print_error("monster_res是空值请检查", self.vo.monster_id)
	end
	if AssetManager.Manifest ~= nil and nil ~= bundle and not AssetManager.IsVersionCached(bundle) then
		-- 没有进包的怪物，用2016001代替
		local temp_bundle, temp_asset = ResPath.GetMonsterModel(2016001)
		self:ChangeModel(SceneObjPart.Main, temp_bundle, temp_asset, loadModelComple)
		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset, loadModelComple)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset, loadModelComple)
	end
end

function Monster:InitEnd()
	Character.InitEnd(self)

	if MAGIC_SPECIAL_STATUS_TYPE.READING == self.vo.status_type then
		self:StartSkillReading(0)
	end

	self:CheckShowEffect()
end

function Monster:CheckShowEffect()
	local is_golden_pig_monster = KaifuActivityData.Instance:GetIsGoldenPigMonsterById(self.vo.monster_id)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= main_part and not is_golden_pig_monster then
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
	if self:IsBoss() then
		self:GetFollowUi()
		if self:CanHideFollowUi() then
			self:HideFollowUi()
		end
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic:AlwaysShowMonsterName() then
		self:ShowName()
	end
	self:ReloadSpecialImage()

end

function Monster:OnClick()
	SceneObj.OnClick(self)
	if nil == self.select_effect then
		self.select_effect = AsyncLoader.New(self.draw_obj:GetRoot().transform)
		self.select_effect:Load(ResPath.GetSelectObjEffect3("red"))
		self.select_effect:SetLocalScale(Vector3(1.2, 1.2, 1.2))
	end
	self.select_effect:SetActive(true)
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
	-- if self.res_id == 3030001 and nil ~= self.draw_obj then
	-- 	self.draw_obj:PlayDead(self.dietype, function()
	-- 		if nil ~= self.draw_obj then
	-- 			self.draw_obj:SetVisible(false)
	-- 		end
	-- 	end, 1)
	-- end
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

function Monster:GetMonsterGuiShu()
	return self.vo.dsp_name
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
				local bundle_name, prefab_name = ResPath.GetMiscEffect(skill_cfg.effect_prefab_name)

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
	self.follow_ui:Create()
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform)
	end
	self.follow_ui:SetHpPercent(self.vo.hp / self.vo.max_hp)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.LingyuFb then
		self.follow_ui:Show()
	end
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

function Monster:SetIsMainTarget(flag)
	self.is_main_target = flag
end

function Monster:OnAnimatorBegin(anim_name)
	Character.OnAnimatorBegin(self, anim_name)
	-- 修复怪物攻击时一直奔跑的bug
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	end
end

-- 是否可以屏蔽
function Monster:IsCanShield()
	local flag = true
	if self.can_shield then
		flag = self.can_shield == 1
	end
	return flag
end