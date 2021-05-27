-------------------------------------------
--基础场景逻辑
-------------------------------------------
BaseSceneLogic = BaseSceneLogic or BaseClass()

function BaseSceneLogic:__init()
	self.scene_type = 0
	self.fuben_type = 0
	self.scene_server_config = nil
end

function BaseSceneLogic:__delete()
	self.scene_server_config = nil
end

function BaseSceneLogic:SetSceneType(scene_type)
	self.scene_type = scene_type
end

function BaseSceneLogic:GetSceneType()
	return self.scene_type
end

function BaseSceneLogic:SetFubenType(fuben_type)
	self.fuben_type = fuben_type
end

function BaseSceneLogic:GetFubenType()
	return self.fuben_type
end

-- 进入场景
function BaseSceneLogic:Enter(old_scene_type, new_scene_type)
	-- 切场景清除挂机信息
	GuajiCtrl.Instance:ClearAllOperate(ClearGuajiCacheReason.SceneChange)

	-- 背景音乐
	local audio_id = AudioBg.Default
	local scene_audio_cfg = ConfigManager.Instance:GetAutoConfig("audio_auto").scene[Scene.Instance:GetSceneId()]
	if nil ~= scene_audio_cfg then
		audio_id = scene_audio_cfg.audio_id
	else
		audio_id = AudioBg[new_scene_type] or audio_id
	end

	if audio_id ~= 0 then
		local audio_res_path = ResPath.GetAudioBgResPath(audio_id)
		AudioManager.Instance:PlayMusic(audio_res_path)
	end

	FpsSampleUtil.Instance:SetFpsSampleInvalid(true)

	HandleGameMapHandler:OnLoadingSceneQuit()
	Scene.Instance:CheckClientObj()
	local guaji_type = tonumber(AdapterToLua:getInstance():getDataCache("GUA_JI_TYPE"))
	local pre_scene_id = tonumber(AdapterToLua:getInstance():getDataCache("SCENE_ID"))
	AdapterToLua:getInstance():setDataCache("GUA_JI_TYPE", "")
	AdapterToLua:getInstance():setDataCache("SCENE_ID", "")
	if guaji_type and guaji_type ~= GuajiType.None and pre_scene_id == scene_id then
		GuajiCtrl.Instance:SetGuajiType(guaji_type)
	end

	local scene_cfg = Scene.Instance:GetSceneServerConfig()
	self.scene_server_config = scene_cfg
	if nil ~= scene_cfg then
		-- 自动挂机
		if scene_cfg.openAutoFight then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
		-- 隐藏主角头像和地图等图标
		if scene_cfg.hideRoleHead then
			MainuiCtrl.Instance:SetHeadAndRightTopVisible(false)
		else
			MainuiCtrl.Instance:SetHeadAndRightTopVisible(true)
		end
	end
	GlobalEventSystem:Fire(SceneEventType.SCENE_CHANGE_COMPLETE, old_scene_type, new_scene_type)
end

--退出场景
function BaseSceneLogic:Out()
	--override
end

function BaseSceneLogic:Update(now_time, elapse_time)
end

-- 获取角色名
function BaseSceneLogic:GetRoleNameBoardText(role_vo)
	local t = {}
	local special_t = {}

	local futi = bit:_and(bit:_rshift(role_vo[OBJ_ATTR.CREATURE_STATE or 0], EntityState.StateHeroMerge), 1) == 1	
	local huti = bit:_and(bit:_rshift(role_vo[OBJ_ATTR.CREATURE_STATE or 0], EntityState.StateShield), 1) == 1	

	if futi then
		special_t[#special_t + 1] = {key = "futi", effect_id = 913, path_func = ResPath.GetEffectUiAnimPath, w = 54, h = 54}
	end 
	if huti then
		special_t[#special_t + 1] = {key = "huti", effect_id = 912, path_func = ResPath.GetEffectUiAnimPath, w = 54, h = 54}
	end

	if #special_t == 1 then
		t[#t + 1] = special_t[1]
	end

	local zs_vip_level = bit:_and(bit:_rshift(role_vo[OBJ_ATTR.ACTOR_CUTTING_LEVEL], 16), 0xffff)
	if zs_vip_level and zs_vip_level > 0 then
		local level = zs_vip_level % ZsVipView.ENUM_JIE
		level = level == 0 and ZsVipView.ENUM_JIE or level
		t[#t + 1] = {img_path = ResPath.GetScene("vip_icon_" .. math.ceil(zs_vip_level / ZsVipView.ENUM_JIE))}
		t[#t + 1] = {img_num_path = ResPath.GetScene("zs_vip_num_" .. level)}
	end 

	t[#t + 1] = {text = RoleData.SubRoleName(role_vo.name), color = UInt2C3b(role_vo.name_color or 0)}

	return t, special_t
end

-- 获取角色仙盟名
function BaseSceneLogic:GetGuildNameBoardText(role_vo)
	if nil == role_vo.guild_name or "" == role_vo.guild_name then
		return {}
	end

	return {
		{text = role_vo.guild_name, color = COLOR3B.GREEN},
	}
end

-- 获取角色伴侣名
function BaseSceneLogic:GetPartnerNameBoardText(role_vo)
	if nil == role_vo.partner_name or "" == role_vo.partner_name then
		return {}
	end

	local partner_text = string.format(Language.Common.PartnerSceneName, role_vo.partner_name)

	return {
		{text = partner_text, color = COLOR3B.GREEN},
	}
end

function BaseSceneLogic:GetOfficeNameText(role_vo)
	local val = role_vo[OBJ_ATTR.ACTOR_WARPATH_ID] or 0
	local office_level = bit:_and(bit:_rshift(val, 16), 0xffff)
	if office_level == 0 then 
		return  {}
	end
	local office_cfg = office_cfg
	if office_cfg == nil then
		return {}
	end
	local profession_id = role_vo[OBJ_ATTR.ACTOR_PROF]
	local name = office_cfg.level_list[office_level] and office_cfg.level_list[office_level].names[profession_id] or "no cfg"
	local color = Str2C3b("de00ff")
	return {
		{text = name, color = color},
	}
end

-- 对象名字高度
function BaseSceneLogic:GetObjNameBoardHeight(role_vo)
	local height = 0
	local is_simple_name = SettingData.Instance and SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SIMPLE_ROLE_NAME) or false 
	if role_vo and Scene.Instance:GetSceneLogic() and not is_simple_name then
		local guild_name_t = self:GetGuildNameBoardText(role_vo)
		for k,v in pairs(guild_name_t) do
			if v.text ~= "" then
				height = height + 21
				break
			end
		end
		local office_name_t = self:GetOfficeNameText(role_vo)
		for k,v in pairs(office_name_t) do
			if v.text ~= "" then
				height = height + 21
				break
			end
		end
		local partner_name_t = self:GetPartnerNameBoardText(role_vo)
		for k,v in pairs(partner_name_t) do
			if v.text ~= "" then
				height = height + 21
				break
			end
		end
	end
	return height
end

-- 是否友方
function BaseSceneLogic:IsFriend(target_obj, main_role)
	if nil == target_obj or nil == main_role then
		return false
	end

	return not self:IsEnemy(target_obj, main_role)
end

-- 是否敌方
function BaseSceneLogic:IsEnemy(target_obj, main_role)
	if nil == target_obj or nil == main_role then
		return false
	end

	if main_role:IsRealDead() then															-- 自己死亡
		return false, Language.Fight.SelfDead
	end

	if main_role:IsInSafeArea() then														-- 自己在安全区
		return false, Language.Fight.InSafe
	end

	if target_obj:GetType() == SceneObjType.Role then
		if main_role:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < COMMON_CONSTS.XIN_SHOU_LEVEL then	-- 自己新手
			return false, Language.Fight.XinShou
		end

		if target_obj:IsInSafeArea() then													-- 目标在安全区
			return false, Language.Fight.TargetInSafe
		end

		if target_obj:IsRealDead() then														-- 目标死亡
			return false, Language.Fight.TargetDead
		end

		if target_obj:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < COMMON_CONSTS.XIN_SHOU_LEVEL then	-- 目标新手
			return false, Language.Fight.TargetXinShou
		end

		return self:IsRoleEnemy(target_obj, main_role)
	elseif target_obj:GetType() == SceneObjType.Monster then
		if target_obj:IsRealDead() then														-- 目标死亡
			return false, Language.Fight.TargetDead
		end

		if target_obj:IsInSafeArea() then													-- 目标在安全区
			return false, Language.Fight.TargetInSafe
		end

		if target_obj:IsHero() then
			return false
		end
		if target_obj:IsFenShen() then
			return false
		end

		if target_obj:IsPet() then
			local owner_obj = Scene.Instance:GetObjectByObjId(target_obj:GetOwnerObjId())
			if nil ~= owner_obj and owner_obj:IsRole() then
				if owner_obj == main_role then
					return false
				end

				if main_role:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < COMMON_CONSTS.XIN_SHOU_LEVEL then	-- 自己新手
					return false, Language.Fight.XinShou
				end

				if owner_obj:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < COMMON_CONSTS.XIN_SHOU_LEVEL then	-- 目标新手
					return false, Language.Fight.TargetXinShou
				end

				return self:IsRoleEnemy(owner_obj, main_role)
			else
				Log("Pet owner error:", target_obj:GetOwnerObjId())
				return false
			end
		end

		if target_obj:IsGuarder() then														-- 护卫
			return false
		end

		return self:IsMonsterEnemy(target_obj, main_role)
	end

	return false, Language.Fight.TargetNotAtk
end

-- 角色是否是敌人
function BaseSceneLogic:IsRoleEnemy(target_obj, main_role)
	local attack_mode = main_role:GetAttr(OBJ_ATTR.ACTOR_PK_MODE)
	if attack_mode == GameEnum.ATTACK_MODE_PEACE then
		return false, Language.Fight.InPeace

	elseif attack_mode == GameEnum.ATTACK_MODE_TEAM then
		if main_role:GetAttr(OBJ_ATTR.ACTOR_TEAM_ID) == 0 
			or main_role:GetAttr(OBJ_ATTR.ACTOR_TEAM_ID) ~= target_obj:GetAttr(OBJ_ATTR.ACTOR_TEAM_ID) then
			return true
		end
		return false, Language.Fight.TargetTeam

	elseif attack_mode == GameEnum.ATTACK_MODE_GUILD then
		if main_role:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) == 0 
			or (main_role:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) ~= target_obj:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
				and (GuildData.Instance:GetGuildRelationship(target_obj.vo.guild_name) ~= GUILD_RELATIONSHIP.UNION 
					or not GuildData.Instance:HasEnemyGuild())) then
			return true
		end
		return false, Language.Fight.TargetGuild

	elseif attack_mode == GameEnum.ATTACK_MODE_ALL then
		return true

	elseif attack_mode == GameEnum.ATTACK_MODE_NAMECOLOR then
		return target_obj:GetAttr("name_color_state") > PKNameColorType.PKColorType_Yellow

	elseif attack_mode == GameEnum.ATTACK_MODE_CAMP then
		if main_role:GetAttr(OBJ_ATTR.ACTOR_CAMP) == 0 
			or main_role:GetAttr(OBJ_ATTR.ACTOR_CAMP) ~= target_obj:GetAttr(OBJ_ATTR.ACTOR_CAMP) then
			return true
		end
		return false, Language.Fight.TargetCamp
	end

	return true
end

-- 怪物是否是敌人
function BaseSceneLogic:IsMonsterEnemy(target_obj, main_role)
	if target_obj:IsBiaoche() and target_obj:GetVo().owner_obj_id == main_role:GetVo().obj_id then
		return false
	end
	return true
end

--飞到指定的场景，
--自动找场景目标点，视情况走过去还是飞过去
function BaseSceneLogic:FlyToScene(scene_id, tip_same_scene)

end

--飞到指定目标点
--视情况走过去还是飞过去
--@is_clear_alloperate 
--不设置或为true则会清理所有缓存操作
function BaseSceneLogic:FlyToPos(x, y , scene_id, to_target_type, is_clear_alloperate)

end

-- 是否可以显示主线任务栏
function BaseSceneLogic:CanShowMainuiTask()
	return nil == self.scene_server_config or not self.scene_server_config.hideMainTaskBar
end

-- 是否可以显示发现BOSS图标
function BaseSceneLogic:CanShowFindBossIcon()
	return nil == self.scene_server_config or not self.scene_server_config.hideFindBossIcon 
end

-- 是否显示秒杀BOSS图标
function BaseSceneLogic:CanShowSecondKillIcon()
	return nil ~= self.scene_server_config and self.scene_server_config.showSecondKillIcon
end

-- 怒气集满时引导施放必杀技能
function BaseSceneLogic:IsNeedGuideBiSha()
	if nil == self.scene_server_config or nil == self.scene_server_config.needGuideBiSha then
		return false
	else
		local role_level_range = self.scene_server_config.needGuideBiSha.roleLevelRange
		local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		return level >= role_level_range[1] and level <= role_level_range[2]
	end
end

